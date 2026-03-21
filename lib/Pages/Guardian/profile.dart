// lib/pages/guardian/guardian_profile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sports/utills/api_service.dart';

import '../../config/colors.dart';
import '../../model/member/profile_data.dart';
import '../../routes/app_routes.dart';

// lib/pages/guardian/guardian_profile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../routes/app_routes.dart';
import '../../utills/shared_preference.dart';
import '../Member/edit_profile.dart';
import '../splash.dart';

class GuardianProfileScreen extends StatefulWidget {
  const GuardianProfileScreen({super.key});

  @override
  State<GuardianProfileScreen> createState() => _GuardianProfileScreenState();
}

class _GuardianProfileScreenState extends State<GuardianProfileScreen> {
  late MemberProfileData memberProfileData;
  bool isLoad = true;
  final apiService = ParentApiService();

  @override
  void initState() {
    getProfileData(true);
    super.initState();
  }

  void getProfileData(isLoad) async {
    setState(() {
      isLoad = isLoad;
    });

    memberProfileData = await apiService.getParentProfile();
    setState(() {
      isLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: isLoad
          ? Center(child: Loader())
          : Column(
              children: [
                // Header
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
                  height: 85.h, // slightly taller → better proportions
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
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
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

                        // Profile Header Card
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                60.h,
                                20.w,
                                24.h,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              child: Column(
                                children: [
                                  if (memberProfileData.data != null &&
                                      memberProfileData.data!.user != null) ...[
                                    Text(
                                      memberProfileData.data!.user!.username ??
                                          "",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w800,
                                        color: accentGreen,
                                      ),
                                    ),
                                    6.height,
                                    Text(
                                      "Parent • ${memberProfileData.data!.user!.mobile ?? ""}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                    4.height,
                                    Text(
                                      memberProfileData.data!.user!.email ?? "",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Positioned(
                              top: -40.h,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50.r,
                                    backgroundColor: Colors.grey.shade200,
                                    child: Text(
                                      memberProfileData
                                                  .data
                                                  ?.user
                                                  ?.username
                                                  ?.isNotEmpty ==
                                              true
                                          ? memberProfileData
                                                .data!
                                                .user!
                                                .username![0]
                                          : 'U',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineLarge,
                                    ),
                                  ),
                                  Positioned(
                                    top: 20.h,
                                    left: 80,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfilePage(
                                                  memberProfileData:
                                                      memberProfileData,
                                                ),
                                          ),
                                        );
                                        getProfileData(false);
                                        if (!mounted) return;
                                        setState(() {});
                                      },
                                      child: CircleAvatar(
                                        radius: 12.r,
                                        backgroundColor: Colors.grey.shade800,
                                        child: Icon(Icons.edit, size: 14),
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    bottom: 4.h,
                                    right: 4.w,
                                    child: GestureDetector(
                                      child: Container(
                                        padding: EdgeInsets.all(6.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.camera_alt_rounded,
                                          size: 18.sp,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        20.height,

                        // Linked Children
                        _buildSectionTitle("My Children"),
                        12.height,
                        _ChildProfileTile(
                          name: "Abinesh",
                          subtitle: "Under-14 A • Football • XYZ FC",
                          onTap: () => toast("View child profile details"),
                        ),
                        12.height,
                        _ChildProfileTile(
                          name: "Gopal",
                          subtitle: "Under-10 B • Swimming • ABC Sports",
                          onTap: () => toast("View child profile details"),
                        ),

                        20.height,

                        // Membership Status - Improved Section
                        if (memberProfileData.data != null &&
                            memberProfileData.data!.memberships != null) ...[
                          _buildSectionTitle("Membership Status"),
                          12.height,
                          ...List.generate(
                            memberProfileData.data!.memberships!.length,
                            (index) {
                              Memberships member =
                                  memberProfileData.data!.memberships![index];
                              return _MembershipRow(
                                clubName: member.clubName ?? "",
                                activity: member.role ?? "",
                                validUntil: member.membershipEndDate ?? "",
                                status: member.status ?? "",
                                statusColor: accentGreen,
                              );
                            },
                          ),
                          // XYZ FC Membership
                        ],

                        20.height,

                        // _buildSectionTitle("Membership Status"),
                        // 12.height,
                        //
                        // // Abinesh Card
                        // Container(
                        //   padding: EdgeInsets.all(16.w),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(20.r),
                        //     border: Border.all(color: Colors.grey.shade300),
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Row(
                        //         children: [
                        //           CircleAvatar(
                        //             radius: 20.r,
                        //             backgroundColor: accentGreen.withOpacity(0.2),
                        //             child: Icon(Icons.person_rounded, color: accentGreen, size: 20.sp),
                        //           ),
                        //           12.width,
                        //           Text(
                        //             "Abinesh",
                        //             style: GoogleFonts.montserrat(
                        //               fontSize: 16.sp,
                        //               fontWeight: FontWeight.w700,
                        //               color: Colors.black,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       16.height,
                        //       _MembershipRow(
                        //         clubName: "XYZ FC",
                        //         activity: "Football",
                        //         validUntil: "Feb 15, 2026",
                        //         status: "No Dues",
                        //         statusColor: accentGreen,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        //
                        // 12.height,
                        // // Gopal Card
                        // Container(
                        //   padding: EdgeInsets.all(16.w),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(20.r),
                        //     border: Border.all(color: Colors.grey.shade300),
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Row(
                        //         children: [
                        //           CircleAvatar(
                        //             radius: 20.r,
                        //             backgroundColor: accentGreen.withOpacity(0.2),
                        //             child: Icon(Icons.person_rounded, color: accentGreen, size: 20.sp),
                        //           ),
                        //           12.width,
                        //           Text(
                        //             "Gopal",
                        //             style: GoogleFonts.montserrat(
                        //               fontSize: 16.sp,
                        //               fontWeight: FontWeight.w700,
                        //               color: Colors.black,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       16.height,
                        //       _MembershipRow(
                        //         clubName: "ABC Sports",
                        //         activity: "Swimming",
                        //         validUntil: "Mar 20, 2026",
                        //         status: "No Dues",
                        //         statusColor: accentGreen,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        20.height,

                        // Quick Actions / Settings
                        _buildSectionTitle("Quick Actions"),
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

                        // Logout
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.4),
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.logout_rounded,
                              color: Colors.redAccent,
                              size: 28.sp,
                            ),
                            title: Text(
                              "Logout",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.redAccent,
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: cardDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  title: Text(
                                    "Confirm Logout",
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                    ),
                                  ),
                                  content: Text(
                                    "You will be signed out of all devices.",
                                    style: GoogleFonts.poppins(
                                      color: textSecondary,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        "Cancel",
                                        style: GoogleFonts.poppins(
                                          color: textSecondary,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        toast("Logging out...");
                                        Future.delayed(
                                          const Duration(milliseconds: 800),
                                          () {
                                            SharedPreferenceHelper.clear();
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const Splash(),
                                              ),
                                              (route) => false,
                                            );
                                          },
                                        );
                                      },
                                      child: Text(
                                        "Logout",
                                        style: GoogleFonts.poppins(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// Membership row widget
class _MembershipRow extends StatelessWidget {
  final String clubName;
  final String activity;
  final String validUntil;
  final String status;
  final Color statusColor;

  const _MembershipRow({
    required this.clubName,
    required this.activity,
    required this.validUntil,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        fontSize: 12.sp,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          12.height,
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14.sp,
                color: textSecondary,
              ),
              6.width,
              Text(
                "Valid until $validUntil",
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Reusable small action button
class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black, size: 24.sp),
          ),
          6.height,
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

// Reusable settings tile
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
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  2.height,
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: textSecondary,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable child tile
class _ChildProfileTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final VoidCallback onTap;

  const _ChildProfileTile({
    required this.name,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26.r,
              backgroundColor: Colors.grey.shade100,
              child: Icon(
                Icons.sports_handball_rounded,
                color: Colors.grey.shade500,
                size: 32.sp,
              ),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textSecondary),
          ],
        ),
      ),
    );
  }
}
