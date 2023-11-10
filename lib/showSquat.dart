import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Squat.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home.dart' as home;
import 'main.dart';

class ShowSquat extends StatefulWidget {
  final Squat? squat;
  final VoidCallback onBack;

  ShowSquat({required this.squat, required this.onBack});

  @override
  _ShowSquatState createState() => _ShowSquatState();
}

class _ShowSquatState extends State<ShowSquat> {
  bool isEditing = false;
  bool isEditable = false;
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final imageUrlController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();

  Future<bool> deleteSquat(String squatId) async {
    final token = await storage.readToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final url = Uri.parse('https://flushit.org/squats/$squatId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.squat!.name;
    locationController.text = widget.squat!.location;
    imageUrlController.text = widget.squat!.image;
    if (widget.squat!.coordinates != null) {
      latController.text = widget.squat!.coordinates!.latitude.toString();
      longController.text = widget.squat!.coordinates!.longitude.toString();
    }
    // coordinatesController.text = widget.squat?.coordinates as String;
    if (widget.squat == null) {
      return Text("The squat is null so we are returning nothing!");
    } else {
      print(widget.squat?.isOwner);
      return Column(
        children: [
          Padding(
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
                        onPressed: widget.onBack,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: isEditing
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8.0, left: 10.0, right: 10.0),
                                child: TextField(
                                  controller: titleController,
                                  decoration:
                                      InputDecoration(labelText: 'Name'),
                                ),
                              )
                            : Text(
                                '${widget.squat!.name}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    if(!isEditing && widget.squat?.isOwner == true)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isEditing = !isEditing;
                          });
                        },
                        icon: Icon(Icons.edit),
                      ),
                    if(widget.squat?.isOwner == true)
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Squat'),
                              content: Text('Are you sure you want to delete this squat?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () => Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: Text('Delete'),
                                  onPressed: () => Navigator.of(context).pop(true),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete ?? false) {
                            final success = await deleteSquat(widget.squat!.id);
                            if (success) {
                              home.loaded = false;
                              isEditing = false;
                              setState(() {
                                final snackBar = SnackBar(
                                  content: Text('Squat Deleted Successfully'),
                                  duration: Duration(seconds: 2),  // Duration to show the SnackBar
                                  // Optionally add an action for more user interaction
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => home.LoggedIn()),
                                );
                                // Display the snackbar
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                // if (updatedName != null) squatData!['name'] = updatedName;
                                // if (updatedLocation != null) squatData!['location'] = updatedLocation;
                                // if (updatedImage != null) squatData!['image'] = updatedImage;
                                // if (updatedCoordinates != null) squatData!['coordinates'] = updatedCoordinates;


                                // widget.isLoaded = false;
                              }); // Call the onBack callback to refresh or go back
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to delete squat')),
                              );
                            }
                          }
                        },
                      ),
                  ],
                ),
                Container(
                  height: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10.0),
                      bottom: Radius.circular(10.0),
                    ),
                    child: Image.network(
                      widget.squat!.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isEditing) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: locationController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: imageUrlController,
                      decoration: InputDecoration(labelText: 'Image URL'),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
                            controller: latController,
                            decoration:
                                InputDecoration(labelText: 'Lat Coordinate'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
                            controller: longController,
                            decoration:
                                InputDecoration(labelText: 'Long Coordinate'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Location: ${widget.squat!.location}',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                if (isEditing)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.deepPurple),
                          overlayColor: MaterialStateProperty.all<Color>(
                              Colors.deepPurpleAccent),
                        ),
                        onPressed: () async {
                          bool success = false;
                          String? updatedName;
                          String? updatedLocation;
                          String? updatedImage;
                          Map<String, dynamic>?
                              updatedCoordinates; // Assuming you have controllers for these

                          // Check conditions for name
                          if (titleController.text != widget.squat?.name) {
                            updatedName = titleController.text;
                          }

                          // Check conditions for location
                          if (locationController.text !=
                              widget.squat?.location) {
                            updatedLocation = locationController.text;
                          }

                          // Check for image
                          if (imageUrlController.text != widget.squat?.image) {
                            updatedImage = imageUrlController.text;
                          }

                          // Check for coordinates
                          // Assuming you have two controllers, one for latitude and one for longitude
                          if (latController.text.isNotEmpty &&
                              longController.text.isNotEmpty) {
                            try {
                              double lat = double.parse(latController.text);
                              double long = double.parse(longController.text);
                              updatedCoordinates = {
                                "type": "Point",
                                "coordinates": [long, lat]
                              };
                            } catch (e) {
                              // Handle the error, maybe show a user-friendly message
                              print("Invalid latitude or longitude format.");
                            }
                          }

                          // Only call updateSquat if there are changes
                          if (updatedName != null ||
                              updatedLocation != null ||
                              updatedImage != null ||
                              updatedCoordinates != null) {
                            success = await updateSquat(
                              squatId: widget.squat?.id,
                              updatedName: updatedName,
                              updatedLocation: updatedLocation,
                              updatedImage: updatedImage,
                              updatedCoordinates: updatedCoordinates,
                            );
                          } else {
                            success = true;
                          }

                          // Handle backend update
                          if (success) {
                            home.loaded = false;
                            isEditing = false;
                            setState(() {
                              final snackBar = SnackBar(
                                content: Text('Squat updated Successfully'),
                                duration: Duration(seconds: 2),  // Duration to show the SnackBar
                                // Optionally add an action for more user interaction
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => home.LoggedIn()),
                              );
                              // Display the snackbar
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              // if (updatedName != null) squatData!['name'] = updatedName;
                              // if (updatedLocation != null) squatData!['location'] = updatedLocation;
                              // if (updatedImage != null) squatData!['image'] = updatedImage;
                              // if (updatedCoordinates != null) squatData!['coordinates'] = updatedCoordinates;


                              // widget.isLoaded = false;
                            });
                          }
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      );
    }
  }
}

Future<bool> updateSquat({
  String? squatId,
  String? updatedName,
  String? updatedLocation,
  String? updatedImage,
  Map<String, dynamic>? updatedCoordinates,
}) async {
  print("Attempting to update the squat with coordinates:");
  print(updatedCoordinates);
  final token = await storage.readToken();
  if (token == null) {
    throw Exception('Token not found');
  }

  final url = Uri.parse('https://flushit.org/update-squat');
  // Create a Map to hold the data
  final data = <String, dynamic>{};
  data['squatId'] = squatId;
  if (updatedName != null) {
    data['name'] = updatedName;
  }
  if (updatedLocation != null) {
    data['location'] = updatedLocation;
  }
  if (updatedImage != null) {
    data['image'] = updatedImage;
  }
  if (updatedCoordinates != null) {
    // Ensure that the 'type' is always set to 'Point'
    updatedCoordinates['type'] = 'Point';
    data['coordinates'] = updatedCoordinates; // expects { "type": "Point", "coordinates": [long, lat] }
  }

  // Encode the data as JSON
  final jsonData = jsonEncode(data);

  // Set the headers and make the POST request
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonData,
  );

  // Handle the response as needed
  if (response.statusCode == 200 || response.statusCode == 201) {
    return true;
  } else {
    return false;
  }
}

void _showSquatBottomSheet(BuildContext context, Squat squat) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return ShowSquat(squat: squat, onBack: (){});  // Replace ShowSquatWidget with your widget's name, and pass the squat object to it.
    },
  );
}


