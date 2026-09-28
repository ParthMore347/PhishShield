"""
PhishShield Live Evaluation & Defense Demo Suite
Runs automated threat classification vectors against the PhishShield Core Engine.
Works either with a live running FastAPI server or in-process via TestClient.
Ideal for project presentations and viva evaluations.
"""

import os
import sys
import time

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

BASE_URL = "http://127.0.0.1:8000"

TEST_VECTORS = [
    {
        "name": "Legitimate Safe Domain",
        "type": "URL",
        "payload": {"url": "https://github.com/explore", "platform": "presentation_demo"},
        "expected": "SAFE"
    },
    {
        "name": "High-Risk TLD & Entropy Spoof",
        "type": "URL",
        "payload": {"url": "http://secure-billing-login-portal.xyz", "platform": "presentation_demo"},
        "expected": "SUSPICIOUS"
    },
    {
        "name": "PayPal Credential Phishing Link",
        "type": "URL",
        "payload": {"url": "https://security-alert-paypal-login.com", "platform": "presentation_demo"},
        "expected": "MALICIOUS"
    },
    {
        "name": "Urgent SMS Smishing Attack",
        "type": "SMS/Text",
        "payload": {"text": "URGENT ACTION REQUIRED: Your bank account has been suspended. Click here to verify credentials.", "platform": "mobile_app"},
        "expected": "MALICIOUS"
    },
    {
        "name": "Safe Internal Service Query",
        "type": "URL",
        "payload": {"url": "https://google.com/search?q=cybersecurity", "platform": "presentation_demo"},
        "expected": "SAFE"
    }
]


class DemoClient:
    def __init__(self):
        self.live_mode = False
        import requests
        self.requests = requests
        try:
            res = self.requests.get(f"{BASE_URL}/", timeout=1.5)
            if res.status_code == 200:
                self.live_mode = True
        except Exception:
            self.live_mode = False

        if not self.live_mode:
            # Fall back to in-process FastAPI TestClient
            backend_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "backend")
            if backend_dir not in sys.path:
                sys.path.insert(0, backend_dir)
            from fastapi.testclient import TestClient
            from app.main import app
            self.test_client_ctx = TestClient(app)
            self.test_client = self.test_client_ctx.__enter__()

    def get(self, path):
        if self.live_mode:
            return self.requests.get(f"{BASE_URL}{path}", timeout=5)
        return self.test_client.get(path)

    def post(self, path, json):
        if self.live_mode:
            return self.requests.post(f"{BASE_URL}{path}", json=json, timeout=5)
        return self.test_client.post(path, json=json)

    def close(self):
        if not self.live_mode and hasattr(self, "test_client_ctx"):
            try:
                self.test_client_ctx.__exit__(None, None, None)
            except Exception:
                pass


def run_demo():
    print("=" * 68)
    print("      [+] PHISHSHIELD MULTI-SOURCE DETECTION ENGINE DEMO [+]")
    print("=" * 68)

    client = DemoClient()
    mode_label = "LIVE HTTP SERVER (http://127.0.0.1:8000)" if client.live_mode else "IN-PROCESS TEST ENGINE (Atlas Connected)"
    print(f"Execution Mode: {mode_label}")

    # 1. Health check
    try:
        res = client.get("/")
        if res.status_code == 200:
            print("[+] Core Engine is ONLINE and responsive.")
        else:
            print(f"[!] Core Engine returned status code: {res.status_code}")
    except Exception as e:
        print(f"[-] Could not connect: {e}")
        return

    # 2. Test vectors
    print("\n" + "-" * 68)
    print("Executing Real-Time Multi-Source Threat Scans:")
    print("-" * 68)

    passed = 0
    for idx, test in enumerate(TEST_VECTORS, 1):
        name = test["name"]
        payload = test["payload"]
        exp = test["expected"]
        target_display = payload.get("url") or payload.get("text")
        if len(target_display) > 42:
            target_display = target_display[:39] + "..."

        t0 = time.time()
        res = client.post("/api/scan", json=payload)
        elapsed_ms = round((time.time() - t0) * 1000, 1)

        if res.status_code == 200:
            data = res.json()
            verdict = data.get("verdict")
            conf = data.get("overall_confidence", 0.0)
            scan_id = data.get("scan_id", "N/A")

            # Check match
            status_symbol = "[OK]" if verdict == exp else "[!]"
            if verdict == exp:
                passed += 1

            print(f"[{idx}/5] {name}")
            print(f"      Target:    {target_display}")
            print(f"      Verdict:   {verdict} (Confidence: {conf * 100:.0f}%) | Latency: {elapsed_ms}ms")
            print(f"      Scan ID:   {scan_id} {status_symbol} Matched Expected: {exp}\n")
        else:
            print(f"[{idx}/5] {name} -> Error {res.status_code}: {res.text}\n")

    # 3. Telemetry Check
    print("-" * 68)
    print("Querying MongoDB Atlas Telemetry Stream:")
    print("-" * 68)
    try:
        t_res = client.get("/api/telemetry")
        if t_res.status_code == 200:
            t_data = t_res.json()
            stats = t_data.get("stats", {})
            print(f"[+] Total Scans Persisted:   {t_data.get('total_scans')}")
            print(f"[+] Persistence Engine:       {t_data.get('persistence').upper()}")
            print(f"[+] Safe / Suspicious / Mal: {stats.get('safe')} / {stats.get('suspicious')} / {stats.get('malicious')}")
            print(f"[+] Fleet Threat Ratio:       {stats.get('threat_ratio')}")
    except Exception as e:
        print(f"[-] Telemetry query failed: {e}")

    print("=" * 68)
    print(f"DEMO COMPLETED: {passed}/{len(TEST_VECTORS)} vectors accurately classified.")
    print("Web SOC Dashboard available at: http://localhost:8000/dashboard")
    print("=" * 68)

    client.close()


if __name__ == "__main__":
    run_demo()
