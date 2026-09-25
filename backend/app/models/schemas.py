from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, Field, model_validator


class ScanRequest(BaseModel):
    url: Optional[str] = Field(default=None, description="URL or domain to scan")
    text: Optional[str] = Field(default=None, description="SMS or text message to scan")
    platform: str = Field(default="unknown", min_length=1, max_length=64)
    image_b64: Optional[str] = Field(default=None, description="Optional base64 encoded QR image")

    @model_validator(mode="after")
    def validate_scan_target(self) -> "ScanRequest":
        if self.url is not None and not isinstance(self.url, str):
            raise ValueError("url must be a string")
        if self.text is not None and not isinstance(self.text, str):
            raise ValueError("text must be a string")
        if self.url and self.text:
            raise ValueError("Provide either url or text, not both")
        if self.url is not None and not self.url.strip():
            raise ValueError("url cannot be blank")
        if self.text is not None and not self.text.strip():
            raise ValueError("text cannot be blank")
        if self.url is None and self.text is None and not self.image_b64:
            raise ValueError("A URL, text message, or QR image is required")
        return self


class ScanError(BaseModel):
    status: Literal["ERROR"] = "ERROR"
    message: Literal["Invalid URL or text format provided for threat analysis."] = (
        "Invalid URL or text format provided for threat analysis."
    )


class HeuristicsResult(BaseModel):
    suspicious_tld: bool
    domain_length: int
    has_ip_address: bool
    special_char_count: int
    typosquatting: bool = False
    url_entropy: float = Field(0.0, ge=0.0, le=1.0)
    score: float = Field(..., ge=0.0, le=1.0)


class NLPResult(BaseModel):
    suspicious_keywords_found: list[str]
    sentiment_anomaly: bool
    keyword_density: float = Field(0.0, ge=0.0, le=1.0)
    score: float = Field(..., ge=0.0, le=1.0)


class QRResult(BaseModel):
    contains_qr: bool
    decoded_url: Optional[str] = None
    is_suspicious_redirect: bool
    score: float = Field(0.0, ge=0.0, le=1.0)


class EngineModuleResults(BaseModel):
    heuristics: Optional[HeuristicsResult] = None
    nlp: Optional[NLPResult] = None
    qr: Optional[QRResult] = None


class ThreatVerdict(BaseModel):
    scan_id: str
    url: str
    input_type: Literal["url", "text"]
    verdict: Literal["SAFE", "SUSPICIOUS", "MALICIOUS", "UNVERIFIED"]
    overall_confidence: float = Field(..., ge=0.0, le=1.0)
    engine_results: EngineModuleResults
    timestamp: datetime = Field(default_factory=datetime.utcnow)
