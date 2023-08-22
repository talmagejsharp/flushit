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

Future<bool> isAvaliable(String username) async {
  final response = await http.get(
      Uri.parse('http://localhost:3000/check_username/$username'));
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}


class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignupWidgetState();
}
class _SignupWidgetState extends State<SignUp> {
  String enteredUsername = "";
  String enteredPassword = "";
  String errorMessage = "";
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
              errorMessage.isNotEmpty
                  ? Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              )
                  : SizedBox(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (enteredUsername != "" && enteredPassword != "") {
                    if(enteredUsername.length < 5){
                      errorMessage = "Minimum length of username is 5 characters";
                      setState(() {});
                    } else if (enteredPassword.length < 8){
                      errorMessage = "Minimum length of password is 8 characters";
                      setState(() {});
                    } else if(enteredUsername.length > 15){
                      errorMessage = "Maximum length of username is 15 characters";
                      setState(() {});
                    } else if(isAvaliable(enteredUsername) == true){
                      registerUser(enteredUsername, enteredPassword, context);
                    } else {
                      errorMessage = "Username already taken, please log in";
                      setState(() {});
                    }
                  } else {
                    errorMessage = "please enter a username and password";
                    setState(() {});
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