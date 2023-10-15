import 'package:flushit/storage.dart';

class DummyWebStorage implements StorageService {
  @override
  void clearAllData() {
    throw UnimplementedError('WebStorage is only for web');
  }

  @override
  void saveToken(String token) {
    throw UnimplementedError('WebStorage is only for web');
  }

  @override
  Future<String?> readToken() async {
    throw UnimplementedError('WebStorage is only for web');
  }
}
