import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(HeartAttackPredictorApp());
}

class HeartAttackPredictorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PredictorForm(),
    );
  }
}

class PredictorForm extends StatefulWidget {
  @override
  _PredictorFormState createState() => _PredictorFormState();
}

class _PredictorFormState extends State<PredictorForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _cholesterolController = TextEditingController();
  String? _prediction;
  Map<String, dynamic>? _probabilities;

  Future<void> _getPrediction() async {
    final url = Uri.parse('http://127.0.0.1:5000/predict'); // Adjust API URL
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Age': int.parse(_ageController.text),
        'BloodPressure': int.parse(_bpController.text),
        'Cholesterol': int.parse(_cholesterolController.text),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _prediction = data['category'];
        _probabilities = data['probabilities'];
      });
    } else {
      setState(() {
        _prediction = 'Error: ${response.body}';
        _probabilities = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Heart Attack Risk Predictor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter your age' : null,
              ),
              TextFormField(
                controller: _bpController,
                decoration: InputDecoration(labelText: 'Blood Pressure'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your blood pressure' : null,
              ),
              TextFormField(
                controller: _cholesterolController,
                decoration: InputDecoration(labelText: 'Cholesterol'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your cholesterol' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _getPrediction();
                  }
                },
                child: Text('Predict'),
              ),
              SizedBox(height: 20),
              if (_prediction != null) ...[
                Text(
                  'Prediction: $_prediction',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (_probabilities != null)
                  Column(
                    children: _probabilities!.entries.map((entry) {
                      return Text(
                        '${entry.key}: ${(entry.value * 100).toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 16),
                      );
                    }).toList(),
                  )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
