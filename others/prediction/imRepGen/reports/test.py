from PIL import Image
import pytesseract
import re

image_path = r"C:\myprojects\integrated projects\git\arogy\prediction\imrepgen\reports\Aadi_report.png"
img = Image.open(image_path)
text = pytesseract.image_to_string(img, config='--psm 6')
print("🔍 OCR TEXT:\n", text)

email_match = re.search(r'[\w\.-]+@[\w\.-]+\.\w+', text)
if email_match:
    print("📧 Email:", email_match.group(0))
else:
    print("❌ Email not found")
