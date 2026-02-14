import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skywise/models/weather_model.dart';
import 'package:skywise/controllers/saved_controller.dart';
import 'package:provider/provider.dart';
import 'package:skywise/providers/theme_provider.dart';
import 'dart:ui';

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  final SavedController _controller = SavedController();

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Saved Locations"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBackground(isDark),
          StreamBuilder<QuerySnapshot>(
            stream: _controller.getSavedCitiesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return SafeArea(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    return _PremiumCityCard(
                      cityName: doc['name'],
                      docId: doc.id,
                      controller: _controller,
                      isDark: isDark,
                    );
                  },
                ),
              );
            },
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
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF020617)]
              : [const Color(0xFF60A5FA), const Color(0xFFF8FAFC)],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(Icons.bookmark_add_outlined,
                size: 64, color: isDark ? Colors.white24 : Colors.grey[300]),
          ),
          const SizedBox(height: 32),
          Text(
            "No Saved Locations",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Quickly access weather for your\nfavorite cities here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey[600],
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumCityCard extends StatelessWidget {
  final String cityName;
  final String docId;
  final SavedController controller;
  final bool isDark;

  const _PremiumCityCard({
    required this.cityName,
    required this.docId,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
                    ],
            ),
            child: FutureBuilder<WeatherData>(
              future: controller.fetchWeather(cityName),
              builder: (context, snapshot) {
                final hasData = snapshot.hasData;
                final weather = snapshot.data;

                return Dismissible(
                  key: Key(docId),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => controller.removeCity(docId),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 32),
                    color: Colors.redAccent.withOpacity(0.85),
                    child: const Icon(Icons.delete_sweep_rounded,
                        color: Colors.white, size: 28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cityName,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasData
                                    ? weather!.mainCondition.toUpperCase()
                                    : "SYNCING...",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hasData)
                          Row(
                            children: [
                              Text(
                                "${weather!.temperature.round()}°",
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                              const SizedBox(width: 20),
                              _getSmallIcon(weather.mainCondition),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSmallIcon(String condition) {
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
    return Icon(icon, color: color.withOpacity(0.8), size: 28);
  }
}
