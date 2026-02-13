import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:skywise/models/weather_model.dart';

class ApiService {
  static const String _weatherApiKey =
      'YOUR_OPENWEATHERMAP_API_KEY'; // Placeholder
  static const String _geminiApiKey = 'YOUR_GEMINI_API_KEY'; // Placeholder
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
      return list.map((item) => ForecastData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  Future<String> getAIAdvice(WeatherData weather) async {
    final model = GenerativeModel(model: 'gemini-pro', apiKey: _geminiApiKey);
    final prompt =
        'Given the weather in ${weather.cityName} is ${weather.temperature}°C with ${weather.description}, what are some lifestyle recommendations?';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text ?? "Stay safe!";
  }
}
