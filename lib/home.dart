import 'dart:convert';
import 'dart:math';
import 'package:flushit/showSquat.dart';
import 'package:flushit/userInfo.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'notAuthenticated.dart';
import 'Squat.dart';
import 'showSquat.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:latlong2/latlong.dart' as latlong2;

List<Squat> squats = [];
bool loaded = false;
Map<String, Squat> _symbolSquatMap = {};

Future<bool> newSquat(
    String name, String location, String imageUrl, BuildContext context) async {
  final token = await storage.readToken();
  if (token == null) {
    throw Exception('Token not found');
  }
  final url = Uri.parse('https://flushit.org/new_squat');

  final data = {
    'name': name,
    'location': location,
    'image': imageUrl,
    'likes': 0
  };

  final jsonData = jsonEncode(data);

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      // If server's response is not successful, print the response body for debugging.
      print('Server responded with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  } catch (e) {
    // If there's an error in sending the request, print the error message for debugging.
    print('Error making request to the server: $e');
    return false;
  }
}


class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoadHome();
}

class _LoadHome extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: storage.readToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child:
                  CircularProgressIndicator()); // Display a loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data != null) {
          // Now, call accessProtectedRoute with a String instead of Future<String?>
          return FutureBuilder<bool>(
            future: accessProtectedRoute(
                snapshot.data!), // Assuming this returns Future<bool>
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

void _LongClick(Point<double> point, LatLng) {
  print("It was tapped for a long time at: " + LatLng.toString());
}

class LoggedIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<LoggedIn> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  MapboxMapController? mapController;
  // Squat talmage = Squat(
  //     id: "234",
  //     name: "Talmage",
  //     location: "At rat house",
  //     likes: 4,
  //     image: "wala",
  //     coordinates: latlong2.LatLng(21.651938, -157.927192));

  @override
  void initState() {
    // squats.add(talmage);
    _tabController = TabController(length: 4, vsync: this);
    super.initState();

  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            controller: _tabController,
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
        body: TabBarView(physics: NeverScrollableScrollPhysics(), controller: _tabController, children: [
          Center(child: SquatView()),
          Center(child: NewSquat(tabController: _tabController,)),
          Center(child: UserInfo()),
          Container(
            height: 300, // adjust as necessary
            width: 300,
            child: MapboxMap(

              accessToken:
                  'pk.eyJ1IjoibWlkZ2U1NDMyMSIsImEiOiJjbG5jMHE2czUwaHduMm1vMWwzaDl1ZmpmIn0.F0c9U1e6dg43W-28N_Qelg',
              onMapCreated: _onMapCreated,
              onMapLongClick: _LongClick,
              onStyleLoadedCallback: _addSquatSymbols,
              initialCameraPosition: const CameraPosition(
                target: LatLng(21.64,
                    -157.92), // This is just a starting point, you can adjust as necessary
                zoom: 11.0,
              ),
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.Tracking,

            ),
          ),
        ]));
    //
    throw UnimplementedError();
    /*} else {

    }*/
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    // _addSquatSymbols();
  }

  void _addSquatSymbols() {
    int x = 0;
    for (var squat in squats) {
      print("Heres a squat");
      if(squat.coordinates != null) {
        print("There I found a squat with coordinates: " +squat.name);
        print(squat.coordinates!.latitude.runtimeType);
        print(squat.coordinates!.longitude.runtimeType);
        x++;
        final symbol = mapController?.addSymbol(SymbolOptions(
          geometry: LatLng(
            squat.coordinates!.latitude,
            squat.coordinates!.longitude, // longitude
          ),

          iconImage:
          'assets/FlushitIcon.png',
          // This assumes you've added a custom marker icon, else you can use 'airport-15' for example
          iconSize: 0.07,
          textField: squat.name,
          textSize: 12.0,
          textOffset: Offset(0, 2),
          // adjust offset as needed
        )
        );
        // _symbolSquatMap.add(symbol, squat);
        
      }
    }
    mapController?.onSymbolTapped.add((symbol) {
      print("A symbol was tapped");
      print(symbol);
      // Deserialize the Squat object from the symbol's data
      // final squatData = jsonDecode(symbol.data!);
      // final tappedSquat = Squat.fromJson(squatData);

      // Show the bottom sheet
      // _showSquatBottomSheet(context, tappedSquat);
    });
  }
}

class NewSquat extends StatefulWidget {
  final TabController? tabController;

  NewSquat({this.tabController});

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Container(
          width: 450,
          height: 600,
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
                        newSquat(enteredName, enteredLocation, enteredImageUrl,
                            context);
                        widget.tabController?.animateTo(0);
                        final snackBar = SnackBar(
                          content: Text('Squat Created Successfully'),
                          duration: Duration(seconds: 2),  // Duration to show the SnackBar
                          // Optionally add an action for more user interaction
                        );

                        // Display the snackbar
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

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
    print("The squat is in fact loaded: ");
    print(loaded);
    if(!loaded)
      return FutureBuilder<List<Squat>>(
        future: fetchSquats(), // Call the asynchronous function here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Display a loading indicator
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return LoggedOut();
          } else if (snapshot.hasData) {
            for(Squat x in snapshot.data!){
              squats.add(x);
            }
            loaded = true;
            return SquatListView(/*squats: snapshot.data!*/); // Pass the actual data
          } else {
            return Text('No data available.');
          }
        },
      );
    else
      return SquatListView();
  }
}

class SquatListView extends StatefulWidget {
  // final List<Squat> squats;

  // SquatListView({required this.squats});

  @override
  State<StatefulWidget> createState() => _SquatListWidget(/*squats: squats*/);
}

class _SquatListWidget extends State<SquatListView> {
  // late final List<Squat> squats;
  Squat? selectedSquat;
  // _SquatListWidget({required this.squats});

  // SquatListWidget({required this.squats});

  @override
  Widget build(BuildContext context) {
    if (selectedSquat != null) {
      return ShowSquat(
          squat: selectedSquat,
          onBack: () {
            setState(() {
              selectedSquat = null;
            });
          });
    }
    double screenWidth = MediaQuery.of(context).size.width;
    int columnsCount = (screenWidth ~/ 200) as int;

    return Padding(
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
          return InkWell(
            onTap: () {
              // Handle the tap here
              setState(() {
                selectedSquat = squat;
              });
            },
            child: Container(
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10.0),
                            bottom: Radius.circular(10.0)),
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
                                fontSize: 14,
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
                            IconButton(
                              icon: Icon(Icons.favorite_border),
                              onPressed: () {},
                            ),
                            Text(squat.likes.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<List<Squat>> fetchSquats() async {
  squats = [];
  final token = await storage.readToken();
  if (token == null) {
    throw Exception('Token not found');
  }
  final url =
      Uri.parse('https://flushit.org/squats'); // Replace with your actual URL
  // Create a Map to hold the data
  // Set the headers and make the POST request
  final response = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
  });

  // Handle the response as needed
  // ...
  if (response.statusCode == 200 || response.statusCode == 201) {
    final List<dynamic> jsonData = json.decode(response.body);
    print("Successful retrival of squats!");
    return jsonData.map((data) => Squat.fromJson(data)).toList();
  } else {
    print('Server responded with status code: ${response.statusCode}');
    print('Response body: ${response.body}'); // This will print the response body
    throw Exception('Failed to load squats');
  }
}

Future<bool> accessProtectedRoute(String token) async {
  final url = 'https://flushit.org/protected'; // replace with your actual URL
  final response = await http.get(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return true;
  } else if (response.statusCode == 401) {
    return false;
  } else if (response.statusCode == 403) {
    return false;
  } else {
    return false;
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
  final url =
      Uri.parse('https://flushit.org/like'); // Replace with your actual URL
  // Create a Map to hold the data
  // Encode the data as JSON
  // Set the headers and make the POST request
  final response = await http.patch(
    url,
    headers: {'Content-Type': 'application/json'},
    body:
        null, //somehow make it so it just adds one to the number of likes already there
  );

  // Handle the response as needed
  // ...
  if (response.statusCode == 200 || response.statusCode == 201) {
    return true;
  } else {
    return false;
  }
}


