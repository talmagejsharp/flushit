import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> writeData(String key, String value) async {
    await _storage.write(key: key, value: value);
    print("created a new key with value " + value);
  }

  Future<String?> readData(String key) async {
    print("attempting to read data with key: " + key);

    String? data = await _storage.read(key: key);
    // print("The data associated with " + key + " is " + data!);
    return data;
  }

  Future<void> clearAllData() async {
    await _storage.deleteAll();
  }

// Add more methods as needed...
}

final SecureStorageService secureStorageService = SecureStorageService();
