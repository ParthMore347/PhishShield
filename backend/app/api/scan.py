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
from app.services.nlp import analyze_text_nlp
from app.services.qr import analyze_qr_code

router = APIRouter()
ERROR_MESSAGE = "Invalid URL or text format provided for threat analysis."
TELEMETRY_LOGS: List[Dict[str, Any]] = []


def _verdict(score: float) -> str:
    if score <= 0.20:
        return "SAFE"
    if score <= 0.65:
        return "SUSPICIOUS"
    return "MALICIOUS"


def _error() -> JSONResponse:
    return JSONResponse(status_code=400, content=ScanError().model_dump())


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
        return _error()

    try:
        if input_type == "url":
            if not parse_url_or_domain(target):
                return _error()
            heuristics = HeuristicsResult(**analyze_url_heuristics(target))
            nlp = None
            score = heuristics.score
            display_target = target
        else:
            nlp = NLPResult(**analyze_text_nlp(target))
            heuristics = None
            score = nlp.score
            display_target = target
    except ValueError:
        return _error()

    if qr_data and qr_data.contains_qr:
        score = max(score, qr_data.score)
    score = round(min(max(score, 0.0), 1.0), 2)
    verdict = _verdict(score)
    scan_id = f"PS-{str(uuid.uuid4())[:8].upper()}"
    result = ThreatVerdict(
        scan_id=scan_id,
        url=display_target,
        input_type=input_type,
        verdict=verdict,
        overall_confidence=score,
        engine_results=EngineModuleResults(heuristics=heuristics, nlp=nlp, qr=qr_data),
        timestamp=datetime.utcnow(),
    )
    TELEMETRY_LOGS.insert(0, {
        "scan_id": scan_id, "url": display_target, "platform": request.platform,
        "verdict": verdict, "confidence": score,
        "timestamp": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC"), "synced": True,
    })
    del TELEMETRY_LOGS[100:]
    return result


@router.get("/telemetry")
async def get_telemetry():
    total = len(TELEMETRY_LOGS)
    malicious = sum(item["verdict"] == "MALICIOUS" for item in TELEMETRY_LOGS)
    suspicious = sum(item["verdict"] == "SUSPICIOUS" for item in TELEMETRY_LOGS)
    safe = sum(item["verdict"] == "SAFE" for item in TELEMETRY_LOGS)
    return {
        "status": "online",
        "total_scans": total,
        "stats": {
            "safe": safe, "suspicious": suspicious, "malicious": malicious,
            "threat_ratio": f"{round(((malicious + suspicious) / max(total, 1)) * 100, 1)}%",
        },
        "recent_events": TELEMETRY_LOGS[:20],
    }
