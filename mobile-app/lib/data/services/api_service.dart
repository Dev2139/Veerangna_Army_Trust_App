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
import '../models/wallet_model.dart';

class ApiService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Clears the stored token when the server rejects it (expired/invalid),
  /// so the app can redirect the user to the login screen.
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // --- Auth ---
  Future<String?> register(String name, String email, String phone, String password, Map<String, dynamic> billingInfo) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.authRegister),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'billingInfo': billingInfo,
        }),
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
  Future<Map<String, dynamic>?> createCashfreeOrder(String campaignId, double amount) async {
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
        return json.decode(response.body);
      }
      print('Create Order Failed (${response.statusCode}): ${response.body}');
      return null;
    } catch (e) {
      print('Create Order Error: ${e.toString()}');
      return null;
    }
  }

  Future<bool> verifyPayment(String orderId, String paymentId, String campaignId, double amount) async {
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
          'order_id': orderId,
          'payment_id': paymentId,
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
      if (response.statusCode == 401) {
        // Token expired or invalid — clear it so the user is sent to login.
        await _clearToken();
      }
      return null;
    } catch (e) {
      print('Get Profile Error: ${e.toString()}');
      return null;
    }
  }

  Future<UserModel?> updateProfile({String? name, String? phone, Map<String, dynamic>? billingInfo}) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (billingInfo != null) body['billingInfo'] = billingInfo;

      final response = await http.put(
        Uri.parse(ApiConstants.authProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Update Profile Error: ${e.toString()}');
      return null;
    }
  }

  Future<UserModel?> uploadProfilePhoto(String filePath) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/users/upload-photo'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Upload Profile Photo Error: ${e.toString()}');
      return null;
    }
  }

  // --- Wallet ---

  /// Get the current user's wallet (creates one if it doesn't exist)
  Future<WalletModel?> getWallet() async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConstants.wallet),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return WalletModel.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Get Wallet Error: ${e.toString()}');
      return null;
    }
  }

  /// Create a Cashfree order to top-up wallet.
  Future<Map<String, dynamic>?> createWalletTopUpOrder(double amount) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse(ApiConstants.walletAddMoneyOrder),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'amount': amount}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      print('Create Wallet TopUp Order Failed (${response.statusCode}): ${response.body}');
      return null;
    } catch (e) {
      print('Create Wallet TopUp Order Error: ${e.toString()}');
      return null;
    }
  }

  /// Verify Cashfree payment for wallet top-up. Returns new balance on success.
  Future<Map<String, dynamic>?> verifyWalletTopUp(
      String orderId, String paymentId, double amount) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse(ApiConstants.walletAddMoneyVerify),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'order_id': orderId,
          'payment_id': paymentId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Verify Wallet TopUp Error: ${e.toString()}');
      return null;
    }
  }

  /// Donate from wallet balance to a campaign. Returns response map on success.
  Future<Map<String, dynamic>?> donateFromWallet(String campaignId, double amount) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse(ApiConstants.walletDonate),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'campaignId': campaignId, 'amount': amount}),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return data;
      }
      // Return error info too so UI can show message
      return {'error': data['error'] ?? 'Failed to donate from wallet'};
    } catch (e) {
      print('Donate From Wallet Error: ${e.toString()}');
      return null;
    }
  }
}
