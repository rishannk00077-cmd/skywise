import 'package:flutter/material.dart';
import 'package:skywise/models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:skywise/controllers/home_controller.dart';
import 'package:provider/provider.dart';
import 'package:skywise/providers/theme_provider.dart';
import 'dart:ui';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
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
        SnackBar(
          content: Text("$_currentCity saved to your list"),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  List<Color> _getBackgroundColors(String? condition, bool isDark) {
    if (isDark) {
      return [
        const Color(0xFF0F172A),
        const Color(0xFF1E293B),
        const Color(0xFF334155)
      ];
    }
    switch (condition?.toLowerCase()) {
      case 'clear':
        return [
          const Color(0xFF38BDF8),
          const Color(0xFF0EA5E9),
          const Color(0xFF0369A1)
        ];
      case 'clouds':
        return [
          const Color(0xFF94A3B8),
          const Color(0xFF64748B),
          const Color(0xFF475569)
        ];
      case 'rain':
      case 'drizzle':
        return [
          const Color(0xFF60A5FA),
          const Color(0xFF3B82F6),
          const Color(0xFF1D4ED8)
        ];
      case 'thunderstorm':
        return [
          const Color(0xFF475569),
          const Color(0xFF1E293B),
          const Color(0xFF0F172A)
        ];
      default:
        return [
          const Color(0xFF3B82F6),
          const Color(0xFF2563EB),
          const Color(0xFF1E3A8A)
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final size = MediaQuery.of(context).size;
    final bgColors = _getBackgroundColors(_weather?.mainCondition, isDark);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildSearchBar(isDark),
        actions: [
          IconButton(
            onPressed: _handleSaveCity,
            icon: const Icon(Icons.bookmark_add, color: Colors.white),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgColors,
              ),
            ),
          ),

          // Background Orbs for extra "wow"
          Positioned(
            top: -50,
            right: -50,
            child: _buildOrb(180, Colors.white.withOpacity(0.1)),
          ),
          Positioned(
            bottom: 100,
            left: -30,
            child: _buildOrb(150, Colors.white.withOpacity(0.05)),
          ),

          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildGlassWeatherCard(size),
                        const SizedBox(height: 30),
                        _buildDetailGrid(),
                        const SizedBox(height: 30),
                        _buildAIAdviceSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: "Search city...",
              hintStyle: TextStyle(color: Colors.white70, fontSize: 13),
              prefixIcon: Icon(Icons.search, color: Colors.white, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _fetchWeatherData(value);
                _searchController.clear();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              _currentCity,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5),
            ),
          ],
        ),
        Text(
          DateFormat('EEEE, d MMMM').format(DateTime.now()),
          style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildGlassWeatherCard(Size size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                        "${_weather?.temperature.round() ?? '--'}\u00B0",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 86,
                            fontWeight: FontWeight.w200,
                            letterSpacing: -4),
                      ),
                      Text(
                        _weather?.mainCondition.toUpperCase() ?? "UNKNOWN",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2),
                      ),
                    ],
                  ),
                  _getWeatherIcon(_weather?.mainCondition ?? ""),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoTile(Icons.air_rounded,
                        "${_weather?.windSpeed ?? 0} km/h", "WIND"),
                    _infoTile(Icons.water_drop_rounded,
                        "${_weather?.humidity ?? 0}%", "HUMIDITY"),
                    _infoTile(Icons.cloud_rounded,
                        "${_weather?.description ?? 'Cloudy'}", "SKY"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getWeatherIcon(String condition) {
    IconData icon;
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 70),
    );
  }

  Widget _infoTile(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
                letterSpacing: 1)),
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
      childAspectRatio: 2.2,
      children: [
        _buildGlassDetailCard(Icons.thermostat_rounded, "FEELS LIKE",
            "${_weather?.feelsLike.round() ?? '--'}\u00B0"),
        _buildGlassDetailCard(Icons.visibility_rounded, "VISIBILITY",
            "${_weather?.visibility.toStringAsFixed(1) ?? '--'} km"),
        _buildGlassDetailCard(Icons.compress_rounded, "PRESSURE",
            "${_weather?.pressure.round() ?? '--'} hPa"),
        _buildGlassDetailCard(Icons.water_drop_rounded, "HUMIDITY",
            "${_weather?.humidity.round() ?? '--'}%"),
      ],
    );
  }

  Widget _buildGlassDetailCard(IconData icon, String label, String value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIAdviceSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: Colors.amberAccent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    "SKYWISE ADVISOR",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 2),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                _aiAdvice,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
