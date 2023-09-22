import 'package:flutter/material.dart';
import 'secure_storage_service.dart';

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
          secureStorageService.clearAllData();
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