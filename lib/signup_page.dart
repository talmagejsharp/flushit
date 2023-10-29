import 'dart:convert';
import 'package:flushit/userInfo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

Future<void> registerUser(String username, String email,  String password, BuildContext context) async {
  final url = Uri.parse('https://flushit.org/register'); // Replace with your actual URL
  // Create a Map to hold the data
  final data = {'username': username, 'email': email, 'password': password};
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
    verifyUser(username, password, context);
  } else {

  }
}




class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignupWidgetState();
}
class _SignupWidgetState extends State<SignUp> {
  signUp(String username, String email, String password, BuildContext context) async {
    if (username.isNotEmpty && password.isNotEmpty && email.isNotEmpty) {
      if(username.length < 5){
        errorMessage = "Minimum length of username is 5 characters";
        setState(() {});
      } else if (password.length < 8){
        errorMessage = "Minimum length of password is 8 characters";
        setState(() {});
      } else {
        bool usernameAvailable = await isUsernameAvailable(username);
        bool emailAvailable = await isEmailAvailable(email);
        if (usernameAvailable && emailAvailable) {
          registerUser(username, email, password, context);
        } else if(!usernameAvailable){
          errorMessage = "Username already taken, please log in";
          setState(() {});
        } else {
          errorMessage = "Email already taken, please log in";
          setState(() {});
        }
      }
    } else {
      errorMessage = "please enter a username and password";
      setState(() {});
    }
    // Perform sign-up logic here

  }
  // String enteredUsername = "";
  // String enteredPassword = "";
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  String errorMessage = "";
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SIGN UP'),
        // backgroundColor: Colors.deepPurple,
        // foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 450,
            height: 600,
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 250, 255, 1),
            ),
            // color: Colors.deepPurpleAccent,
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
                    child: Text('Create an account with Flushit',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Text('Enter a username, password and email'),
                  SizedBox(height: 50,),
                  TextField(
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(_usernameFocus); // Move focus to password field
                    },
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(_passwordFocus); // Move focus to password field
                    },
                    focusNode: _usernameFocus,
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    onEditingComplete: () {
                      print('The password is : ' + passwordController.text);
                      signUp(usernameController.text, emailController.text, passwordController.text,  context);
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
                      : SizedBox(),
                  SizedBox(height: 40),
                  Container(
                    width: 150,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.deepPurple),
                        overlayColor: MaterialStatePropertyAll<Color>(Colors.deepPurpleAccent),

                      ),
                      onPressed: () async {
                        // print('The password is : ' + passwordController.text);
                        signUp(usernameController.text, emailController.text, passwordController.text,  context);
                        },
                      child: Text('SIGN UP',
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
    ),
          )
        ),
      )

    );
  }

}