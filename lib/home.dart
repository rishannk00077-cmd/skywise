import 'package:flutter/material.dart';
import 'package:skywise/models/weather_model.dart';
import 'package:skywise/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ApiService _apiService = ApiService();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  WeatherData? _weather;
  String _currentCity = "Mumbai";
  String _aiAdvice = "Fetching AI advice...";
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWeatherData(_currentCity);
  }

  Future<void> _fetchWeatherData(String city) async {
    setState(() => _isLoading = true);
    try {
      final weather = await _apiService.fetchWeather(city);
      final advice = await _apiService.getAIAdvice(weather);

      setState(() {
        _weather = weather;
        _aiAdvice = advice;
        _currentCity = city;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not find city: $city")),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveCity(String city) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('saved_cities')
          .doc(city)
          .set({'name': city, 'timestamp': FieldValue.serverTimestamp()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$city saved to your list")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: _buildSearchBar(),
        actions: [
          IconButton(
            onPressed: () => _saveCity(_currentCity),
            icon: const Icon(Icons.bookmark_add_outlined,
                color: Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 25),
                  _buildMainWeatherCard(size),
                  const SizedBox(height: 25),
                  _buildDetailGrid(),
                  const SizedBox(height: 25),
                  _buildAIAdviceSection(),
                  const SizedBox(height: 100), // Navigation buffer
                ],
              ),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: "Search city...",
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Color(0xFF1E3A8A), size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 11),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) _fetchWeatherData(value);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentCity,
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A)),
        ),
        Text(
          DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
          style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade400),
        ),
      ],
    );
  }

  Widget _buildMainWeatherCard(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_weather?.temperature.round() ?? '--'}°C",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _weather?.mainCondition ?? "Loading...",
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        letterSpacing: 1.2),
                  ),
                ],
              ),
              Image.network(
                "https://cdn-icons-png.flaticon.com/512/414/414927.png",
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.cloud_outlined,
                    size: 80,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoTile(Icons.air, "${_weather?.windSpeed ?? 0} km/h", "Wind"),
              _infoTile(
                  Icons.water_drop, "${_weather?.humidity ?? 0}%", "Humidity"),
              _infoTile(Icons.cloud_outlined,
                  "${_weather?.description ?? 'Cloudy'}", "Sky"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildDetailGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 2.5,
      children: [
        _buildSmallDetailCard(Icons.wb_sunny_outlined, "Feels Like",
            "${_weather?.temperature.round() ?? '--'}°"),
        _buildSmallDetailCard(Icons.visibility_outlined, "Visibility", "10 km"),
        _buildSmallDetailCard(Icons.compress_outlined, "Pressure", "1012 hPa"),
        _buildSmallDetailCard(Icons.beach_access_outlined, "UV Index", "Low"),
      ],
    );
  }

  Widget _buildSmallDetailCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B82F6), size: 24),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIAdviceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 22),
              const SizedBox(width: 10),
              Text(
                "Skywise Assistant".toUpperCase(),
                style: const TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _aiAdvice,
            style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
