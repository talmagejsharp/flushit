import 'package:latlong2/latlong.dart';

class Squat {
  final String id;
  final String? ownerId; // To reference the User model's ObjectId as a String
  final String name;
  final String location;
  final int likes;
  final String image;
  final LatLng? coordinates;
  final bool? isOwner; // Optional property to indicate ownership

  Squat({
    required this.id,
    this.ownerId,
    required this.name,
    required this.location,
    required this.likes,
    required this.image,
    this.coordinates,
    this.isOwner, // Make isOwner optional
  });

  factory Squat.fromJson(Map<String, dynamic> json) {
    return Squat(
      id: json['_id'],
      ownerId: json['owner'], // Assuming the 'owner' field contains the ObjectId of the user
      name: json['name'],
      location: json['location'],
      likes: json['likes'],
      image: json['image'],
      coordinates: json['coordinates'] != null ? LatLng(
        json['coordinates']['coordinates'][1], // Latitude
        json['coordinates']['coordinates'][0], // Longitude
      ) : null,
      isOwner: json['isOwner'], // This field might not be present in all responses, hence it is nullable
    );
  }
}
