// screens/member/member_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/colors.dart';
import 'member_dashboard.dart';
import 'member_notifications_profile.dart';
import 'member_schedule.dart';
import 'member_performance.dart';


class MemberBottomNav extends StatefulWidget {
  const MemberBottomNav({super.key});

  @override
  State<MemberBottomNav> createState() => _MemberBottomNavState();
}

class _MemberBottomNavState extends State<MemberBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MemberDashboard(),
    const MemberScheduleScreen(),
    const MemberMetricsScreen(),
    const MemberNotificationsScreen(),
    const MemberProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -4),
            ),
          ],
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
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Schedule'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Metrics'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
