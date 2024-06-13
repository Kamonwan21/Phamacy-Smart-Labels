import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
Future<void> _login() async {
  final url = Uri.parse('http://10.143.10.37/ApiPhamacySmartLabel/PatientVerifyTest');
  // Uri.parse('http://10.143.10.37/ApiPhamacySmartLabel/PatientVerify');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({'emplid': _usernameController.text, 'pass': _passwordController.text});
  
  try {
    final response = await http.post(url, headers: headers, body: body);
    final jsonResponse = jsonDecode(response.body);
    
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: $jsonResponse'); // Debugging output
    
    if (response.statusCode == 200) {
      final userlogin = jsonResponse['userlogin'];
      if (userlogin is List && userlogin.isNotEmpty) {
        final visitId = userlogin[0]['visit_id'];
        print('visit_id type: ${visitId.runtimeType}');
        print('visit_id: $visitId'); // Debugging output
        _showSnackBar(jsonResponse['message']);
        if (visitId != null) {
          _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (context) => PatientDetailsPage(visitId: visitId),
            ),
          );
        }
      } else {
        _showSnackBar('Login failed : No visit ID found.');
      }
    } else if (response.statusCode == 404) {
      _showSnackBar('Error 404: Resource not found');
    } else {
      _showSnackBar('Unexpected error: ${jsonResponse['message'] ?? 'Unknown error'}');
    }
  } catch (e) {
    _showSnackBar('An error occurred: $e');
  }
}

void _showSnackBar(String message) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (setting) {
        return MaterialPageRoute(
            builder: (context) => Scaffold(
                  body: Center(
                    child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('images/login.png',
                                  width: 200, height: 150),
                              TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  hintText: "กรุณากรอกหมายเลข HN ",
                                  labelText: 'Username',
                                  helperText:
                                      'Please enter your HN number here.', // Helper text
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your HN';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText:
                                      "กรุณากรอกหมายเลข 4 ตัวท้ายหลังบัตรประชาชน",
                                  labelText: 'Password',
                                  helperText:
                                      'Please enter \nthe last 4 digits of your Passport or your Birthday Ex. 19950919.\nกรอกหมายเลข 4 ตัวท้ายหลังบัตรประชาชน หรือ วันเดือนปีเกิด \nเช่น 19950919', // Helper text
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your 4 Ids';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _login();
                                    }
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 20),
                                  ))
                            ],
                          ),
                        )),
                  ),
                ));
      },
    );
  }
}
