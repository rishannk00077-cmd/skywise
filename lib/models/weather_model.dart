class WeatherData {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final double humidity;
  final double windSpeed;
  final String description;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.humidity,
    required this.windSpeed,
    required this.description,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      humidity: json['main']['humidity'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      description: json['weather'][0]['description'],
    );
  }
}

class ForecastData {
  final DateTime date;
  final double temperature;
  final String mainCondition;

  ForecastData({
    required this.date,
    required this.temperature,
    required this.mainCondition,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    return ForecastData(
      date: DateTime.fromMicrosecondsSinceEpoch(json['dt'] * 1000),
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
    );
  }
}
