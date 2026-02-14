import 'package:skywise/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class HomeController {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> fetchWeatherData(String city) async {
    final weather = await _apiService.fetchWeather(city);
    final advice = await _apiService.getPersonalizedAIAdvice(weather);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_city', city);

    // Log to history in Firebase
    await _addToHistory(city);

    return {
      'weather': weather,
      'advice': advice,
      'city': city,
    };
  }

  Future<Map<String, dynamic>> fetchWeatherByLocation() async {
    Position position = await _determinePosition();
    final weather = await _apiService.fetchWeatherByCoords(
        position.latitude, position.longitude);
    final advice = await _apiService.getPersonalizedAIAdvice(weather);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_city', weather.cityName);

    await _addToHistory(weather.cityName);

    return {
      'weather': weather,
      'advice': advice,
      'city': weather.cityName,
    };
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
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

  Future<void> _addToHistory(String city) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add({
        'city': city,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
