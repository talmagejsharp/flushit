export 'web_storage.dart' if (dart.library.io) 'dummy_or_secure_storage.dart';


abstract class StorageService {
  void clearAllData();
  void saveToken(String token);
  Future<String?> readToken();
}