//this is the new file!
import 'dart:convert';

import 'package:flushit/DioService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:io'; // This contains the Cookie class

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'secure_storage_service.dart';

bool loggedIn = false;
String errorMessage = "";

Future<bool> verifyUser(
    String username, String password, BuildContext context) async {
// Assuming dio and cookieJar have been initialized outside this function

// Adding the CookieManager interceptor; you only need to add this once
// so consider doing this during Dio initialization instead

  final url = 'https://flushit.org/login'; // Using string directly, Dio will handle the URI conversion
  print("Dio instance: ${DioService().dio.hashCode}" );
  final data = {'username': username, 'password': password};

  try {
    final response = await DioService().dio.post(
      url,
      data: data,
      options: Options(
        headers: {'Content-Type': 'application/json'},

      ),
    );

    if (response.statusCode == 200) {
      print("Headers before the request: ${DioService().dio.options.headers}");
// With Dio and CookieJar, cookies are automatically saved and sent with requests.
// So, there's no need to manually parse and save the JWT from Set-Cookie header.
// However, if you want to handle the JWT manually, you can still do it.
// (But that's unnecessary when using Dio with CookieJar).
//       List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse('https://flushit.org'));
//       print(cookies); // This will print all cookies stored for the domain 'https://flushit.org'.

      Navigator.pushNamed(context, '/home');
      return true;
    } else {
      print('Failed to log-in user');
      print(response.statusCode);
      return false;
    }
  } catch (error) {
    print('Error occurred during login: $error');
    return false;
  }
}

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<Login> {
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
    return Scaffold(
        appBar: AppBar(
          title: Text('LOGIN'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              width: 450,
              height: 600,
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 250, 255, 1),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.deepPurpleAccent,
                //     spreadRadius: 5,
                //     blurRadius: 7,
                //     offset: Offset(3, 3), // changes position of shadow
                //   ),
                // ],
                border: Border.all(),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                  child: Padding(
                padding: EdgeInsets.all(40.0),
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
                ),
              )),
            ),
          ),
        ));
  }
}
