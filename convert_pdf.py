import sys
import docx
from docx2pdf import convert

try:
    convert(r"d:\PhishSheildTY\phishshield\PhishShield_Project_Report_Till_Chapter_3.docx",
            r"d:\PhishSheildTY\phishshield\PhishShield_Project_Report_Till_Chapter_3.pdf")
    print("PDF generated successfully with docx2pdf")
except Exception as e:
    print(f"docx2pdf error: {e}")
