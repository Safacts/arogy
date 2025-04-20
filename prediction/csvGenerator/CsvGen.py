import csv
import random

# List of names
names = ["Aadi", "Bharat", "Shiva", "Anand", "Raj", "Maya", "Neha", "Vikram", "Priya", "Amit"]

# Generate random data
def generate_random_data():
    age = random.randint(18, 70)
    blood_pressure = random.randint(110, 180)
    cholesterol = random.randint(150, 300)
    return age, blood_pressure, cholesterol

# Create CSV file
def create_csv_file(filename="health_data.csv"):
    with open(filename, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["Name", "Age", "BloodPressure", "Cholesterol"])

        for name in names:
            age, bp, cholesterol = generate_random_data()
            writer.writerow([name, age, bp, cholesterol])

    print(f"CSV file '{filename}' created successfully.")

# Run the function to create the CSV
create_csv_file()
