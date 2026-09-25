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
    return {
        "suspicious_keywords_found": found,
        "sentiment_anomaly": phrase_hits > 0,
        "keyword_density": round(min(density, 1.0), 3),
        "score": round(score, 3),
    }


def analyze_url_nlp(url: str) -> dict:
    return analyze_text_nlp(url)
