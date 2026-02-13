import 'package:flutter/material.dart';
import 'package:skywise/models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:skywise/controllers/home_controller.dart';
import 'package:provider/provider.dart';
import 'package:skywise/providers/theme_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController _controller = HomeController();

  WeatherData? _weather;
  String _currentCity = "Mumbai";
  String _aiAdvice = "Fetching AI advice...";
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final lastCity = await _controller.loadLastCity();
    _fetchWeatherData(lastCity);
  }

  Future<void> _fetchWeatherData(String city) async {
    setState(() => _isLoading = true);
    try {
      final data = await _controller.fetchWeatherData(city);
      setState(() {
        _weather = data['weather'];
        _aiAdvice = data['advice'];
        _currentCity = data['city'];
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

  Future<void> _handleSaveCity() async {
    await _controller.saveCity(_currentCity);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$_currentCity saved to your list")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(isDark),
        actions: [
          IconButton(
            onPressed: _handleSaveCity,
            icon: Icon(Icons.bookmark_add_outlined,
                color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 25),
                  _buildMainWeatherCard(size),
                  const SizedBox(height: 25),
                  _buildDetailGrid(isDark),
                  const SizedBox(height: 25),
                  _buildAIAdviceSection(isDark),
                  const SizedBox(height: 100), // Navigation buffer
                ],
              ),
            ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: "Search city...",
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          prefixIcon: Icon(Icons.search,
              color: Theme.of(context).primaryColor, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) _fetchWeatherData(value);
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentCity,
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E3A8A)),
        ),
        Text(
          DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
          style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade400),
        ),
      ],
    );
  }

  Widget _buildMainWeatherCard(Size size) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
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
              _getWeatherIcon(_weather?.mainCondition ?? ""),
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

  Widget _getWeatherIcon(String condition) {
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

    return Icon(icon, color: color, size: 80);
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

  Widget _buildDetailGrid(bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 2.5,
      children: [
        _buildSmallDetailCard(Icons.wb_sunny_outlined, "Feels Like",
            "${_weather?.feelsLike.round() ?? '--'}°", isDark),
        _buildSmallDetailCard(Icons.visibility_outlined, "Visibility",
            "${_weather?.visibility.toStringAsFixed(1) ?? '--'} km", isDark),
        _buildSmallDetailCard(Icons.compress_outlined, "Pressure",
            "${_weather?.pressure.round() ?? '--'} hPa", isDark),
        _buildSmallDetailCard(Icons.water_drop_outlined, "Humidity",
            "${_weather?.humidity.round() ?? '--'}%", isDark),
      ],
    );
  }

  Widget _buildSmallDetailCard(
      IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E3A8A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIAdviceSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? Colors.white12 : Colors.blue.shade50),
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
                style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _aiAdvice,
            style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
