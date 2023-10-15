import 'package:flushit/storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService implements StorageService{
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt', value: token);
  }

  @override
  Future<String?> readToken() async {
    String? data = await _storage.read(key: 'jwt');
    // print("The data associated with " + key + " is " + data!);
    return data;
  }

  @override
  Future<void> clearAllData() async {
    await _storage.deleteAll();
  }

// Add more methods as needed...
}

final SecureStorageService secureStorageService = SecureStorageService();
