import os
import sys
import docx
from docx2pdf import convert

base_dir = os.path.dirname(os.path.abspath(__file__))
docx_in = sys.argv[1] if len(sys.argv) > 1 else os.path.join(base_dir, "PhishShield_Project_Report_Till_Chapter_3.docx")
pdf_out = sys.argv[2] if len(sys.argv) > 2 else os.path.join(base_dir, "PhishShield_Project_Report_Till_Chapter_3.pdf")

try:
    convert(docx_in, pdf_out)
    print(f"PDF generated successfully: {pdf_out}")
except Exception as e:
    print(f"docx2pdf error: {e}")

