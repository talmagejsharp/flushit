import 'package:latlong2/latlong.dart';

class Squat {
  final String name;
  final String location;
  final int likes;
  final String image;
  final LatLng? coordinates;  // Using LatLng class here

  Squat({
    required this.name,
    required this.location,
    required this.likes,
    required this.image,
    this.coordinates,
  });

  factory Squat.fromJson(Map<String, dynamic> json) {
    return Squat(
      name: json['name'],
      location: json['location'],
      likes: json['likes'],
      image: json['image'],
      coordinates: json['coordinates'] != null ? LatLng(
        json['coordinates']['coordinates'][1], // Latitude
        json['coordinates']['coordinates'][0], // Longitude
      ) : null,
    );
  }
}