import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skywise/models/weather_model.dart';
import 'package:skywise/services/api_service.dart';

class SavedController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  Stream<QuerySnapshot> getSavedCitiesStream() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('saved_cities')
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
    return const Stream.empty();
  }

  Future<WeatherData> fetchWeather(String city) async {
    return await _apiService.fetchWeather(city);
  }

  Future<void> removeCity(String city) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('saved_cities')
          .doc(city)
          .delete();
    }
  }
}
