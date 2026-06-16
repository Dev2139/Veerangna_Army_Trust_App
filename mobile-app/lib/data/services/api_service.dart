import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../models/campaign_model.dart';
import '../models/news_model.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/gallery_model.dart';
import '../models/banner_model.dart';

class ApiService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // --- Auth ---
  Future<String?> register(String name, String email, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.authRegister),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'phone': phone, 'password': password}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        return null; // success
      } else {
        final data = json.decode(response.body);
        return data['error'] ?? 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Network error: ${e.toString()}';
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.authLogin),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Login Error: \$e');
      return false;
    }
  }

  // --- Campaigns ---
  Future<List<CampaignModel>> getCampaigns() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.campaigns));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => CampaignModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Get Campaigns Error: \$e');
      return [];
    }
  }

  // --- News ---
  Future<List<NewsModel>> getNews() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.news));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => NewsModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Get News Error: ${e.toString()}');
      return [];
    }
  }

  // --- Events ---
  Future<List<EventModel>> getEvents() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.events));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => EventModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Get Events Error: ${e.toString()}');
      return [];
    }
  }

  Future<bool> registerForEvent(String eventId, String name, String phone, int attendees) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConstants.events}/$eventId/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'phone': phone,
          'attendees': attendees,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Register Event Error: ${e.toString()}');
      return false;
    }
  }

  // --- Payments ---
  Future<String?> createRazorpayOrder(String campaignId, double amount) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/payments/create-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'campaignId': campaignId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id']; // Razorpay order_id
      }
      return null;
    } catch (e) {
      print('Create Order Error: ${e.toString()}');
      return null;
    }
  }

  Future<bool> verifyPayment(String orderId, String paymentId, String signature, String campaignId, double amount) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/payments/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
          'campaignId': campaignId,
          'amount': amount,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Verify Payment Error: ${e.toString()}');
      return false;
    }
  }

  // --- Gallery ---
  Future<List<GalleryModel>> getGallery() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.gallery));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => GalleryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Get Gallery Error: ${e.toString()}');
      return [];
    }
  }

  Future<List<GalleryModel>> getFoodGallery() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/food-gallery'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => GalleryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Get Food Gallery Error: ${e.toString()}');
      return [];
    }
  }

  // --- Banners ---
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.banners));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => BannerModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Get Banners Error: ${e.toString()}');
      return [];
    }
  }

  // --- Profile ---
  Future<UserModel?> getUserProfile() async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConstants.authProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Get Profile Error: ${e.toString()}');
      return null;
    }
  }
}
