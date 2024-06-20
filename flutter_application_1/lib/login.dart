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
    final url =
        Uri.parse('http://10.143.10.37/ApiPhamacySmartLabel/PatientVerifyTest');
    // Uri.parse('http://10.143.10.37/ApiPhamacySmartLabel/PatientVerify');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(
        {'emplid': _usernameController.text, 'pass': _passwordController.text});

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
          if (visitId != null) {
            _navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(
                builder: (context) => PatientDetailsPage(visitId: visitId),
              ),
            );
          }
        } else {
          // ignore: use_build_context_synchronously
          showAlertDialog(context);
        }
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login Failed!"),
          content: const Text(
            "Invalid Username or Password",
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                "OK",
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
          elevation: 24.0,
        );
      },
    );
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
                        padding: const EdgeInsets.all(20.0),
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
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your HN';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              const Align(
                                alignment: Alignment
                                    .centerLeft, // จัดข้อความให้อยู่ชิดซ้าย
                                child:
                                    Text('Please enter your HN number here.'),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText:
                                      "กรุณากรอกหมายเลข 4 ตัวท้ายหลังบัตรประชาชน",
                                  labelText: 'Password',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your 4 Ids';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: const TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            'กรอกหมายเลข 4 ตัวท้ายหลังบัตรประชาชน หรือ วันเดือนปีเกิด\n',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: 'เช่น 19950919\n',
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text:
                                            'Please enter the last 4 digits of your Passport or your Birthday.\n',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: 'Ex. 19950919',
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
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
