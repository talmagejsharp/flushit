import 'dart:convert';
import 'package:flushit/customButtons.dart';
import 'package:flushit/secure_storage_service.dart';
import 'package:flushit/storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'notAuthenticated.dart';
import 'package:flutter/foundation.dart';

String userEmail = "";
String userName = "";


Future<Map<String, dynamic>> fetchUserData() async {
  String? token;
  final url = 'https://flushit.org/user-data'; // Replace with your server address

  // assuming that you have a way to fetch the token
  token = await storage.readToken();
  // Replace with your way of getting the token

  final response = await http.get(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer $token'},
  );
  print(json.decode(response.body));
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
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await fetchUserData();
      setState(() {
        userData = data;
        isLoading = false;
      });
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
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start (left) of the column
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0), // Adds padding around the avatar
            child: Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQr8HYOWYPZeGsah03Cu0h0v5xq2c8m6d5X3Q&usqp=CAU'),
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Horizontal padding for the Text Widgets
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left
              children: [
                Row(
                  children: [
                    Text('Username: ${userData!['username']}', style: TextStyle(fontSize: 20)),
                    IconButton(onPressed: (){}, icon: Icon(Icons.edit)),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Email: ${userData!['email']}', style: TextStyle(fontSize: 20)),
                    IconButton(onPressed: (){}, icon: Icon(Icons.edit)),
                  ],
                ),
                SizedBox(height: 10),
                Text('User Rank: Gold', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Adds padding around the logout button
                child: LogoutButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

