import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class DioService {
  static final DioService _singleton = DioService._internal();
  final dio = Dio();



  DioService._internal() {
    final cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

  }

  factory DioService() {
    return _singleton;
  }
}