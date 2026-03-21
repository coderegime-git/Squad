import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart' hide whiteColor;
import 'package:sports/Pages/splash.dart';

import '../../config/colors.dart';
import '../config/common.dart';
import '../utills/shared_preference.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: Colors.black87),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sunrise Sports Club',
                        style: boldTextStyle(size: 20),
                      ),
                      4.height,
                      Text(
                        'Guardian Dashboard',
                        style: secondaryTextStyle(size: 12),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(Icons.person, color: primaryColour),
                  ),
                ],
              ),

              24.height,

              /// QUICK STATS CARDS
              Row(
                children: [
                  _statCard(
                    title: 'Members',
                    value: '12',
                    icon: Icons.group,
                    color: Colors.orange.shade300,
                  ),
                  12.width,
                  _statCard(
                    title: 'Events',
                    value: '5',
                    icon: Icons.event,
                    color: Colors.blue.shade300,
                  ),
                ],
              ),
              12.height,
              Row(
                children: [
                  _statCard(
                    title: 'Pending Approvals',
                    value: '2',
                    icon: Icons.pending_actions,
                    color: Colors.red.shade300,
                  ),
                  12.width,
                  _statCard(
                    title: 'Payments Due',
                    value: '₹1500',
                    icon: Icons.payment,
                    color: Colors.green.shade300,
                  ),
                ],
              ),

              24.height,

              /// UPCOMING EVENTS
              Text('Upcoming Events', style: boldTextStyle(size: 18)),
              12.height,
              _eventTile(
                title: 'Cricket Practice',
                subtitle: 'Tomorrow • 6:00 PM',
                icon: Icons.sports_cricket,
              ),
              _eventTile(
                title: 'Swimming Session',
                subtitle: 'Sat • 8:00 AM',
                icon: Icons.pool,
              ),
              _eventTile(
                title: 'Football Match',
                subtitle: 'Sun • 4:00 PM',
                icon: Icons.sports_soccer,
              ),

              24.height,

              /// CHILDREN / MEMBERS
              Text('Your Children', style: boldTextStyle(size: 18)),
              12.height,
              _memberCard(name: 'Arjun Kumar', group: 'Under-14 Cricket'),
              _memberCard(name: 'Riya Kumar', group: 'Beginner Swimming'),
              _memberCard(name: 'Kabir Singh', group: 'Under-10 Football'),

              24.height,

              /// QUICK ACTIONS
              Text('Quick Actions', style: boldTextStyle(size: 18)),
              12.height,
              Row(
                children: [
                  _actionButton(
                    icon: Icons.calendar_today,
                    label: 'View Events',
                  ),
                  12.width,
                  _actionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Messages',
                  ),
                ],
              ),
              12.height,
              Row(
                children: [
                  _actionButton(icon: Icons.person_add, label: 'Add Member'),
                  12.width,
                  _actionButton(icon: Icons.payment, label: 'Payments'),
                ],
              ),
              40.height,
            ],
          ),
        ),
      ),
    );
  }

  /// DRAWER MENU
  Drawer _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              color: primaryColour,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: primaryColour),
                  ),
                  12.height,
                  Text(
                    'Guardian Name',
                    style: boldTextStyle(color: Colors.white),
                  ),
                  4.height,
                  Text(
                    'guardian@club.com',
                    style: secondaryTextStyle(color: Colors.white70, size: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Events'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Members'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Messages'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
            const Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: primaryTextStyle(color: Colors.red)),
              onTap: () {
                SharedPreferenceHelper.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Splash()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// WIDGETS
  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            8.height,
            Text(value, style: boldTextStyle(size: 20, color: Colors.black87)),
            Text(title, style: secondaryTextStyle(size: 12)),
          ],
        ),
      ),
    );
  }

  Widget _eventTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColour),
          12.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: primaryTextStyle()),
              4.height,
              Text(subtitle, style: secondaryTextStyle(size: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _memberCard({required String name, required String group}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryColour.withOpacity(0.2),
            child: Icon(Icons.person, color: primaryColour),
          ),
          12.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: primaryTextStyle()),
              4.height,
              Text(group, style: secondaryTextStyle(size: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColour),
            8.height,
            Text(label, style: primaryTextStyle(size: 13)),
          ],
        ),
      ),
    );
  }
}
