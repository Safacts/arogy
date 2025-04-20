from flask import Flask, request, jsonify
import joblib
import numpy as np
from PIL import Image
import pytesseract
import io

app = Flask(__name__)

# Load the model and scaler
model = joblib.load('assets/heart_attack_model.pkl')
scaler = joblib.load('assets/scaler.pkl')

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.json
        # Extract features
        features = np.array([data['Age'], data['BloodPressure'], data['Cholesterol']]).reshape(1, -1)
        # Scale the input
        scaled_features = scaler.transform(features)
        # Get predictions and probabilities
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

# 🔥 NEW: Extract data from PNG image report
@app.route('/extract', methods=['POST'])
def extract():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file uploaded'}), 400

    image_file = request.files['image']
    image = Image.open(image_file.stream)

    # Use pytesseract to extract text
    text = pytesseract.image_to_string(image)

    # Debug print
    print("OCR Text Output:\n", text)

    # Basic parsing logic (customize to match your image format)
    age, bp, chol = None, None, None
    for line in text.splitlines():
        lower = line.lower()
        if 'age' in lower:
            age = ''.join(filter(str.isdigit, line))
        elif 'blood pressure' in lower or 'bp' in lower:
            bp = ''.join(filter(str.isdigit, line))
        elif 'cholesterol' in lower:
            chol = ''.join(filter(str.isdigit, line))

    # Fallbacks
    age = int(age) if age else 50
    bp = int(bp) if bp else 120
    chol = int(chol) if chol else 200

    return jsonify({
        'Age': age,
        'BloodPressure': bp,
        'Cholesterol': chol
    })

if __name__ == '__main__':
    app.run(debug=True)
