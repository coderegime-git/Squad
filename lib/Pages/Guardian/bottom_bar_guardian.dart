// screens/guardian/guardian_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sports/Pages/Guardian/payments.dart';
import 'package:sports/Pages/Guardian/performance.dart';
import 'package:sports/Pages/Guardian/profile.dart';
import 'package:sports/Pages/Guardian/schedule.dart';

import '../../config/colors.dart';
import '../../config/constant.dart';
import 'guardian_chat.dart';
import 'home.dart';
import 'notification.dart';


class GuardianBottomNav extends StatefulWidget {
  const GuardianBottomNav({super.key});

  @override
  State<GuardianBottomNav> createState() => _GuardianBottomNavState();
}

class _GuardianBottomNavState extends State<GuardianBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GuardianDashboard(),
    const ChildScheduleScreen(),
    GuardianMetricsScreen(),
    GuardianChat(),
    GuardianPaymentsScreen(),
    GuardianProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: Container(
        //padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 20.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              //color: Colors.black.withOpacity(0.3),
              //blurRadius: 16,
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
              BottomNavigationBarItem(icon: Icon(Icons.chat_rounded), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Icons.payment_rounded), label: 'Payments'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}