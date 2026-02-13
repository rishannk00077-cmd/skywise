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
        title: const Text("Saved Locations",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Gradient
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

          StreamBuilder<QuerySnapshot>(
            stream: _controller.getSavedCitiesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return SafeArea(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    return _CityWeatherCard(
                      cityName: doc['name'],
                      docId: doc.id,
                      controller: _controller,
                      onDelete: () => _controller.removeCity(doc.id),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded,
              size: 100, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          const Text("No saved locations yet",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Search and bookmark cities on Home",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 14)),
        ],
      ),
    );
  }
}

class _CityWeatherCard extends StatelessWidget {
  final String cityName;
  final String docId;
  final SavedController controller;
  final VoidCallback onDelete;
  final bool isDark;

  const _CityWeatherCard({
    required this.cityName,
    required this.docId,
    required this.controller,
    required this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: FutureBuilder<WeatherData>(
              future: controller.fetchWeather(cityName),
              builder: (context, snapshot) {
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(
                    cityName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: -0.5),
                  ),
                  subtitle: Text(
                    snapshot.hasData
                        ? snapshot.data!.mainCondition.toUpperCase()
                        : "LOADING...",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (snapshot.hasData)
                        Text(
                          "${snapshot.data!.temperature.round()}\u00B0",
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w200,
                              color: Colors.white),
                        ),
                      const SizedBox(width: 15),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_rounded,
                            color: Colors.white70, size: 24),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
