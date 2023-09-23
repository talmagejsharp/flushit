import 'dart:convert';
import 'package:flushit/customButtons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'global.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_storage_service.dart';

String userEmail = "";
String userName = "";


Future<Map<String, dynamic>> fetchUserData() async {
  final url = 'https://flushit.org/user-data'; // Replace with your server address

  // assuming that you have a way to fetch the token
  String? token = await secureStorageService.readData(
      'jwt'); // Replace with your way of getting the token

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
      return Center(child: Text('No user data available'));
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQr8HYOWYPZeGsah03Cu0h0v5xq2c8m6d5X3Q&usqp=CAU'), // Replace with NetworkImage for network image
            backgroundColor: Colors.deepPurple,
          ),
          SizedBox(height: 20),
          Text(
            'Username: ${userData!['username']}',
            style: TextStyle( fontSize: 20),
          ),
          SizedBox(height: 10),
          Text(
            'Email: ${userData!['email']}',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),
          Text(
            'Password: *********',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),
          Text(
            'User Rank: Gold',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          LogoutButton(),
          // other widgets displaying user data
        ],
      ),
    );
  }
}

