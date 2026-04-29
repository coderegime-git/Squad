// screens/coach/coach_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/colors.dart';
import 'coach_chat_profile.dart';
import 'coach_dashboard.dart';
import 'coach_events_screen.dart';
import 'coach_groups_events.dart';

class CoachBottomNav extends StatefulWidget {
  const CoachBottomNav({super.key});

  @override
  State<CoachBottomNav> createState() => _CoachBottomNavState();
}

class _CoachBottomNavState extends State<CoachBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CoachDashboard(),
    const CoachGroupsScreen(),
    const CoachEventsScreen(),
    const CoachChatScreen(),
    const CoachProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [BoxShadow(offset: const Offset(0, -4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.black,
            selectedItemColor: accentGreen,
            unselectedItemColor: Colors.grey.shade500,
            showUnselectedLabels: true,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
            ),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.group_rounded),
                label: 'Groups',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_rounded),
                label: 'Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_rounded),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
