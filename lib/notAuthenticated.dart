import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'global.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_storage_service.dart';


class LoggedOut extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Unauthenticated();
}

class _Unauthenticated extends State<LoggedOut> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'You are not authenticated please log in',
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
            child: Text('Back to Home'))
      ],
    );
  }
}

