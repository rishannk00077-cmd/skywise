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
  int index=0;
  List<Widget>Pages=[Home(),Forecast(),Saved(),Profile()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index=value;
          }
          );
        },
        selectedItemColor: Colors.blue.shade400,
        unselectedItemColor: Colors.blue.shade900,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home",backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: "Forecast",backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Saved",backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: "Profile",backgroundColor: Colors.white),
         
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {},
      child: Icon(Icons.auto_awesome),
      backgroundColor: Colors.blue.shade900,
      foregroundColor: Colors.white,
      ),
      body: Pages[index],
    );
  }
}
