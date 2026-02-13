import 'package:skywise/models/weather_model.dart';
import 'package:skywise/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForecastController {
  final ApiService _apiService = ApiService();

  Future<List<ForecastData>> fetchForecast(String city) async {
    return await _apiService.fetchForecast(city);
  }

  Future<String> loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_city') ?? "Mumbai";
  }
}
