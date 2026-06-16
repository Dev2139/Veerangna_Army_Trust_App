import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    } else if (Platform.isAndroid) {
      return 'http://192.168.172.90:5000/api'; // Actual local IP for physical phone
    } else {
      return 'http://192.168.172.90:5000/api';
    }
  }
  
  static String get authLogin => '$baseUrl/auth/login';
  static String get authRegister => '$baseUrl/auth/register';
  static String get authProfile => '$baseUrl/users/profile';
  static String get campaigns => '$baseUrl/campaigns';
  static String get news => '$baseUrl/news';
  static String get events => '$baseUrl/events';
  static String get gallery => '$baseUrl/gallery';
  static String get banners => '$baseUrl/banners/active';
  static String get createOrder => '$baseUrl/donations/create-order';
}
