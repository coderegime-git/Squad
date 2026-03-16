// lib/screens/coach/coach_event_subgroups_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/getSubGroups.dart';
import '../../utills/api_service.dart';
import 'coach_event_teams_screen.dart';

class CoachEventSubGroupsScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  final String eventName;

  const CoachEventSubGroupsScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.eventName,
  });

  @override
  State<CoachEventSubGroupsScreen> createState() =>
      _CoachEventSubGroupsScreenState();
}

class _CoachEventSubGroupsScreenState
    extends State<CoachEventSubGroupsScreen> {
  final ClubApiService _api = ClubApiService();
  late Future<GetSubGroups> _subGroupsFuture;

  @override
  void initState() {
    super.initState();
    _subGroupsFuture = _api.getSubGroups(widget.groupId);
  }

  void _refresh() {
    setState(() {
      _subGroupsFuture = _api.getSubGroups(widget.groupId);
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
                padding:
                EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
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
                            "Sub-Groups",
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
                            widget.groupName,
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
            child: FutureBuilder<GetSubGroups>(
              future: _subGroupsFuture,
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
                        Text("Failed to load sub-groups",
                            style:
                            GoogleFonts.poppins(color: Colors.grey)),
                        12.height,
                        ElevatedButton(
                            onPressed: _refresh,
                            child: const Text("Retry")),
                      ],
                    ),
                  );
                }

                final subGroups = snapshot.data?.data ?? [];
                if (subGroups.isEmpty) {
                  return Center(
                    child: Text(
                      "No sub-groups found",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  color: accentGreen,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 12.h),
                    itemCount: subGroups.length,
                    itemBuilder: (_, i) {
                      final sg = subGroups[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CoachEventTeamsScreen(
                                subGroupId: sg.subGroupId!,
                                subGroupName: sg.name ?? 'Sub-Group',
                                eventName: widget.eventName,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                                color: accentOrange.withOpacity(0.3),
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
                                  color: accentOrange.withOpacity(0.12),
                                  borderRadius:
                                  BorderRadius.circular(12.r),
                                ),
                                child: Icon(Icons.groups_2_rounded,
                                    color: accentOrange, size: 24.sp),
                              ),
                              14.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sg.name ?? '',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (sg.description.isNotEmpty)
                                      Text(
                                        sg.description,
                                        style: GoogleFonts.poppins(
                                            fontSize: 12.sp,
                                            color: Colors.grey.shade600),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  color: Colors.grey.shade400),
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