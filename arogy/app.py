from flask import Flask, request, jsonify
import joblib
import numpy as np

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

if __name__ == '__main__':
    app.run(debug=True)
