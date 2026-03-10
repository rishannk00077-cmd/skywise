import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skywise/models/weather_model.dart';
import 'package:skywise/services/ai_service.dart';

class ApiService {
  static const String _weatherApiKey = 'd8592dbbdd7ee831839feb1a2d774f39';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final AIService _aiService = AIService();

  Future<WeatherData> fetchWeather(String city) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/weather?q=$city&appid=$_weatherApiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<WeatherData> fetchWeatherByCoords(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_weatherApiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<ForecastData>> fetchForecast(String city) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/forecast?q=$city&appid=$_weatherApiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body)['list'];
      List<ForecastData> fullList =
          list.map((item) => ForecastData.fromJson(item)).toList();

      Map<String, ForecastData> dailyForecasts = {};
      for (var item in fullList) {
        String day = "${item.date.year}-${item.date.month}-${item.date.day}";
        if (!dailyForecasts.containsKey(day) || item.date.hour == 12) {
          dailyForecasts[day] = item;
        }
      }
      return dailyForecasts.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  Future<Map<String, String>> getPersonalizedAIAdvice(
      WeatherData weather) async {
    return await _aiService.getWeatherAdvice(
      weather.description,
      weather.temperature,
      weather.humidity,
      weather.windSpeed,
      weather.cityName,
    );
  }
}
