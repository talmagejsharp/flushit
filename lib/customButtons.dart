import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flushit/secure_storage_service.dart';
import 'main.dart';
import 'storage.dart';


class LogoutButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
          MaterialStatePropertyAll<Color>(Colors.deepPurple),
          overlayColor:
          MaterialStatePropertyAll<Color>(Colors.deepPurpleAccent),
        ),
        onPressed: () {
          storage.clearAllData();
          Navigator.pushNamed(context, '/');
        },
        child: Text(
          'LOGOUT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            letterSpacing: 2.0,
          ),
        ));
  }
}