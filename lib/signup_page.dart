import 'dart:convert';
import 'global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

Future<void> registerUser(String username, String password, BuildContext context) async {
  final url = Uri.parse('http://localhost:3000/register'); // Replace with your actual URL
  // Create a Map to hold the data
  print('working on signing in at' + url.path);
  final data = {'username': username, 'password': password};
  // Encode the data as JSON
  final jsonData = jsonEncode(data);
  // Set the headers and make the POST request
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonData,
  );

  // Handle the response as needed
  // ...
  if (response.statusCode == 200 || response.statusCode == 201) {
    print('User registered successfully');
    verifyUser(username, password, context);
  } else {
    print('Failed to register user');
    print(response.statusCode);
  }
}


class SignUp extends StatelessWidget {
  String enteredUsername = "";
  String enteredPassword = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SIGN UP'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (String value) async {
                  enteredUsername = value;
                },
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                onChanged: (String value) async {
                  enteredPassword = value;
                },
                obscureText: true, // Mask the input for passwords
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (enteredUsername != "" && enteredPassword != "") {
                    print ('username: '+enteredUsername + ' password: ' +enteredPassword);
                    registerUser(enteredUsername, enteredPassword, context);
                  }
                  // Perform sign-up logic here
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
    )
      )

    );
  }
}