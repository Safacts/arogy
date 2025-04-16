import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Process? flaskProcess;
bool isServerRunning = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await startFlaskServer(); // Wait for the server to be ready
  runApp(HeartAttackPredictorApp());
}

Future<void> startFlaskServer() async {
  try {
    final process = await Process.start(
      Platform.isWindows ? 'dist\\app.exe' : 'dist/app.exe',
      [],
    );

    flaskProcess = process;

    process.stdout.transform(utf8.decoder).listen((data) {
      print('Flask stdout: $data');
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      print('Flask stderr: $data');
    });

    // Poll the server until it responds
    const maxRetries = 10;
    for (int i = 0; i < maxRetries; i++) {
      try {
        final response = await http.get(Uri.parse('http://127.0.0.1:5000'));
        if (response.statusCode == 200 || response.statusCode == 404) {
          isServerRunning = true;
          print("✅ Flask server is ready.");
          break;
        }
      } catch (e) {
        // Server not ready yet
      }
      await Future.delayed(Duration(seconds: 1));
    }

    if (!isServerRunning) {
      print("❌ Flask server failed to start in time.");
    }
  } catch (e) {
    print('Error starting Flask server: $e');
  }
}


class HeartAttackPredictorApp extends StatelessWidget {
  const HeartAttackPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: PredictorForm(),
    );
  }
}

class PredictorForm extends StatefulWidget {
  const PredictorForm({super.key});

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
  String _statusMessage = "Waiting for server...";

  @override
  void dispose() {
    flaskProcess?.kill();
    super.dispose();
  }

  Future<void> _getPrediction() async {
    if (!isServerRunning) {
      setState(() {
        _statusMessage = "Server is not yet ready. Please try again later.";
      });
      return;
    }

    final url = Uri.parse('http://127.0.0.1:5000/predict');
    try {
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
          _statusMessage = "Prediction received!";
        });
      } else {
        setState(() {
          _prediction = 'Error: ${response.body}';
          _probabilities = null;
          _statusMessage = "Failed to get prediction!";
        });
      }
    } catch (e) {
      setState(() {
        _prediction = null;
        _probabilities = null;
        _statusMessage = "Failed to connect to server: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Heart Attack Risk Predictor'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.red.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 8.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Enter Your Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: Icon(Icons.cake, color: Colors.red),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter your age' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _bpController,
                      decoration: InputDecoration(
                        labelText: 'Blood Pressure',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: Icon(Icons.favorite, color: Colors.red),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your blood pressure' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _cholesterolController,
                      decoration: InputDecoration(
                        labelText: 'Cholesterol',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: Icon(Icons.water_drop, color: Colors.red),
                      ),
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
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0), backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text('Predict'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    if (_prediction != null) ...[
                      Divider(color: Colors.red),
                      Text(
                        'Prediction:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        _prediction!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_probabilities != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _probabilities!.entries.map((entry) {
                            return Text(
                              '${entry.key}: ${(entry.value * 100).toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            );
                          }).toList(),
                        ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
