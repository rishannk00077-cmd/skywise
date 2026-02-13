import 'package:flutter/material.dart';
import 'package:skywise/models/weather_model.dart';
import 'package:skywise/services/api_service.dart';
import 'package:intl/intl.dart';

class Forecast extends StatefulWidget {
  const Forecast({super.key});

  @override
  State<Forecast> createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  final ApiService _apiService = ApiService();
  List<ForecastData> _forecastList = [];
  bool _isLoading = true;
  final String _city = "Mumbai";

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    try {
      final forecast = await _apiService.fetchForecast(_city);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "7-Day Forecast",
          style:
              TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _forecastList.length,
              itemBuilder: (context, index) {
                final item = _forecastList[index];
                return _buildForecastCard(item);
              },
            ),
    );
  }

  Widget _buildForecastCard(ForecastData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                Text(
                  data.mainCondition,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.wb_cloudy_outlined,
                  color: Color(0xFF3B82F6), size: 24),
              const SizedBox(width: 25),
              Text(
                "${data.temperature.round()}°",
                style: const TextStyle(
                    color: Color(0xFF1E3A8A),
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
}
