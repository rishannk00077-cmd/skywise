import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:skywise/models/weather_model.dart';

class ApiService {
  static const String _weatherApiKey =
      'd8592dbbdd7ee831839feb1a2d774f39'; // Placeholder
  static const String _geminiApiKey = 'AIzaSyAs8s29JPwoZbE8JCyD2PY8xKj37lfugVc'; // Placeholder
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

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

  Future<List<ForecastData>> fetchForecast(String city) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/forecast?q=$city&appid=$_weatherApiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body)['list'];
      List<ForecastData> fullList =
          list.map((item) => ForecastData.fromJson(item)).toList();

      // Filter to get one forecast per day (around 12:00:00 if possible)
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

  Future<String> getAIAdvice(WeatherData weather) async {
    try {
      final model = GenerativeModel(model: 'gemini-pro', apiKey: _geminiApiKey);
      final prompt =
          'Given the weather in ${weather.cityName} is ${weather.temperature}°C with ${weather.description}, what are some lifestyle recommendations? Keep it brief (2-3 sentences).';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ??
          "Enjoy your day and stay prepared for the ${weather.mainCondition}!";
    } catch (e) {
      return "Stay safe and check local weather alerts regularly!";
    }
  }
}
