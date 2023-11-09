import 'dart:convert';
import 'package:flushit/customButtons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'notAuthenticated.dart';

String userEmail = "";
String userName = "";
bool loaded = false;
bool isLoading = true;
Map<String, dynamic>? userData;

Future<bool> isUsernameAvailable(String username) async {
  final response =
      await http.get(Uri.parse('https://flushit.org/check_username/$username'));
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

Future<bool> isEmailAvailable(String email) async {
  final response =
      await http.get(Uri.parse('https://flushit.org/check_email/$email'));
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

Future<bool> updateUser({ String? updatedUsername, String? updatedEmail, String? updatedProfilePicture, }) async {
  final token = await storage.readToken();
  if (token == null) {
    throw Exception('Token not found');
  }

  final url = Uri.parse('https://flushit.org/update-user');

  // Create a Map to hold the data
  final data = <String, String>{};
  if (updatedUsername != null) {
    data['username'] = updatedUsername;
  }
  if (updatedEmail != null) {
    data['email'] = updatedEmail;
  }
  if (updatedProfilePicture != null) {
    data['profilePicture'] = updatedProfilePicture;
  }

  // Encode the data as JSON
  final jsonData = jsonEncode(data);

  // Set the headers and make the POST request
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonData,
  );

  // Handle the response as needed
  if (response.statusCode == 200 || response.statusCode == 201) {
    return true;
  } else {
    return false;
  }
}


Future<Map<String, dynamic>> fetchUserData() async {
  String? token;
  final url =
      'https://flushit.org/user-data'; // Replace with your server address
  // assuming that you have a way to fetch the token
  token = await storage.readToken();
  // Replace with your way of getting the token

  final response = await http.get(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    return json.decode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Error fetching user data: ${response.statusCode}');
  }
}

class UserInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfo> {


  bool isEditing = false;
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final profilePictureController = TextEditingController();
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if(!loaded) {
        final data = await fetchUserData();
        setState(() {
          userData = data;
          isLoading = false;
          usernameController.text = userData?['username'] ?? '';
          emailController.text = userData?['email'] ?? '';
          profilePictureController.text = userData?['profilePicture'] ?? '';
        });
        loaded = true;
      }
    } catch (error) {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (userData == null) {
      return LoggedOut();
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment
            .start, // Aligns children to the start (left) of the column
        children: [
          Padding(
            padding:
                const EdgeInsets.all(20.0), // Adds padding around the avatar
            child: Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: (userData!['profilePicture'] == null)
                    ? NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQr8HYOWYPZeGsah03Cu0h0v5xq2c8m6d5X3Q&usqp=CAU')
                    : NetworkImage(userData!['profilePicture']),
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0), // Horizontal padding for the Text Widgets
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Aligns text to the left
              children: [
                if (isEditing && errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                Row(
                  children: [
                    if (isEditing)
                      Expanded(
                        child: TextField(
                          controller: usernameController,
                          decoration: InputDecoration(labelText: "Username"),
                        ),
                      )
                    else
                      Text('Username: ${userData!['username']}',
                          style: TextStyle(fontSize: 20)),
                    if(!isEditing)
                    IconButton(
                        onPressed: () {
                          setState(() {
                            loaded = false;
                            isEditing = true;
                          });
                        },
                        icon: Icon(Icons.edit)),
                  ],
                ),
                SizedBox(height: 10),
                if (isEditing)
                  Container(
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: "Email"),
                    ),
                  )
                else
                  Text('Email: ${userData!['email']}',
                      style: TextStyle(fontSize: 20)),
                SizedBox(height: 10),
                if (isEditing)
                  Container(
                    child: TextField(
                      controller: profilePictureController,
                      decoration: InputDecoration(labelText: "Profile Picture URL"),
                    ),
                  ),
                Text('User Rank: ${userData!['rank']}',
                    style: TextStyle(fontSize: 20)),
                if (isEditing)
                  Center(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.deepPurple),
                        overlayColor:
                        MaterialStatePropertyAll<Color>(Colors.deepPurpleAccent),
                      ),
                      onPressed: () async {
                        bool success = false;
                        String? updatedUsername;
                        String? updatedEmail;
                        String? updatedProfilePicture; // Assuming you have a controller for this

                        // Check conditions for username
                        if (usernameController.text != userData!['username']) {
                          if (await isUsernameAvailable(usernameController.text)) {
                            updatedUsername = usernameController.text;
                          } else {
                            setState(() {
                              errorMessage = "Username already taken, try again!";
                            });
                          }
                        }

                        // Check conditions for email
                        if (emailController.text != userData!['email']) {
                          if (await isEmailAvailable(emailController.text)) {
                            updatedEmail = emailController.text;
                          } else {
                            setState(() {
                              errorMessage = "Email already taken, try again!";
                            });
                          }
                        }

                        // Check for profile picture if you have logic for it
                        // Example:
                        if (profilePictureController.text != userData!['profilePicture']) {
                          updatedProfilePicture = profilePictureController.text;
                        }

                        // Only call updateUser if there were no errors
                        if (updatedUsername != null || updatedEmail != null || updatedProfilePicture != null) {
                          success = await updateUser(
                            updatedUsername: updatedUsername,
                            updatedEmail: updatedEmail,
                            updatedProfilePicture: updatedProfilePicture,
                          );
                        } else {
                          success = true;
                        }

                        // Handle backend update
                        if (success) {
                          setState(() {
                            final snackBar = SnackBar(
                              content: Text('Account Updated Successfully'),
                              duration: Duration(seconds: 2),  // Duration to show the SnackBar
                              // Optionally add an action for more user interaction
                            );

                            // Display the snackbar
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            if (updatedUsername != null) userData!['username'] = updatedUsername;
                            if (updatedEmail != null) userData!['email'] = updatedEmail;
                             if (updatedProfilePicture != null) userData!['profilePicture'] = updatedProfilePicture;
                            isEditing = false;
                            errorMessage = "";
                          });
                        }
                      },
                      child: Text("Save", style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        letterSpacing: 2.0,
                      ),),
                    ),
                  ),

              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(
                    16.0), // Adds padding around the logout button
                child: LogoutButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
