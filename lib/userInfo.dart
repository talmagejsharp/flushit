import 'dart:convert';
import 'package:flushit/customButtons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'global.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_storage_service.dart';

class UserInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InfoPage();
}

class _InfoPage extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('This is a profile page\n We will store user information here'),
        LogoutButton(),
      ],
    );
  }
}
