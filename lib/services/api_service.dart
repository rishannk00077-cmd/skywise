import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skywise/models/weather_model.dart';

class ApiService {
  static const String _weatherApiKey = 'd8592dbbdd7ee831839feb1a2d774f39';
  static const String _geminiApiKey = 'AIzaSyAqznqfb3Weyns2H82DN76Dx57-bH8yZFM';
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
    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$_geminiApiKey');

      final prompt = '''
      The current weather in ${weather.cityName} is ${weather.temperature}°C, ${weather.description}, humidity ${weather.humidity}%, wind speed ${weather.windSpeed}km/h. 
      Provide 4 specific pieces of advice in JSON format matching exactly these keys: "outfit", "travel", "health", "farming".
      - "outfit": Suggest what to wear today based on the temperature and sky.
      - "travel": Safety/planning advice for local travel.
      - "health": Precautions for these weather conditions.
      - "farming": One specific tip for Indian farmers in these conditions (e.g. irrigation, harvest).
      Keep each response to exactly 1 short sentence.
      ''';

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final aiText = (jsonResponse['candidates'][0]['content']['parts'][0]
                    ['text'] ??
                "I'm sorry, I couldn't process that response.")
            .replaceAll('*', '');

        // Clean up the response if it contains markdown code blocks
        String cleanedJson =
            aiText.replaceAll('```json', '').replaceAll('```', '').trim();

        try {
          final Map<String, dynamic> decoded = jsonDecode(cleanedJson);
          return {
            'outfit': decoded['outfit']?.toString() ??
                "Dress comfortably for ${weather.temperature}°C.",
            'travel': decoded['travel']?.toString() ??
                "Travel normally, but stay aware of ${weather.description}.",
            'health':
                decoded['health']?.toString() ?? "Stay hydrated and active.",
            'farming': decoded['farming']?.toString() ??
                "Monitor your crops regularly.",
          };
        } catch (e) {
          // Fallback if AI response isn't perfect JSON
          return {
            'outfit': "Wear layers suitable for ${weather.temperature}°C.",
            'travel':
                "Check local traffic and weather conditions before heading out.",
            'health':
                "Take normal health precautions for ${weather.description}.",
            'farming':
                "Agriculture: Keep an eye on soil moisture levels today.",
          };
        }
      } else {
        throw Exception('Gemini API Error: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'outfit': "Stay comfortable in current weather.",
        'travel': "Standard travel precautions apply.",
        'health': "Prioritize your well-being today.",
        'farming': "Regular field monitoring recommended.",
      };
    }
  }
}
