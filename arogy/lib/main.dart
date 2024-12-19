import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  startFlaskServer(); // Start the Flask server
  runApp(HeartAttackPredictorApp());
}

// Function to start the Flask server
void startFlaskServer() async {
  try {
    // Ensure Python is installed, and install if not
    await ensurePythonInstalled();

    // Start the Flask server using Python
    final process = await Process.start(
      'python', // Ensure 'python' is accessible via your system's PATH
      ['app.py'], // Replace 'app.py' with the path to your Flask script
      workingDirectory: Directory.current.path, // Adjust if app.py is elsewhere
      runInShell: true,
    );

    // Listen for server output
    process.stdout.transform(utf8.decoder).listen((data) {
      print('Flask server: $data');
    });
    process.stderr.transform(utf8.decoder).listen((data) {
      print('Flask server error: $data');
    });
  } catch (e) {
    print('Error starting Flask server: $e');
  }
}

// Function to ensure Python is installed
Future<void> ensurePythonInstalled() async {
  try {
    final result = await Process.run('python', ['--version']);
    if (result.exitCode == 0) {
      print('Python installation verified: ${result.stdout}');
      return;
    }
  } catch (e) {
    print('Python is not installed or not found in PATH. Attempting to install...');
  }

  // Download Python installer for the respective OS
  if (Platform.isWindows) {
    await downloadAndInstallPython(
      url: 'https://www.python.org/ftp/python/3.11.6/python-3.11.6-amd64.exe',
      installerName: 'python-installer.exe',
      installArgs: ['/quiet', 'InstallAllUsers=1', 'PrependPath=1'],
    );
  } else if (Platform.isMacOS) {
    print('Please install Python manually on macOS: https://www.python.org/downloads/');
    exit(1); // Exit the program
  } else if (Platform.isLinux) {
    print('Attempting to install Python using apt...');
    await Process.run('sudo', ['apt', 'update']);
    await Process.run('sudo', ['apt', 'install', '-y', 'python3']);
    print('Python installed via apt!');
  } else {
    throw Exception('Unsupported platform for automatic Python installation.');
  }
}

// Function to download and install Python
Future<void> downloadAndInstallPython({
  required String url,
  required String installerName,
  required List<String> installArgs,
}) async {
  final installerFile = File(installerName);

  // Download Python installer
  print('Downloading Python installer from $url...');
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    await installerFile.writeAsBytes(response.bodyBytes);
    print('Python installer downloaded successfully!');
  } else {
    throw Exception('Failed to download Python installer. Status code: ${response.statusCode}');
  }

  // Run the installer
  print('Running Python installer...');
  final installProcess = await Process.run(
    installerFile.path,
    installArgs,
    runInShell: true,
  );

  if (installProcess.exitCode == 0) {
    print('Python installed successfully!');
  } else {
    throw Exception('Failed to install Python. Please check the installer output.');
  }

  // Clean up installer file
  await installerFile.delete();
  print('Installer cleaned up.');
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
