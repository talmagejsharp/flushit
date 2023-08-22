import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'global.dart';

bool loggedIn = false;
String errorMessage = "";

Future<bool> verifyUser(String username, String password, BuildContext context) async {
  final url = Uri.parse('http://localhost:3000/login'); // Replace with your actual URL
  // Create a Map to hold the data
  print('working on logging in');
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
    return true;
  } else {
    print('Failed to log-in user');
    print(response.statusCode);
    return false;
  }
}

class Login extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _LoginWidgetState();
}
class _LoginWidgetState extends State<Login> {
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
              errorMessage.isNotEmpty
                  ? Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              )
                  : SizedBox(), // Empty SizedBox when no error message
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (enteredUsername != "" && enteredPassword != "") {
                    // print ('username: '+ enteredUsername + ' password: ' +enteredPassword);
                    if(verifyUser(enteredUsername, enteredPassword, context) == true){

                    } else{
                      errorMessage = "Incorrect Username or Password";
                      setState(() {});
                    }
                  } else {
                    errorMessage = "Please enter a username or password";
                    setState(() {});
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