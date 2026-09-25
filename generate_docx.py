import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

def set_cell_border(cell, **kwargs):
    """
    Set cell borders
    kwargs: top, bottom, left, right
    values: dict(sz=12, val='single', color='FF0000', space='0')
    """
    tcPr = cell._tc.get_or_add_tcPr()
    tcBorders = tcPr.first_child_found_in("w:tcBorders")
    if tcBorders is None:
        tcBorders = OxmlElement('w:tcBorders')
        tcPr.append(tcBorders)
    for edge in ('top', 'left', 'bottom', 'right', 'insideH', 'insideV'):
        edge_data = kwargs.get(edge)
        if edge_data:
            tag = 'w:{}'.format(edge)
            element = tcBorders.find(qn(tag))
            if element is None:
                element = OxmlElement(tag)
                tcBorders.append(element)
            for key, attr in [('val', 'w:val'), ('color', 'w:color'), ('sz', 'w:sz'), ('space', 'w:space')]:
                if key in edge_data:
                    element.set(qn(attr), str(edge_data[key]))

def set_cell_background(cell, color_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), color_hex)
    tcPr.append(shd)

def create_report_docx(filename):
    doc = docx.Document()
    
    # Page Margins
    for section in doc.sections:
        section.top_margin = Inches(1)
        section.bottom_margin = Inches(1)
        section.left_margin = Inches(1)
        section.right_margin = Inches(1)

    # Style definitions
    style_normal = doc.styles['Normal']
    font = style_normal.font
    font.name = 'Times New Roman'
    font.size = Pt(12)
    font.color.rgb = RGBColor(0, 0, 0)

    # Helper function for adding paragraphs
    def add_p(text="", align=WD_ALIGN_PARAGRAPH.LEFT, bold=False, italic=False, size=12, space_before=0, space_after=6, line_spacing=1.15, color=(0,0,0)):
        p = doc.add_paragraph()
        p.alignment = align
        p.paragraph_format.space_before = Pt(space_before)
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.line_spacing = line_spacing
        if text:
            run = p.add_run(text)
            run.bold = bold
            run.italic = italic
            run.font.size = Pt(size)
            run.font.name = 'Times New Roman'
            run.font.color.rgb = RGBColor(*color)
        return p

    def add_heading_1(text):
        p = add_p(text, align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=18, space_before=18, space_after=12, color=(44, 62, 80))
        return p

    def add_heading_2(text):
        p = add_p(text, align=WD_ALIGN_PARAGRAPH.LEFT, bold=True, size=14, space_before=14, space_after=6, color=(44, 62, 80))
        return p

    def add_heading_3(text):
        p = add_p(text, align=WD_ALIGN_PARAGRAPH.LEFT, bold=True, size=12, space_before=10, space_after=4, color=(52, 73, 94))
        return p

    # --- COVER PAGE ---
    add_p("PHISHSHIELD", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=24, space_before=36, space_after=12)
    add_p("A Field Project Report", align=WD_ALIGN_PARAGRAPH.CENTER, size=14, space_after=18)
    add_p("BACHELOR OF SCIENCE (COMPUTER SCIENCE)", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=14, space_after=24)
    
    add_p("By", align=WD_ALIGN_PARAGRAPH.CENTER, size=12, space_after=6)
    add_p("Mr. Hardik Prakash Kotawdekar", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=13, space_after=2)
    add_p("BSCS / IV-2526/6125", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=12, space_after=24)

    add_p("Under the esteemed guidance of", align=WD_ALIGN_PARAGRAPH.CENTER, size=12, space_after=6)
    add_p("Mrs. Bindy Wilson", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=13, space_after=2)
    add_p("Assistant Professor", align=WD_ALIGN_PARAGRAPH.CENTER, size=12, space_after=36)

    add_p("DEPARTMENT OF INFORMATION TECHNOLOGY & COMPUTER SCIENCE", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=12, space_after=18)
    add_p("KERALEEYA SAMAJAM (REGD.) DOMBIVLI'S", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=12, space_after=2)
    add_p("MODEL COLLEGE (EMPOWERED AUTONOMOUS)", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=12, space_after=2)
    add_p("(Affiliated to University of Mumbai)", align=WD_ALIGN_PARAGRAPH.CENTER, italic=True, size=11, space_after=18)
    add_p("DOMBIVLI, 421201 MAHARASHTRA", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=11, space_after=24)
    add_p("MARCH 2026", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=12, space_after=0)

    doc.add_page_break()

    # --- CERTIFICATE PAGE 1 ---
    add_p("KERALEEYA SAMAJAM (REGD.) DOMBIVLI'S", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=12)
    add_p("MODEL COLLEGE (EMPOWERED AUTONOMOUS)", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=12)
    add_p("(Affiliated to University of Mumbai)", align=WD_ALIGN_PARAGRAPH.CENTER, italic=True, size=11)
    add_p("DOMBIVLI- MAHARASHTRA-421201", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=11, space_after=12)
    add_p("DEPARTMENT OF INFORMATION TECHNOLOGY & COMPUTER SCIENCE", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=12, space_after=24)
    
    add_p("CERTIFICATE", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=16, space_after=18)
    
    p = add_p(align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=48, line_spacing=1.5)
    p.add_run("This is to certify that the project entitled, ")
    r = p.add_run("“PhishShield”")
    r.bold = True
    p.add_run(", is bonafied work of ")
    r = p.add_run("Mr. Hardik Prakash Kotawdekar")
    r.bold = True
    p.add_run(" bearing Seat No: ")
    r = p.add_run("BSCS/IV-2526/6125")
    r.bold = True
    p.add_run(" submitted in partial fulfilment of the requirements for the award of degree of ")
    r = p.add_run("BACHELOR OF SCIENCE in COMPUTER SCIENCE")
    r.bold = True
    p.add_run(" from Keraleeya Samajam (Regd.) Dombivli’s Model College.")

    # Signatures
    table_sig = doc.add_table(rows=2, cols=2)
    table_sig.alignment = WD_TABLE_ALIGNMENT.CENTER
    table_sig.autofit = False
    
    cell_l1 = table_sig.cell(0, 0)
    cell_r1 = table_sig.cell(0, 1)
    cell_l2 = table_sig.cell(1, 0)
    cell_r2 = table_sig.cell(1, 1)
    
    cell_l1.paragraphs[0].text = "Internal Guide\n\n\nExternal Examiner"
    cell_r1.paragraphs[0].text = "Coordinator\n\n\n"
    cell_l2.paragraphs[0].text = "Date: _____________"
    cell_r2.paragraphs[0].text = "College Seal"

    doc.add_page_break()

    # --- CERTIFICATE PAGE 2 (GROUP) ---
    add_p("Keraleeya Samajam (Regd.) Dombivli’s", align=WD_ALIGN_PARAGRAPH.CENTER, italic=True, size=11)
    add_p("MODEL COLLEGE (Empowered Autonomous)", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=13)
    add_p("(Affiliated to University of Mumbai)", align=WD_ALIGN_PARAGRAPH.CENTER, italic=True, size=11)
    add_p("Re-Accredited Grade “A” by NAAC", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=11, space_after=18)
    
    add_p("CERTIFICATE", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=16, space_after=14)

    p = add_p(align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=14, line_spacing=1.3)
    p.add_run("This is to certify that the following students of the ")
    p.add_run("B.Sc. Computer Science Program").bold = True
    p.add_run(", studying in ")
    p.add_run("Semester IV").bold = True
    p.add_run(" have successfully completed a group project titled: ")
    p.add_run("“PhishShield”").bold = True
    p.add_run(" in the area of ")
    p.add_run("Cybersecurity & Full-Stack Development").bold = True
    p.add_run(" specialization, during the academic year ")
    p.add_run("2025-2026").bold = True
    p.add_run(". The students listed below have contributed to this project work and to the best of our knowledge, the work is original and all information provided is accurate and relevant.")

    add_p("List of Group members", align=WD_ALIGN_PARAGRAPH.LEFT, bold=True, size=12, space_after=6)

    # Members Table
    table_m = doc.add_table(rows=11, cols=3)
    table_m.alignment = WD_TABLE_ALIGNMENT.CENTER
    headers = ["Sr. No", "Name", "Roll/Seat No"]
    data_members = [
        ("1", "Hardik Prakash Kotawdekar", "54 / BSCS-IV-2526-6125"),
        ("2", "Parth Vikas More", "74 / BSCS-IV-2526/6145"),
        ("3", "Pratik Ashwini Pandey", "88 / BSCS-IV-2526-6159"),
        ("4", "Atharva Vinayak Dound", "25 / BSCS-IV-2526-6096"),
        ("5", "Atharva Mahesh Dingorkar", "22 / BSCS-IV-2526-6093"),
        ("6", "", ""), ("7", "", ""), ("8", "", ""), ("9", "", ""), ("10", "", "")
    ]
    for i, h in enumerate(headers):
        cell = table_m.cell(0, i)
        cell.paragraphs[0].text = h
        cell.paragraphs[0].runs[0].bold = True
        set_cell_background(cell, "EAEAEA")
    for row_idx, data in enumerate(data_members, start=1):
        for col_idx, val in enumerate(data):
            table_m.cell(row_idx, col_idx).paragraphs[0].text = val

    # Style table borders
    for row in table_m.rows:
        for cell in row.cells:
            set_cell_border(cell, top={'sz':4, 'val':'single', 'color':'CCCCCC'},
                                  bottom={'sz':4, 'val':'single', 'color':'CCCCCC'},
                                  left={'sz':4, 'val':'single', 'color':'CCCCCC'},
                                  right={'sz':4, 'val':'single', 'color':'CCCCCC'})

    add_p("", space_after=24)
    t_sig2 = doc.add_table(rows=1, cols=2)
    t_sig2.alignment = WD_TABLE_ALIGNMENT.CENTER
    t_sig2.cell(0,0).paragraphs[0].text = "Internal Guide"
    t_sig2.cell(0,1).paragraphs[0].text = "Head of the Dept/Principal"
    t_sig2.cell(0,1).paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.RIGHT

    doc.add_page_break()

    # --- ABSTRACT ---
    add_heading_1("ABSTRACT")
    add_p("PhishShield is an advanced, multi-source phishing detection ecosystem designed to detect and block malicious links across web browsers, mobile applications, and QR code vectors in real-time. The system addresses the increasing sophistication of cyber threats, social engineering attacks, and credential harvesting schemes by combining quick heuristic filtering, Natural Language Processing (NLP) brand-spoofing check pipelines, and computer vision for QR code parsing (Quishing analysis).", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=12)
    add_p("Developed using Python and FastAPI for the high-performance asynchronous backend, the core engine processes threat evaluation requests with low latency. Data validation is enforced using Pydantic, while computer vision tasks leverage Pillow and pyzbar. The user-facing clients include a Google Chrome Manifest V3 extension built with HTML5, CSS3, and JavaScript for desktop edge protection, and a mobile client built with Flutter and Dart providing cross-platform security telemetry. MongoDB serves as the NoSQL database for caching logs, threat telemetry, and scan statistics.", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=12)
    add_p("Key features of PhishShield include real-time link scanning, domain age and TLD risk heuristics, brand spoofing string comparison using string distance metrics, automated QR code extraction, short-URL expansion, and malicious site warning block pages. The system also features role-based telemetry management and configurable desktop/mobile interface profiles.", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=12)
    add_p("PhishShield is a scalable platform tailored for cybersecurity awareness and proactive digital defense. It supports educational, personal, and enterprise environments by delivering a robust, automated ecosystem for real-time phishing detection and continuous threat assessment.", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=24)

    doc.add_page_break()

    # --- ACKNOWLEDGEMENT ---
    add_heading_1("ACKNOWLEDGEMENT")
    add_p("It gives us a pleasure to present our project on “PhishShield”. This is our milestone in Bachelor of Science (Computer Science). We would like to express our sincere thanks to all the teachers who helped us throughout the project. We would like to acknowledge the help and guidance provided by Mrs. Bindy Wilson, Assistant Professor in all places during the presentation of this project.", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=12)
    add_p("We are thankful to our honorable Principal Dr. CA Ravindra P Bambardekar towards our project works. We are also thankful to the staff members of the IT-CS department for their moral support. We extend our gratitude to Dr. Divya Premachandran, In-charge of IT & CS Department for her support and guidance.", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=24)

    doc.add_page_break()

    # --- DECLARATION ---
    add_heading_1("DECLARATION")
    add_p("We hereby declare that the project entitled, “PhishShield” done at Keraleeya Samajam (Regd.) Dombivli’s Model College (Autonomous), has not been in any case duplicated to submit to any other university for the award of any degree. To the best of our knowledge other than us, no one has submitted to any other university.", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=12)
    add_p("The project is done in partial fulfilment of the requirements for the award of degree of BACHELOR OF SCIENCE (COMPUTER SCIENCE) to be submitted as a IV semester project as part of our curriculum.", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=36)

    add_p("Hardik Prakash Kotawdekar", align=WD_ALIGN_PARAGRAPH.RIGHT, bold=True)
    add_p("Name of Student", align=WD_ALIGN_PARAGRAPH.RIGHT)
    add_p("Sign", align=WD_ALIGN_PARAGRAPH.RIGHT, space_after=24)

    doc.add_page_break()

    # --- TABLE OF CONTENTS ---
    add_heading_1("TABLE OF CONTENTS")
    t_toc = doc.add_table(rows=16, cols=3)
    t_toc.alignment = WD_TABLE_ALIGNMENT.CENTER
    toc_data = [
        ("Sr. No.", "Title", "Page no"),
        ("Chapter 1", "Introduction", "13-14"),
        ("1.1", "Objective", "13"),
        ("1.2", "Purpose, Scope and Applicability", "13"),
        ("1.2.1", "Purpose", "13"),
        ("1.2.2", "Scope", "14"),
        ("1.2.3", "Applicability", "14"),
        ("", "", ""),
        ("Chapter 2", "Survey of technologies", "17-20"),
        ("2.1", "Existing System", "17"),
        ("2.2", "List of Technologies", "17-18"),
        ("2.3", "Comparative Study", "19"),
        ("2.4", "Selected Technologies", "20"),
        ("", "", ""),
        ("Chapter 3", "Requirement and Analysis", "23-27"),
        ("3.1", "Problem Definition", "23")
    ]
    for r_idx, row in enumerate(toc_data):
        for c_idx, val in enumerate(row):
            cell = t_toc.cell(r_idx, c_idx)
            cell.paragraphs[0].text = val
            if r_idx == 0 or val.startswith("Chapter"):
                cell.paragraphs[0].runs[0].bold = True
                if r_idx == 0:
                    set_cell_background(cell, "EAEAEA")

    for row in t_toc.rows:
        for cell in row.cells:
            set_cell_border(cell, top={'sz':4, 'val':'single', 'color':'CCCCCC'},
                                  bottom={'sz':4, 'val':'single', 'color':'CCCCCC'},
                                  left={'sz':4, 'val':'single', 'color':'CCCCCC'},
                                  right={'sz':4, 'val':'single', 'color':'CCCCCC'})

    doc.add_page_break()

    # --- LIST OF TABLES & FIGURES ---
    add_heading_1("List of Tables")
    t_lot = doc.add_table(rows=4, cols=3)
    t_lot.alignment = WD_TABLE_ALIGNMENT.CENTER
    lot_data = [
        ("Sr. No.", "Name of Table", "Page No"),
        ("Chapter 1", "Applicability", "14"),
        ("1.2.3.1", "Different Scope in Applicability", "14"),
        ("Chapter 2", "Survey of Technologies", "17-20")
    ]
    for r_idx, row in enumerate(lot_data):
        for c_idx, val in enumerate(row):
            cell = t_lot.cell(r_idx, c_idx)
            cell.paragraphs[0].text = val
            if r_idx == 0 or val.startswith("Chapter"):
                cell.paragraphs[0].runs[0].bold = True

    add_p("", space_after=18)
    add_heading_1("List of Figures")
    t_lof = doc.add_table(rows=2, cols=3)
    t_lof.alignment = WD_TABLE_ALIGNMENT.CENTER
    lof_data = [
        ("Sr. No.", "Name of Figures", "Page No"),
        ("3.5.1", "Conceptual Model", "27")
    ]
    for r_idx, row in enumerate(lof_data):
        for c_idx, val in enumerate(row):
            cell = t_lof.cell(r_idx, c_idx)
            cell.paragraphs[0].text = val
            if r_idx == 0:
                cell.paragraphs[0].runs[0].bold = True

    doc.add_page_break()

    # --- PERIODIC FIELD REPORT BOX (ABSTRACT) ---
    add_heading_1("Periodic Field Project Report")
    t_p1 = doc.add_table(rows=8, cols=2)
    t_p1.alignment = WD_TABLE_ALIGNMENT.CENTER
    p1_data = [
        ("Name of the Student", "Hardik Prakash Kotawdekar"),
        ("Program /Semester", "BSC CS SEM IV"),
        ("Roll No/Seat No", "54 / BSCS-IV-2526/6125"),
        ("Field project Title", "PhishShield"),
        ("Name of the Faculty mentor", "Mrs. Bindy Wilson"),
        ("Overview (Max 150 Words)\n(Brief summary of key activities)", "The PhishShield Project is a multi-source phishing detection system featuring browser extensions, mobile apps, and backend threat detection modules. The platform is designed to be user-friendly, responsive, and scalable. In this system, users can analyze links, QR codes, and suspicious domain patterns in real-time."),
        ("Learning Outcomes (Max 100 words)\n(Highlight main lessons)", "PhishShield is a multi-source phishing detection platform offering link heuristics, brand-spoofing NLP, and quishing analysis designed for security awareness and real-time defense, with high scalability and cross-platform adaptability."),
        ("Mentor Feedback and Suggestions (Max 100 words)", "Abstract is completed and it’s fine")
    ]
    for r_idx, (k, v) in enumerate(p1_data):
        t_p1.cell(r_idx, 0).paragraphs[0].text = k
        t_p1.cell(r_idx, 0).paragraphs[0].runs[0].bold = True
        t_p1.cell(r_idx, 1).paragraphs[0].text = v

    for row in t_p1.rows:
        for cell in row.cells:
            set_cell_border(cell, top={'sz':4, 'val':'single', 'color':'888888'},
                                  bottom={'sz':4, 'val':'single', 'color':'888888'},
                                  left={'sz':4, 'val':'single', 'color':'888888'},
                                  right={'sz':4, 'val':'single', 'color':'888888'})

    add_p("", space_after=18)
    t_s = doc.add_table(rows=1, cols=2)
    t_s.cell(0,0).paragraphs[0].text = "Student Sign with date"
    t_s.cell(0,1).paragraphs[0].text = "Mentor's Signature with date"
    t_s.cell(0,1).paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.RIGHT

    doc.add_page_break()

    # --- CHAPTER 1 ---
    add_heading_1("CHAPTER 1\nINTRODUCTION")
    
    add_heading_2("1.1 Objective:")
    add_p("The primary objective of Quizverse / PhishShield is to design and implement a dynamic, user-friendly, and scalable multi-source phishing detection ecosystem that caters to a diverse range of users and use cases across desktop and mobile platforms. The system aims to deliver an engaging digital experience through intuitive interfaces and reliable backend threat inspection services. Specific objectives include:", align=WD_ALIGN_PARAGRAPH.JUSTIFY)
    
    bullets_ch1 = [
        "To implement critical threat scanning features such as domain heuristic evaluation, TLD risk indexing, and automated URL shortener expansion to detect deceptive links in real-time.",
        "To detect brand spoofing and social engineering attempts through Natural Language Processing (NLP) pipelines, evaluating string entropy and brand name variations.",
        "To perform computer vision-based QR code parsing and 'Quishing' analysis to intercept malicious links embedded within physical or digital images.",
        "To empower desktop users through a Chrome Manifest V3 extension featuring active tab analysis and full-screen malicious site warning blocks.",
        "To provide mobile users with a cross-platform Flutter application featuring customizable theme profiles, live QR scanning, and telemetry history tracking.",
        "To maintain an asynchronous telemetry logging system using MongoDB to cache scan verdicts, threat metrics, and analytical statistics efficiently."
    ]
    for b in bullets_ch1:
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.line_spacing = 1.15
        p.add_run(b)

    add_heading_2("1.2 Purpose, Scope & Applicability:")
    add_heading_3("1.2.1 Purpose")
    add_p("The purpose behind developing PhishShield stems from the growing need for immersive, adaptable, and technology-enabled platforms that support digital security, fraud prevention, and real-time threat evaluation. It aims to bridge the gap between static traditional blacklist systems and modern expectations of multi-vector threat detection, data-driven feedback, and ease of edge deployment across devices. PhishShield strives to be:", align=WD_ALIGN_PARAGRAPH.JUSTIFY)
    
    bullets_purp = [
        "A platform for digital security awareness, combining automated threat analysis and clear visual feedback into one engaging interface.",
        "A tool for individual users, educators, and organizations, allowing structured link assessment and insight into malicious web vectors.",
        "A scalable base for future integrations such as AI-driven phishing page screenshot classification, threat intelligence sharing APIs, and automated threat reporting modules."
    ]
    for b in bullets_purp:
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.line_spacing = 1.15
        p.add_run(b)

    add_heading_3("1.2.2 Scope")
    add_p("PhishShield encompasses the development of a scalable, user-friendly, and interactive phishing detection platform that can cater to both individual web users and corporate environments. The system is designed to handle multiple input vectors, including active browser tab URLs, manually submitted links, and decoded QR images, ensuring flexibility in usage. It enables instant threat classification, efficient threat telemetry logging, and responsive access across desktop and mobile form factors. While the current implementation focuses on core heuristic checks, brand-spoofing NLP parsing, and QR image decoding, the architecture is modular, allowing for seamless integration of advanced features such as deep neural network visual similarity checking and sandboxing in future iterations. The project is adaptable for deployment in home browsing, academic institutions, and corporate network edge extensions.", align=WD_ALIGN_PARAGRAPH.JUSTIFY)

    add_heading_3("1.2.3 Applicability")
    add_p("PhishShield is designed to serve a broad spectrum of user groups and institutional contexts. Its modular design and customizable functionality make it adaptable across multiple domains:", align=WD_ALIGN_PARAGRAPH.JUSTIFY)

    # Table 1.2.3.1
    t_app = doc.add_table(rows=7, cols=2)
    t_app.alignment = WD_TABLE_ALIGNMENT.CENTER
    app_data = [
        ("User Type", "Use Case Example"),
        ("Students & Individuals", "Checking suspicious email links, short URLs, and social media links before opening them"),
        ("Mobile App Users", "Scanning physical QR codes (menus, flyers, payment posters) to prevent Quishing attacks"),
        ("Desktop Web Browsers", "Real-time background checking of active browser tabs via Chrome Extension MV3"),
        ("IT & Security Admins", "Inspecting threat telemetry logs and analyzing attack trends targeting specific brands"),
        ("Organizations & Enterprises", "Protecting non-technical personnel from clicking social engineering and credential harvesting links"),
        ("EdTech & Cyber Training", "Demonstrating how domain heuristics and brand spoofing tactics work in real-time")
    ]
    for r_i, (u, c) in enumerate(app_data):
        t_app.cell(r_i, 0).paragraphs[0].text = u
        t_app.cell(r_i, 1).paragraphs[0].text = c
        if r_i == 0:
            t_app.cell(r_i, 0).paragraphs[0].runs[0].bold = True
            t_app.cell(r_i, 1).paragraphs[0].runs[0].bold = True
            set_cell_background(t_app.cell(r_i, 0), "EAEAEA")
            set_cell_background(t_app.cell(r_i, 1), "EAEAEA")

    for row in t_app.rows:
        for cell in row.cells:
            set_cell_border(cell, top={'sz':4, 'val':'single', 'color':'888888'},
                                  bottom={'sz':4, 'val':'single', 'color':'888888'},
                                  left={'sz':4, 'val':'single', 'color':'888888'},
                                  right={'sz':4, 'val':'single', 'color':'888888'})

    add_p("Table 1.2.3.1: Different Scope in Applicability", align=WD_ALIGN_PARAGRAPH.CENTER, italic=True, size=10, space_before=4, space_after=18)

    # Periodic Report Chapter 1
    t_p1c = doc.add_table(rows=8, cols=2)
    t_p1c.alignment = WD_TABLE_ALIGNMENT.CENTER
    p1c_data = [
        ("Name of the Student", "Hardik Prakash Kotawdekar"),
        ("Program /Semester", "BSC CS SEM IV"),
        ("Roll No/Seat No", "54 / BSCS-IV-2526/6125"),
        ("Field project Title", "PhishShield"),
        ("Name of the Faculty mentor", "Mrs. Bindy Wilson"),
        ("Overview (Max 150 Words)", "PhishShield is an interactive and scalable online phishing detection platform designed to make browsing secure and transparent. It provides features like heuristic domain checks, NLP brand analysis, QR parsing, and real-time threat verdicts. The platform supports educators, students, organizations, and security teams with easy telemetry management and real-time insights."),
        ("Learning Outcomes (Max 100 words)", "• Ability to design and develop a scalable online threat detection system.\n• Implement features like heuristics, NLP brand checking, and QR parsing.\n• Manage telemetry logs efficiently through database services.\n• Apply the platform across web extensions, mobile apps, and security contexts."),
        ("Mentor Feedback and Suggestions", "Change the Scope of this chapter. Chapter 1 is completed and its fine")
    ]
    for r_idx, (k, v) in enumerate(p1c_data):
        t_p1c.cell(r_idx, 0).paragraphs[0].text = k
        t_p1c.cell(r_idx, 0).paragraphs[0].runs[0].bold = True
        t_p1c.cell(r_idx, 1).paragraphs[0].text = v

    for row in t_p1c.rows:
        for cell in row.cells:
            set_cell_border(cell, top={'sz':4, 'val':'single', 'color':'888888'},
                                  bottom={'sz':4, 'val':'single', 'color':'888888'},
                                  left={'sz':4, 'val':'single', 'color':'888888'},
                                  right={'sz':4, 'val':'single', 'color':'888888'})

    doc.add_page_break()

    # --- CHAPTER 2 ---
    add_heading_1("CHAPTER 2\nSURVEY OF TECHNOLOGIES")
    add_heading_2("2.1 EXISTING SYSTEM")
    add_p("In the current digital security landscape, phishing protection relies heavily on centralized web blacklists, static browser built-in filters (such as Google Safe Browsing), and traditional desktop antivirus software. While effective against known malicious URLs, Google Safe Browsing often experiences a latency window when indexing newly registered zero-day phishing domains. VirusTotal provides multi-engine aggregation but requires manual URL submissions and lacks proactive edge protection during routine browsing. Specialized mobile security apps frequently suffer from intrusive ad displays or heavy resource overhead. Furthermore, most conventional security systems lack dedicated computer vision engines to intercept 'Quishing' (QR-code based phishing) or brand-spoofing NLP parsing at the client edge. Common limitations across existing solutions include static database dependencies, slow response times to zero-day domains, limited cross-platform integration between mobile and browser extensions, and low visibility for users into specific threat evaluation metrics.", align=WD_ALIGN_PARAGRAPH.JUSTIFY)

    add_heading_2("2.2 LIST OF TECHNOLOGIES")
    
    techs = [
        ("1. Python & FastAPI", "Python is a high-level, versatile programming language ideal for cybersecurity data processing. FastAPI is an ultra-fast, asynchronous Python web framework used to build the core REST API of PhishShield.", "Serves as the central threat inspection backend engine, receiving scan requests from clients, parsing domain properties, orchestrating heuristics, NLP, and vision modules, and returning normalized threat verdicts.", "Lightweight, native support for async execution (async/await), fast execution speeds via Uvicorn, automatic OpenAPI generation, and seamless integration."),
        ("2. Google Chrome Manifest V3", "Manifest V3 is the modern standard for Google Chrome extension development, emphasizing performance, privacy, and security boundaries.", "Powers the desktop edge extension, enabling background tab inspection, real-time popup interface alerts, and full-screen warning page blocks.", "Provides native access to Chrome Tabs and Web Request APIs, ensures high energy efficiency, and integrates clean glassmorphic HTML/CSS user interfaces."),
        ("3. Flutter & Dart", "Flutter is an open-source UI software development kit created by Google, allowing single-codebase cross-platform application development compiled natively to mobile environments.", "Builds the mobile edge application, featuring active QR code scanner integration, custom theme customization (Cyberpunk, OLED, Enterprise), and telemetry visualization.", "Exceptional rendering performance, rich ecosystem of native hardware integration packages (camera/QR scanning), and fluid UI responsiveness."),
        ("4. Computer Vision Libraries (Pillow & pyzbar)", "Pillow is Python's standard image processing library, while pyzbar enables decoding of 1D barcodes and QR codes from image streams.", "Parses Base64 image payloads sent from mobile devices or uploaded files, extracts encoded URL payloads from QR codes, and forwards resolved links to the heuristic engine.", "Highly accurate, fast decoding capability, operating independently without requiring heavy deep learning framework overhead."),
        ("5. MongoDB (NoSQL Database)", "MongoDB is a document-oriented, NoSQL database system designed for high volume, JSON-like flexible data storage and rapid document retrieval.", "Stores asynchronous threat logs, client scan telemetry, performance metrics, and cached scan verdicts using motor async drivers.", "Flexible dynamic schema fits evolving engine outputs, fast write operations, and effortless JSON document mapping.")
    ]

    for title, desc, role, why in techs:
        add_heading_3(title)
        add_p(desc, align=WD_ALIGN_PARAGRAPH.JUSTIFY)
        p1 = add_p(bold=False, align=WD_ALIGN_PARAGRAPH.JUSTIFY)
        p1.add_run("• Role in PhishShield: ").bold = True
        p1.add_run(role)
        p2 = add_p(bold=False, align=WD_ALIGN_PARAGRAPH.JUSTIFY)
        p2.add_run("• Why this technology? ").bold = True
        p2.add_run(why)

    add_heading_2("2.3 COMPARATIVE STUDY")
    t_comp = doc.add_table(rows=9, cols=5)
    t_comp.alignment = WD_TABLE_ALIGNMENT.CENTER
    comp_headers = ["Technology", "Type", "Purpose in PhishShield", "Strengths", "Limitations"]
    for i, h in enumerate(comp_headers):
        cell = t_comp.cell(0, i)
        cell.paragraphs[0].text = h
        cell.paragraphs[0].runs[0].bold = True
        set_cell_background(cell, "EAEAEA")

    comp_rows = [
        ("FastAPI (Python)", "Web Framework", "Backend logic: URL inspection, routing", "Async execution, auto OpenAPI docs", "Requires Python 3.10+ runtime"),
        ("Flask (Python)", "Web Framework", "Alternative backend engine option", "Simple syntax, easy setup", "Synchronous by default, manual async"),
        ("Django", "Full-Stack Framework", "Alternative full-stack web framework", "Built-in ORM, admin panel", "Overweight for API-only engines"),
        ("Chrome MV3", "Browser Extension", "PC Edge real-time tab monitoring", "Native browser access, zero latency", "Restrictive service worker lifecycle"),
        ("Flutter / Dart", "Mobile Framework", "Mobile client app for QR scanning", "Single codebase, native speed", "Larger app binary footprint"),
        ("React Native", "Mobile Framework", "Alternative mobile app framework", "Large ecosystem, JavaScript syntax", "Bridge overhead for camera frames"),
        ("MongoDB", "NoSQL Database", "Stores threat logs, scan telemetry", "Flexible schema, fast JSON mapping", "Higher memory usage than SQL"),
        ("MySQL", "Relational DB", "Alternative relational DB engine", "Strict schemas, ACID compliance", "Rigid schema migrations required")
    ]
    for r_idx, data in enumerate(comp_rows, start=1):
        for c_idx, val in enumerate(data):
            t_comp.cell(r_idx, c_idx).paragraphs[0].text = val

    for row in t_comp.rows:
        for cell in row.cells:
            set_cell_border(cell, top={'sz':4, 'val':'single', 'color':'888888'},
                                  bottom={'sz':4, 'val':'single', 'color':'888888'},
                                  left={'sz':4, 'val':'single', 'color':'888888'},
                                  right={'sz':4, 'val':'single', 'color':'888888'})

    add_p("Table 2.3.1: Comparative study between different technologies", align=WD_ALIGN_PARAGRAPH.CENTER, italic=True, size=10, space_before=4, space_after=14)

    add_heading_2("2.4 SELECTED TECHNOLOGIES")
    sel = [
        "1. Python 3.10+ & FastAPI – Used to build the core asynchronous engine, managing HTTP endpoint routing, heuristic rules evaluation, string analysis, and client payload validation.",
        "2. Google Chrome Manifest V3 – Selected for desktop edge protection, executing active tab hostname checks and rendering responsive glassmorphism popups.",
        "3. Flutter & Dart – Selected for mobile client development, enabling hardware camera access for real-time QR code extraction and dynamic client themes.",
        "4. Pillow & pyzbar – Chosen for lightweight image decoding and Quishing payload retrieval from uploaded or captured QR code images.",
        "5. MongoDB & Motor – Selected for asynchronous document storage to save telemetry logs, cache URL verdicts, and track engine statistics cleanly."
    ]
    for s in sel:
        add_p(s, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=4)

    doc.add_page_break()

    # --- CHAPTER 3 ---
    add_heading_1("CHAPTER 3\nREQUIREMENT ANALYSIS")
    add_heading_2("3.1 PROBLEM DEFINITION")
    add_p("The process of navigating the modern web safely is often hindered by inefficiencies and a lack of engaging tools for users. Conventional methods such as static domain blacklists or periodic browser updates do not provide real-time protection against zero-day phishing sites or physical threats like Quishing. This creates challenges for both individual users and security administrators. Some of the key issues include:", align=WD_ALIGN_PARAGRAPH.JUSTIFY)

    prob_bullets = [
        "Limited Accessibility & Real-Time Defense: Traditional blacklists suffer from update delays, allowing brand-new phishing sites to harvest user credentials before being reported.",
        "Rise of QR Code Attacks ('Quishing'): Physical QR codes on posters, menus, or payment terminals can hide malicious links that bypass desktop email filters.",
        "Deceptive Brand Spoofing & Typosquatting: Attackers use visually similar domains (e.g., paypa1.com instead of paypal.com) and high character entropy to trick users.",
        "URL Shortener Concealment: Abusive use of shortener services (bit.ly, tinyurl) hides the ultimate destination URL, preventing users from seeing the true target.",
        "Lack of Unified Cross-Platform Protection: Users switch constantly between desktop browser tabs and mobile devices, requiring a centralized inspection engine with edge clients.",
        "Unclear Threat Visibility: Most security tools output simple binary blocks without exposing diagnostic metrics (heuristics score, brand spoofing probability, QR target structure)."
    ]
    for b in prob_bullets:
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.line_spacing = 1.15
        p.add_run(b)

    add_p("To address these challenges, PhishShield has been conceptualized as a multi-source phishing detection platform that automates threat evaluation and provides a flexible, engaging, and scalable environment for safe digital navigation. It enables instant URL parsing, brand string distance checks, vision-based QR extraction, background tab monitoring, and responsive client notifications.", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=12)

    add_heading_2("3.2 REQUIREMENT SPECIFICATION")
    add_heading_3("Functional Requirements")
    func_reqs = [
        ("1. Multi-Source Link Inspection:", "The system shall accept scan requests originating from active browser tabs (Chrome MV3), manual link input fields, and decoded QR code image streams. The system shall automatically resolve short URLs."),
        ("2. Heuristic Detection Engine:", "The system shall compute domain entropy, inspect Top-Level Domain (TLD) risk coefficients, detect suspicious IP domain masks, verify subdomain depth, and identify abnormal special characters."),
        ("3. NLP Brand-Spoofing Analysis:", "The system shall compare incoming domain strings against target brand databases using string distance algorithms (Levenshtein distance) to detect typosquatting and urgency keywords."),
        ("4. Vision & QR Code (Quishing) Processing:", "The system shall accept Base64-encoded image payloads uploaded by users or captured via camera. The system shall utilize pyzbar to locate, crop, and decode embedded QR code URLs."),
        ("5. Normalized Verdict & Scoring Engine:", "The system shall aggregate results from heuristic, NLP, and vision modules into a unified confidence score ranging from 0.0 to 1.0, classifying targets into SAFE, SUSPICIOUS, or MALICIOUS."),
        ("6. PC Edge (Chrome Extension MV3) Operations:", "The extension shall display current active tab threat verdicts in a glassmorphic popup UI and inject full-screen malicious site warning block pages when navigating to threat domains."),
        ("7. Mobile Edge (Flutter Client) Operations:", "The mobile application shall provide real-time camera QR scanning functionality using mobile_scanner and support configurable interface theme profiles."),
        ("8. Telemetry & Log Management:", "The system shall asynchronously record scan logs, threat classifications, client platform tags, and timestamp metrics into a MongoDB collection.")
    ]
    for title, desc in func_reqs:
        p = add_p(bold=True, size=11, space_before=4, space_after=2)
        p.add_run(title)
        add_p(desc, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=6)

    add_heading_3("Non-Functional Requirements")
    non_func = [
        ("Performance & Response Time:", "The core backend API shall evaluate incoming scan requests and generate a normalized threat verdict within 500 milliseconds under standard load."),
        ("Scalability:", "The backend system built with FastAPI asynchronous request loops shall handle concurrent scanning requests from thousands of connected edge clients without performance degradation."),
        ("Reliability & Availability:", "The core API service shall maintain 99.9% uptime, returning structured fallback verdicts if individual external sub-services fail."),
        ("Security & Data Privacy:", "All client-server communication shall be conducted over HTTPS/TLS. Scan payloads shall contain no personally identifiable user browsing history."),
        ("Cross-Platform Usability:", "The Chrome extension shall function seamlessly across Windows, macOS, and Linux browser instances, while the Flutter app shall adapt responsively to varying mobile screen sizes.")
    ]
    for title, desc in non_func:
        p = add_p(space_after=4)
        p.add_run("• " + title + " ").bold = True
        p.add_run(desc)

    add_heading_2("3.3 PLANNING AND SCHEDULING")
    add_p("Every project requires proper planning and scheduling to ensure timely completion and avoid unnecessary delays. Without a structured timeline, projects may get extended indefinitely, leading to inefficiency and loss of productivity. To overcome this challenge, it is important to establish a clear schedule for each phase of the project.", align=WD_ALIGN_PARAGRAPH.JUSTIFY)
    add_p("One of the most effective tools for project scheduling is a Gantt chart. A Gantt chart provides a visual representation of tasks, their durations, and dependencies, helping project managers and developers track progress effectively. It also ensures that deadlines are met and resources are properly allocated.", align=WD_ALIGN_PARAGRAPH.JUSTIFY)
    add_p("In the case of the PhishShield project, the development process has been divided into specific task phases such as environment boilerplate setup, FastAPI core engine development, Flutter mobile client implementation, Chrome MV3 extension creation, and MongoDB telemetry integration.", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=12)

    add_heading_2("3.4 SOFTWARE AND HARDWARE REQUIREMENTS")
    add_heading_3("Software Requirements:")
    sw = [
        "Backend Core: Python 3.10+, FastAPI, Uvicorn, Pydantic v2",
        "Computer Vision / Libraries: Pillow, pyzbar, requests",
        "Database Engine: MongoDB Server 6.0+, motor async driver",
        "PC Extension: Chrome Manifest V3, HTML5, Vanilla CSS3, Modern ES6 JavaScript",
        "Mobile Client: Flutter SDK 3.x, Dart 3.x, mobile_scanner, http package",
        "Code Editor / IDE: Visual Studio Code, PyCharm, Android Studio",
        "Web Browser: Google Chrome (Developer Mode enabled)"
    ]
    for item in sw:
        add_p("• " + item, space_after=2)

    add_heading_3("Hardware Requirements:")
    hw = [
        "RAM – 8 GB minimum, 16 GB recommended",
        "Processor – Intel Core i5 8th Gen / AMD Ryzen 5 or above (Apple M1/M2 supported)",
        "Hard Disk – 10 GB minimum SSD storage space",
        "System – Windows 10/11, macOS, or Linux (64-bit preferred)",
        "Internet Connection – Required for online TLD checks and package dependencies"
    ]
    for item in hw:
        add_p("• " + item, space_after=2)

    add_heading_2("3.5 CONCEPTUAL MODEL")
    add_p("Figure 3.5.1 Conceptual Model", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, space_before=12, space_after=12)
    
    # ASCII / Structured Box for Conceptual Model
    t_cm = doc.add_table(rows=1, cols=1)
    t_cm.alignment = WD_TABLE_ALIGNMENT.CENTER
    cell = t_cm.cell(0, 0)
    set_cell_background(cell, "F8F9FA")
    set_cell_border(cell, top={'sz':6, 'val':'single', 'color':'444444'},
                          bottom={'sz':6, 'val':'single', 'color':'444444'},
                          left={'sz':6, 'val':'single', 'color':'444444'},
                          right={'sz':6, 'val':'single', 'color':'444444'})
    
    cm_text = (
        "[ PHISHSHIELD MULTI-SOURCE ENGINE ]\n"
        "       │\n"
        "       ├──> PC Edge Client (Chrome Extension MV3: Active Tab URL, Popup UI, Warning Blocks)\n"
        "       ├──> Mobile Edge Client (Flutter App: Camera QR Scan, Manual Input, Multi-Theme UI)\n"
        "       │\n"
        "       ▼\n"
        "[ FASTAPI CORE BACKEND ENGINE ]\n"
        "       │\n"
        "       ├──> Heuristics Engine (Domain Entropy, TLD Danger Index, Subdomain Depth)\n"
        "       ├──> NLP Engine (Brand Distance, Typosquatting, Urgency Keywords)\n"
        "       └──> Vision Engine (Base64 Decoding, pyzbar QR Parse, Shortener Trace)\n"
        "       │\n"
        "       ▼\n"
        "[ THREAT VERDICT EVALUATION (SAFE / SUSPICIOUS / MALICIOUS) ]\n"
        "       │\n"
        "       ▼\n"
        "[ MONGODB TELEMETRY STORAGE (Async Log Caching & Statistics) ]"
    )
    p_cm = cell.paragraphs[0]
    p_cm.text = cm_text
    p_cm.runs[0].font.name = 'Courier New'
    p_cm.runs[0].font.size = Pt(9.5)

    doc.save(filename)
    print(f"Successfully generated {filename}")

if __name__ == "__main__":
    output_path = r"d:\PhishSheildTY\phishshield\PhishShield_Project_Report_Till_Chapter_3.docx"
    create_report_docx(output_path)
