import 'package:flutter/material.dart';
import 'package:skywise/models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:skywise/controllers/forecast_controller.dart';
import 'package:provider/provider.dart';
import 'package:skywise/providers/theme_provider.dart';
import 'dart:ui';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "7-Day Forecast",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient matching Home
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
              ),
            ),
          ),

          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : SafeArea(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: _forecastList.length,
                    itemBuilder: (context, index) {
                      final item = _forecastList[index];
                      return _buildPremiumForecastCard(item, isDark);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPremiumForecastCard(ForecastData data, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE').format(data.date),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18),
                      ),
                      Text(
                        DateFormat('d MMM').format(data.date),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          data.description,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _getSmallWeatherIcon(data.mainCondition),
                    const SizedBox(height: 8),
                    Text(
                      "${data.temperature.round()}\u00B0",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w200),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSmallWeatherIcon(String condition) {
    IconData icon;
    Color color = Colors.white;

    switch (condition.toLowerCase()) {
      case 'clear':
        icon = Icons.wb_sunny_rounded;
        break;
      case 'clouds':
        icon = Icons.wb_cloudy_rounded;
        break;
      case 'rain':
        icon = Icons.umbrella_rounded;
        break;
      case 'thunderstorm':
        icon = Icons.thunderstorm_rounded;
        break;
      case 'snow':
        icon = Icons.ac_unit_rounded;
        break;
      default:
        icon = Icons.cloud_queue_rounded;
    }

    return Icon(icon, color: color, size: 30);
  }
}
