import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'login.dart';

class PatientDetailsPage extends StatefulWidget {
  final String visitId;

  const PatientDetailsPage({required this.visitId, Key? key}) : super(key: key);

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  Map<String, dynamic>? patientDetails;
  List<dynamic>? medications;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _fetchPatientDetails();
    _configureTts();
  }

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(0.5);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _fetchPatientDetails() async {
    final url = Uri.parse('http://10.143.10.37/ApiPhamacySmartLabel/PatientDetails');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'emplid': widget.visitId, 'pass': ""});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == '200') {
          setState(() {
            patientDetails = (jsonResponse['detailsH'] as List<dynamic>?)?.first;
            medications = jsonResponse['detailsB'] as List<dynamic>?;
          });
        } else {
          _showSnackBar('Failed to load patient details: ${jsonResponse['message']}');
        }
      } else {
        _showSnackBar('Failed to load patient details');
      }
    } catch (e) {
      _showSnackBar('An error occurred while fetching patient details.');
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _speakText(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Medication Sheet',
          style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
            color: Colors.white,
          )
        ],
      ),
      body: patientDetails != null && medications != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('Profile',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Card(
                    child: ListTile(
                      title: Text('${patientDetails!['patient_name'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 18)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HN : ${patientDetails!['hn'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16)),
                          Text('Gender : ${patientDetails!['fix_gender_id'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16)),
                          Text('Birth date : ${patientDetails!['birthdate'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16)),
                          Text('Age : ${patientDetails!['age'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16)),
                          Text('Diagnosis : ${patientDetails!['diagnosis'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16)),
                          Text('Allergy : ${patientDetails!['drugaallergy'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16)),
                          Text('Doctor : ${patientDetails!['opddoctorname'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () {
                          final detailsText = """
                            ${patientDetails!['patient_name'] ?? 'N/A'}
                            HN: ${patientDetails!['hn'] ?? 'N/A'}
                            Gender: ${patientDetails!['fix_gender_id'] ?? 'N/A'}
                            Birth date: ${patientDetails!['birthdate'] ?? 'N/A'}
                            Age: ${patientDetails!['age'] ?? 'N/A'}
                            Diagnosis: ${patientDetails!['diagnosis'] ?? 'N/A'}
                            Allergy: ${patientDetails!['drugaallergy'] ?? 'N/A'}
                            Doctor: ${patientDetails!['opddoctorname'] ?? 'N/A'}
                          """;
                          _speakText(detailsText);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Medications',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: medications!.length,
                    itemBuilder: (context, index) {
                      final medication = medications![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name : ${medication['item_name'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16)),
                              Text('Instructions : ${medication['instruction_text_line1'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16)),
                              Text('${medication['instruction_text_line2'] ?? ''}',
                                  style: const TextStyle(fontSize: 16)),
                              Text('${medication['instruction_text_line3'] ?? ''}',
                                  style: const TextStyle(fontSize: 16)),
                              Text('Description : ${medication['item_deacription'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16)),
                              Text('Caution : ${medication['item_caution'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16)),
                              Center(
                                child: IconButton(
                                  icon: const Icon(Icons.volume_up),
                                  onPressed: () {
                                    final medicationText = """
                                    Medication Name: ${medication['item_name'] ?? 'N/A'}
                                      Instructions: ${medication['instruction_text_line1'] ?? 'N/A'}
                                      ${medication['instruction_text_line2'] ?? ''}
                                      ${medication['instruction_text_line3'] ?? ''}
                                      Description: ${medication['item_deacription'] ?? 'N/A'}
                                      Caution: ${medication['item_caution'] ?? 'N/A'}
                                    """;
                                    _speakText(medicationText);
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
