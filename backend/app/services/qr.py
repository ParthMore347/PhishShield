import base64
import io
import os
from pathlib import Path
from typing import Optional, Tuple
from PIL import Image

# Gracefully import pyzbar to avoid startup crashes if native libzbar is missing
try:
    if os.name == "nt":
        package_dir = Path(os.sys.executable).resolve().parent.parent / "Lib" / "site-packages" / "pyzbar"
        if package_dir.exists():
            os.add_dll_directory(str(package_dir))
    from pyzbar import pyzbar
    PYZBAR_AVAILABLE = True
except (ImportError, OSError):
    PYZBAR_AVAILABLE = False

def decode_qr_image(image_b64: str) -> Tuple[bool, Optional[str]]:
    """
    Decodes a base64 encoded image to find and extract any QR codes.
    Returns: (contains_qr, decoded_url)
    """
    if not image_b64:
        return False, None
    
    try:
        # Strip data prefix if present (e.g. data:image/png;base64,)
        if "," in image_b64:
            image_b64 = image_b64.split(",")[1]
            
        img_bytes = base64.b64decode(image_b64)
        image = Image.open(io.BytesIO(img_bytes))
        
        if PYZBAR_AVAILABLE:
            decoded_objects = pyzbar.decode(image)
            for obj in decoded_objects:
                if obj.type == "QRCODE":
                    decoded_url = obj.data.decode("utf-8")
                    return True, decoded_url
        else:
            # Fallback mock for demo/testing when libzbar is not installed on the system
            # If the base64 string starts with standard test patterns, return a mock URL
            # or just log that pyzbar is unavailable.
            pass
            
    except Exception as e:
        print(f"Error during QR decoding: {str(e)}")
        
    return False, None

def analyze_qr_code(image_b64: str) -> dict:
    """
    Scans a base64 image for QR codes and assesses if the embedded link is malicious.
    """
    contains_qr, decoded_url = decode_qr_image(image_b64)
    
    if not contains_qr or not decoded_url:
        return {
            "contains_qr": False,
            "decoded_url": None,
            "is_suspicious_redirect": False,
            "score": 0.0
        }
        
    # Check if decoded URL is a known redirector or has phishing indicators
    is_suspicious = False
    score = 0.0
    
    # Check redirectors or link shorteners which are commonly abused in QR scams (Quishing)
    redirectors = ["bit.ly", "tinyurl.com", "t.co", "cutt.ly", "linktr.ee"]
    if any(red in decoded_url.lower() for red in redirectors):
        is_suspicious = True
        score = 0.8
        
    return {
        "contains_qr": True,
        "decoded_url": decoded_url,
        "is_suspicious_redirect": is_suspicious,
        "score": score
    }
