// screens/member/member_notifications.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';

class MemberNotificationsScreen extends StatelessWidget {
  const MemberNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: scaffoldDark,
        body: Column(
          children: [
            // Container(
            //   height: 80.h,
            //   width: double.infinity,
            //   padding: EdgeInsets.symmetric(horizontal: 20.w),
            //   decoration: BoxDecoration(
            //     color: Colors.black.withOpacity(0.9),
            //     border: Border(
            //       bottom: BorderSide(
            //         color: Colors.white.withOpacity(0.08),
            //         width: 0.5,
            //       ),
            //     ),
            //   ),
            //   child: Padding(
            //     padding: EdgeInsets.only(top: 20),
            //     child: Row(
            //       children: [
            //         // Icon(
            //         //   Icons.menu_outlined,
            //         //   color: Colors.white,
            //         //   size: 20.sp,
            //         // ),
            //         // 10.width,
            //
            //         Text("Notifications",style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: cardDark,fontSize: 20.sp,fontWeight: FontWeight.bold,),),
            //         const Spacer(),
            //         // GestureDetector(
            //         //   onTap: (){
            //         //     Navigator.pushNamed(context, AppRoutes.guardianNotifications);
            //         //   },
            //         //   //onTap: () => toast("Notifications tapped"),
            //         //   child: Stack(
            //         //     children: [
            //         //       Icon(
            //         //         Icons.notifications_none_rounded,
            //         //         color: Colors.white,
            //         //         size: 26.sp,
            //         //       ),
            //         //       Positioned(
            //         //         right: 0,
            //         //         top: 0,
            //         //         child: Container(
            //         //           width: 10.r,
            //         //           height: 10.r,
            //         //           decoration: BoxDecoration(
            //         //             color: accentOrange,
            //         //             shape: BoxShape.circle,
            //         //             border: Border.all(
            //         //               color: Colors.black,
            //         //               width: 1.5,
            //         //             ),
            //         //           ),
            //         //         ),
            //         //       ),
            //         //     ],
            //         //   ),
            //         // ),
            //
            //         //20.width,
            //
            //         // Child switcher
            //         // GestureDetector(
            //         //   onTap: () => toast("Switch child"),
            //         //   child: CircleAvatar(
            //         //     radius: 20.r,
            //         //     backgroundColor: accentGreen.withOpacity(0.3),
            //         //     child: Icon(
            //         //       Icons.swap_horiz_rounded,
            //         //       color: accentGreen,
            //         //       size: 24.sp,
            //         //     ),
            //         //   ),
            //         // ),
            //       ],
            //     ),
            //   ),
            // ),
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
                        "Notifications",
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
                  _NotificationTile(
                    title: "New event scheduled",
                    subtitle: "Coach Raj scheduled a training session for Saturday",
                    time: "2h ago",
                    isUnread: true,
                  ),
                  _NotificationTile(
                    title: "Performance feedback received",
                    subtitle: "Coach Sarah added feedback on your swimming technique",
                    time: "1d ago",
                    isUnread: true,
                  ),
                  _NotificationTile(
                    title: "Match reminder",
                    subtitle: "Weekend match starts in 2 days. Confirm availability.",
                    time: "2d ago",
                    isUnread: false,
                  ),
                  _NotificationTile(
                    title: "Payment reminder",
                    subtitle: "Membership renewal due in 5 days",
                    time: "3d ago",
                    isUnread: false,
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

class _NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool isUnread;

  const _NotificationTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isUnread ? accentGreen.withOpacity(0.05) : cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isUnread ? accentGreen.withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          if (isUnread)
            Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(
                color: accentGreen,
                shape: BoxShape.circle,
              ),
              margin: EdgeInsets.only(right: 12.w),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                4.height,
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: textSecondary,
                  ),
                ),
                4.height,
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// screens/member/member_profile.dart
class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      child: Scaffold(
        backgroundColor: scaffoldDark,
        body: Column(
          children: [
            // Container(
            //   height: 80.h,
            //   width: double.infinity,
            //   padding: EdgeInsets.symmetric(horizontal: 20.w),
            //   decoration: BoxDecoration(
            //     color: Colors.black.withOpacity(0.9),
            //     border: Border(
            //       bottom: BorderSide(
            //         color: Colors.white.withOpacity(0.08),
            //         width: 0.5,
            //       ),
            //     ),
            //   ),
            //   child: Padding(
            //     padding: EdgeInsets.only(top: 20),
            //     child: Row(
            //       children: [
            //         Text("My Profile",style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: cardDark,fontSize: 20.sp,fontWeight: FontWeight.bold,),),
            //         const Spacer(),
            //       ],
            //     ),
            //   ),
            // ),
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
                                "Abinesh Kumar",
                                style: GoogleFonts.montserrat(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  color: accentGreen,
                                ),
                              ),
                              6.height,
                              Text(
                                "Member • +91 98765 43210",
                                style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.black),
                              ),
                              4.height,
                              Text(
                                "abinesh@gmail.com",
                                style: GoogleFonts.poppins(fontSize: 14.sp, color: textSecondary),
                              ),
                              4.height,
                              Text(
                                "Member since Jan 2024",
                                style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
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
                              "AK",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                    20.height,

                    _buildSectionTitle("My Activities"),
                    12.height,
                    _ActivityTile(
                      clubName: "XYZ FC",
                      activity: "Football",
                      group: "Under-14 A",
                    ),
                    _ActivityTile(
                      clubName: "ABC Sports",
                      activity: "Swimming",
                      group: "Intermediate B",
                    ),

                    15.height,
                    _buildSectionTitle("Membership Status"),
                    12.height,

                    // XYZ FC Membership
                    _MembershipStatusCard(
                      clubName: "XYZ FC",
                      activity: "Football",
                      validUntil: "Feb 15, 2026",
                      status: "No Dues",
                      statusColor: accentGreen,
                    ),
                    12.height,

                    // ABC Sports Membership
                    _MembershipStatusCard(
                      clubName: "ABC Sports",
                      activity: "Swimming",
                      validUntil: "Mar 20, 2026",
                      status: "No Dues",
                      statusColor: accentGreen,
                    ),

                    20.height,
                    _buildSectionTitle("Settings"),
                    12.height,
                    _SettingsTile(
                      icon: Icons.security_rounded,
                      title: "Privacy & Security",
                      subtitle: "Manage data & permissions",
                      onTap: () => toast("Privacy settings – coming soon"),
                    ),
                    12.height,
                    _SettingsTile(
                      icon: Icons.help_center_rounded,
                      title: "Help & Support",
                      subtitle: "FAQ, contact club, report issue",
                      onTap: () => toast("Support options"),
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

// New widget for individual membership card
class _MembershipStatusCard extends StatelessWidget {
  final String clubName;
  final String activity;
  final String validUntil;
  final String status;
  final Color statusColor;

  const _MembershipStatusCard({
    required this.clubName,
    required this.activity,
    required this.validUntil,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: statusColor.withOpacity(0.35)),
        color: Colors.white
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clubName,
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    4.height,
                    Text(
                      activity,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: textSecondary,
                      ),
                    ),
                    4.height,
                    Text("Active",style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: accentGreen,fontWeight: FontWeight.bold),)

                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          16.height,
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 16.sp, color: textSecondary),
              8.width,
              Text(
                "Valid until $validUntil",
                style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String clubName;
  final String activity;
  final String group;

  const _ActivityTile({
    required this.clubName,
    required this.activity,
    required this.group,
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
            child: Icon(Icons.sports_soccer_rounded, color: accentGreen, size: 24.sp),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clubName,
                  style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
                Text(
                  "$activity • $group",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 26.sp),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black)),
                  2.height,
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textSecondary, size: 24.sp),
          ],
        ),
      ),
    );
  }
}