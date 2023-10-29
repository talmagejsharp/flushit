import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Squat.dart';

class ShowSquat extends StatelessWidget {
  final Squat? squat;
  final VoidCallback onBack;

  ShowSquat({required this.squat, required this.onBack});

  @override
  Widget build(BuildContext context) {
    if (squat == null) {
      return Text("The squat is null so we are returning nothing!");
    } else {
      print("The squat is not null. It has a name value of "+ squat!.name);
      return Column(
        // appBar: AppBar(title: Text(squat!.name)),
        children: [Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: onBack,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text('${squat!.name}',
                        style: TextStyle(
                          // color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Container(
                height: 300,  // Or any other value you deem appropriate
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10.0), bottom:Radius.circular(10.0) ),
                  child: Image.network(
                    squat!.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),


              Text('Reps: ${squat!.location}'),
              // ... display other details
            ],
          ),
        ),],
      );

    }
  }
}
