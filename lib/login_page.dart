import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'global.dart';

bool loggedIn = false;

Future<void> verifyUser(String username, String password, BuildContext context) async {
  final url = Uri.parse('http://localhost:3000/login'); // Replace with your actual URL
  // Create a Map to hold the data
  print('working on logging in at ');
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
  if (response.statusCode == 200) {
    print('User logged-in successfully');
    isAuthenticated = true;
    globalUserName = username;
    Navigator.pushNamed(context, '/home');
  } else {
    print('Failed to log-in user');
    print(response.statusCode);

  }
}

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String enteredUsername = "";
    String enteredPassword = "";
    return Scaffold(
      appBar: AppBar(
        title: Text('LOGIN'),
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
                    // print ('username: '+ enteredUsername + ' password: ' +enteredPassword);
                    verifyUser(enteredUsername, enteredPassword, context);
                  }
                  // Perform sign-up logic here
                },
                child: Text('Login'),
              ),
            ],
          ),
    )
      )

    );
  }
}