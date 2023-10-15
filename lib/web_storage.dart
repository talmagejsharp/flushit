import 'dart:html' as html;
import 'package:flushit/storage.dart';

class WebStorage implements StorageService{
  @override
  void saveToken(String token){
    html.window.sessionStorage['jwt'] = token;
  }
  @override
  Future<String?> readToken() async {
    return html.window.sessionStorage['jwt'];
  }
  @override
  void clearAllData(){
    html.window.localStorage.clear();
    html.window.sessionStorage.clear();
  }
  // Implement your web-specific storage methods here using html.window.sessionStorage and similar
}

final WebStorage webStorage = WebStorage();