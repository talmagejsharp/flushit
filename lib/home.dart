import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'global.dart';

Future<bool> newSquat(String name, String location, String imageUrl, BuildContext context) async {
  final url = Uri.parse('http://localhost:3000/new_squat'); // Replace with your actual URL
  // Create a Map to hold the data
  final data = {'name': name, 'location': location, 'image': imageUrl};
  print(data);
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
    print('Squat created successfully');
    return true;
  } else {
    print('Failed to create squat');
    print(response.statusCode);
    return false;
  }
}



class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    if (isAuthenticated == true) {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'Flushit',
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 2.0,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.deepPurple,
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.bathroom, color: Colors.white54,),),
                  Tab(icon: Icon(
                    Icons.add_box_rounded, color: Colors.white54,)),
                  Tab(icon: Icon(Icons.person, color: Colors.white54,)),
                ],
              ),

            ),
            body: TabBarView(
                children: [
                  Center(child: Column(
                    children: [
                      Text(
                          'Hello, ' + globalUserName + ' Welcome to Flushit!'),
                      SquatView(),
                    ],
                  )),
                  Center(child: NewSquat()),
                  Center(child: Column(
                    children: [
                      Text(
                          'This is a profile page\n We will store user information here'),
                      ElevatedButton(onPressed: () {
                        print('attempting to log out');
                        Navigator.pushNamed(context, '/');
                        globalUserName = "";
                        isAuthenticated = false;
                      }, child: Text('LOGOUT'))
                    ],
                  )),
                ]
            )


        ),
      );
      //
      throw UnimplementedError();
    } else {
      return Column(children: [
        Text('You are not authenticated please log in',
        ),
        ElevatedButton(onPressed: (){
          Navigator.pushNamed(context, '/');
        }, child: Text('Back to Home'))
      ],);
    }
  }


}

class NewSquat extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewSquatState();
}

class _NewSquatState extends State<NewSquat> {
  String enteredName = '';
  String errorMessage = '';
  String enteredLocation = '';
  String enteredImageUrl = '';
  int numberOfLikes = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Create a new Squat'),
        TextField(
          onChanged: (String value) async {
            enteredName = value;
          },
          decoration: InputDecoration(
            labelText: 'Squat Name',
          ),
        ),
        SizedBox(height: 16),
        TextField(
          onChanged: (String value) async {
            enteredLocation = value;
          },

          decoration: InputDecoration(
            labelText: 'Squat Location',
          ),
        ),
        TextField(
          onChanged: (String value) async {
            enteredImageUrl = value;
          },
          decoration: InputDecoration(
            labelText: 'Squat Image URL',
          ),
        ),
        errorMessage.isNotEmpty
            ? Text(
          errorMessage,
          style: TextStyle(color: Colors.red),
        )
            : SizedBox(), // Empty SizedBox when no error message
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if(enteredName != '' && enteredImageUrl != '' && enteredLocation != ''){
              print(enteredName + enteredLocation + enteredImageUrl);
              newSquat(enteredName, enteredLocation, enteredImageUrl, context);
            }
            else {
              errorMessage = 'Please enter a name, location and url for your squat';
              setState(() {});
            }
          },
          child: Text('Create'),
        ),
        Text('lets see if this will even work shall we'),
        Text('yes, we shall'),
      ],
    );

  }

}

class SquatView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewSquatView();
}

class _NewSquatView extends State<SquatView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Squat>>(
      future: fetchSquats(), // Call the asynchronous function here
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Display a loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return SquatListWidget(
              squats: snapshot.data!); // Pass the actual data
        } else {
          return Text('No data available.');
        }
      },
    );
  }
}

class SquatListWidget extends StatelessWidget  {
  final List<Squat> squats; // Receive the squats list as a parameter

  SquatListWidget({required this.squats});
  @override
  Widget build(BuildContext context) {
    print('attempting to display ' + squats.length.toString()
    );
    return Container(
      height: 400,
      child: Center(
        child: ListView.builder(
          itemCount: squats.length,
          itemBuilder: (context, index) {
            final squat = squats[index];
            return ListTile(
              leading: Image.network(squat.image),
              title: Text(squat.name),
              subtitle: Text(squat.location),
              // trailing: Text('Visits : ${squat.visits.toString()}')
            );
          },
        ),
      ),
    );
  }
}

Future<List<Squat>> fetchSquats() async {
  final url = Uri.parse('http://localhost:3000/squats'); // Replace with your actual URL
  // Create a Map to hold the data
  // Set the headers and make the POST request
  final response = await http.get(
    url
  );
  print('attempting to retrieve squats');

  // Handle the response as needed
  // ...
  if (response.statusCode == 200 || response.statusCode == 201) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((data) => Squat.fromJson(data)).toList();
  } else {
    print(response.statusCode);
    throw Exception('Failed to load squats');
  }
}

class Squat {
  final String name;
  final String location;
  // final int visits;
  final String image;

  Squat({
    required this.name,
    required this.location,
    // required this.visits,
    required this.image,
  });

  factory Squat.fromJson(Map<String, dynamic> json) {
    return Squat(
      name: json['name'],
      location: json['location'],
      // visits: json['visits'],
      image: json['image'],
    );
  }
}


