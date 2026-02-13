import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skywise/services/api_service.dart';
import 'package:skywise/models/weather_model.dart';

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Saved Locations",
          style:
              TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('saved_cities')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return _CityWeatherCard(
                cityName: doc['name'],
                docId: doc.id,
                apiService: _apiService,
                onDelete: () => _deleteCity(doc.id),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_outlined,
              size: 80, color: Colors.blue.shade100),
          const SizedBox(height: 20),
          const Text("No saved locations yet",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          const Text("Search and bookmark cities on Home",
              style: TextStyle(color: Colors.black26, fontSize: 13)),
        ],
      ),
    );
  }

  void _deleteCity(String id) {
    _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('saved_cities')
        .doc(id)
        .delete();
  }
}

class _CityWeatherCard extends StatelessWidget {
  final String cityName;
  final String docId;
  final ApiService apiService;
  final VoidCallback onDelete;

  const _CityWeatherCard({
    required this.cityName,
    required this.docId,
    required this.apiService,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherData>(
      future: apiService.fetchWeather(cityName),
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
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
              style: const TextStyle(
                  color: Color(0xFF1E3A8A),
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
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3B82F6)),
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
