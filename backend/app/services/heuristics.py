import ipaddress
import math
import re
import urllib.parse
from difflib import SequenceMatcher

KNOWN_SAFE_DOMAINS = {
    "google.com",
    "github.com",
    "microsoft.com",
    "apple.com",
    "amazon.com",
    "paypal.com",
    "netflix.com",
}
SUSPICIOUS_TLDS = {".xyz", ".club", ".top", ".info", ".online", ".site", ".work", ".buzz"}
BRAND_DOMAINS = tuple(KNOWN_SAFE_DOMAINS)
DOMAIN_RE = re.compile(r"^(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$", re.I)
LONG_DOMAIN_LENGTH = 40


def _entropy(value: str) -> float:
    if not value:
        return 0.0
    counts = {character: value.count(character) for character in set(value)}
    raw = -sum((count / len(value)) * math.log2(count / len(value)) for count in counts.values())
    return min(raw / 6.0, 1.0)


def parse_url_or_domain(value: str) -> tuple[urllib.parse.ParseResult, str] | None:
    candidate = value.strip()
    if not candidate or any(character.isspace() for character in candidate):
        return None
    try:
        parsed = urllib.parse.urlparse(candidate if "://" in candidate else f"https://{candidate}")
    except ValueError:
        return None
    if parsed.scheme not in {"http", "https"} or parsed.username or parsed.password:
        return None
    try:
        hostname = parsed.hostname
        parsed.port
    except ValueError:
        return None
    if not hostname or not DOMAIN_RE.match(hostname) and not _is_ip(hostname):
        return None
    try:
        hostname = hostname.encode("idna").decode("ascii").lower().rstrip(".")
    except UnicodeError:
        return None
    return parsed, hostname


def _is_ip(hostname: str) -> bool:
    try:
        ipaddress.ip_address(hostname)
        return True
    except ValueError:
        return False


def analyze_url_heuristics(url: str) -> dict:
    parsed_and_host = parse_url_or_domain(url)
    if not parsed_and_host:
        raise ValueError("Invalid URL or domain")
    parsed, domain = parsed_and_host
    base_domain = domain[domain.rfind(".") + 1 :]
    suspicious_tld = f".{base_domain}" in SUSPICIOUS_TLDS
    has_ip = _is_ip(domain)
    labels = domain.split(".")
    special_char_count = sum(domain.count(character) for character in "-_@")
    typosquatting = any(
        domain != safe and SequenceMatcher(None, domain.replace(".", ""), safe.replace(".", "")).ratio() >= 0.88
        for safe in BRAND_DOMAINS
    )
    entropy = _entropy(f"{domain}{parsed.path}{parsed.query}")
    score = 0.0
    score += 0.30 if suspicious_tld else 0.0
    score += 0.45 if has_ip else 0.0
    score += 0.75 if typosquatting else 0.0
    score += 0.10 if len(domain) > LONG_DOMAIN_LENGTH else 0.0
    score += 0.10 if len(labels) > 4 else 0.0
    score += 0.10 if special_char_count >= 2 else 0.0
    score += 0.10 if entropy >= 0.78 else 0.0
    if domain in KNOWN_SAFE_DOMAINS:
        score = 0.0
    return {
        "suspicious_tld": suspicious_tld,
        "domain_length": len(domain),
        "has_ip_address": has_ip,
        "special_char_count": special_char_count,
        "typosquatting": typosquatting,
        "url_entropy": round(entropy, 3),
        "score": round(min(score, 1.0), 3),
    }
