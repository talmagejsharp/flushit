import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'global.dart';

Future<bool> newSquat(
    String name, String location, String imageUrl, BuildContext context) async {
  final url = Uri.parse(
      'http://flushit.org/new_squat'); // Replace with your actual URL
  // Create a Map to hold the data
  final data = {'name': name, 'location': location, 'image': imageUrl, 'likes': 0};
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
        length: 4,
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
                  Tab(
                    icon: Icon(
                      Icons.location_pin,
                      color: Colors.white54,
                    ),
                  ),
                  Tab(
                      icon: Icon(
                    Icons.add_box_rounded,
                    color: Colors.white54,
                  )),
                  Tab(
                      icon: Icon(
                    Icons.person,
                    color: Colors.white54,
                  )),
                  Tab(
                      icon: Icon(
                    Icons.add_circle,
                    color: Colors.white54,
                  )),
                ],
              ),
            ),
            body: TabBarView(children: [
              Center(
                  child: Column(
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(40.0),
                  //   child: Text(
                  //       'Hello, ' + globalUserName + ' Welcome to Flushit!'),
                  // ),
                  SquatView(),
                ],
              )),
              Center(child: NewSquat()),
              Center(
                  child: Column(
                children: [
                  Text(
                      'This is a profile page\n We will store user information here'),
                  ElevatedButton(
                      onPressed: () {
                        print('attempting to log out');
                        Navigator.pushNamed(context, '/');
                        globalUserName = "";
                        isAuthenticated = false;
                      },
                      child: Text('LOGOUT'))
                ],
              )),
              Center(child: ImagePickerScreen()),
            ])),
      );
      //
      throw UnimplementedError();
    } else {
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
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
        width: 450,
        height: 600,
        decoration: BoxDecoration(
          // color: Color.fromRGBO(255, 250, 255, 1),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.deepPurpleAccent,
          //     spreadRadius: 5,
          //     blurRadius: 7,
          //     offset: Offset(3, 3), // changes position of shadow
          //   ),
          // ],
          border: Border.all(
            color: Colors.black26,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Text(
                'Create your new Squat ',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Expanded(
                  child: IconButton(
                icon: Icon(
                  Icons.add_box_rounded,
                  size: 50,
                  color: Colors.black26,
                ),
                onPressed: () {},
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      // Remove the overlay color for hovered state
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.transparent;
                      }
                      return Colors
                          .transparent; // Use the default overlay color for other states
                    },
                  ),
                ),
              )),
              TextField(
                onChanged: (String value) async {
                  enteredName = value;
                },
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              // SizedBox(height: 16),
              TextField(
                onChanged: (String value) async {
                  enteredLocation = value;
                },
                decoration: InputDecoration(
                  labelText: 'Location',
                ),
              ),
              TextField(
                onChanged: (String value) async {
                  enteredImageUrl = value;
                },
                decoration: InputDecoration(
                  labelText: 'Image URL',
                ),
              ),
              errorMessage.isNotEmpty
                  ? Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    )
                  : SizedBox(), // Empty SizedBox when no error message
              Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.deepPurple),
                    overlayColor: MaterialStatePropertyAll<Color>(
                        Colors.deepPurpleAccent),
                  ),
                  onPressed: () {
                    if (enteredName != '' &&
                        enteredImageUrl != '' &&
                        enteredLocation != '') {
                      print(enteredName + enteredLocation + enteredImageUrl);
                      newSquat(enteredName, enteredLocation, enteredImageUrl,
                          context);
                    } else {
                      errorMessage =
                          'Please enter a name, location and url for your squat';
                      setState(() {});
                    }
                  },
                  child: Text(
                    'CREATE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              Text('lets see if this will even work shall we'),
              Text('yes, we shall'),
            ],
          ),
        ),
      ),
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

class SquatListWidget extends StatelessWidget {
  final List<Squat> squats;

  SquatListWidget({required this.squats});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int columnsCount = (screenWidth ~/200) as int;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnsCount, // Adjust the number of columns here
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: squats.length,
          itemBuilder: (context, index) {
            final squat = squats[index];
            // int likes = squat.likes;
            String textLikes;
            return Container(
              // decoration: BoxDecoration(
              //   color: Color.fromRGBO(255, 250, 255, 1),
              //   border: Border.all(
              //     color: Colors.black26,
              //     width: 2,
              //   ),
              //   borderRadius: BorderRadius.circular(10.0),
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10.0), bottom:Radius.circular(10.0) ),
              child: Image.network(
                squat.image,
                fit: BoxFit.cover,
              ),
            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              squat.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              squat.location,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Expanded(child: SizedBox()),
                        Column(
                          children: [
                            IconButton(icon: Icon(Icons.favorite_border), onPressed: () {  }, ),
                            Text(squat.likes.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


Future<List<Squat>> fetchSquats() async {
  final url =
      Uri.parse('http://flushit.org/squats'); // Replace with your actual URL
  // Create a Map to hold the data
  // Set the headers and make the POST request
  final response = await http.get(url);
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
   final int likes;
  final String image;

  Squat({
    required this.name,
    required this.location,
    required this.likes,
    required this.image,
  });

  factory Squat.fromJson(Map<String, dynamic> json) {
    return Squat(
      name: json['name'],
      location: json['location'],
       likes: json['likes'],
      image: json['image'],
    );
  }
}

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Picker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!)
                : Placeholder(
                    fallbackHeight: 200.0, fallbackWidth: double.infinity),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: Text('Pick Image from Gallery'),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: Text('Take a New Picture'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> like(String id) async {
  final url = Uri.parse(
      'http://flushit.org/like'); // Replace with your actual URL
  // Create a Map to hold the data
  // Encode the data as JSON
  // Set the headers and make the POST request
  final response = await http.patch(
    url,
    headers: {'Content-Type': 'application/json'},
    body: null, //somehow make it so it just adds one to the number of likes already there
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
