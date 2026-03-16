// screens/clubadmin/clubadmin_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/colors.dart';
import 'club_admin_dashboard.dart';
import 'club_admin_groups_notifications.dart';
import 'club_admin_members.dart';
import 'club_admin_schedule.dart';
// import 'clubadmin_dashboard.dart';
// import 'clubadmin_schedule.dart';
// import 'clubadmin_members.dart';
// import 'clubadmin_groups.dart';
// import 'clubadmin_notifications.dart';

class ClubAdminBottomNav extends StatefulWidget {
  const ClubAdminBottomNav({super.key});

  @override
  State<ClubAdminBottomNav> createState() => _ClubAdminBottomNavState();
}

class _ClubAdminBottomNavState extends State<ClubAdminBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ClubAdminDashboard(),
    const ClubAdminScheduleScreen(),
    const ClubAdminMembersScreen(),
    const ClubAdminGroupsScreen(),
    const ClubAdminNotificationsScreen(),
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
              BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Members'),
              BottomNavigationBarItem(icon: Icon(Icons.group_rounded), label: 'Groups'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Notifications'),
            ],
          ),
        ),
      ),
    );
  }
}
