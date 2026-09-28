
# PHISHSHIELD

A Field Project Report

**BACHELOR OF SCIENCE (COMPUTER SCIENCE)**

By

**Mr. Parth Vikas More**  
**BSCS / IV-2526/6145**

Under the esteemed guidance of  
**Mrs. Priti Chopade**  
Assistant Professor

DEPARTMENT OF INFORMATION TECHNOLOGY & COMPUTER SCIENCE

**KERALEEYA SAMAJAM (REGD.) DOMBIVLI'S**  
**MODEL COLLEGE (EMPOWERED AUTONOMOUS)**  
*(Affiliated to University of Mumbai)*

**DOMBIVLI, 421201 MAHARASHTRA**

**MARCH 2026**

---

**KERALEEYA SAMAJAM (REGD.) DOMBIVLI'S**  
**MODEL COLLEGE (EMPOWERED AUTONOMOUS)**  
*(Affiliated to University of Mumbai)*  
**DOMBIVLI- MAHARASHTRA-421201**

**DEPARTMENT OF INFORMATION TECHNOLOGY & COMPUTER SCIENCE**

### CERTIFICATE

This is to certify that the project entitled, **“PhishShield”**, is bonafied work of **Mr. Parth Vikas More** bearing Seat No: **BSCS/IV-2526/6145** submitted in partial fulfilment of the requirements for the award of degree of **BACHELOR OF SCIENCE in COMPUTER SCIENCE** from Keraleeya Samajam (Regd.) Dombivli’s Model College.

Internal Guide  
Coordinator  
External Examiner  
Date:  
College Seal  

---

**Keraleeya Samajam (Regd.) Dombivli’s**  
**MODEL COLLEGE**  
**(Empowered Autonomous)**  
*(Affiliated to University of Mumbai)*  
**Re-Accredited Grade “A” by NAAC**

### CERTIFICATE

This is to certify that the following students of the **B.Sc. Computer Science Program**, studying in **Semester IV** have successfully completed a group project titled: **“PhishShield”** in the area of **Cybersecurity & Full-Stack Development specialization**, during the academic year **2025-2026**. The students listed below have contributed to this project work and to the best of our knowledge, the work is original and all information provided is accurate and relevant.

**List of Group members**

| Sr. No | Name | Roll/Seat No |
|---|---|---|
| 1 | Parth Vikas More | 66 / BSCS-IV-2526/6145 |
| 2 | Parth Vikas More | 74 / BSCS-IV-2526/6145 |
| 3 | Pratik Ashwini Pandey | 88/ BSCS-IV-2526-6159 |
| 4 | Atharva Vinayak Dound | 25/ BSCS-IV-2526-6096 |
| 5 | Atharva Mahesh Dingorkar | 22/ BSCS-IV-2526-6093 |
| 6 | | |
| 7 | | |
| 8 | | |
| 9 | | |
| 10 | | |

Internal Guide  
Head of the Dept/Principal  

---

<br>

### ABSTRACT

**PhishShield** is an advanced, multi-source phishing detection ecosystem designed to detect and block malicious links across web browsers, mobile applications, and QR code vectors in real-time. The system addresses the increasing sophistication of cyber threats, social engineering attacks, and credential harvesting schemes by combining quick heuristic filtering, Natural Language Processing (NLP) brand-spoofing check pipelines, and computer vision for QR code parsing (Quishing analysis).

Developed using Python and FastAPI for the high-performance asynchronous backend, the core engine processes threat evaluation requests with low latency. Data validation is enforced using Pydantic, while computer vision tasks leverage Pillow and `pyzbar`. The user-facing clients include a Google Chrome Manifest V3 extension built with HTML5, CSS3, and JavaScript for desktop edge protection, and a mobile client built with Flutter and Dart providing cross-platform security telemetry. MongoDB serves as the NoSQL database for caching logs, threat telemetry, and scan statistics.

Key features of PhishShield include real-time link scanning, domain age and TLD risk heuristics, brand spoofing string comparison using string distance metrics, automated QR code extraction, short-URL expansion, and malicious site warning block pages. The system also features role-based telemetry management and configurable desktop/mobile interface profiles.

PhishShield is a scalable platform tailored for cybersecurity awareness and proactive digital defense. It supports educational, personal, and enterprise environments by delivering a robust, automated ecosystem for real-time phishing detection and continuous threat assessment.

---

<br>

### ACKNOWLEDGEMENT

It gives us a pleasure to present our project on **“PhishShield”**. This is our milestone in Bachelor of Science (Computer Science). We would like to express our sincere thanks to all the teachers who helped us throughout the project. We would like to acknowledge the help and guidance provided by **Mrs. Priti Chopade**, Assistant Professor in all places during the presentation of this project.

We are thankful to our honorable Principal **Dr. CA Ravindra P Bambardekar** towards our project works. We are also thankful to the staff members of the IT-CS department for their moral support. We extend our gratitude to **Dr. Divya Premachandran**, In-charge of IT & CS Department for her support and guidance.

---

<br>

### DECLARATION

We hereby declare that the project entitled, **“PhishShield”** done at Keraleeya Samajam (Regd.) Dombivli’s Model College (Autonomous), has not been in any case duplicated to submit to any other university for the award of any degree. To the best of our knowledge other than us, no one has submitted to any other university.

The project is done in partial fulfilment of the requirements for the award of degree of **BACHELOR OF SCIENCE (COMPUTER SCIENCE)** to be submitted as a IV semester project as part of our curriculum.

Parth Vikas More  
Name of Student  
Sign  

---

<br>

## TABLE OF CONTENTS

| Sr. No. | Title | Page no |
|---|---|---|
| **Chapter 1** | **Introduction** | **13-14** |
| 1.1 | Objective | 13 |
| 1.2 | Purpose, Scope and Applicability | 13 |
| 1.2.1 | Purpose | 13 |
| 1.2.2 | Scope | 14 |
| 1.2.3 | Applicability | 14 |
| | | |
| **Chapter 2** | **Survey of technologies** | **17-20** |
| 2.1 | Existing System | 17 |
| 2.2 | List of Technologies | 17-18 |
| 2.3 | Comparative Study | 19 |
| 2.4 | Selected Technologies | 20 |
| | | |
| **Chapter 3** | **Requirement and Analysis** | **23-27** |
| 3.1 | Problem Definition | 23 |
| 3.2 | Requirement Specification | 24-25 |
| 3.3 | Planning and Scheduling | 26 |
| 3.4 | Software and Hardware Requirements | 26 |
| 3.5 | Conceptual Model | 27 |

---

<br>

## List of Tables

| Sr. No. | Name of Table | Page No |
|---|---|---|
| **Chapter 1** | **Applicability** | **14** |
| 1.2.3.1 | Different Scope in Applicability | 14 |
| | | |
| **Chapter 2** | **Survey of Technologies** | **17-20** |
| 2.3.1 | Comparative study between different technologies | 19-20 |

---

<br>

## List of Figures

| Sr. No. | Name of Figures | Page No |
|---|---|---|
| **Chapter 3** | **Requirement and Analysis** | **23-27** |
| 3.5.1 | Conceptual Model | 27 |

---

<br>

### Periodic Field Project Report (Abstract Phase)

| Field | Details |
|---|---|
| **Name of the Student** | Parth Vikas More |
| **Program /Semester** | BSC CS SEM IV |
| **Roll No/Seat No** | 54 / BSCS-IV-2526/6125 |
| **Field project Title** | PhishShield |
| **Name of the Faculty mentor** | Mrs. Priti Chopade |
| **Overview (Max 150 Words)** | The PhishShield Project is a multi-source phishing detection system featuring browser extensions, mobile apps, and backend threat detection modules. The platform is designed to be user-friendly, responsive, and scalable. In this system, users can analyze links, QR codes, and suspicious domain patterns in real-time. |
| **Learning Outcomes (Max 100 words)** | PhishShield is a multi-source phishing detection platform offering link heuristics, brand-spoofing NLP, and quishing analysis designed for security awareness and real-time defense, with high scalability and cross-platform adaptability. |

**Mentor Feedback and Suggestions (Max 100 words):**  
Abstract is completed and it’s fine  

Student Sign with date &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Mentor's Signature with date  

---

<br>

# CHAPTER 1

# INTRODUCTION

### 1.1 Objective:

The primary objective of **PhishShield** is to design and implement a dynamic, user-friendly, and scalable multi-source phishing detection ecosystem that caters to a diverse range of users across desktop and mobile platforms. The system aims to deliver an engaging digital security experience through intuitive interfaces and reliable backend threat inspection services. Specific objectives include:

- To implement critical threat scanning features such as domain heuristic evaluation, TLD risk indexing, and automated URL shortener expansion to detect deceptive links in real-time.
- To detect brand spoofing and social engineering attempts through Natural Language Processing (NLP) pipelines, evaluating string entropy and brand name variations.
- To perform computer vision-based QR code parsing and "Quishing" analysis to intercept malicious links embedded within physical or digital images.
- To empower desktop users through a Chrome Manifest V3 extension featuring active tab analysis and full-screen malicious site warning blocks.
- To provide mobile users with a cross-platform Flutter application featuring customizable theme profiles, live QR scanning, and telemetry history tracking.
- To maintain an asynchronous telemetry logging system using MongoDB to cache scan verdicts, threat metrics, and analytical statistics efficiently.

---

### 1.2 Purpose, Scope & Applicability:

#### 1.2.1 Purpose

The purpose behind developing **PhishShield** stems from the growing need for immersive, adaptable, and technology-enabled platforms that support digital security, fraud prevention, and real-time threat evaluation. It aims to bridge the gap between static traditional blacklist systems and modern expectations of multi-vector threat detection, data-driven feedback, and ease of edge deployment across devices. PhishShield strives to be:

- A platform for digital security awareness, combining automated threat analysis and clear visual feedback into one engaging interface.
- A tool for individual users, educators, and organizations, allowing structured link assessment and insight into malicious web vectors.
- A scalable base for future integrations such as AI-driven phishing page screenshot classification, threat intelligence sharing APIs, and automated threat reporting modules.

---

#### 1.2.2 Scope

**PhishShield** encompasses the development of a scalable, user-friendly, and interactive phishing detection platform that caters to individual web users, mobile device users, and enterprise networks. The system is designed to handle multiple input channels—including active browser URLs, manually pasted link strings, and uploaded or scanned QR code images—ensuring flexibility in usage. It enables instant threat classification (`SAFE`, `SUSPICIOUS`, `MALICIOUS`), efficient telemetry logging, and responsive access across desktop and mobile form factors. 

While the current implementation focuses on core heuristic checks, brand-spoofing NLP parsing, and QR image decoding, the architecture is modular, allowing for seamless integration of advanced features such as deep neural network visual similarity checking, live domain sandbox execution, and global threat intelligence database synchronization in future iterations. The project is adaptable for deployment in home browsing, academic institutions, corporate network edge extensions, and mobile security suites, making it a versatile tool in the cybersecurity ecosystem.

---

#### 1.2.3 Applicability

PhishShield is designed to serve a broad spectrum of user groups and organizational contexts. Its modular design and customizable functionality make it adaptable across multiple domains:

| User Type | Use Case Example |
|---|---|
| **Students & Individuals** | Checking suspicious email links, short URLs, and social media links before opening them |
| **Mobile App Users** | Scanning physical QR codes (menus, flyers, payment posters) to prevent Quishing attacks |
| **Desktop Web Browsers** | Real-time background checking of active browser tabs via Chrome Extension MV3 |
| **IT & Security Admins** | Inspecting threat telemetry logs and analyzing attack trends targeting specific brands |
| **Organizations & Enterprises** | Protecting non-technical personnel from clicking social engineering and credential harvesting links |
| **EdTech & Cyber Training** | Demonstrating how domain heuristics and brand spoofing tactics work in real-time |

*Table 1.2.3.1: Different Scope in Applicability*

---

<br>

### Periodic Field Project Report (Chapter 1 Phase)

| Field | Details |
|---|---|
| **Name of the Student** | Parth Vikas More |
| **Program /Semester** | BSC CS SEM IV |
| **Roll No/Seat No** | 54 / BSCS-IV-2526/6125 |
| **Field project Title** | PhishShield |
| **Name of the Faculty mentor** | Mrs. Priti Chopade |
| **Overview (Max 150 Words)** | PhishShield is an interactive and scalable multi-source phishing detection platform designed to make digital browsing safe and transparent. It provides features like heuristic domain filtering, NLP brand-spoofing checks, QR parsing, and real-time threat verdicts. The platform supports individual users, mobile device users, and network administrators with simple threat management and live security insights. Its modular design allows future integration of advanced features like AI vision models, sandboxing, and global threat sync. |
| **Learning Outcomes (Max 100 words)** | • Ability to design and develop a scalable multi-platform cybersecurity detection system.<br>• Implement features like link heuristics, NLP string analysis, and QR code parsing.<br>• Manage telemetry logs efficiently through asynchronous database services.<br>• Apply the platform across web extensions, mobile clients, and enterprise threat detection contexts. |

**Mentor Feedback and Suggestions (Max 100 words):**  
Chapter 1 is completed and it’s fine  

Student Sign with date &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Mentor's Signature with date  

---

<br>

# CHAPTER 2

# SURVEY OF TECHNOLOGIES

### 2.1 EXISTING SYSTEM

In the current digital security landscape, phishing protection relies heavily on centralized web blacklists, static browser built-in filters (such as Google Safe Browsing or Microsoft SmartScreen), and traditional desktop antivirus software. While effective against known, long-standing malicious URLs, Google Safe Browsing often experiences a latency window when indexing newly registered zero-day phishing domains. VirusTotal provides multi-engine aggregation but requires manual URL submissions and lacks proactive edge protection during routine browsing. Specialized mobile security apps frequently suffer from intrusive ad displays, slow scanning processes, or heavy resource overhead. Furthermore, most conventional security systems lack dedicated computer vision engines to intercept "Quishing" (QR-code based phishing) or brand-spoofing NLP parsing at the client edge. Common limitations across existing solutions include static database dependencies, slow response times to zero-day domains, limited cross-platform integration between mobile and browser extensions, and low visibility for users into specific threat evaluation metrics.

---

### 2.2 LIST OF TECHNOLOGIES

#### 1. Python & FastAPI
Python is a high-level, versatile programming language ideal for cybersecurity data processing, heuristics calculation, and web framework development. FastAPI is an ultra-fast, asynchronous Python web framework used to build the high-performance core REST API of PhishShield.
- **Role in PhishShield**: Serves as the central threat inspection backend engine, receiving scan requests from clients, parsing domain properties, orchestrating heuristics, NLP, and vision modules, and returning normalized threat verdicts.
- **Why Python & FastAPI?**: Lightweight, native support for async execution (`async/await`), fast execution speeds via Uvicorn, automatic OpenAPI generation, and seamless ecosystem integration with data parsing tools.

#### 2. Google Chrome Manifest V3 (Extension Architecture)
Manifest V3 is the modern standard for Google Chrome browser extension development, emphasizing enhanced performance, privacy, and security boundaries through service workers.
- **Role in PhishShield**: Powers the desktop edge extension, enabling background tab inspection, real-time popup interface alerts, and full-screen warning page blocks upon detecting malicious domains.
- **Why Chrome MV3?**: Provides native access to Chrome Tabs and Web Request APIs, ensures high energy efficiency, and integrates clean glassmorphic HTML/CSS user interfaces directly into the browser.

#### 3. Flutter & Dart
Flutter is an open-source UI software development kit created by Google, allowing single-codebase cross-platform application development compiled natively to mobile environments using the Dart programming language.
- **Role in PhishShield**: Builds the mobile edge application, featuring active QR code scanner integration (`mobile_scanner`), custom theme customization (Cyberpunk, OLED, Enterprise), and telemetry statistics visualization.
- **Why Flutter?**: Exceptional rendering performance, rich ecosystem of native hardware integration packages (camera/QR scanning), and fluid UI responsiveness.

#### 4. Computer Vision Libraries (Pillow & pyzbar)
Pillow is Python's standard image processing library, while `pyzbar` enables decoding of 1D barcodes and QR codes from image streams.
- **Role in PhishShield**: Parses Base64 image payloads sent from mobile devices or uploaded files, extracts encoded URL payloads from QR codes, and forwards resolved links to the heuristic pipeline.
- **Why pyzbar?**: Highly accurate, fast decoding capability, operating independently without requiring heavy deep learning framework overhead.

#### 5. MongoDB (NoSQL Database)
MongoDB is a document-oriented, NoSQL database system designed for high volume, JSON-like flexible data storage and rapid document retrieval.
- **Role in PhishShield**: Stores asynchronous threat logs, client scan telemetry, performance metrics, and cached scan verdicts using `motor` async drivers.
- **Why MongoDB?**: Flexible dynamic schema fits evolving engine outputs (`ENGINE_MODULE_RESULTS`), fast write operations, and effortless JSON document mapping with Python's Pydantic schemas.

---

### 2.3 COMPARATIVE STUDY

| Technology | Type | Purpose in PhishShield | Strengths | Limitations |
|---|---|---|---|---|
| **FastAPI (Python)** | Web Framework | Backend logic: URL inspection, routing, module evaluation | Async execution, auto OpenAPI docs, lightweight, very high throughput | Requires Python 3.10+ runtime, synchronous blocking code can reduce speed |
| **Flask (Python)** | Web Framework | Alternative backend engine option | Simple syntax, easy setup, mature community | Synchronous by default, requires manual extensions for OpenAPI docs and async IO |
| **Django** | Full-Stack Framework | Alternative full-stack web framework | Built-in ORM, admin panel, batteries-included architecture | Overweight for API-only engines, higher latency, rigid structural conventions |
| **Chrome MV3 (JS/HTML)** | Browser Extension API | PC Edge real-time tab monitoring and page blocking | Native browser access, high efficiency, zero user context switching | Restrictive background service worker lifecycles compared to MV2 |
| **Flutter / Dart** | Mobile Framework | Mobile client app for QR scanning and dashboard | Single codebase, native compilation, smooth 60fps UI, multi-theme | Larger app binary footprint compared to native Kotlin/Android apps |
| **React Native** | Mobile Framework | Alternative mobile app framework | Large ecosystem, JavaScript syntax | Bridge layer can induce overhead during fast camera camera frame decoding |
| **MongoDB** | NoSQL Database | Stores threat logs, scan telemetry, engine diagnostic json | Flexible schema, fast JSON mapping, horizontal scalability | High memory utilization, lacks rigid relational constraints without ODM |
| **MySQL** | Relational Database | Alternative relational DB engine | Strict relational schemas, transactional integrity, standardized SQL | Rigid schema migrations required when adding modular analysis fields |

*Table 2.3.1: Comparative study between different technologies*

---

### 2.4 SELECTED TECHNOLOGIES

1. **Python 3.10+ & FastAPI**: Used to build the core asynchronous engine, managing HTTP endpoint routing, heuristic rules evaluation, string analysis, and client payload validation.
2. **Google Chrome Manifest V3 (HTML5 / CSS3 / ES6 JS)**: Selected for desktop edge protection, executing active tab hostname checks and rendering responsive glassmorphism popups.
3. **Flutter & Dart**: Selected for mobile client development, enabling hardware camera access for real-time QR code extraction and dynamic client themes.
4. **Pillow & pyzbar**: Chosen for lightweight image decoding and Quishing payload retrieval from uploaded or captured QR code images.
5. **MongoDB & Motor**: Selected for asynchronous document storage to save telemetry logs, cache URL verdicts, and track engine statistics cleanly without relational schema constraints.

---

<br>

### Periodic Field Project Report (Chapter 2 Phase)

| Field | Details |
|---|---|
| **Name of the Student** | Parth Vikas More |
| **Program /Semester** | BSC CS SEM IV |
| **Roll No/Seat No** | 54 / BSCS-IV-2526/6125 |
| **Field project Title** | PhishShield |
| **Name of the Faculty mentor** | Mrs. Priti Chopade |
| **Overview (Max 150 Words)** | The survey highlights existing phishing detection systems like Google Safe Browsing and static blacklists, noting their strengths but also limitations such as indexing latency, lack of quishing/QR analysis, and missing cross-platform client integration. To overcome these gaps, PhishShield adopts a technology stack consisting of Python with FastAPI, Chrome Manifest V3, Flutter/Dart, pyzbar vision parsing, and MongoDB. These technologies together provide structured design, interactive features, efficient backend logic, and reliable data storage. A comparative study of alternatives like Flask, Django, React Native, and MySQL further justifies the chosen stack for its simplicity, performance, and suitability. |
| **Learning Outcomes (Max 100 words)** | • Understand the strengths and limitations of existing phishing security tools.<br>• Learn the role of FastAPI, Chrome MV3, Flutter, pyzbar, and MongoDB in building a cybersecurity ecosystem.<br>• Compare different technologies (FastAPI vs Flask/Django, Flutter vs React Native, NoSQL vs SQL) to select the most suitable stack.<br>• Gain insight into designing scalable, interactive, and data-driven threat analysis platforms.<br>• Apply chosen technologies effectively to implement PhishShield's edge clients and core backend. |

**Mentor Feedback and Suggestions (Max 100 words):**  
Chapter 2 is completed and it’s fine  

Student Sign with date &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Mentor's Signature with date  

---

<br>

# CHAPTER 3

# REQUIREMENT AND ANALYSIS

### 3.1 PROBLEM DEFINITION

The process of navigating the modern web safely is increasingly hindered by sophisticated cyber threats, social engineering attacks, and credential harvesting schemes. Conventional security solutions like static domain blacklists or periodic browser database updates often fail to provide instant, real-time protection against newly registered zero-day phishing domains and physical vector threats like Quishing. This creates significant vulnerabilities for both individual users and organizational networks. Some of the key issues include:

- **Zero-Day Phishing Domain Latency**: Traditional blacklists suffer from update delays, allowing brand-new phishing sites to harvest user credentials before being reported and indexed.
- **Rise of QR Code Attacks ("Quishing")**: Physical QR codes on posters, menus, or payment terminals can hide malicious links that bypass desktop email filters and target unsuspecting mobile device users.
- **Deceptive Brand Spoofing & Typosquatting**: Attackers use visually similar domains (e.g., `paypa1.com` instead of `paypal.com`) and high character entropy to trick users into submitting sensitive credentials.
- **URL Shortener Concealment**: Abusive use of shortener services (`bit.ly`, `tinyurl`) hides the ultimate destination URL, preventing users from seeing the true target before clicking.
- **Lack of Unified Cross-Platform Protection**: Users switch constantly between desktop browser tabs and mobile devices, requiring a centralized inspection engine with dedicated edge clients for both platforms.
- **Unclear Threat Visibility**: Most security tools output simple binary blocks without exposing diagnostic metrics (heuristics score, brand spoofing probability, QR target structure), reducing security awareness for users.

To address these challenges, **PhishShield** has been conceptualized as a multi-source phishing detection ecosystem that automates threat evaluation and provides a flexible, engaging, and scalable security environment. It enables instant URL parsing, brand string distance checks, vision-based QR extraction, background tab monitoring, and responsive client notifications. By integrating heuristics, NLP analysis, and asynchronous telemetry logging, PhishShield bridges the gap between static blacklist filters and modern dynamic digital defense solutions.

---

### 3.2 REQUIREMENT SPECIFICATION

#### Functional Requirements

1. **Multi-Source Link Inspection**:
   - The system shall accept scan requests originating from active browser tabs (Chrome MV3), manual link input fields, and decoded QR code image streams.
   - The system shall automatically resolve short URLs (`bit.ly`, `tinyurl`) to extract and evaluate the final target destination URL.

2. **Heuristic Detection Engine**:
   - The system shall compute domain entropy, inspect Top-Level Domain (TLD) risk coefficients, and detect suspicious IP address domain masks.
   - The system shall verify subdomain depth and identify abnormal special character combinations within URL strings.

3. **NLP Brand-Spoofing & Content Analysis**:
   - The system shall compare incoming domain strings against target brand databases using string distance algorithms (e.g., Levenshtein distance) to detect typosquatting.
   - The system shall inspect URL path components for social engineering urgency keywords (e.g., `verify-account`, `login-update`, `banking-secure`).

4. **Vision & QR Code (Quishing) Processing**:
   - The system shall accept Base64-encoded image payloads uploaded by users or captured via the mobile device camera.
   - The system shall utilize `pyzbar` to locate, crop, and decode embedded QR code URLs, immediately forwarding resolved links to the core threat engine.

5. **Normalized Verdict & Scoring Engine**:
   - The system shall aggregate results from heuristic, NLP, and vision modules into a unified confidence score ranging from 0.0 to 1.0.
   - The system shall classify input targets into discrete threat verdicts: `SAFE`, `SUSPICIOUS`, or `MALICIOUS`.

6. **PC Edge (Chrome Extension MV3) Operations**:
   - The extension shall display current active tab threat verdicts in a glassmorphic popup UI.
   - The extension shall inject full-screen malicious site warning block pages when navigating to confirmed threat domains, offering bypass and safety options.

7. **Mobile Edge (Flutter Client) Operations**:
   - The mobile application shall provide real-time camera QR scanning functionality using `mobile_scanner`.
   - The mobile app shall support configurable interface theme profiles (Cyberpunk, OLED Dark, Enterprise).

8. **Telemetry & Log Management**:
   - The system shall asynchronously record scan logs, threat classifications, client platform tags, and timestamp metrics into a MongoDB collection.
   - The system shall enable querying of historical scan telemetry for diagnostic review.

---

#### Non-Functional Requirements

- **Performance & Response Time**: The core backend API shall evaluate incoming scan requests and generate a normalized threat verdict within 500 milliseconds under standard load.
- **Scalability**: The backend system built with FastAPI asynchronous request loops shall handle concurrent scanning requests from thousands of connected edge clients without performance degradation.
- **Reliability & Availability**: The core API service shall maintain 99.9% uptime, returning structured fallback verdicts if individual external sub-services fail.
- **Security & Data Privacy**: All client-server communication shall be conducted over HTTPS/TLS. Scan payloads shall contain no personally identifiable user browsing history beyond the submitted URL target.
- **Cross-Platform Usability**: The Chrome extension shall function seamlessly across Windows, macOS, and Linux browser instances, while the Flutter app shall adapt responsively to varying mobile screen sizes.

---

### 3.3 PLANNING AND SCHEDULING

Every project requires proper planning and scheduling to ensure timely completion and avoid unnecessary delays. Without a structured timeline, projects may get extended indefinitely, leading to inefficiency and loss of productivity. To overcome this challenge, it is important to establish a clear schedule for each phase of the project.

One of the most effective tools for project scheduling is a **Gantt chart**. A Gantt chart provides a visual representation of tasks, their durations, and dependencies, helping project managers and developers track progress effectively. It also ensures that deadlines are met and resources are properly allocated.

In the case of the **PhishShield** project, the development process has been divided into specific task phases such as environment boilerplate setup, FastAPI core engine development, Flutter mobile client implementation, Chrome MV3 extension creation, and MongoDB telemetry integration. Each task is assigned a timeline to ensure systematic progress.

#### Project Task Phase Summary

```
Phase 1: Environment Setup & Project Boilerplate         [Weeks 1 - 2]
Phase 2: FastAPI Core Engine & Detection Pipelines       [Weeks 3 - 5]
Phase 3: Flutter Mobile Edge UI & API Integration         [Weeks 6 - 8]
Phase 4: Chrome MV3 PC Extension UI & Tab Scanning       [Weeks 9 - 10]
Phase 5: MongoDB Logging & Integration Testing          [Weeks 11 - 12]
```

---

### 3.4 SOFTWARE AND HARDWARE REQUIREMENTS

#### Software Requirements:
- **Backend Core**: Python 3.10+, FastAPI, Uvicorn, Pydantic v2
- **Computer Vision / Libraries**: Pillow, `pyzbar`, `requests`
- **Database Engine**: MongoDB Server 6.0+, `motor` async driver
- **PC Extension**: Chrome Manifest V3, HTML5, Vanilla CSS3, Modern ES6 JavaScript
- **Mobile Client**: Flutter SDK 3.x, Dart 3.x, `mobile_scanner`, `http` package
- **Code Editor / IDE**: Visual Studio Code, PyCharm, Android Studio
- **Web Browser**: Google Chrome (Developer Mode enabled)

#### Hardware Requirements:
- **RAM**: 8 GB minimum, 16 GB recommended
- **Processor**: Intel Core i5 8th Gen / AMD Ryzen 5 or above (Apple M1/M2 supported)
- **Storage**: 10 GB available SSD storage space
- **Operating System**: Windows 10/11, macOS, or Ubuntu Linux (64-bit)
- **Mobile Hardware**: Android / iOS test device or Emulator with virtual camera support
- **Network**: Internet connection required for online TLD checks and package dependencies

---

### 3.5 CONCEPTUAL MODEL

#### Figure 3.5.1: Conceptual Architecture & Data Model

```
+-----------------------------------------------------------------------+
|                               PHISHSHIELD                             |
|                        Multi-Source Detection Engine                  |
+-----------------------------------------------------------------------+
                                   |
         +-------------------------+-------------------------+
         |                                                   |
         v                                                   v
+------------------+                               +------------------+
|    PC EDGE       |                               |   MOBILE EDGE    |
| (Chrome Extension|                               |  (Flutter App)   |
|   Manifest V3)   |                               |                  |
+------------------+                               +------------------+
| - Active Tab URL |                               | - QR Camera Scan |
| - Glass Popup UI |                               | - Manual Input   |
| - Block Warnings |                               | - Multi-Themes   |
+------------------+                               +------------------+
         |                                                   |
         +-------------------------+-------------------------+
                                   |
                                   v
              +-----------------------------------------+
              |           FASTAPI BACKEND CORE          |
              |       (Asynchronous Scan Endpoint)      |
              +-----------------------------------------+
                                   |
         +-------------------------+-------------------------+
         |                         |                         |
         v                         v                         v
+------------------+     +-------------------+     +-------------------+
| HEURISTICS ENGINE|     |    NLP ENGINE     |     |   VISION ENGINE   |
+------------------+     +-------------------+     +-------------------+
| - Domain Entropy |     | - Brand Distance  |     | - Base64 Decoding |
| - TLD Danger Index|    | - Typosquatting   |     | - pyzbar QR Parse |
| - Subdomain Depth|     | - Urgency Keywords|     | - Shortener Trace |
+------------------+     +-------------------+     +-------------------+
         |                         |                         |
         +-------------------------+-------------------------+
                                   |
                                   v
              +-----------------------------------------+
              |           THREAT VERDICT EVAL           |
              |     (SAFE / SUSPICIOUS / MALICIOUS)     |
              +-----------------------------------------+
                                   |
                                   v
              +-----------------------------------------+
              |        MONGODB TELEMETRY STORAGE        |
              |     (Async Log Caching & Statistics)    |
              +-----------------------------------------+
```

---

<br>

### Periodic Field Project Report (Chapter 3 Phase)

| Field | Details |
|---|---|
| **Name of the Student** | Parth Vikas More |
| **Program /Semester** | BSC CS SEM IV |
| **Roll No/Seat No** | 54 / BSCS-IV-2526/6125 |
| **Field project Title** | PhishShield |
| **Name of the Faculty mentor** | Mrs. Priti Chopade |
| **Overview (Max 150 Words)** | The Requirement Analysis of PhishShield identifies key problems in traditional phishing detection systems such as zero-day indexing latency, quishing vulnerabilities, typosquatting brand deception, and lack of cross-platform integration. To address these, PhishShield is designed with functional requirements like multi-source link inspection, domain heuristic checks, brand NLP string analysis, QR vision parsing, and Chrome/Flutter edge interface deployment. Non-functional requirements emphasize fast 500ms response times, high async scalability, reliability, and security. A clear development plan ensures timely progress, supported by software (FastAPI, Flutter, Chrome MV3, pyzbar, MongoDB) and hardware specifications. |
| **Learning Outcomes (Max 100 words)** | • Understand the limitations of traditional static domain blacklists and phishing security tools.<br>• Learn how to define functional and non-functional requirements for a multi-platform security engine.<br>• Gain knowledge of project planning and scheduling through task roadmap phases.<br>• Identify appropriate software and hardware requirements for developing scalable threat inspection systems.<br>• Apply requirement analysis to design secure, efficient, and user-friendly cybersecurity platforms. |

**Mentor Feedback and Suggestions (Max 100 words):**  
Chapter 3 is completed and it’s fine  

Student Sign with date &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Mentor's Signature with date  
