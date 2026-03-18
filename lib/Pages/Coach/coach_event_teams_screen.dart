// lib/screens/coach/coach_event_teams_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_coaches.dart';
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

  // ── Navigate to Create Team page ──────────────────────────────────────────
  void _openCreatePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TeamFormPage(
          subGroupId: widget.subGroupId,
          subGroupName: widget.subGroupName,
          eventName: widget.eventName,
        ),
      ),
    ).then((created) {
      if (created == true) _refresh();
    });
  }

  // ── Navigate to Edit Team page ────────────────────────────────────────────
  void _openEditPage(TeamData team) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TeamFormPage(
          subGroupId: widget.subGroupId,
          subGroupName: widget.subGroupName,
          eventName: widget.eventName,
          existing: team,
        ),
      ),
    ).then((updated) {
      if (updated == true) _refresh();
    });
  }

  // ── Delete confirmation ────────────────────────────────────────────────────
  void _confirmDelete(TeamData team) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          "Delete Team",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${team.name}"?\nThis action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success =
              await _api.deleteTeam(widget.subGroupId, team.teamId);
              if (success) {
                _refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Team deleted"),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Delete failed. Please try again."),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child:
            Text("Delete", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePage,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Create Team",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ),
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

                final myUserId = SharedPreferenceHelper.getId() ?? 0;
                print("Logged in userId: $myUserId");
                final teams = allTeams;

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
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 90.h),
                    itemCount: teams.length,
                    itemBuilder: (_, i) {
                      final team = teams[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CoachAssignMembersScreen(
                                teamId: team.teamId,
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
                              // Edit & Delete icons + Assign chip
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => _openEditPage(team),
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.08),
                                        borderRadius:
                                        BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(Icons.edit_rounded,
                                          color: Colors.blue.shade400,
                                          size: 18.sp),
                                    ),
                                  ),
                                  8.width,
                                  GestureDetector(
                                    onTap: () => _confirmDelete(team),
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.08),
                                        borderRadius:
                                        BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(Icons.delete_rounded,
                                          color: Colors.red.shade400,
                                          size: 18.sp),
                                    ),
                                  ),
                                  8.width,
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: accentGreen.withOpacity(0.12),
                                      borderRadius:
                                      BorderRadius.circular(20.r),
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

// ═════════════════════════════════════════════════════════════════════════════
// Team Form Page — used for both Create and Edit
// ═════════════════════════════════════════════════════════════════════════════
class _TeamFormPage extends StatefulWidget {
  final int subGroupId;
  final String subGroupName;
  final String eventName;
  final TeamData? existing;

  const _TeamFormPage({
    required this.subGroupId,
    required this.subGroupName,
    required this.eventName,
    this.existing,
  });

  @override
  State<_TeamFormPage> createState() => _TeamFormPageState();
}

class _TeamFormPageState extends State<_TeamFormPage> {
  final ClubApiService _api = ClubApiService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;

  List<CoachData> _allCoaches = [];
  List<int> _selectedCoachIds = [];
  bool _coachesLoading = true;
  bool _loading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _selectedCoachIds = List<int>.from(widget.existing?.coachIds ?? []);
    _loadCoaches();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCoaches() async {
    try {
      final result = await _api.getCoaches();
      setState(() {
        _allCoaches = result.data ?? [];
        _coachesLoading = false;
      });
    } catch (_) {
      setState(() => _coachesLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    bool success;
    if (_isEdit) {
      success = await _api.updateTeam(
        widget.subGroupId,
        widget.existing!.teamId,
        {
          "name": _nameCtrl.text.trim(),
          "status": "ACTIVE",
          "coachIds": _selectedCoachIds,
        },
      );
    } else {
      success = await _api.createTeam(
        widget.subGroupId,
        {
          "name": _nameCtrl.text.trim(),
          "coachIds": _selectedCoachIds,
        },
      );
    }

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEdit ? "Team updated successfully" : "Team created successfully"),
          backgroundColor: Colors.blue,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Operation failed. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                            _isEdit ? "Edit Team" : "Create Team",
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

          // Form body
          Expanded(
            child: SingleChildScrollView(
              padding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Team details card
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Team Details",
                            style: GoogleFonts.montserrat(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          16.height,

                          // Team Name
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: "Team Name *",
                              labelStyle:
                              GoogleFonts.poppins(fontSize: 13.sp),
                              hintText: "e.g. Warriors, Kings",
                              hintStyle: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: Colors.blue, width: 2),
                              ),
                              prefixIcon: const Icon(Icons.sports_rounded,
                                  color: Colors.blue),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            style: GoogleFonts.poppins(fontSize: 14.sp),
                            validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? "Team name is required"
                                : null,
                          ),
                        ],
                      ),
                    ),

                    20.height,

                    // Coaches card
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Assign Coaches",
                                style: GoogleFonts.montserrat(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              if (_selectedCoachIds.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.12),
                                    borderRadius:
                                    BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    "${_selectedCoachIds.length} selected",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          12.height,
                          if (_coachesLoading)
                            const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ))
                          else if (_allCoaches.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Text(
                                "No coaches available",
                                style: GoogleFonts.poppins(
                                    fontSize: 13.sp, color: Colors.grey),
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                children: List.generate(
                                  _allCoaches.length,
                                      (idx) {
                                    final coach = _allCoaches[idx];
                                    final id = coach.coachId ?? 0;
                                    final isSelected =
                                    _selectedCoachIds.contains(id);
                                    final isLast =
                                        idx == _allCoaches.length - 1;
                                    return Column(
                                      children: [
                                        InkWell(
                                          borderRadius: BorderRadius.vertical(
                                            top: idx == 0
                                                ? const Radius.circular(12)
                                                : Radius.zero,
                                            bottom: isLast
                                                ? const Radius.circular(12)
                                                : Radius.zero,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              if (isSelected) {
                                                _selectedCoachIds.remove(id);
                                              } else {
                                                _selectedCoachIds.add(id);
                                              }
                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12.w,
                                                vertical: 10.h),
                                            child: Row(
                                              children: [
                                                // Avatar
                                                CircleAvatar(
                                                  radius: 18.r,
                                                  backgroundColor: Colors.blue
                                                      .withOpacity(0.1),
                                                  child: Text(
                                                    coach.username.isNotEmpty
                                                        ? coach.username
                                                        .substring(0, 1)
                                                        .toUpperCase()
                                                        : 'C',
                                                    style: GoogleFonts.montserrat(
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                      FontWeight.w700,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                                12.width,
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text(
                                                        coach.username,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 13.sp,
                                                          fontWeight:
                                                          FontWeight.w600,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      if (coach.specialization.isNotEmpty)
                                                        Text(
                                                          coach.specialization,
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 11.sp,
                                                            color: Colors
                                                                .grey.shade500,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                // Checkbox
                                                AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 150),
                                                  width: 22.w,
                                                  height: 22.w,
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Colors.blue
                                                        : Colors.transparent,
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? Colors.blue
                                                          : Colors
                                                          .grey.shade400,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        6.r),
                                                  ),
                                                  child: isSelected
                                                      ? Icon(Icons.check,
                                                      color: Colors.white,
                                                      size: 14.sp)
                                                      : null,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (!isLast)
                                          Divider(
                                              height: 1,
                                              color: Colors.grey.shade100),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    32.height,

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                            : Text(
                          _isEdit ? "Update Team" : "Create Team",
                          style: GoogleFonts.montserrat(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    20.height,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}