from flask import Flask, request, jsonify
import joblib
import numpy as np
from PIL import Image
import pytesseract
import os
import sys
import re

app = Flask(__name__)
from flask_cors import CORS
CORS(app)

@app.route('/status', methods=['GET'])
def server_status():
    return "Flask is running", 200


def resource_path(relative_path):
    base_path = getattr(sys, '_MEIPASS', os.path.dirname(os.path.abspath(__file__)))
    return os.path.join(base_path, relative_path)

# Load model and scaler
model = joblib.load(resource_path('heart_attack_model.pkl'))
scaler = joblib.load(resource_path('scaler.pkl'))

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.json
        features = np.array([data['Age'], data['BloodPressure'], data['Cholesterol']]).reshape(1, -1)
        scaled_features = scaler.transform(features)
        probabilities = model.predict_proba(scaled_features)[0]
        category = probabilities.argmax()
        category_label = ['Low Risk', 'Medium Risk', 'High Risk'][category]
        return jsonify({
            'category': category_label,
            'probabilities': {
                'Low Risk': probabilities[0],
                'Medium Risk': probabilities[1],
                'High Risk': probabilities[2]
            }
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/extract', methods=['POST'])
def extract():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file uploaded'}), 400

    image_file = request.files['image']
    image = Image.open(image_file.stream)

    # Run OCR
    text = pytesseract.image_to_string(image, config='--psm 6')
    print("OCR Text Output:\n", text)

    # Cleaned text for email search
    cleaned_text = ' '.join(text.split())

    # Initialize fields
    age, bp, chol, email = None, None, None, None

    # Line-by-line search for fields
    for line in text.splitlines():
        line = line.strip()
        if re.search(r'\bage\b', line, re.IGNORECASE):
            age_match = re.search(r'(\d+)', line)
            if age_match:
                age = age_match.group(1)
        elif re.search(r'blood pressure|bp', line, re.IGNORECASE):
            bp_match = re.search(r'(\d+)', line)
            if bp_match:
                bp = bp_match.group(1)
        elif re.search(r'cholesterol', line, re.IGNORECASE):
            chol_match = re.search(r'(\d+)', line)
            if chol_match:
                chol = chol_match.group(1)

    # Email from cleaned flat text
    email_match = re.search(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', cleaned_text)
    if email_match:
        email = email_match.group(0)

    # Fallbacks
    age = int(age) if age else 50
    bp = int(bp) if bp else 120
    chol = int(chol) if chol else 200
    email = email if email else "Not found"

    return jsonify({
        'Age': age,
        'BloodPressure': bp,
        'Cholesterol': chol,
        'Email': email
    })

if __name__ == '__main__':
    app.run(debug=True)
