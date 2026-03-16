// lib/screens/coach/coach_event_teams_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_teams.dart';
import '../../utills/api_service.dart';
import '../../utills/shared_preference.dart';
import 'coach_assign_members_screen.dart';

class CoachEventTeamsScreen extends StatefulWidget {
  final int subGroupId;
  final String subGroupName;
  final String eventName;

  const CoachEventTeamsScreen({
    super.key,
    required this.subGroupId,
    required this.subGroupName,
    required this.eventName,
  });

  @override
  State<CoachEventTeamsScreen> createState() => _CoachEventTeamsScreenState();
}

class _CoachEventTeamsScreenState extends State<CoachEventTeamsScreen> {
  final ClubApiService _api = ClubApiService();
  late Future<GetTeams> _teamsFuture;

  @override
  void initState() {
    super.initState();
    _teamsFuture = _api.getTeams(widget.subGroupId);
  }

  void _refresh() {
    setState(() {
      _teamsFuture = _api.getTeams(widget.subGroupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Header
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
                padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Teams",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.subGroupName,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: Colors.white60,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: FutureBuilder<GetTeams>(
              future: _teamsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red, size: 40.sp),
                        12.height,
                        Text("Failed to load teams",
                            style: GoogleFonts.poppins(color: Colors.grey)),
                        12.height,
                        ElevatedButton(
                            onPressed: _refresh,
                            child: const Text("Retry")),
                      ],
                    ),
                  );
                }

                final allTeams = snapshot.data?.data ?? [];

                // ── Filter: only show teams assigned to this coach ──────
                final myUserId = SharedPreferenceHelper.getId() ?? 0;
                print("Logged in userId: $myUserId");
                final teams = allTeams
                    .where((t) => t.coachIds.contains(myUserId))
                    .toList();

                if (teams.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_outlined,
                            size: 48.sp, color: Colors.grey.shade400),
                        12.height,
                        Text(
                          "No teams assigned to you",
                          style: GoogleFonts.montserrat(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        8.height,
                        Text(
                          "Ask club admin to assign you to a team",
                          style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.grey.shade400),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  color: accentGreen,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 12.h),
                    itemCount: teams.length,
                    itemBuilder: (_, i) {
                      final team = teams[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CoachAssignMembersScreen(
                                teamId: team.teamId!,
                                teamName: team.name ?? 'Team',
                                subGroupName: widget.subGroupName,
                              ),
                            ),
                          ).then((_) => _refresh());
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                                width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(Icons.sports_rounded,
                                    color: Colors.blue, size: 24.sp),
                              ),
                              14.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      team.name ?? '',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "Tap to assign members",
                                      style: GoogleFonts.poppins(
                                          fontSize: 11.sp,
                                          color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: accentGreen.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  "Assign",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: accentGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}