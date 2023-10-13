import 'dart:convert';
import 'dart:math';
import 'package:flushit/userInfo.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_storage_service.dart';
import 'notAuthenticated.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

Future<bool> newSquat(
    String name, String location, String imageUrl, BuildContext context) async {
  final url = Uri.parse('https://flushit.org/new_squat'); // Replace with your actual URL
  // Create a Map to hold the data
  final data = {'name': name, 'location': location, 'image': imageUrl, 'likes': 0};
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
  State<StatefulWidget> createState() => _LoadHome();

}

Future<String?> retrieveJwtToken() async {
  if (kIsWeb) {
    // Retrieve the JWT from Session Storage for web
    return html.window.sessionStorage['jwt']; // Change to `localStorage` if you stored it there
  } else {
    // Retrieve the JWT using secureStorageService for mobile
    return await secureStorageService.readData('jwt');
  }
}


class _LoadHome extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
    future: retrieveJwtToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Display a loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data != null) {
          // Now, call accessProtectedRoute with a String instead of Future<String?>
          return FutureBuilder<bool>(
            future: accessProtectedRoute(snapshot.data!), // Assuming this returns Future<bool>
            builder: (context, innerSnapshot) {
              if (innerSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (innerSnapshot.hasError) {
                return Text('Error: ${innerSnapshot.error}');
              } else if (innerSnapshot.hasData && innerSnapshot.data == true) {
                return LoggedIn(); // Or whatever you want to display when the user is logged in.
              } else {
                return LoggedOut(); // Or whatever you want to display when the user is not logged in.
              }
            },
          );
        } else {
          return LoggedOut();
        }
      },
    );
  }
}

void _LongClick(Point<double> point, LatLng){
  print("It was tapped for a long time at: " + LatLng.toString());
}

class LoggedIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<LoggedIn> {
  late MapboxMapController mapController;


  @override
  Widget build(BuildContext context) {
      return DefaultTabController(
        length: 4,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 30,
                      margin: EdgeInsets.all(10),
                      child: Image.asset('assets/FlushitIcon.png')),
                  Text(
                    'Flushit',
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 2.0,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                        Icons.map,
                        color: Colors.white54,
                      )),
                ],
              ),
            ),
            body: TabBarView(children: [
              Center(
                  child: Column(
                children: [
                  SquatView(),
                ],
              )),
              Center(child: NewSquat()),
              Center(
                  child: UserInfo()),
              Container(
                height: 300,  // adjust as necessary
                width: 300,
                child: MapboxMap(
                  accessToken: 'pk.eyJ1IjoibWlkZ2U1NDMyMSIsImEiOiJjbG5jMHE2czUwaHduMm1vMWwzaDl1ZmpmIn0.F0c9U1e6dg43W-28N_Qelg',
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  onMapLongClick: _LongClick,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(21.64, -157.92), // This is just a starting point, you can adjust as necessary
                    zoom: 11.0,
                  ),
                  myLocationEnabled: true,
                  myLocationTrackingMode: MyLocationTrackingMode.Tracking,
                ),
              ),
            ])),
      );
      //
      throw UnimplementedError();
    /*} else {

    }*/
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
          return Center(child: CircularProgressIndicator()); // Display a loading indicator
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
  final token = await retrieveJwtToken();
  if (token == null) {
    throw Exception('Token not found');
  }
  final url = Uri.parse('https://flushit.org/squats'); // Replace with your actual URL
  // Create a Map to hold the data
  // Set the headers and make the POST request
  final response = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
  });
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

Future<bool> accessProtectedRoute(String token) async {
  print("Attempting to accessProtectedRoute using token " + token);
  final url = 'https://flushit.org/protected'; // replace with your actual URL
  final response = await http.get(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    print('Successfully accessed protected route!');
    return true;
  } else if (response.statusCode == 401) {
    print('Unauthorized - Token not provided or user not logged in');
    return false;
  } else if (response.statusCode == 403) {
    print('Forbidden - Invalid token');
    return false;
  } else {
    print('Something went wrong');
    return false;
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
  final url = Uri.parse('https://flushit.org/like'); // Replace with your actual URL
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
