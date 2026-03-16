// screens/coach/coach_chat.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';

class CoachChatScreen extends StatelessWidget {
  const CoachChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Container(
              height: 85.h,                      // slightly taller → better proportions
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 5.h,
                    left: 20.w,
                    right: 20.w,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Chats",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      //const Spacer(),

                      // GestureDetector(
                      //   onTap: () {
                      //     //Navigator.pushNamed(context, AppRoutes.guardianNotifications);
                      //   },
                      //   child: Stack(
                      //     children: [
                      //       Icon(
                      //         Icons.notifications_none_rounded,
                      //         color: Colors.white,
                      //         size: 26.sp,
                      //       ),
                      //       Positioned(
                      //         right: 0,
                      //         top: 0,
                      //         child: Container(
                      //           width: 10.r,
                      //           height: 10.r,
                      //           decoration: BoxDecoration(
                      //             color: accentOrange,
                      //             shape: BoxShape.circle,
                      //             border: Border.all(
                      //               color: Colors.black,
                      //               width: 1.5,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20.w),
                children: [
                  _ChatTile(
                    name: "Under-14 A Parents",
                    lastMessage: "Tournament schedule confirmed",
                    time: "2h ago",
                    unreadCount: 3,
                  ),
                  _ChatTile(
                    name: "Under-12 B Parents",
                    lastMessage: "Thanks for the feedback!",
                    time: "1d ago",
                    unreadCount: 0,
                  ),
                  _ChatTile(
                    name: "Swimming Parents",
                    lastMessage: "Pool timings updated",
                    time: "2d ago",
                    unreadCount: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;

  const _ChatTile({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: unreadCount > 0 ? accentGreen.withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: accentGreen.withOpacity(0.2),
            child: Icon(Icons.group_rounded, color: accentGreen, size: 28.sp),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                4.height,
                Text(
                  lastMessage,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary),
              ),
              if (unreadCount > 0) ...[
                4.height,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: accentGreen,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "$unreadCount",
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}


// screens/coach/coach_profile.dart
class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldDark,
      body: Column(
        children: [
          Container(
            height: 85.h,                      // slightly taller → better proportions
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 5.h,
                  left: 20.w,
                  right: 20.w,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "My Profile",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //const Spacer(),

                    // GestureDetector(
                    //   onTap: () {
                    //     //Navigator.pushNamed(context, AppRoutes.guardianNotifications);
                    //   },
                    //   child: Stack(
                    //     children: [
                    //       Icon(
                    //         Icons.notifications_none_rounded,
                    //         color: Colors.white,
                    //         size: 26.sp,
                    //       ),
                    //       Positioned(
                    //         right: 0,
                    //         top: 0,
                    //         child: Container(
                    //           width: 10.r,
                    //           height: 10.r,
                    //           decoration: BoxDecoration(
                    //             color: accentOrange,
                    //             shape: BoxShape.circle,
                    //             border: Border.all(
                    //               color: Colors.black,
                    //               width: 1.5,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  55.height,
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 24.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(24.r),
                          color: Colors.white
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Coach Raj Kumar",
                              style: GoogleFonts.montserrat(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                color: accentGreen,
                              ),
                            ),
                            6.height,
                            Text(
                              "Head Football Coach",
                              style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.black),
                            ),
                            4.height,
                            Text(
                              "+91 98765 43210",
                              style: GoogleFonts.poppins(fontSize: 14.sp, color: textSecondary),
                            ),
                            4.height,
                            Text(
                              "raj@xyzfc.com",
                              style: GoogleFonts.poppins(fontSize: 14.sp, color: textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -40.h,
                        child: CircleAvatar(
                          radius: 50.r,
                          backgroundColor: Colors.grey.shade200,
                          child: Text(
                            "RK",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                      ),
                    ],
                  ),

                  20.height,
                  _buildSectionTitle("Assigned Groups"),
                  12.height,
                  _AssignedGroupTile(groupName: "Under-14 A", activity: "Football", members: 18),
                  _AssignedGroupTile(groupName: "Under-12 B", activity: "Football", members: 15),

                  15.height,
                  _buildSectionTitle("Statistics"),
                  12.height,
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: accentGreen.withOpacity(0.35)),
                      color: Colors.white
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatColumn(label: "Total Groups", value: "3"),
                        Container(width: 1, height: 40.h, color: Colors.grey.shade300),
                        _StatColumn(label: "Total Members", value: "45"),
                        Container(width: 1, height: 40.h, color: Colors.grey.shade300),
                        _StatColumn(label: "Sessions", value: "120"),
                      ],
                    ),
                  ),

                  20.height,
                  _buildSectionTitle("Settings"),
                  12.height,
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: "Edit Profile",
                    onTap: () => toast("Edit profile"),
                  ),
                  _SettingsTile(
                    icon: Icons.security_rounded,
                    title: "Privacy & Security",
                    onTap: () => toast("Privacy settings"),
                  ),
                  _SettingsTile(
                    icon: Icons.help_center_rounded,
                    title: "Help & Support",
                    onTap: () => toast("Support"),
                  ),

                  30.height,
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.logout_rounded, color: Colors.redAccent, size: 28.sp),
                      title: Text(
                        "Logout",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: Colors.redAccent),
                      onTap: () => toast("Logging out..."),
                    ),
                  ),
                  100.height,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _AssignedGroupTile extends StatelessWidget {
  final String groupName;
  final String activity;
  final int members;

  const _AssignedGroupTile({
    required this.groupName,
    required this.activity,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: accentGreen.withOpacity(0.2),
            child: Icon(Icons.group_rounded, color: accentGreen, size: 24.sp),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
                Text(
                  "$activity • $members members",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: textSecondary),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: accentGreen,
          ),
        ),
        4.height,
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 24.sp),
            16.width,
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textSecondary),
          ],
        ),
      ),
    );
  }
}
