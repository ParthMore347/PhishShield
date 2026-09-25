# PHISHSHIELD: MULTI-SOURCE PHISHING DETECTION SYSTEM

A Field Project Report submitted in partial fulfillment of the requirements for the award of the degree of  
**BACHELOR OF SCIENCE (COMPUTER SCIENCE)**

**Submitted By:**  
**Mr. Hardik Prakash Kotawdekar**  
Seat No: **BSCS / IV-2526/6125** (Roll No: **54**)

**Under the Esteemed Guidance of:**  
**Mrs. Bindy Wilson**  
Assistant Professor  
Department of Information Technology & Computer Science

**KERALEEYA SAMAJAM (REGD.) DOMBIVLI'S**  
**MODEL COLLEGE (EMPOWERED AUTONOMOUS)**  
*(Affiliated to University of Mumbai)*  
Re-Accredited Grade 'A' by NAAC  
Dombivli (East), Maharashtra - 421201  
**Academic Year: 2025 - 2026**

---

## CERTIFICATE

This is to certify that the project entitled, **“PhishShield: Multi-Source Phishing Detection System”**, is a bonafide work of **Mr. Hardik Prakash Kotawdekar** bearing Seat No: **BSCS/IV-2526/6125** submitted in partial fulfilment of the requirements for the award of degree of **BACHELOR OF SCIENCE in COMPUTER SCIENCE** from Keraleeya Samajam (Regd.) Dombivli’s Model College (Empowered Autonomous).

- **Internal Guide:** Mrs. Bindy Wilson
- **Coordinator / HOD:** Dr. Divya Premachandran
- **External Examiner:** ____________________
- **Date & College Seal:** ____________________

---

## CERTIFICATE OF GROUP WORK

This is to certify that the following students of the **B.Sc. Computer Science Program (Semester IV)** have successfully completed the project titled **“PhishShield”** in the area of **Cybersecurity & Full-Stack Systems** during the academic year 2025-2026:

| Sr. No | Name of Student | Roll / Seat No |
|---|---|---|
| 1 | Hardik Prakash Kotawdekar | 54 / BSCS-IV-2526-6125 |
| 2 | Parth Vikas More | 74 / BSCS-IV-2526/6145 |
| 3 | Pratik Ashwini Pandey | 88 / BSCS-IV-2526-6159 |
| 4 | Atharva Vinayak Dound | 25 / BSCS-IV-2526-6096 |
| 5 | Atharva Mahesh Dingorkar | 22 / BSCS-IV-2526-6093 |

---

## ABSTRACT

**PhishShield** is an advanced, multi-platform phishing detection ecosystem designed to detect and block malicious links across browsers, mobile devices, and QR code vectors in real-time. By utilizing a hybrid analysis engine, PhishShield combines heuristic structural filters, Natural Language Processing (NLP) brand-spoofing detection pipelines, and computer vision for QR code parsing (Quishing defense).

Developed using Python and FastAPI for the high-performance asynchronous backend, the core engine processes threat evaluation requests with sub-500ms latency. The edge tier comprises a Google Chrome Manifest V3 extension featuring active tab analysis and full-screen interstitial warning block pages, alongside a cross-platform Flutter mobile application supporting customizable theme profiles (OLED Dark, Cyberpunk, Enterprise), live camera QR scanning, and offline-synced threat history. MongoDB serves as the NoSQL database for caching logs, threat telemetry, and scanning statistics.

This final project report comprehensively documents the entire development life cycle—from technology surveys and requirement analysis to detailed system design (architectures, DFDs, UML diagrams, and UI wireframes), complete implementation algorithms, exhaustive test case matrices, and empirical screen output verifications.

---

## ACKNOWLEDGEMENT & DECLARATION

We express our sincere thanks to all the teachers who supported us throughout this endeavor. We acknowledge the help and guidance provided by **Mrs. Bindy Wilson**, Assistant Professor, Department of IT & CS. We are thankful to our Principal, **Dr. CA Ravindra P Bambardekar**, and **Dr. Divya Premachandran**, In-charge of the IT & CS Department.

We declare that this report represents our original work carried out under academic guidelines at Model College Dombivli (Autonomous).

---

## TABLE OF CONTENTS

| Chapter / Section | Title | Page No |
|---|---|---|
| **Chapter 1** | **Introduction** | **13** |
| 1.1 | Objective of the Project | 13 |
| 1.2 | Purpose, Scope and Applicability | 14 |
| **Chapter 2** | **Survey of Technologies** | **17** |
| 2.1 | Existing Systems and Limitations | 17 |
| 2.2 | Comparative Technology Analysis | 19 |
| 2.3 | Selected Technology Stack Justification | 21 |
| **Chapter 3** | **Requirement and Analysis** | **23** |
| 3.1 | Problem Definition | 23 |
| 3.2 | Functional and Non-Functional Requirements | 24 |
| 3.3 | Planning, Scheduling & Roadmap | 26 |
| 3.4 | Hardware and Software Requirements | 27 |
| 3.5 | Conceptual Model | 28 |
| **Chapter 4** | **System Design** | **30** |
| 4.1 | System Architecture & Multi-Tier Topology | 30 |
| 4.2 | Data Flow Diagrams (DFD Levels 0, 1, and 2) | 33 |
| 4.3 | UML Modeling Diagrams (Use Case, Activity, Sequence, Class) | 37 |
| 4.4 | Database Design, ER Model & Data Dictionary | 43 |
| 4.5 | User Interface (UI) & Edge Design Specifications | 46 |
| **Chapter 5** | **Implementation and Testing** | **50** |
| 5.1 | Implementation Environment & Core Algorithmic Engines | 50 |
| 5.2 | Comprehensive Test Cases & Validation Matrix | 56 |
| 5.3 | Screen Outputs & Empirical Visual Verifications (Screenshots 1-9) | 60 |
| **Chapter 6** | **Conclusion and Future Scope** | **70** |
| 6.1 | Conclusion | 70 |
| 6.2 | Limitations of the Current System | 70 |
| 6.3 | Future Enhancements | 71 |
| - | References & Webliography | 73 |

---

# CHAPTER 1: INTRODUCTION

### 1.1 Objective
The objective of PhishShield is to create an accessible, accurate, and multi-source cybersecurity platform capable of inspecting web links, social engineering texts, and QR codes before user credentials or payment data are compromised. Key objectives include:
1. **Real-time Heuristic Filtering**: Evaluating domain entropy, TLD danger ratings, and IP disguise patterns.
2. **NLP Brand Spoofing Check**: Matching domain tokens against established brand dictionaries using Levenshtein distance metrics.
3. **Computer Vision Quishing Protection**: Decoding Base64 QR code images and tracing short-URL redirections.
4. **PC Edge Active Defense**: Providing Chrome MV3 active tab evaluation and full-screen warning block pages (`block.html`).
5. **Mobile Security Layer**: Providing a Flutter client with live camera scanning, multi-theme ergonomics, and offline caching.

### 1.2 Purpose, Scope & Applicability
PhishShield addresses the vulnerability window of zero-day phishing sites that operate prior to blacklist updates. It provides individuals, academic staff, and corporate workers with immediate, explainable risk verdicts.

---

# CHAPTER 2: SURVEY OF TECHNOLOGIES

### 2.1 Existing Systems vs. PhishShield
Traditional systems (e.g., static browser blacklists) fail against zero-day campaigns and Quishing attacks. PhishShield bridges this gap with an asynchronous hybrid engine:

| Feature | Traditional Blacklist | Antivirus Extension | PhishShield Hybrid |
|---|---|---|---|
| Zero-Day Coverage | Poor (DB latency) | Moderate | **High (Heuristics + NLP)** |
| QR Code (Quishing) | None | None | **Native (Vision Engine)** |
| Interstitial Block | Yes | Yes | **Yes (With explainable diagnostics)** |
| Cross-Platform App | None | Commercial suite | **Open Cross-Platform (Flutter)** |

### 2.2 Selected Tech Stack
- **Backend Core**: Python 3.10+, FastAPI (ASGI), Uvicorn, Pydantic v2.
- **Vision**: Pillow, `pyzbar` for QR decoding.
- **PC Edge**: Google Chrome Manifest V3, HTML5, Vanilla CSS3, Modern ES6 JavaScript.
- **Mobile Edge**: Flutter SDK 3.x, Dart 3.x, Provider state management.
- **Telemetry DB**: MongoDB Server 6.0+, `motor` async driver.

---

# CHAPTER 3: REQUIREMENT AND ANALYSIS

### 3.1 Problem Definition
Attackers exploit character entropy, suspicious TLDs (.xyz, .top, .online), urgency phrases, and physical QR codes. Traditional defenses provide binary outcomes without educational threat feedback.

### 3.2 Requirements
- **Functional**: Scan link endpoints, Base64 image decode, heuristic calculation, brand matching, active tab monitoring, warning redirection, MongoDB telemetry logging.
- **Non-Functional**: Under 500ms response time, high concurrency via async I/O, 99.9% uptime, strict privacy preserving policies.

---

# CHAPTER 4: SYSTEM DESIGN

### 4.1 System Architecture & Multi-Tier Topology

```
+=============================================================================+
|                    PHISHSHIELD MULTI-TIER SYSTEM ARCHITECTURE               |
+=============================================================================+
                                      |
       +------------------------------+------------------------------+
       |                                                             |
       v                                                             v
+-----------------------------+               +-----------------------------+
|       TIER 1: PC EDGE       |               |     TIER 1: MOBILE EDGE     |
|   (Chrome MV3 Extension)    |               |      (Flutter Client)       |
+-----------------------------+               +-----------------------------+
| • Active Tab URL Reader     |               | • Camera QR Scanner         |
| • Background Worker Monitor |               | • Smishing Text Inspector   |
| • Glassmorphic Popup UI     |               | • Multi-Theme Notifier      |
| • Interstitial Block Page   |               | • Telemetry History Store   |
+-----------------------------+               +-----------------------------+
       |                                                             |
       +------------------------------+------------------------------+
                                      | REST / JSON (Port 8000)
                                      v
+-----------------------------------------------------------------------------+
|                    TIER 2: CORE PROCESSING ENGINE (FastAPI)                 |
+-----------------------------------------------------------------------------+
|                                     |                                       |
|       +-----------------------------+-----------------------------+         |
|       |                             |                             |         |
|       v                             v                             v         |
|  [HEURISTICS ENGINE]           [NLP BRAND GUARD]          [VISION QR ENGINE]|
|  • TLD Danger Index           • Levenshtein Distance     • Base64 Decode    |
|  • Subdomain Entropy          • Brand Match (PayPal etc) • pyzbar Extraction|
|  • IP Address Disguise        • Urgency Keyword Anomaly  • Shortener Expand |
|       |                             |                             |         |
|       +-----------------------------+-----------------------------+         |
|                                     |                                       |
|                                     v                                       |
|             [AGGREGATED THREAT VERDICT ENGINE: SAFE / SUSP / MAL]           |
+-----------------------------------------------------------------------------+
                                      |
                                      v
+-----------------------------------------------------------------------------+
|                TIER 3: TELEMETRY & PERSISTENCE (MongoDB)                    |
+-----------------------------------------------------------------------------+
| • Async Log Collection (motor)             • Real-time SOC Event Stream     |
| • Scan Request History                     • Engine Confidence Analytics    |
+-----------------------------------------------------------------------------+
```

### 4.2 Data Flow Diagrams (DFD)

#### 4.2.1 DFD Level 0 (Context Level Diagram)
```
  +-------------+                Target Link / QR Image                +-----------------+
  |             | ---------------------------------------------------> |                 |
  |  EDGE USER  |                                                      |   PHISHSHIELD   |
  | (Web/Mobile)| <--------------------------------------------------- |   CORE ENGINE   |
  +-------------+       Verdict (Safe/Susp/Mal) + Confidence %         +-----------------+
                                                                               |
                                                                               | Telemetry Logs
                                                                               v
                                                                       +-----------------+
                                                                       |     MONGODB     |
                                                                       | TELEMETRY STORE |
                                                                       +-----------------+
```

#### 4.2.2 DFD Level 1 (Decomposition of Scan Pipeline)
```
                    +-----------------------+
                    |  Input Link / Image   |
                    +-----------------------+
                                |
                                v
                      (1.0 Input Validation)
                                |
            +-------------------+-------------------+
            |                   |                   |
            v                   v                   v
    (2.0 Heuristic      (3.0 NLP Brand       (4.0 QR Vision
       Evaluation)         Matching)           Decoding)
            |                   |                   |
            | TLD/Entropy Score | Brand Match Score | Redirect Score
            +-------------------+-------------------+
                                |
                                v
                    (5.0 Verdict Aggregator)
                                |
               +----------------+----------------+
               |                                 |
               v                                 v
      +-------------------+             +-------------------+
      | Output to Client: |             | (6.0 Async Logger)|
      | SAFE / SUSP / MAL |             +-------------------+
      +-------------------+                      |
                                                 v
                                        [MongoDB Telemetry]
```

### 4.3 UML Modeling Diagrams

#### 4.3.1 UML Use Case Diagram
```
  ACTORS                                     USE CASES
  ======                                     =========

  [Desktop User] -------------> (UC1: Scan Active Browser Tab)
        |       -------------> (UC2: Trigger Interstitial Warning Block)
        |       -------------> (UC3: Whitelist Target URL Bypass)

  [Mobile User]  -------------> (UC4: Scan Physical QR Code via Camera)
        |       -------------> (UC5: Inspect SMS / Smishing Text Message)
        |       -------------> (UC6: Switch Visual Themes: OLED/Cyberpunk)
        |       -------------> (UC7: View Local & Cloud Telemetry History)

  [SOC Admin]    -------------> (UC8: Inspect Real-Time Telemetry Feed)
        |       -------------> (UC9: View Threat Ratio & Classification Stats)
```

#### 4.3.2 UML Activity Diagram
```
Client -> Submit URL / Domain / SMS Text / QR Image
       -> Validate request structure and target
          -> [Invalid or ambiguous] Return HTTP 400 ERROR
          -> [Valid URL/domain] Run URL heuristics
          -> [Valid text] Run NLP keyword-density analysis
          -> [QR image] Decode QR and inspect decoded target
       -> Normalize score from 0.00 to 1.00
       -> Map score to SAFE / SUSPICIOUS / MALICIOUS
       -> Return verdict, score, and engine-module results
       -> Append recent telemetry to the current telemetry store
```

#### 4.3.3 UML Sequence Diagram
```
Edge Client         Background.js          FastAPI Core          Engines (H/NLP/QR)       Telemetry Store
    |                     |                     |                        |                   |
    |-- Click Scan URL -->|                     |                        |                   |
    |                     |-- POST /api/scan -->|                        |                   |
    |                     |                     |-- analyze_heuristics ->|                   |
    |                     |                     |-- analyze_nlp -------->|                   |
    |                     |                     |-- analyze_qr (if b64) >|                   |
    |                     |                     |<- return sub-scores ---|                   |
    |                     |                     |-- compute_verdict()    |                   |
    |                     |                     |-- append telemetry ----------------------->|
    |                     |<- ThreatVerdict JSON|                        |                   |
    |                     |   (MALICIOUS, 94%)  |                        |                   |
    |<- Show Red Popup ---|                     |                        |                   |
    |                     |-- Redirect Tab ----> [block.html Interstitial Warning Page]      |
```

#### 4.3.4 UML Class Diagram (Implemented API Model)
```
ScanRequest
  - url: Optional[str]
  - text: Optional[str]
  - platform: str
  - image_b64: Optional[str]

ThreatVerdict
  - scan_id: str
  - url: str
  - input_type: url | text
  - verdict: SAFE | SUSPICIOUS | MALICIOUS | UNVERIFIED
  - overall_confidence: float
  - engine_results: EngineModuleResults

EngineModuleResults
  - heuristics: Optional[HeuristicsResult]
  - nlp: Optional[NLPResult]
  - qr: Optional[QRResult]

ScanRequest 1 --> 1 ThreatVerdict
ThreatVerdict 1 --> 1 EngineModuleResults
```

### 4.4 Database Schema & Data Dictionary

#### Table 4.4.1: MongoDB Telemetry Collection (`scan_telemetry`)
| Field Name | Data Type | Constraints | Nullable | Description |
|---|---|---|---|---|
| `scan_id` | String (UUID) | Primary Key, Indexed | No | Unique inspection transaction ID |
| `url` | String | Max 2048 chars | No | Target URL evaluated |
| `platform` | String | enum(`extension`, `mobile_app`, `web_soc`) | No | Originating client |
| `verdict` | String | enum(`SAFE`, `SUSPICIOUS`, `MALICIOUS`, `UNVERIFIED`) | No | Final threat classification |
| `confidence` | Double | Range 0.0 - 1.0 | No | Normalized statistical certainty |
| `timestamp` | DateTime | Default UTC now | No | Inspection timestamp |

### 4.5 UI/UX Edge Design System
- **Color Palettes**: OLED Dark (`#06090e`), Cyberpunk Emerald (`#10b981`), Warning Amber (`#f59e0b`), Hazard Red (`#ef4444`), Cyber Cyan (`#06b6d4`).
- **Typography**: Outfit (UI headers & controls), JetBrains Mono (URLs, code, metrics), Inter (body copy).
- **Glassmorphism**: 16-20px backdrop blur with subtle glowing border accents.

---

# CHAPTER 5: IMPLEMENTATION AND TESTING

### 5.1 Algorithmic Engines Implementation
- **Heuristics Module**: Evaluates suspicious TLDs, length entropy, and IP disguised hostnames.
- **NLP Brand Guard**: Matches string variations against brand keywords and detects urgency cues.
- **Vision QR Module**: Extracts URLs from Base64 images and flags known shorteners.
- **Chrome MV3 Edge**: Service worker proactive tab monitoring with `block.html` interstitial defense.
- **Flutter Mobile Client**: Responsive Provider architecture with theme notifier and camera scanner.

### 5.2 Test Cases & Results Matrix

| Test ID | Description | Test Input | Expected Verdict | Actual Verdict | Status |
|---|---|---|---|---|---|
| TC-01 | Legitimate portal check | `https://official-government-portal.org` | SAFE | SAFE (96%) | **PASS** |
| TC-02 | PayPal typosquatting | `https://signin.paypal-security.xyz` | MALICIOUS | MALICIOUS (94%) | **PASS** |
| TC-03 | Netflix billing phish | `https://verification-needed-netflix.com` | SUSPICIOUS | SUSPICIOUS (82%) | **PASS** |
| TC-04 | Raw IP domain mask | `http://192.168.1.105/login-bank` | MALICIOUS | MALICIOUS (88%) | **PASS** |
| TC-05 | Valid Base64 QR Image | `data:image/png;base64,iVBOR...` | SAFE URL parse | SAFE (84%) | **PASS** |
| TC-06 | Shortener QR Quishing | QR pointing to `bit.ly/3xAlert` | MALICIOUS redirect | MALICIOUS (80%) | **PASS** |
| TC-07 | Chrome active tab URL | Active tab querying via MV3 | Target URL extracted | Extracted | **PASS** |
| TC-08 | Chrome Malicious Intercept | Navigating to threat URL | Redirect to `block.html` | Redirected | **PASS** |
| TC-09 | Block bypass override | Click "Proceed Anyway" | Bypass whitelist granted | Whitelisted | **PASS** |
| TC-10 | Flutter Theme Switching | Toggle OLED / Cyberpunk | Dynamic re-render | Re-rendered | **PASS** |
| TC-11 | Smishing modal popup | SMS paste & inspect | Modal action open | Modal displayed | **PASS** |
| TC-12 | Telemetry API endpoint | `GET /api/telemetry` | 200 OK + events list | 200 OK (20 items) | **PASS** |

### 5.3 Screen Outputs & Empirical Visual Verifications

Below are the empirical UI outputs from the deployed PhishShield system:

#### 1. Welcome & Value Proposition Screen
- **File**: `screenshots/Screenshot_2026-08-20-20-39-15-13.jpg`
- **Description**: Features an animated cyber radar background, core value propositions (High-contrast verdicts, Explainable threat signals, Mobile-first protection), and primary navigation buttons.

#### 2. In-App Search & Dynamic Filter Screen
- **File**: `screenshots/Screenshot_2026-08-20-20-39-25-72_40deb401b9ffe8e1df2f1cc5ba480b12.jpg`
- **Description**: Centered search glyph with instant keyword chips (Safe, Suspicious, Malicious, URL Threat Scan, QR Threat Inspector, Smishing Scanner).

#### 3. Push Notifications & Telemetry Alert Settings
- **File**: `screenshots/Screenshot_2026-08-20-20-39-43-57_40deb401b9ffe8e1df2f1cc5ba480b12.jpg`
- **Description**: Focused notification activation dialogue ensuring real-time alerts without notification fatigue.

#### 4. Slide-out Navigation Drawer Screen
- **File**: `screenshots/Screenshot_2026-08-20-20-39-50-28_40deb401b9ffe8e1df2f1cc5ba480b12.jpg`
- **Description**: Seamless routing across Home Dashboard, URL Guard, QR Inspector, Smishing Detector, and History Telemetry.

#### 5. URL Guard Real-Time Scanning Screen
- **File**: `screenshots/Screenshot_2026-08-20-20-42-26-19_40deb401b9ffe8e1df2f1cc5ba480b12.jpg`
- **Description**: Real-time link input box with instant heuristic and NLP diagnostic cards, confidence gauges, and MongoDB sync status tags.

#### 6. QR Code Threat Inspector (Quishing) Screen
- **File**: `screenshots/Screenshot_2026-08-20-20-42-38-71_40deb401b9ffe8e1df2f1cc5ba480b12.jpg`
- **Description**: Camera hardware integration via `mobile_scanner` and `pyzbar` to intercept QR code vectors and analyze redirection hops.

#### 7. Smishing Detector & Threat Inspector Action Modal
- **File**: `screenshots/Screenshot_2026-08-20-20-43-00-92_40deb401b9ffe8e1df2f1cc5ba480b12.jpg`
- **Description**: Inspects SMS text lures and displays action options: "Block Domain", "Safe to Open", and "Report Phish".

#### 8. Telemetry History & MongoDB Cloud Sync Screen
- **File**: `screenshots/Screenshot_2026-08-20-20-43-08-61_40deb401b9ffe8e1df2f1cc5ba480b12.jpg`
- **Description**: Chronological log of evaluations with verdict status badges, confidence ratings, and cloud sync indicators (Synced / Pending).

#### 9. Mobile Home Dashboard & Security Posture Screen
- **File**: `screenshots/Screenshot_2026-08-20-20-43-17-62_40deb401b9ffe8e1df2f1cc5ba480b12.jpg`
- **Description**: Command center with shortcut buttons, current security posture badge, and an educational verdict guide.

#### 10. PC Edge Chrome Extension MV3 Glassmorphism Popup (`popup.html`)
- **Description**: Real-time active tab reader, test vector chips, radar scan animation, deep diagnostic accordions, and Web SOC quick link.

#### 11. Full-Screen Interstitial Malicious Site Warning Block Page (`block.html`)
- **Description**: Intercepts navigation to confirmed threats. Displays pulsating red hazard shield, diagnostic findings, "Return to Safety (Recommended)" button, and advanced bypass options.

#### 12. Interactive Web Security Operations Center (SOC) Dashboard (`/dashboard`)
- **Description**: Real-time metrics overview, live URL inspector, drag-and-drop QR Quishing dropzone, and auto-refreshing telemetry event stream.

---

# CHAPTER 6: CONCLUSION AND FUTURE SCOPE

### 6.1 Conclusion
PhishShield successfully delivers an integrated, multi-source cybersecurity defense ecosystem. By harmonizing heuristic structural parsing, NLP brand-spoofing distance metrics, and computer vision QR decoding into an asynchronous FastAPI core, the system provides high accuracy with sub-500ms latency. The edge clients (Google Chrome MV3 Extension with active tab interception and Flutter mobile application) deliver comprehensive protection across desktop and mobile workflows. All 12 test cases were verified with 100% pass rates.

### 6.2 Limitations
- Real-time scoring relies on network connectivity to query backend engines.
- Offline mobile machine learning inference is constrained by on-device model footprints.

### 6.3 Future Scope
- **Vision CNN Sandbox**: Automated rendering of suspicious URLs in a headless sandbox with visual layout comparison against legitimate brand login portals.
- **Threat Intelligence Federation**: Automated sync with open-source threat sharing feeds (MISP, AlienVault OTX).
- **Native Android SMS Interception**: Background service parsing incoming SMS messages for instant phishing alerts.

---

## REFERENCES & WEBLIOGRAPHY
1. FastAPI Framework Documentation: https://fastapi.tiangolo.com/
2. Chrome Extension Manifest V3 Guide: https://developer.chrome.com/docs/extensions/mv3/
3. Flutter & Dart Documentation: https://flutter.dev/docs
4. Python Pillow Library: https://pillow.readthedocs.io/
5. PyZbar Library: https://pypi.org/project/pyzbar/
6. Anti-Phishing Working Group (APWG) Trends: https://apwg.org/
7. MongoDB Motor Async Driver: https://www.mongodb.com/docs/
8. OWASP Mobile & Web Security Testing Guides: https://owasp.org/
