// screens/coach/coach_chat.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sports/utills/api_service.dart';

import '../../config/colors.dart';
import '../../model/coach/get_assigned_groups.dart';
import '../../model/member/profile_data.dart';
import '../../utills/shared_preference.dart';
import '../Member/edit_profile.dart';
import '../splash.dart';
import 'coach_group_chat_list_screen.dart';
import 'coach_member_profile_screen.dart';
import 'coach_my_member_screen.dart';

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
                  padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Chats",
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
          color: unreadCount > 0
              ? accentGreen.withOpacity(0.3)
              : Colors.grey.shade300,
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
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: textSecondary,
                  ),
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
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: textSecondary,
                ),
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

class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  late MemberProfileData memberProfileData;
  bool isLoad = true;
  final apiService = CoachApiService();
  final uploadImageService = UploadProfileImageService();

  File? _profileImage;

  @override
  void initState() {
    getProfileData(true);
    super.initState();
  }
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    final file = File(picked.path);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Upload Profile Photo",
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(file, height: 160, width: 260, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              Text("Do you want to set this as your profile photo?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 13, color: textSecondary)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("Cancel", style: GoogleFonts.poppins(color: textSecondary)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text("Upload", style: GoogleFonts.poppins(
                        color: accentGreen, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    toast("Uploading...");
    final url = await uploadImageService.uploadProfileImage(file);
    if (url != null) {
      setState(() => _profileImage = file);
      toast("Profile photo updated!");
      getProfileData(false);
    } else {
      toast("Upload failed. Please try again.");
    }
  }
  void getProfileData(bool isLoads) async {
    setState(() => isLoad = isLoads);
    memberProfileData = await apiService.getCouchProfile();
    setState(() => isLoad = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldDark,
      body: isLoad
          ? Center(child: Loader())
          : Column(
        children: [
          // ── App bar ──────────────────────────────────────
          Container(
            height: 85.h,
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
                    top: 5.h, left: 20.w, right: 20.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "My Profile",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                        padding: EdgeInsets.fromLTRB(
                            20.w, 60.h, 20.w, 24.h),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(24.r),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            if (memberProfileData.data?.user !=
                                null) ...[
                              Text(
                                memberProfileData
                                    .data!.user!.username ??
                                    '',
                                style: GoogleFonts.montserrat(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  color: accentGreen,
                                ),
                              ),
                              6.height,
                              Text(
                                "Coach • ${memberProfileData.data!.user!.mobile ?? ''}",
                                style: GoogleFonts.poppins(
                                    fontSize: 15.sp,
                                    color: Colors.black),
                              ),
                              4.height,
                              Text(
                                memberProfileData
                                    .data!.user!.email ??
                                    '',
                                style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Avatar
                      Positioned(
                        top: -40.h,
                        child: CircleAvatar(
                          radius: 50.r,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!) as ImageProvider
                              : (memberProfileData.data?.profile?.profileImageUrl != null &&
                              memberProfileData.data!.profile!.profileImageUrl!.isNotEmpty)
                              ? NetworkImage(memberProfileData.data!.profile!.profileImageUrl!)
                              : null,
                          child: (_profileImage == null &&
                              (memberProfileData.data?.profile?.profileImageUrl == null ||
                                  memberProfileData.data!.profile!.profileImageUrl!.isEmpty))
                              ? Text(
                            memberProfileData.data?.user?.username?.isNotEmpty == true
                                ? memberProfileData.data!.user!.username![0].toUpperCase()
                                : 'C',
                            style: Theme.of(context).textTheme.headlineLarge,
                          )
                              : null,
                        ),
                      ),

                      Positioned(
                        top: 20.h,
                        left: 80,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickAndUploadImage(),
                          child: CircleAvatar(
                            radius: 12.r,
                            backgroundColor: Colors.grey.shade800,
                            child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  20.height,

                  _buildSectionTitle("Settings"),
                  12.height,
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

                  // ── My Groups & Members ───────────────────
                  _buildSectionTitle("My Groups & Members"),
                  12.height,

                  // ★ NEW — assigned groups & members
                  _SettingsTile(
                    icon: Icons.account_tree_rounded,
                    title: "View Assigned Groups & Members",
                    accent: accentGreen,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const CoachAssignedMembersScreen(),
                      ),
                    ),
                  ),

                  // _SettingsTile(
                  //   icon: Icons.people_outline_rounded,
                  //   title: "View All My Members",
                  //   onTap: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (_) =>
                  //       const CoachMyMembersScreen(),
                  //     ),
                  //   ),
                  // ),
                  _SettingsTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: "Group Chats",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CoachChatScreen()),
                    ),
                  ),

                  20.height,

                  // ── Logout ───────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                          color:
                          Colors.redAccent.withOpacity(0.4)),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.logout_rounded,
                          color: Colors.redAccent, size: 28.sp),
                      title: Text(
                        "Logout",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                      trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.redAccent),
                      onTap: () {
                        SharedPreferenceHelper.clear();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Splash()),
                              (route) => false,
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
        ),
      ),
    );
  }
}
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? accent;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? Colors.black;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: accent != null
              ? accent!.withOpacity(0.07)
              : cardDark,
          borderRadius: BorderRadius.circular(16.r),
          border: accent != null
              ? Border.all(color: accent!.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24.sp),
            16.width,
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.6)),
          ],
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
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "$activity • $members members",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: textSecondary,
                  ),
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

// class _SettingsTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final VoidCallback onTap;
//
//   const _SettingsTile({
//     required this.icon,
//     required this.title,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16.r),
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
//         margin: EdgeInsets.only(bottom: 8.h),
//         decoration: BoxDecoration(
//           color: cardDark,
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: Colors.black, size: 24.sp),
//             16.width,
//             Expanded(
//               child: Text(
//                 title,
//                 style: GoogleFonts.poppins(
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             Icon(Icons.chevron_right_rounded, color: textSecondary),
//           ],
//         ),
//       ),
//     );
//   }
// }
// lib/screens/coach/coach_assigned_members_screen.dart
//
// Shows coach's assigned groups + subgroups with their members.
// Tapping a member opens CoachMemberProfileScreen.



class CoachAssignedMembersScreen extends StatefulWidget {
  const CoachAssignedMembersScreen({super.key});

  @override
  State<CoachAssignedMembersScreen> createState() =>
      _CoachAssignedMembersScreenState();
}

class _CoachAssignedMembersScreenState
    extends State<CoachAssignedMembersScreen> {
  final CoachApiService _api = CoachApiService();
  final DocumentApiService _docApi = DocumentApiService();

  AssignedGroupsData? _assignedData;
  bool _isLoading = true;

  // memberId → list of members
  final Map<String, List<Map<String, dynamic>>> _groupMembers = {};
  final Map<String, List<Map<String, dynamic>>> _subGroupMembers = {};
  final Set<String> _loadingKeys = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getAssignedGroups();
      setState(() {
        _assignedData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      toast('Failed to load assigned groups');
    }
  }

  Future<void> _loadGroupMembers(int groupId) async {
    final key = 'g_$groupId';
    if (_groupMembers.containsKey(key) || _loadingKeys.contains(key)) return;
    setState(() => _loadingKeys.add(key));
    final members = await _api.getGroupMembersRaw(groupId);
    setState(() {
      _groupMembers[key] = members;
      _loadingKeys.remove(key);
    });
  }

  Future<void> _loadSubGroupMembers(int subGroupId) async {
    final key = 'sg_$subGroupId';
    if (_subGroupMembers.containsKey(key) || _loadingKeys.contains(key)) return;
    setState(() => _loadingKeys.add(key));
    final members = await _api.getSubGroupMembersRaw(subGroupId);
    setState(() {
      _subGroupMembers[key] = members;
      _loadingKeys.remove(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                    top: 5.h, left: 20.w, right: 20.w, bottom: 14.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                    16.width,
                    Text(
                      'My Groups & Members',
                      style: GoogleFonts.montserrat(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _load,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: accentGreen.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.refresh_rounded,
                            color: accentGreen, size: 20.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? Center(
                child: CircularProgressIndicator(color: accentGreen))
                : _assignedData == null ||
                (_assignedData!.groups.isEmpty &&
                    _assignedData!.subGroups.isEmpty)
                ? _emptyState()
                : RefreshIndicator(
              onRefresh: _load,
              color: accentGreen,
              child: ListView(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 14.h),
                children: [
                  // ── Groups ────────────────────────────
                  if (_assignedData!.groups.isNotEmpty) ...[
                    _sectionTitle('Assigned Groups',
                        Icons.group_rounded, accentGreen),
                    8.height,
                    ..._assignedData!.groups
                        .map((g) => _groupTile(g)),
                    16.height,
                  ],

                  // ── Sub-groups ────────────────────────
                  if (_assignedData!.subGroups.isNotEmpty) ...[
                    _sectionTitle('Assigned Sub-groups',
                        Icons.group_work_rounded, Colors.teal),
                    8.height,
                    ..._assignedData!.subGroups
                        .map((sg) => _subGroupTile(sg)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Group expandable tile ─────────────────────────────────────────────────
  Widget _groupTile(AssignedGroup group) {
    final key = 'g_${group.groupId}';
    final members = _groupMembers[key];
    final isLoading = _loadingKeys.contains(key);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accentGreen.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.group_rounded, color: accentGreen, size: 20.sp),
          ),
          title: Text(
            group.groupName,
            style: GoogleFonts.montserrat(
                fontSize: 14.sp, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            members == null
                ? 'Tap to load members'
                : '${members.length} member${members.length != 1 ? 's' : ''}',
            style:
            GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade500),
          ),
          iconColor: accentGreen,
          collapsedIconColor: Colors.grey,
          onExpansionChanged: (expanded) {
            if (expanded) _loadGroupMembers(group.groupId);
          },
          children: [
            if (isLoading)
              Padding(
                padding: EdgeInsets.all(16.w),
                child:
                Center(child: CircularProgressIndicator(color: accentGreen)),
              )
            else if (members == null || members.isEmpty)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text('No members in this group',
                    style: GoogleFonts.poppins(
                        fontSize: 13.sp, color: Colors.grey)),
              )
            else
              ...members.map((m) => _memberTile(m, accentGreen)),
          ],
        ),
      ),
    );
  }

  // ── SubGroup expandable tile ──────────────────────────────────────────────
  Widget _subGroupTile(AssignedSubGroup sg) {
    final key = 'sg_${sg.subGroupId}';
    final members = _subGroupMembers[key];
    final isLoading = _loadingKeys.contains(key);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.teal.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.group_work_rounded,
                color: Colors.teal, size: 20.sp),
          ),
          title: Text(
            sg.subGroupName,
            style: GoogleFonts.montserrat(
                fontSize: 14.sp, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            members == null
                ? 'Tap to load members'
                : '${members.length} member${members.length != 1 ? 's' : ''}',
            style:
            GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade500),
          ),
          iconColor: Colors.teal,
          collapsedIconColor: Colors.grey,
          onExpansionChanged: (expanded) {
            if (expanded) _loadSubGroupMembers(sg.subGroupId);
          },
          children: [
            if (isLoading)
              Padding(
                padding: EdgeInsets.all(16.w),
                child:
                Center(child: CircularProgressIndicator(color: Colors.teal)),
              )
            else if (members == null || members.isEmpty)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text('No members in this sub-group',
                    style: GoogleFonts.poppins(
                        fontSize: 13.sp, color: Colors.grey)),
              )
            else
              ...members.map((m) => _memberTile(m, Colors.teal)),
          ],
        ),
      ),
    );
  }

  // ── Member row inside an expanded tile ────────────────────────────────────
  Widget _memberTile(Map<String, dynamic> member, Color accent) {
    final name = member['name'] ?? member['username'] ?? 'Member';
    final email = member['email'] ?? '';
    final memberId = member['memberId'] ?? member['id'] ?? 0;


    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CoachMemberProfileScreen(
            memberId: memberId,
            memberName: name,
            memberEmail: email,
            memberData: member, // ← ADD THIS
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: Colors.grey.shade100, width: 1)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: accent.withOpacity(0.12),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: accent),
              ),
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  if (email.isNotEmpty)
                    Text(email,
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18.sp),
        8.width,
        Text(title,
            style: GoogleFonts.montserrat(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87)),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
                color: Colors.grey.shade200, shape: BoxShape.circle),
            child: Icon(Icons.group_off_rounded,
                size: 40.sp, color: Colors.grey.shade400),
          ),
          16.height,
          Text('No assigned groups yet',
              style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500)),
          8.height,
          Text('Ask your admin to assign groups to you',
              style: GoogleFonts.poppins(
                  fontSize: 12.sp, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}