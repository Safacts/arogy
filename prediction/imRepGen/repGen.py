import csv
from PIL import Image, ImageDraw, ImageFont
import os
import re

# Load data from CSV
def load_csv_data(filename="health_data.csv"):
    data = []
    with open(filename, mode='r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            data.append({
                "Name": row["Name"],
                "Age": int(row["Age"]),
                "BloodPressure": int(row["BloodPressure"]),
                "Cholesterol": int(row["Cholesterol"]),
            })
    return data

# Draw a rounded background box
def draw_rounded_box(draw, box, radius, fill):
    x1, y1, x2, y2 = box
    draw.rectangle([x1 + radius, y1, x2 - radius, y2], fill=fill)
    draw.rectangle([x1, y1 + radius, x2, y2 - radius], fill=fill)
    draw.pieslice([x1, y1, x1 + 2*radius, y1 + 2*radius], 180, 270, fill=fill)
    draw.pieslice([x2 - 2*radius, y1, x2, y1 + 2*radius], 270, 360, fill=fill)
    draw.pieslice([x1, y2 - 2*radius, x1 + 2*radius, y2], 90, 180, fill=fill)
    draw.pieslice([x2 - 2*radius, y2 - 2*radius, x2, y2], 0, 90, fill=fill)

# Create image report
def create_health_report_image(person, output_dir="reports"):
    width, height = 800, 600
    margin = 50
    img = Image.new("RGB", (width, height), "white")
    draw = ImageDraw.Draw(img)

    # Load fonts
    try:
        title_font = ImageFont.truetype("arialbd.ttf", 36)
        section_font = ImageFont.truetype("arialbd.ttf", 22)
        label_font = ImageFont.truetype("arialbd.ttf", 16)
        value_font = ImageFont.truetype("arial.ttf", 16)
        footer_font = ImageFont.truetype("arial.ttf", 14)
    except:
        title_font = section_font = label_font = value_font = footer_font = ImageFont.load_default()

    # Header Title
    header_color = (44, 130, 201)
    draw.rectangle([0, 0, width, 80], fill=header_color)
    draw.text((margin, 20), "MEDICAL HEALTH REPORT", font=title_font, fill="white")

    # Section box
    section_top = 100
    box_fill = (240, 248, 255)
    draw_rounded_box(draw, (margin, section_top, width - margin, height - 100), 20, fill=box_fill)

    # Section label
    draw.text((margin + 20, section_top + 20), "Patient Information", font=section_font, fill="#000000")

    # Patient details
    labels = ["Name", "Age", "Blood Pressure", "Cholesterol"]
    values = [
        person["Name"],
        f"{person['Age']} years",
        f"{person['BloodPressure']} mmHg",
        f"{person['Cholesterol']} mg/dL"
    ]

    y = section_top + 70
    for i in range(len(labels)):
        draw.text((margin + 40, y), f"{labels[i]}:", font=label_font, fill="#333333")
        draw.text((margin + 200, y), values[i], font=value_font, fill="#555555")
        y += 40

    # Footer
    draw.text((margin, height - 60), "Note: This report is auto-generated and not a substitute for a medical diagnosis.",
              font=footer_font, fill="#666666")
    draw.text((margin, height - 40), "Issued by: City Health Center | Contact: 123-456-7890",
              font=footer_font, fill="#666666")

    # Save image
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    safe_name = re.sub(r'[^a-zA-Z0-9_]', '', person['Name'].replace(" ", "_"))
    img_path = os.path.join(output_dir, f"{safe_name}_report.png")
    img.save(img_path)
    print(f"✅ Saved: {img_path}")

# Main function
def generate_reports():
    data = load_csv_data("health_data.csv")
    for person in data:
        create_health_report_image(person)

if __name__ == "__main__":
    generate_reports()
