// screens/clubadmin/event_teams_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';

import '../../model/clubAdmin/getSubGroups.dart';
import '../../model/clubAdmin/get_coaches.dart';
import '../../model/clubAdmin/get_teams.dart';
import '../../model/clubAdmin/get_members.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';
import 'event_team_members.dart';


class EventTeamsScreen extends StatefulWidget {
  final SubGroupData subGroup;
  final int eventId;

  const EventTeamsScreen({
    super.key,
    required this.subGroup,
    required this.eventId,
  });

  @override
  State<EventTeamsScreen> createState() => _EventTeamsScreenState();
}

class _EventTeamsScreenState extends State<EventTeamsScreen> {
  final ClubApiService _apiService = ClubApiService();
  late Future<List<TeamData>> _teamsFuture;
  final Set<int> _deletingIds = {};

  @override
  void initState() {
    super.initState();
    _teamsFuture = _fetchTeams();
  }

  Future<List<TeamData>> _fetchTeams() async {
    final result = await _apiService.getTeams(widget.subGroup.subGroupId);
    return result.data;
  }

  void _refresh() => setState(() => _teamsFuture = _fetchTeams());

  // ── Create Team Sheet ──────────────────────────────────────────────────────
  void _showCreateSheet() {
    final nameCtrl = TextEditingController();
    List<int> selectedCoachIds = [];
    List<CoachData> coaches = [];
    bool isLoading = false;
    bool loadingCoaches = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          // Load coaches once
          if (loadingCoaches) {
            _apiService.getCoaches().then((result) {
              setSheet(() {
                coaches = result.data;
                loadingCoaches = false;
              });
            }).catchError((_) {
              setSheet(() => loadingCoaches = false);
            });
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 20.h,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.r)),
                    ),
                  ),
                  16.height,
                  Text('Create Team',
                      style: GoogleFonts.montserrat(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  6.height,
                  Text('Sub-group: ${widget.subGroup.name}',
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp, color: textSecondary)),
                  20.height,
                  _sheetField(
                      'Team Name *', nameCtrl, Icons.sports_soccer_rounded,
                      hint: 'e.g., Team Alpha'),
                  16.height,
                  // Text('Assign Coaches (optional)',
                  //     style: GoogleFonts.poppins(
                  //         fontSize: 12.sp,
                  //         color: textSecondary,
                  //         fontWeight: FontWeight.w500)),
                  Row(
                    children: [
                      Text('Assign Coach *',),
                      6.width,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text('Required', style: GoogleFonts.poppins(
                            fontSize: 10.sp, color: Colors.red, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  8.height,
                  loadingCoaches
                      ? const Center(child: CircularProgressIndicator())
                      : coaches.isEmpty
                      ? Text('No coaches available',
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp, color: textSecondary))
                      : Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: coaches.map((coach) {
                      final selected =
                      selectedCoachIds.contains(coach.coachId);
                      return FilterChip(
                        label: Text(coach.username,
                            style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.grey.shade700)),
                        selected: selected,
                        onSelected: (sel) {
                          setSheet(() {
                            if (sel) {
                              selectedCoachIds.add(coach.coachId);
                            } else {
                              selectedCoachIds
                                  .remove(coach.coachId);
                            }
                          });
                        },
                        selectedColor: accentGreen.withOpacity(0.15),
                        checkmarkColor: accentGreen,
                        backgroundColor: Colors.white,
                        shape: StadiumBorder(
                            side: BorderSide(
                                color: Colors.grey.shade300)),
                      );
                    }).toList(),
                  ),
                  20.height,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                        if (nameCtrl.text.trim().isEmpty) {
                          toast('Please enter team name');
                          return;
                        }
// ADD THIS ↓
                        if (selectedCoachIds.isEmpty) {
                          toast('Please assign at least one coach', bgColor: accentOrange);
                          return;
                        }
                        setSheet(() => isLoading = true);
                        final success = await _apiService.createTeam(
                          widget.subGroup.subGroupId,
                          {
                            "subGroupId": widget.subGroup.subGroupId,
                            "name": nameCtrl.text.trim(),
                            "coachIds": selectedCoachIds,
                          },
                        );
                        setSheet(() => isLoading = false);
                        if (success) {
                          Navigator.pop(ctx);
                          AppUI.success(context,
                              'Team "${nameCtrl.text}" created!');
                          _refresh();
                        } else {
                          AppUI.error(context,
                              'Failed to create team. Try again.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: isLoading
                          ? AppUI.buttonSpinner()
                          : Text('Create Team',
                          style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Confirm Delete ─────────────────────────────────────────────────────────
  Future<void> _confirmDelete(TeamData team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Team',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700, fontSize: 16.sp)),
        content: Text(
          'Are you sure you want to delete "${team.name}"?',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                    color: textSecondary, fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _deletingIds.add(team.teamId));
      final success = await _apiService.deleteTeam(
          widget.subGroup.subGroupId, team.teamId);
      setState(() => _deletingIds.remove(team.teamId));
      if (success) {
        toast('Team "${team.name}" deleted');
        _refresh();
      } else {
        AppUI.error(context, 'Failed to delete team. Try again.');
      }
    }
  }

  // ── Team Card ──────────────────────────────────────────────────────────────
  Widget _teamCard(TeamData team) {
    final isDeleting = _deletingIds.contains(team.teamId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventTeamMembersScreen(team: team),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: accentOrange.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: accentOrange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Icon(Icons.sports_soccer_rounded,
                    color: accentOrange, size: 24.sp),
              ),
            ),
            14.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(team.name,
                      style: GoogleFonts.montserrat(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  4.height,
                  if (team.coachIds.isNotEmpty)
                    Text('${team.coachIds.length} coach(es) assigned',
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp, color: textSecondary)),
                  4.height,
                  Row(
                    children: [
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 10.sp, color: textSecondary),
                      4.width,
                      Text('Tap to manage members',
                          style: GoogleFonts.poppins(
                              fontSize: 10.sp, color: textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: accentOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r)),
                  child: Text('ID: ${team.teamId}',
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: accentOrange,
                          fontWeight: FontWeight.w600)),
                ),
                12.height,
                GestureDetector(
                  onTap: isDeleting ? null : () => _confirmDelete(team),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: isDeleting
                        ? Padding(
                      padding: EdgeInsets.all(7.w),
                      child: AppUI.buttonSpinner(),
                    )
                        : Icon(Icons.delete_forever,
                        color: Colors.red.shade600, size: 18.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetField(
      String label,
      TextEditingController ctrl,
      IconData icon, {
        String? hint,
        bool required = true,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: textSecondary,
                fontWeight: FontWeight.w500)),
        6.height,
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                fontSize: 12.sp, color: textSecondary.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: textSecondary, size: 18.sp),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: accentGreen, width: 1.5)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
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
                        child: Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 20.sp),
                      ),
                      16.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Teams',
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
                              widget.subGroup.name,
                              style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade400),
                              maxLines: 1,
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

            // ── Sub-group Info Strip ─────────────────────────────────────
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.group_work_rounded,
                        color: Colors.blue, size: 20.sp),
                  ),
                  14.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.subGroup.name,
                            style: GoogleFonts.montserrat(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        if (widget.subGroup.description.isNotEmpty)
                          Text(widget.subGroup.description,
                              style: GoogleFonts.poppins(
                                  fontSize: 11.sp, color: textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r)),
                    child: Text('ID: ${widget.subGroup.subGroupId}',
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: Colors.blue,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            // ── Teams List ───────────────────────────────────────────────
            Expanded(
              child: FutureBuilder<List<TeamData>>(
                future: _teamsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: accentGreen));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 48.sp, color: Colors.red.shade300),
                          12.height,
                          Text('Failed to load teams',
                              style:
                              GoogleFonts.poppins(color: textSecondary)),
                          12.height,
                          ElevatedButton(
                            onPressed: _refresh,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: accentGreen,
                                foregroundColor: Colors.white),
                            child: Text('Retry', style: GoogleFonts.poppins()),
                          ),
                        ],
                      ),
                    );
                  }

                  final teams = snapshot.data ?? [];

                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    color: accentGreen,
                    child: teams.isEmpty
                        ? ListView(
                      children: [
                        SizedBox(height: 100.h),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.sports_soccer_outlined,
                                  size: 60.sp,
                                  color: Colors.grey.shade400),
                              16.height,
                              Text('No teams yet',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500)),
                              8.height,
                              Text('Tap + to create the first team',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    )
                        : ListView.separated(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 8.h),
                      itemCount: teams.length,
                      separatorBuilder: (_, __) => 10.height,
                      itemBuilder: (_, i) => _teamCard(teams[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateSheet,
          backgroundColor: accentGreen,
          icon: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
          label: Text('Add Team',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          elevation: 4,
        ),
      ),
    );
  }
}