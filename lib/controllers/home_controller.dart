import 'package:skywise/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeController {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> fetchWeatherData(String city) async {
    final weather = await _apiService.fetchWeather(city);
    final advice = await _apiService.getAIAdvice(weather);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_city', city);

    return {
      'weather': weather,
      'advice': advice,
      'city': city,
    };
  }

  Future<String> loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_city') ?? "Mumbai";
  }

  Future<void> saveCity(String city) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('saved_cities')
          .doc(city)
          .set({'name': city, 'timestamp': FieldValue.serverTimestamp()});
    }
  }
}
