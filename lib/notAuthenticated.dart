import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
        Padding(
          padding: const EdgeInsets.all(50.0),
          child: Text(
            'Oops!',
            style: TextStyle(
              color: Colors.deepPurple,
              letterSpacing: 2.0,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(50.0),
          child: Text(
            'You are not authenticated please log in.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStatePropertyAll<Color>(Colors.deepPurple),
                  overlayColor:
                  MaterialStatePropertyAll<Color>(Colors.deepPurpleAccent),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                child: Text('BACK HOME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    letterSpacing: 2.0,
                  ),
                )

            ),
          ),
        )
      ],
    );
  }
}

