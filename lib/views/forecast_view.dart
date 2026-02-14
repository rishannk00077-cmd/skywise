import 'package:flutter/material.dart';
import 'package:skywise/models/weather_model.dart';
import 'package:skywise/controllers/forecast_controller.dart';
import 'package:provider/provider.dart';
import 'package:skywise/providers/theme_provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class Forecast extends StatefulWidget {
  const Forecast({super.key});

  @override
  State<Forecast> createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  final ForecastController _controller = ForecastController();
  List<ForecastData>? _forecast;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    setState(() => _isLoading = true);
    try {
      final city = await _controller.loadLastCity();
      final data = await _controller.fetchForecast(city);
      setState(() {
        _forecast = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
        automaticallyImplyLeading: false,
        title: const Text("Weekly Outlook"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBackground(isDark),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : SafeArea(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 120),
                    itemCount: _forecast?.length ?? 0,
                    itemBuilder: (context, index) {
                      final item = _forecast![index];
                      return _buildForecastCard(item, isDark, index);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF020617)]
              : [const Color(0xFF3B82F6), const Color(0xFFF8FAFC)],
        ),
      ),
    );
  }

  Widget _buildForecastCard(ForecastData data, bool isDark, int index) {
    bool isToday = index == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : (isToday
                      ? Colors.white.withOpacity(0.9)
                      : Colors.white.withOpacity(0.7)),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5))
                    ],
            ),
            child: Row(
              children: [
                _buildDateBlock(data.date, isToday, isDark),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.mainCondition.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: isDark ? Colors.white70 : Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDetailAdvice(data.mainCondition),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${data.temperature.round()}°",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w200,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    _getSmallWeatherIcon(data.mainCondition, isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateBlock(DateTime date, bool isToday, bool isDark) {
    return Column(
      children: [
        Text(
          DateFormat('EEE').format(date).toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: isToday
                ? const Color(0xFF3978EF)
                : (isDark ? Colors.white54 : Colors.grey[600]),
          ),
        ),
        Text(
          DateFormat('dd').format(date),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  String _getDetailAdvice(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return "Perfect for outdoor activities.";
      case 'clouds':
        return "Pleasant overcast skies.";
      case 'rain':
        return "Keep an umbrella handy.";
      case 'thunderstorm':
        return "Better to stay indoors.";
      default:
        return "Outlook remains stable.";
    }
  }

  Widget _getSmallWeatherIcon(String condition, bool isDark) {
    IconData icon;
    Color color;
    switch (condition.toLowerCase()) {
      case 'clear':
        icon = Icons.wb_sunny_rounded;
        color = Colors.amber;
        break;
      case 'clouds':
        icon = Icons.wb_cloudy_rounded;
        color = Colors.grey;
        break;
      case 'rain':
        icon = Icons.umbrella_rounded;
        color = Colors.blue;
        break;
      default:
        icon = Icons.wb_cloudy_rounded;
        color = Colors.grey;
    }
    return Icon(icon, color: color.withOpacity(0.8), size: 20);
  }
}
