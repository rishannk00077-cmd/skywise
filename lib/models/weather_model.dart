class WeatherData {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final double humidity;
  final double windSpeed;
  final String description;
  final double pressure;
  final double visibility;
  final double feelsLike;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.pressure,
    required this.visibility,
    required this.feelsLike,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      humidity: json['main']['humidity'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      description: json['weather'][0]['description'],
      pressure: json['main']['pressure'].toDouble(),
      visibility: (json['visibility'] ?? 0) / 1000.0, // convert to km
      feelsLike: json['main']['feels_like'].toDouble(),
    );
  }
}

class ForecastData {
  final DateTime date;
  final double temperature;
  final String mainCondition;
  final String description;

  ForecastData({
    required this.date,
    required this.temperature,
    required this.mainCondition,
    required this.description,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    return ForecastData(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
    );
  }
}
