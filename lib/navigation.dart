import 'package:flutter/material.dart';
import 'package:skywise/forecast.dart';
import 'package:skywise/home.dart';
import 'package:skywise/profile.dart';
import 'package:skywise/saved.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int index = 0;
  List<Widget> Pages = [Home(), Forecast(), Saved(), Profile()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.blueGrey.shade200,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: "Forecast"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmarks), label: "Saved"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Could open an AI dialog here
        },
        elevation: 4,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.auto_awesome),
      ),
      body: Pages[index],
    );
  }
}
