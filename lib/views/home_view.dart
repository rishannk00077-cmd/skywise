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
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  WeatherData? _weather;
  String _currentCity = "Mumbai";
  Map<String, String> _aiAdvice = {
    'outfit': 'Fetching suggestions...',
    'travel': 'Fetching suggestions...',
    'health': 'Fetching suggestions...',
    'farming': 'Fetching suggestions...',
  };
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _initData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    try {
      // Try fetching current location first
      await _fetchWeatherByLocation();
    } catch (e) {
      // Fallback to last city if location fails
      final lastCity = await _controller.loadLastCity();
      _fetchWeatherData(lastCity);
    }
  }

  Future<void> _fetchWeatherData(String city) async {
    setState(() {
      _isLoading = true;
      _fadeController.reset();
    });
    try {
      final data = await _controller.fetchWeatherData(city);
      setState(() {
        _weather = data['weather'];
        _aiAdvice = data['advice'];
        _currentCity = data['city'];
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Location not found: $city"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchWeatherByLocation() async {
    setState(() {
      _isLoading = true;
      _fadeController.reset();
    });
    try {
      final data = await _controller.fetchWeatherByLocation();
      setState(() {
        _weather = data['weather'];
        _aiAdvice = data['advice'];
        _currentCity = data['city'];
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location Error: ${e.toString()}")),
        );
        // If location fails and we don't have weather yet, load last city
        if (_weather == null) {
          final lastCity = await _controller.loadLastCity();
          _fetchWeatherData(lastCity);
        } else {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _handleSaveCity() async {
    await _controller.saveCity(_currentCity);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$_currentCity bookmarked successfully"),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
    }
  }

  List<Color> _getBackgroundColors(String? condition, bool isDark) {
    if (isDark) {
      return [
        const Color(0xFF0F172A),
        const Color(0xFF1E293B),
        const Color(0xFF020617),
      ];
    }
    switch (condition?.toLowerCase()) {
      case 'clear':
        return [
          const Color(0xFF2DD4BF),
          const Color(0xFF0EA5E9),
          const Color(0xFF2563EB)
        ];
      case 'clouds':
        return [
          const Color(0xFF94A3B8),
          const Color(0xFF475569),
          const Color(0xFF1E293B)
        ];
      case 'rain':
      case 'drizzle':
        return [
          const Color(0xFF60A5FA),
          const Color(0xFF2563EB),
          const Color(0xFF1E3A8A)
        ];
      case 'thunderstorm':
        return [
          const Color(0xFF334155),
          const Color(0xFF0F172A),
          const Color(0xFF020617)
        ];
      default:
        return [
          const Color(0xFF3B82F6),
          const Color(0xFF1D4ED8),
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
          _buildActionIcon(Icons.my_location_rounded, _fetchWeatherByLocation),
          _buildActionIcon(Icons.bookmark_border_rounded, _handleSaveCity),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _buildAnimatedBackground(bgColors, size),
          if (_isLoading)
            const Center(
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
          else
            FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildMainWeatherCard(size),
                      const SizedBox(height: 32),
                      _buildDetailGrid(),
                      const SizedBox(height: 40),
                      _buildAIAdvisorHeader(),
                      const SizedBox(height: 20),
                      _buildAICategorizedAdvice(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildAnimatedBackground(List<Color> colors, Size size) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: _buildOrb(250, Colors.white.withOpacity(0.08)),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: _buildOrb(200, Colors.white.withOpacity(0.05)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 50,
            spreadRadius: 20,
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: "Search city...",
              hintStyle:
                  TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Colors.white70, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentCity,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, d MMMM').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            _getPulseIcon(_weather?.mainCondition ?? ""),
          ],
        ),
      ],
    );
  }

  Widget _getPulseIcon(String condition) {
    IconData iconData = Icons.wb_cloudy_rounded;
    Color iconColor = Colors.white;

    switch (condition.toLowerCase()) {
      case 'clear':
        iconData = Icons.wb_sunny_rounded;
        iconColor = Colors.amberAccent;
        break;
      case 'rain':
        iconData = Icons.umbrella_rounded;
        break;
      case 'thunderstorm':
        iconData = Icons.thunderstorm_rounded;
        break;
      default:
        iconData = Icons.wb_cloudy_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Icon(iconData, color: iconColor, size: 28),
    );
  }

  Widget _buildMainWeatherCard(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            "${_weather?.temperature.round() ?? '--'}°",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 120,
              fontWeight: FontWeight.w100,
              letterSpacing: -8,
            ),
          ),
          Text(
            _weather?.mainCondition.toUpperCase() ?? "UNKNOWN",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoTilePremium(
                  Icons.air_rounded, "${_weather?.windSpeed} km/h"),
              _infoTilePremium(
                  Icons.water_drop_rounded, "${_weather?.humidity}%"),
              _infoTilePremium(Icons.cloud_rounded, "${_weather?.description}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTilePremium(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDetailGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _buildDetailCard(Icons.thermostat_rounded, "FEELS LIKE",
            "${_weather?.feelsLike.round()}°"),
        _buildDetailCard(Icons.visibility_rounded, "VISIBILITY",
            "${_weather?.visibility} km"),
        _buildDetailCard(
            Icons.compress_rounded, "PRESSURE", "${_weather?.pressure} hPa"),
        _buildDetailCard(
            Icons.water_drop_outlined, "HUMIDITY", "${_weather?.humidity}%"),
      ],
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white60, size: 20),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIAdvisorHeader() {
    return Row(
      children: [
        const Icon(Icons.auto_awesome_rounded,
            color: Colors.amberAccent, size: 24),
        const SizedBox(width: 12),
        const Text(
          "SKYWISE ADVISOR",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amberAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text("PRO",
              style: TextStyle(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 10)),
        ),
      ],
    );
  }

  Widget _buildAICategorizedAdvice() {
    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          int count = constraints.maxWidth > 600 ? 4 : 2;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: count,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              _buildAdviceCard(Icons.checkroom_rounded, "Outfit",
                  _aiAdvice['outfit']!, Colors.orangeAccent),
              _buildAdviceCard(Icons.flight_takeoff_rounded, "Travel",
                  _aiAdvice['travel']!, Colors.blueAccent),
              _buildAdviceCard(Icons.health_and_safety_rounded, "Health",
                  _aiAdvice['health']!, Colors.greenAccent),
              _buildAdviceCard(Icons.agriculture_rounded, "Farming",
                  _aiAdvice['farming']!, Colors.amberAccent),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildAdviceCard(
      IconData icon, String title, String advice, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              advice,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w500),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
