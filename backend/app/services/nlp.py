import re

URGENCY_PHRASES = (
    "urgent action required",
    "account suspended",
    "click here to claim",
    "verify your account",
    " payment required",
    "security alert",
)
PHISHING_KEYWORDS = {
    "urgent", "action", "suspended", "verify", "click", "claim", "password",
    "account", "payment", "expire", "restricted", "credential", "wallet",
    "login", "signin", "secure", "bank", "banking", "update", "support",
    "billing", "paypal", "netflix", "amazon", "google", "apple", "crypto",
    "phishing",
}


def analyze_text_nlp(text: str) -> dict:
    normalized = " ".join(text.lower().split())
    words = re.findall(r"[a-z0-9']+", normalized)
    if len(words) < 3:
        raise ValueError("Text message is too short")
    found = sorted({word for word in words if word in PHISHING_KEYWORDS})
    phrase_hits = sum(phrase in normalized for phrase in URGENCY_PHRASES)
    density = len(found) / len(words)
    score = min((density * 0.9) + (phrase_hits * 0.28), 1.0)
    signals = []
    if found:
        signals.append(f"Suspicious intent keywords: {', '.join(found)}")
    if phrase_hits > 0:
        signals.append("High-pressure urgency/coercive phrase pattern detected")
    if not signals:
        signals.append("No deceptive semantic triggers detected")
    return {
        "suspicious_keywords_found": found,
        "sentiment_anomaly": phrase_hits > 0,
        "keyword_density": round(min(density, 1.0), 3),
        "score": round(score, 3),
        "signals": signals,
    }


def analyze_url_nlp(url: str) -> dict:
    normalized = url.lower()
    words = re.findall(r"[a-z0-9']+", normalized)
    found = sorted({word for word in words if word in PHISHING_KEYWORDS})
    score = 0.0
    if len(found) == 1:
        score = 0.35
    elif len(found) >= 2:
        score = 0.75
    density = len(found) / max(len(words), 1)
    score = max(score, min(density * 1.2, 1.0))
    signals = []
    if found:
        signals.append(f"Deceptive phishing tokens in URL ({', '.join(found)})")
    return {
        "suspicious_keywords_found": found,
        "sentiment_anomaly": False,
        "keyword_density": round(min(density, 1.0), 3),
        "score": round(min(score, 1.0), 3),
        "signals": signals,
    }
