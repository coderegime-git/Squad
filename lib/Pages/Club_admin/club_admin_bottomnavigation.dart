// screens/clubadmin/clubadmin_bottom_nav.dart
// Changes:
// - Groups tab now shows standalone ClubAdminGroupsScreen
// - Removed Link Child to Guardian from nav
// - FIXED: Every tab now rebuilds fresh when clicked (no more stale data)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/colors.dart';
import 'club_admin_dashboard.dart';
import 'club_admin_members.dart';
import 'club_admin_notifications.dart';
import 'club_admin_schedule.dart';
import 'club_admin_groups_and_subgroups.dart';

class ClubAdminBottomNav extends StatefulWidget {
  const ClubAdminBottomNav({super.key});

  @override
  State<ClubAdminBottomNav> createState() => _ClubAdminBottomNavState();
}

class _ClubAdminBottomNavState extends State<ClubAdminBottomNav> {
  int _currentIndex = 0;

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const ClubAdminDashboard();
      case 1:
        return const ClubAdminScheduleScreen();
      case 2:
        return const ClubAdminMembersScreen();
      case 3:
        return const ClubAdminGroupsScreen();     // Groups
      case 4:
        return const ClubAdminNotificationsScreen();
      default:
        return const ClubAdminDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Key Fix: This rebuilds the screen fresh every time you switch tabs
      body: _buildScreen(_currentIndex),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -4),
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
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
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded),
                label: 'Schedule',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_rounded),
                label: 'Members',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group_rounded),
                label: 'Groups',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.notifications_rounded),
              //   label: 'Notifications',
              // ),
            ],
          ),
        ),
      ),
    );
  }
}