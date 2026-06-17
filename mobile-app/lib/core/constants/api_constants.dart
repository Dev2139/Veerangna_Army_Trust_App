import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static const String baseUrl = 'https://veerangna-army-trust-app.vercel.app/api';
  
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
