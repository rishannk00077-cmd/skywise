import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _groqApiKey =
      'gsk_5yvWntK6Tq0N738K5Nf1WGdyb3FY0KqM18K93SjGf8K12L9N73';
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  Future<String> getChatResponse(List<Map<String, String>> messages) async {
    try {
      final formattedMessages = [
        {
          "role": "system",
          "content":
              "You are Skywise AI, a professional weather assistant. Provide helpful, accurate, and concise weather-related advice and information."
        },
        ...messages.map((m) => {
              "role": m['role'] == 'user' ? "user" : "assistant",
              "content": m['content']
            })
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          "model": _model,
          "messages": formattedMessages,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['choices'][0]['message']['content'] ??
            "I'm sorry, I couldn't process that.";
      } else {
        throw Exception('Groq API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI Service Error: $e');
    }
  }

  Future<Map<String, String>> getWeatherAdvice(String weatherDescription,
      double temp, double humidity, double windSpeed, String city) async {
    try {
      final prompt = '''
      The current weather in $city is $temp°C, $weatherDescription, humidity $humidity%, wind speed ${windSpeed}km/h. 
      Provide 4 specific pieces of advice in JSON format matching exactly these keys: "outfit", "travel", "health", "farming".
      - "outfit": Suggest what to wear today.
      - "travel": Safety/planning advice for local travel.
      - "health": Precautions for these weather conditions.
      - "farming": One specific tip for Indian farmers.
      Keep each response to exactly 1 short sentence. Return ONLY the JSON.
      ''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          "model": _model,
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "response_format": {"type": "json_object"}
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final aiText = jsonResponse['choices'][0]['message']['content'];
        return Map<String, String>.from(jsonDecode(aiText));
      } else {
        throw Exception('Groq API Error: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'outfit': "Dress comfortably for current weather.",
        'travel': "Standard travel precautions apply.",
        'health': "Prioritize your well-being today.",
        'farming': "Regular field monitoring recommended.",
      };
    }
  }
}
