import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
from sklearn.impute import SimpleImputer
from sklearn.metrics import confusion_matrix, accuracy_score
from sklearn.multiclass import OneVsRestClassifier  # For handling multi-class classification
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import joblib

# Read the dataset for heart attack prediction
# data = pd.read_csv('heart_attack_data.csv')

# data = pd.read_csv('synthetic_health_dataset.csv')

# data = pd.read_csv('heart_attack_data1.csv')

data = pd.read_csv('enhanced_heart_attack_data.csv')

# Handle missing values in the dataset (numeric columns only)
data.fillna(data.mean(numeric_only=True), inplace=True)

# Select features and target variable
# Example features: Age, Blood Pressure, Cholesterol, etc.
try:
    X = data[['Age', 'Blood Pressure', 'Cholesterol']]  # Adjust features as per your dataset
    y = data['Heart Attack Risk']  # Target variable
except KeyError as e:
    raise ValueError(f"One or more required columns are missing in the dataset: {e}")

# Encode target if it is categorical
if y.dtypes == 'object':
    y = y.map({'Low': 0, 'Medium': 1, 'High': 2})  # Map categories to integers for classification
    if y.isnull().any():
        raise ValueError("Target variable contains values outside of the defined categories (Low, Medium, High).")

# Handle missing values in features
imputer = SimpleImputer(strategy='mean')
X = imputer.fit_transform(X)

# Split the data for training and testing
X_train, X_test, y_train, y_test = train_test_split(X, y.astype(int), test_size=0.2, random_state=42)  # Ensure labels are integers

# Scale the data
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# Train the model
model = OneVsRestClassifier(LogisticRegression(max_iter=200, class_weight='balanced'))  # Use balanced class weights
model.fit(X_train, y_train)

# Save the trained model and scaler for offline use
joblib.dump(model, 'heart_attack_model.pkl')
joblib.dump(scaler, 'scaler.pkl')
print("Model and scaler saved as 'heart_attack_model.pkl' and 'scaler.pkl'.")

# Apply the model to the entire dataset to get predictions and probabilities
X_scaled = scaler.transform(X)  # Scale the entire dataset
probabilities = model.predict_proba(X_scaled)  # Generate probabilities between 0 and 1 for each class

# Categorize risk levels based on the highest probability
risk_categories = probabilities.argmax(axis=1)  # Use argmax directly to choose the highest probability class
risk_category_labels = pd.Series(risk_categories).map({0: 'Low Risk', 1: 'Medium Risk', 2: 'High Risk'})  # Map predictions back to original categories

# Evaluate the model on the test set
accuracy = accuracy_score(y_test, model.predict(X_test))
conf_matrix = confusion_matrix(y_test, model.predict(X_test))

print(f"Accuracy: {accuracy:.2f}")
print("Confusion Matrix:")
print(conf_matrix)

# Plot confusion matrix
plt.figure(figsize=(12, 8))  # Larger figure size for clarity
sns.heatmap(conf_matrix, annot=True, fmt='d', cmap='coolwarm', cbar=False)
plt.title('Confusion Matrix', fontsize=16)
plt.xlabel('Predicted', fontsize=14)
plt.ylabel('Actual', fontsize=14)
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)
plt.tight_layout()
plt.savefig('confusion_matrix.png', dpi=300)  # High DPI for better resolution

# Plot distribution of probabilities for Medium Risk
plt.figure(figsize=(12, 8))  # Larger figure size
sns.histplot(probabilities[:, 1], kde=True, bins=30, color='blue', alpha=0.7)
plt.title('Distribution of Medium Risk Probabilities', fontsize=16)
plt.xlabel('Probability', fontsize=14)
plt.ylabel('Frequency', fontsize=14)
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)
plt.tight_layout()
plt.savefig('probability_distribution.png', dpi=300)  # High DPI

# Plot risk categories
plt.figure(figsize=(12, 8))  # Larger figure size
sns.countplot(x=risk_category_labels, hue=risk_category_labels, palette='viridis', dodge=False, legend=False)
plt.title('Heart Attack Risk Categories Distribution', fontsize=16)
plt.xlabel('Risk Category', fontsize=14)
plt.ylabel('Count', fontsize=14)
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)
plt.tight_layout()
plt.savefig('risk_categories.png', dpi=300)  # High DPI

print("Plots and model files are ready for integration into your Flutter project.")
