import uuid
from datetime import datetime
from typing import Any, Dict, List, Union

from fastapi import APIRouter
from fastapi.responses import JSONResponse

from app.models.schemas import (
    EngineModuleResults, HeuristicsResult, NLPResult, QRResult, ScanError,
    ScanRequest, ThreatVerdict,
)
from app.services.heuristics import analyze_url_heuristics, parse_url_or_domain
from app.services.nlp import analyze_text_nlp, analyze_url_nlp
from app.services.qr import analyze_qr_code
from app.services.database import database_service

router = APIRouter()
ERROR_MESSAGE = "Invalid URL or text format provided for threat analysis."
TELEMETRY_LOGS: List[Dict[str, Any]] = []


def _verdict(score: float) -> str:
    if score <= 0.20:
        return "SAFE"
    if score <= 0.65:
        return "SUSPICIOUS"
    return "MALICIOUS"


def mask_target(value: str) -> str:
    """
    Privacy masking: shows only first 6 and last 6 characters of a target URL or text.
    Example: 'https://security-alert-paypal.com' -> 'https:......al.com'
    Protects user privacy by never persisting raw full URLs or sensitive text to logs.
    """
    if not value or len(value) <= 12:
        return value
    return f"{value[:6]}......{value[-6:]}"


def _error(message: str = "Invalid URL or text format provided for threat analysis.") -> JSONResponse:
    return JSONResponse(status_code=400, content=ScanError(status="INVALID_INPUT", message=message).model_dump())


@router.post("/scan", response_model=Union[ThreatVerdict, ScanError])
async def scan_link(request: ScanRequest):
    target = (request.url or request.text or "").strip()
    input_type = "url" if request.url is not None else "text"
    qr_data = None
    if request.image_b64:
        qr_analysis = analyze_qr_code(request.image_b64)
        qr_data = QRResult(**qr_analysis)
        if qr_analysis["decoded_url"] and not target:
            target = qr_analysis["decoded_url"]
            input_type = "url"
    if not target:
        return _error("Target cannot be empty. Please provide a URL, text message, or QR image.")

    heuristics = None
    nlp = None

    try:
        if input_type == "url":
            if not parse_url_or_domain(target):
                return _error("Invalid target format: please enter a valid domain or URL (e.g. https://example.com).")
            heuristics = HeuristicsResult(**analyze_url_heuristics(target))
            if heuristics.is_known_safe:
                nlp = NLPResult(suspicious_keywords_found=[], sentiment_anomaly=False, keyword_density=0.0, score=0.0, signals=[])
                score = 0.0
            else:
                nlp = NLPResult(**analyze_url_nlp(target))
                score = max(heuristics.score, nlp.score)
            display_target = target
        else:
            nlp = NLPResult(**analyze_text_nlp(target))
            heuristics = None
            score = nlp.score
            display_target = target
    except ValueError as e:
        return _error(str(e))

    if qr_data and qr_data.contains_qr:
        score = max(score, qr_data.score)
    score = round(min(max(score, 0.0), 1.0), 2)

    # Deterministic Evaluation Standard:
    # 0% - 20%: SAFE -> (100 - Risk)% Safe
    # 21% - 65%: SUSPICIOUS -> Risk% Threat
    # 66% - 100%: MALICIOUS -> Risk% Threat
    if score <= 0.20:
        verdict = "SAFE"
        confidence_label = f"{round((1.0 - score) * 100)}% Safe"
        overall_confidence = round(1.0 - score, 2)
    elif score <= 0.65:
        verdict = "SUSPICIOUS"
        confidence_label = f"{round(score * 100)}% Threat"
        overall_confidence = score
    else:
        verdict = "MALICIOUS"
        confidence_label = f"{round(score * 100)}% Threat"
        overall_confidence = score

    signals: List[str] = []
    if heuristics and heuristics.signals:
        signals.extend(heuristics.signals)
    if nlp and nlp.signals:
        signals.extend(nlp.signals)
    if qr_data and qr_data.contains_qr:
        if qr_data.is_suspicious_redirect:
            signals.append("QR code initiates suspicious or masked redirection")
        else:
            signals.append("QR code payload extracted cleanly")

    scan_id = f"PS-{str(uuid.uuid4())[:8].upper()}"
    result = ThreatVerdict(
        scan_id=scan_id,
        url=display_target,
        input_type=input_type,
        verdict=verdict,
        risk_score=score,
        confidence_label=confidence_label,
        overall_confidence=overall_confidence,
        signals=signals,
        engine_results=EngineModuleResults(heuristics=heuristics, nlp=nlp, qr=qr_data),
        timestamp=datetime.utcnow(),
    )
    telemetry_event = {
        "scan_id": scan_id, "url": mask_target(display_target), "platform": request.platform,
        "verdict": verdict, "confidence": overall_confidence,
        "risk_score": score,
        "confidence_label": confidence_label,
        "input_type": input_type,
        "device_id": request.device_id,
        "nickname": request.nickname,
        "avatar_id": request.avatar_id,
        "timestamp": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC"), "synced": False,
    }
    TELEMETRY_LOGS.insert(0, telemetry_event)
    del TELEMETRY_LOGS[100:]
    telemetry_event["synced"] = await database_service.insert_telemetry(telemetry_event)
    return result


@router.get("/telemetry")
async def get_telemetry(device_id: str | None = None):
    persisted_logs = await database_service.get_recent_telemetry(device_id=device_id)
    logs = persisted_logs or [
        item for item in TELEMETRY_LOGS
        if device_id is None or item.get("device_id") == device_id
    ]
    total = len(logs)
    malicious = sum(item["verdict"] == "MALICIOUS" for item in logs)
    suspicious = sum(item["verdict"] == "SUSPICIOUS" for item in logs)
    safe = sum(item["verdict"] == "SAFE" for item in logs)
    return {
        "status": "online",
        "persistence": "mongodb" if database_service.connected else "memory",
        "total_scans": total,
        "stats": {
            "safe": safe, "suspicious": suspicious, "malicious": malicious,
            "threat_ratio": f"{round(((malicious + suspicious) / max(total, 1)) * 100, 1)}%",
        },
        "recent_events": logs[:20],
    }
