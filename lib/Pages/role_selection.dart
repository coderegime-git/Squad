// lib/pages/onboarding/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../routes/app_routes.dart';
import 'Coach/set_up_coach.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldDark,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 26.sp),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    //1.height,

                    // Branding
                    Text(
                      "SQUAD",
                      style: GoogleFonts.montserrat(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.bold,
                        color: accentGreen,
                        letterSpacing: 2,
                      ),
                    ),
                    6.height,
                    Text(
                      "Club • Coach • Parent • Player",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: accentOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    32.height,

                    // Title
                    Text(
                      "Who are you joining as?",
                      style: GoogleFonts.montserrat(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    6.height,
                    Text(
                      "We'll customize your Squad experience\nbased on your role.",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    28.height,

                    // Admin-level roles (highlighted)
                    // _RoleCard(
                    //   icon: "assets/images/admin.png",
                    //   title: "Admin",
                    //   subtitle: "Manage platform, register clubs, global payments",
                    //   //color: accentOrange,
                    //   isAdmin: true,
                    //   onTap: () {
                    //     toast("Platform Admin selected");
                    //     // Navigator.pushReplacementNamed(context, AppRoutes.admin);
                    //   },
                    // ),
                    // 12.height,

                    _RoleCard(
                      icon: "assets/images/club_admin.png",
                      title: "Club Admin",
                      subtitle: "Manage your club, members, events & payments",
                      //color: accentOrange,
                      isAdmin: true,
                      onTap: () {
                        toast("Club Admin selected");
                        Navigator.pushReplacementNamed(context, AppRoutes.clubAdmin);
                      },
                    ),

                    //28.height,

                    // Other roles
                    // Text(
                    //   "Club & Team Roles",
                    //   style: GoogleFonts.montserrat(
                    //     fontSize: 16.sp,
                    //     fontWeight: FontWeight.w600,
                    //     color: textSecondary,
                    //   ),
                    // ),
                    12.height,

                    _RoleCard(
                      icon: "assets/images/coach.png",
                      title: "Coach",
                      subtitle: "Lead training, track attendance & performance",
                      //color: accentGreen,
                      onTap: () {
                        toast("Coach selected", bgColor: accentGreen);
                       Navigator.pushReplacementNamed(context, AppRoutes.coachBar);
                      },
                    ),
                    12.height,

                    _RoleCard(
                      icon: "assets/images/parents.png",
                      title: "Parent / Guardian",
                      subtitle: "Follow your child's progress & events",
                      //color: accentGreen,
                      onTap: () {
                        toast("Parent selected");
                        //Navigator.pushReplacementNamed(context, AppRoutes.parentSignup);
                        Navigator.pushNamed(context, AppRoutes.guardianBar);
                      },
                    ),
                    12.height,

                    _RoleCard(
                      icon: "assets/images/player.png",
                      title: "Player / Member",
                      subtitle: "View schedule & performance",
                      //color: accentGreen,
                      onTap: () {
                        toast("Player selected");
                        Navigator.pushReplacementNamed(context, AppRoutes.memberBar);
                      },
                    ),
                    12.height,

                    // _RoleCard(
                    //   icon: Icons.person_rounded,
                    //   title: "Other",
                    //   subtitle: "Referee, Sponsor, Staff or other role",
                    //   color: accentOrange,
                    //   onTap: () {
                    //     toast("Other role selected");
                    //   },
                    // ),
                    //
                    // 40.height,
                  ],
                ),
              ),
            ),

            // Footer
            // Padding(
            //   padding: EdgeInsets.only(bottom: 24.h),
            //   child: Text(
            //     "Final role may be assigned/verified by club admin",
            //     style: GoogleFonts.poppins(
            //       fontSize: 12.sp,
            //       color: textSecondary.withOpacity(0.8),
            //       fontStyle: FontStyle.italic,
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  //final Color color;
  final bool isAdmin;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    //required this.color,
    this.isAdmin = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.grey.shade400,
            width: 0.7,
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: isAdmin ? accentOrange.withOpacity(0.2) : color.withOpacity(0.12),
          //     blurRadius: isAdmin ? 14 : 10,
          //     offset: const Offset(0, 4),
          //   ),
          // ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 5.h),
               decoration: BoxDecoration(
                 color: Colors.grey.shade300,
                 shape: BoxShape.circle

               ),
              child: Image.asset(icon,height: 30.h,width: 40,),

            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 13.sp,
                      fontWeight:  FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  3.height,
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: textSecondary,
                      //height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 22.sp),
          ],
        ),
      ),
    );
  }
}