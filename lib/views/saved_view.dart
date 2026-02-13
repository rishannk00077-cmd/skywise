import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skywise/models/weather_model.dart';
import 'package:skywise/controllers/saved_controller.dart';
import 'package:provider/provider.dart';
import 'package:skywise/providers/theme_provider.dart';

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
      appBar: AppBar(
        title: const Text("Saved Locations"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.getSavedCitiesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_outlined,
              size: 80, color: isDark ? Colors.white10 : Colors.blue.shade100),
          const SizedBox(height: 20),
          Text("No saved locations yet",
              style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey, fontSize: 16)),
          const Text("Search and bookmark cities on Home",
              style: TextStyle(color: Colors.black26, fontSize: 13)),
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
    return FutureBuilder<WeatherData>(
      future: controller.fetchWeather(cityName),
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Text(
              cityName,
              style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            subtitle: Text(
              snapshot.hasData ? snapshot.data!.mainCondition : "Loading...",
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (snapshot.hasData)
                  Text(
                    "${snapshot.data!.temperature.round()}°",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).primaryColor),
                  ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
