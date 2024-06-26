//this is the new file!
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'main.dart';

bool loggedIn = false;
String errorMessage = "";

Future<bool> verifyUser(
    String username, String password, BuildContext context) async {
  final url = Uri.parse('https://flushit.org/login');
  final data = {'username': username, 'password': password};
  final jsonData = jsonEncode(data);

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonData,
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final token = jsonResponse['token'];
    // Check if the app is running on web or mobile
    storage.saveToken(token);

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
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    String? token = await storage.readToken(); // Read the stored token
    if (token != null) {
      bool isLoggedIn = await accessProtectedRoute(token);
      if (isLoggedIn) {
        // If logged in, redirect to another page
        Navigator.pushReplacementNamed(context, '/home');
        final snackBar = SnackBar(
          content: Text('Automatically redirected to home'),
          duration: Duration(seconds: 2),  // Duration to show the SnackBar
          // Optionally add an action for more user interaction
        );

        // Display the snackbar
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }


  final FocusNode _passwordFocus = FocusNode();
  attemptLogin(String username, String password, context) async {
    if (username != "" && password != "") {
      // print ('username: '+ enteredUsername + ' password: ' +enteredPassword);
      if (await verifyUser(username, password, context) == true) {
      } else {
        errorMessage = "Incorrect Username or Password";
        setState(() {});
      }
    } else {
      errorMessage = "Please enter a username or password";
      setState(() {});
    }
  }

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    usernameController.dispose();
    passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('LOGIN'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
                width: screenWidth * 0.9, // 90% of screen width
                height: screenHeight * 0.7, // 70% of screen height
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 250, 255, 1),
                  // border: Border.all(),
                  // borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 75),
                      child: Text(
                        'Login to your Flushit Account',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextField(
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      },
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      onEditingComplete: () {
                        attemptLogin(usernameController.text,
                            passwordController.text, context);
                      },
                      focusNode: _passwordFocus,
                      controller: passwordController,
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
                    SizedBox(height: 40),
                    Container(
                      width: 150,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              Colors.deepPurple),
                          overlayColor: MaterialStatePropertyAll<Color>(
                              Colors.deepPurpleAccent),
                        ),
                        onPressed: () async {
                          // print('The password is : ' + passwordController.text);
                          attemptLogin(usernameController.text,
                              passwordController.text, context);
                        },
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
