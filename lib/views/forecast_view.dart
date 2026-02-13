import 'package:flutter/material.dart';
import 'package:skywise/models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:skywise/controllers/forecast_controller.dart';
import 'package:provider/provider.dart';
import 'package:skywise/providers/theme_provider.dart';

class Forecast extends StatefulWidget {
  const Forecast({super.key});

  @override
  State<Forecast> createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  final ForecastController _controller = ForecastController();
  List<ForecastData> _forecastList = [];
  bool _isLoading = true;
  String _city = "Mumbai";

  @override
  void initState() {
    super.initState();
    _loadCityAndFetchForecast();
  }

  Future<void> _loadCityAndFetchForecast() async {
    final city = await _controller.loadLastCity();
    setState(() {
      _city = city;
    });
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    setState(() => _isLoading = true);
    try {
      final forecast = await _controller.fetchForecast(_city);
      setState(() {
        _forecastList = forecast;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("7-Day Forecast"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _forecastList.length,
              itemBuilder: (context, index) {
                final item = _forecastList[index];
                return _buildForecastCard(item, isDark);
              },
            ),
    );
  }

  Widget _buildForecastCard(ForecastData data, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, d MMM').format(data.date),
                  style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                Text(
                  data.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _getWeatherIcon(data.mainCondition),
              const SizedBox(width: 25),
              Text(
                "${data.temperature.round()}°",
                style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                    fontSize: 22,
                    fontWeight: FontWeight.w900),
              ),
              const Icon(Icons.chevron_right, color: Colors.black12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getWeatherIcon(String condition) {
    IconData icon;
    Color color = const Color(0xFF3B82F6);

    switch (condition.toLowerCase()) {
      case 'clear':
        icon = Icons.wb_sunny_outlined;
        color = Colors.orange;
        break;
      case 'clouds':
        icon = Icons.wb_cloudy_outlined;
        break;
      case 'rain':
        icon = Icons.umbrella_outlined;
        break;
      case 'thunderstorm':
        icon = Icons.thunderstorm_outlined;
        break;
      case 'snow':
        icon = Icons.ac_unit_outlined;
        break;
      default:
        icon = Icons.cloud_queue_outlined;
    }

    return Icon(icon, color: color, size: 28);
  }
}
