// screens/coach/coach_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sports/Pages/Coach/CoachCreateEditEventSheet.dart';
import 'package:sports/Pages/Coach/club_events_list_screen.dart';

import '../../config/app_theme.dart';
import '../../config/colors.dart';
import '../../model/coach/club.dart';
import '../../model/coach/coach_event.dart';
import '../../routes/app_routes.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';
import 'club_members_list_screen.dart';
import 'coach_create_event_sheet.dart';
import 'coach_events_screen.dart';
import 'event_details_screen.dart';

class CoachDashboard extends StatefulWidget {
  const CoachDashboard({super.key});

  @override
  State<CoachDashboard> createState() => _CoachDashboardState();
}

class _CoachDashboardState extends State<CoachDashboard> {
  int _totalMembers = 0;
  bool _isLoadingMembers = false;
  late Future<CoachProfile> _profileFuture;
  late Future<List<TodaySession>> _todaySessionsFuture;
  late Future<List<CoachEvent>> _upcomingEventsFuture;
  late Future<AttendanceSummary> _attendanceSummaryFuture;
  late Future<List<Club>> _clubsFuture;

  final CoachApiService _coachApiService = CoachApiService();

  Future<void> _fetchTotalMembers() async {
    setState(() => _isLoadingMembers = true);
    try {
      final clubs = await _coachApiService.getCoachClubs();
      if (clubs.isNotEmpty) {
        final members = await _coachApiService.getClubMembers(clubs.first.clubId);
        setState(() => _totalMembers = members.length);
      }
    } catch (e) {
      print("Error fetching total members: $e");
    } finally {
      setState(() => _isLoadingMembers = false);
    }
  }

  void _navigateToMembersList() async {
    final clubs = await _coachApiService.getCoachClubs();
    if (clubs.isEmpty) {
      toast("No clubs available");
      return;
    }

    if (clubs.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClubMembersListScreen(
            clubId: clubs.first.clubId,
            clubName: clubs.first.clubName,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                16.height,
                Text(
                  "Select Club",
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                16.height,
                ...clubs.map((club) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: accentGreen.withOpacity(0.1),
                    child: Text(
                      club.clubName[0].toUpperCase(),
                      style: TextStyle(color: accentGreen),
                    ),
                  ),
                  title: Text(club.clubName),
                  subtitle: Text(club.description),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClubMembersListScreen(
                          clubId: club.clubId,
                          clubName: club.clubName,
                        ),
                      ),
                    );
                  },
                )).toList(),
              ],
            ),
          );
        },
      );
    }
  }

  void _navigateToGroupsList() async {
    final clubs = await _coachApiService.getCoachClubs();
    if (clubs.isEmpty) {
      toast("No clubs available");
      return;
    }

    if (clubs.length == 1) {
      // You'll need to create this screen
      toast("Navigate to groups for ${clubs.first.clubName}");
    } else {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                16.height,
                Text(
                  "Select Club",
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                16.height,
                ...clubs.map((club) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: accentGreen.withOpacity(0.1),
                    child: Text(
                      club.clubName[0].toUpperCase(),
                      style: TextStyle(color: accentGreen),
                    ),
                  ),
                  title: Text(club.clubName),
                  subtitle: Text(club.description),
                  onTap: () {
                    Navigator.pop(context);
                    toast("Navigate to groups for ${club.clubName}");
                  },
                )).toList(),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
    _todaySessionsFuture = _fetchTodaySessions();
    _upcomingEventsFuture = _fetchUpcomingEvents();
    _attendanceSummaryFuture = _fetchAttendanceSummary();
    _clubsFuture = _fetchClubs();
    _fetchTotalMembers();
  }

  Future<CoachProfile> _fetchProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return CoachProfile(name: "Coach Raj", specialization: "Football");
  }

  Future<List<TodaySession>> _fetchTodaySessions() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      TodaySession(
        groupName: "Under-14 A",
        time: "4:00 PM - 6:00 PM",
        location: "Main Ground",
        attendanceTaken: false,
      ),
      TodaySession(
        groupName: "Under-12 B",
        time: "6:30 PM - 8:00 PM",
        location: "Side Pitch",
        attendanceTaken: true,
      ),
    ];
  }

  Future<List<CoachEvent>> _fetchUpcomingEvents() async {
    try {
      final clubs = await _coachApiService.getCoachClubs();
      if (clubs.isEmpty) return [];

      // Get events from first club (or you can aggregate from all clubs)
      final events = await _coachApiService.getClubEvents(clubs.first.clubId);

      // Filter upcoming events and convert to CoachEvent model
      return events
          .where((e) => e.eventDate.isAfter(DateTime.now().subtract(const Duration(days: 1))))
          .take(3) // Show only first 3 upcoming events
          .map((e) => CoachEvent(
        eventId: e.eventId,
        title: e.eventName,
        date: e.eventDate,
        location: e.location,
        type: e.eventType,
        clubId: e.clubId,
        startTime: e.startTime,
        endTime: e.endTime,
        status: e.status,
        createdByUserId: e.createdByUserId,
        createdByUsername: e.createdByUsername,
        coachIds: e.coachIds,
      ))
          .toList();
    } catch (e) {
      print("Error fetching upcoming events: $e");
      return [];
    }
  }

  Future<AttendanceSummary> _fetchAttendanceSummary() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return AttendanceSummary(
      pendingCount: 2,
      completedToday: 1,
      totalSessions: 5,
    );
  }

  Future<List<Club>> _fetchClubs() async {
    try {
      // Call the actual API
      final clubs = await _coachApiService.getCoachClubs();
      return clubs;
    } catch (e) {
      print("Error fetching clubs: $e");
      return []; // Return empty list on error
    }
  }

  void _navigateToAllEvents() {
    _showClubSelectionForEvents();
  }

  void _showClubSelectionForEvents() async {
    final clubs = await _coachApiService.getCoachClubs();
    if (clubs.isEmpty) {
      toast("No clubs available");
      return;
    }

    if (clubs.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClubEventsListScreen(
            clubId: clubs.first.clubId,
            clubName: clubs.first.clubName,
          ),
        ),
      ).then((_) {
        setState(() {
          _upcomingEventsFuture = _fetchUpcomingEvents();
        });
      });
    } else {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                16.height,
                Text(
                  "Select Club",
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                16.height,
                ...clubs.map((club) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: accentGreen.withOpacity(0.1),
                    child: Text(
                      club.clubName[0].toUpperCase(),
                      style: TextStyle(color: accentGreen),
                    ),
                  ),
                  title: Text(club.clubName),
                  subtitle: Text(club.description),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClubEventsListScreen(
                          clubId: club.clubId,
                          clubName: club.clubName,
                        ),
                      ),
                    ).then((_) {
                      setState(() {
                        _upcomingEventsFuture = _fetchUpcomingEvents();
                      });
                    });
                  },
                )).toList(),
              ],
            ),
          );
        },
      );
    }
  }

  // Handle create event
  void _handleCreateEvent() {
    _showClubSelectionForCreateEvent();
  }

  void _showClubSelectionForCreateEvent() async {
    final clubs = await _coachApiService.getCoachClubs();
    if (clubs.isEmpty) {
      toast("No clubs available");
      return;
    }

    if (clubs.length == 1) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CoachCreateEditEventSheet(
          clubId: clubs.first.clubId,
          clubName: clubs.first.clubName,
          onSuccess: () {
            setState(() {
              _upcomingEventsFuture = _fetchUpcomingEvents();
            });
            AppUI.success(context, "Event created successfully!");
          },
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                16.height,
                Text(
                  "Select Club for Event",
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                16.height,
                ...clubs.map((club) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: accentGreen.withOpacity(0.1),
                    child: Text(
                      club.clubName[0].toUpperCase(),
                      style: TextStyle(color: accentGreen),
                    ),
                  ),
                  title: Text(club.clubName),
                  subtitle: Text(club.description),
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CoachCreateEditEventSheet(
                        clubId: club.clubId,
                        clubName: club.clubName,
                        onSuccess: () {
                          setState(() {
                            _upcomingEventsFuture = _fetchUpcomingEvents();
                          });
                          AppUI.success(context, "Event created successfully!");
                        },
                      ),
                    );
                  },
                )).toList(),
              ],
            ),
          );
        },
      );
    }
  }

  // Handle event tap for editing/viewing
  void _handleEventTap(CoachEvent event) async {
    if (event.clubId == null || event.eventId == null) {
      toast("Event information not available");
      return;
    }

    // Get club details to get club name
    final clubs = await _coachApiService.getCoachClubs();
    final club = clubs.firstWhere(
          (c) => c.clubId == event.clubId,
      orElse: () => Club(clubId: event.clubId!, clubName: "Club", description: ""),
    );

    // Fetch full event details
    try {
      final fullEvent = await _coachApiService.getEventDetails(event.clubId!, event.eventId!);

      if (fullEvent != null) {
        // Convert CoachEvent to CoachEventModel
        final eventModel = CoachEventModel(
          eventId: fullEvent.eventId,
          eventName: fullEvent.eventName,
          eventDate: fullEvent.eventDate,
          startTime: fullEvent.startTime,
          endTime: fullEvent.endTime,
          location: fullEvent.location,
          eventType: fullEvent.eventType,
          status: fullEvent.status,
          clubId: fullEvent.clubId,
          createdByUserId: fullEvent.createdByUserId,
          createdByUsername: fullEvent.createdByUsername,
          coachIds: fullEvent.coachIds,
          createdAt: fullEvent.createdAt,
        );

        // Open edit sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => CoachCreateEditEventSheet(
            clubId: event.clubId!,
            clubName: club.clubName,
            event: eventModel,
            onSuccess: () {
              setState(() {
                _upcomingEventsFuture = _fetchUpcomingEvents();
              });
            },
          ),
        );
      } else {
        toast("Could not load event details");
      }
    } catch (e) {
      print("Error loading event details: $e");
      toast("Error loading event details");
    }
  }

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
            // Header
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
                    top: 5.h,                      // same as your original top padding
                    left: 20.w,
                    right: 20.w,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ← We keep your exact same greeting text here
                      Text(
                        "Hello, Coach Ram",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,          // changed to white for visibility on black
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),

                      // ← Your exact same notifications widget (unchanged)
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.guardianNotifications);
                        },
                        child: Stack(
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,          // white on black
                              size: 26.sp,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10.r,
                                height: 10.r,
                                decoration: BoxDecoration(
                                  color: accentOrange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 24.height,
                    //
                    // // Quick Stats
                    // FutureBuilder<AttendanceSummary>(
                    //   future: _attendanceSummaryFuture,
                    //   builder: (context, snapshot) {
                    //     final summary = snapshot.data ?? AttendanceSummary.empty();
                    //     return Row(
                    //       children: [
                    //         _buildStatCard(
                    //           icon: Icons.pending_actions_rounded,
                    //           label: "Pending",
                    //           value: "${summary.pendingCount}",
                    //           color: accentOrange,
                    //           subtitle: "Attendance",
                    //         ),
                    //         _buildStatCard(
                    //           icon: Icons.check_circle_outline_rounded,
                    //           label: "Completed",
                    //           value: "${summary.completedToday}",
                    //           color: accentGreen,
                    //           subtitle: "Today",
                    //         ),
                    //       ],
                    //     );
                    //   },
                    // ),
                    24.height,

                    // MY CLUBS SECTION - Place this right after header
                    _buildMyClubsSection(),

                    24.height,
                    Text(
                      "Overview ",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    10.height,
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Today\'s Sessions',
                            value: '2',
                            icon: Icons.sports_soccer,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Pending',
                            value: '5',
                            icon: Icons.pending_actions,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    //
                    // FutureBuilder<List<TodaySession>>(
                    //   future: _todaySessionsFuture,
                    //   builder: (context, snapshot) {
                    //     if (!snapshot.hasData) {
                    //       return const _SessionCardShimmer();
                    //     }
                    //     final sessions = snapshot.data!;
                    //     if (sessions.isEmpty) {
                    //       return Container(
                    //         padding: EdgeInsets.all(20.w),
                    //         decoration: BoxDecoration(
                    //           color: cardDark,
                    //           borderRadius: BorderRadius.circular(20.r),
                    //           border: Border.all(color: Colors.grey.shade300),
                    //         ),
                    //         child: Center(
                    //           child: Text(
                    //             "No sessions scheduled today",
                    //             style: GoogleFonts.poppins(color: textSecondary),
                    //           ),
                    //         ),
                    //       );
                    //     }
                    //     return Column(
                    //       children: sessions.map((s) => _TodaySessionCard(session: s)).toList(),
                    //     );
                    //   },
                    // ),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _navigateToMembersList,
                            child: StatCard(
                              title: 'Total Members',
                              value: _isLoadingMembers ? '...' : '$_totalMembers',
                              icon: Icons.people_outline,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _navigateToGroupsList,
                            child: StatCard(
                              title: 'Groups',
                              value: '3',
                              icon: Icons.groups_outlined,
                              color: AppColors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Session ",
                          style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSessionCard(
                      context,
                      title: 'Under-14 A Training',
                      time: '4:00 PM - 5:30 PM',
                      location: 'Main Ground',
                      members: 15,
                      status: 'Upcoming',
                    ),
                    const SizedBox(height: 12),
                    _buildSessionCard(
                      context,
                      title: 'Under-16 Practice',
                      time: '6:00 PM - 7:30 PM',
                      location: 'Field B',
                      members: 17,
                      status: 'Upcoming',
                    ),
                    const SizedBox(height: 24),
                    // Upcoming Events
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Upcoming Events",
                          style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToAllEvents,
                          child: Text(
                            "See All",
                            style: GoogleFonts.montserrat(
                              color: accentGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    12.height,

                    FutureBuilder<List<CoachEvent>>(
                      future: _upcomingEventsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const _EventCardShimmer();
                        }

                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 40.sp,
                                    color: Colors.grey.shade400,
                                  ),
                                  12.height,
                                  Text(
                                    "No upcoming events",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  8.height,
                                  ElevatedButton(
                                    onPressed: _handleCreateEvent,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentGreen,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 8.h,
                                      ),
                                    ),
                                    child: Text("Create Event"),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final events = snapshot.data!;
                        return Column(
                          children: events.map((event) => _UpcomingEventCard(
                            event: event,
                            onTap: () => _handleEventTap(event),
                          )).toList(),
                        );
                      },
                    ),

                    24.height,

                    // Quick Actions
                    Text(
                      "Quick Actions",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    16.height,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _QuickActionButton(
                          icon: Icons.add_circle_outline_rounded,
                          label: "Create Event",
                          onTap: _handleCreateEvent,
                        ),
                        _QuickActionButton(
                          icon: Icons.assignment_turned_in_rounded,
                          label: "Take Attendance",
                          onTap: () => toast("Take attendance"),
                        ),
                        _QuickActionButton(
                          icon: Icons.rate_review_rounded,
                          label: "Add Feedback",
                          onTap: () => toast("Add feedback"),
                        ),
                      ],
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

  Widget _buildMyClubsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "My Clubs",
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            // TextButton(
            //   onPressed: () => toast("View all clubs"),
            //   style: TextButton.styleFrom(
            //     padding: EdgeInsets.zero,
            //     minimumSize: Size(50.w, 30.h),
            //   ),
            //   child: Text(
            //     "View All",
            //     style: GoogleFonts.montserrat(
            //       color: accentGreen,
            //       fontSize: 12.sp,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
          ],
        ),
        12.height,

        // Clubs List from API
        FutureBuilder<List<Club>>(
          future: _clubsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildClubShimmer();
            }

            if (snapshot.hasError) {
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 32.sp),
                      8.height,
                      Text(
                        "Failed to load clubs",
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 14.sp,
                        ),
                      ),
                      4.height,
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _clubsFuture = _fetchClubs();
                          });
                        },
                        child: Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.sports_soccer,
                        size: 48.sp,
                        color: Colors.grey.shade400,
                      ),
                      12.height,
                      Text(
                        "No clubs assigned yet",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      4.height,
                      Text(
                        "You'll be assigned to clubs soon",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final clubs = snapshot.data!;

            // If there are clubs, show them in a horizontal scrollable list
            // or in a column based on how many clubs
            if (clubs.length > 2) {
              return SizedBox(
                height: 160.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: clubs.length,
                  itemBuilder: (context, index) {
                    return _buildClubCard(clubs[index], index);
                  },
                ),
              );
            } else {
              return Column(
                children: clubs.map((club) => _buildClubCard(club, clubs.indexOf(club))).toList(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildClubCard(Club club, int index) {
    // Generate different gradient colors for each club
    final List<List<Color>> gradients = [
      [Color(0xFF667eea), Color(0xFF764ba2)], // Purple
      [Color(0xFFf093fb), Color(0xFFf5576c)], // Pink/Red
      [Color(0xFF4facfe), Color(0xFF00f2fe)], // Blue
      [Color(0xFF43e97b), Color(0xFF38f9d7)], // Green
      [Color(0xFFfa709a), Color(0xFFfee140)], // Orange/Yellow
    ];

    final gradient = gradients[index % gradients.length];

    return Container(
      width: 350.w, // Fixed width for horizontal scrolling
      margin: EdgeInsets.only(right: 12.w, bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top row with club icon and arrow
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.sports_soccer,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              const Spacer(),
              // Icon(
              //   Icons.arrow_forward_ios_rounded,
              //   color: Colors.white.withOpacity(0.7),
              //   size: 16.sp,
              // ),
            ],
          ),

          // Club name and description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                club.clubName,
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              4.height,
              Text(
                club.description,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              8.height,
              // Member since if available
              if (club.createdAt != null)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 10.sp,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    4.width,
                    Text(
                      "Since ${_formatDate(club.createdAt!)}",
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Quick stats for the club (you can add more details here)
          8.height,
          // Row(
          //   children: [
          //     _buildClubStat(icon: Icons.group, value: "12", label: "Teams"),
          //     12.width,
          //     _buildClubStat(icon: Icons.people, value: "45", label: "Members"),
          //   ],
          // ),
        ],
      ),
    );
  }

  // Helper method for club stats
  Widget _buildClubStat({required IconData icon, required String value, required String label}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 12.sp,
        ),
        4.width,
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        2.width,
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // NEW METHOD: Build shimmer for clubs
  Widget _buildClubShimmer() {
    return SizedBox(
      height: 160.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            width: 280.w,
            margin: EdgeInsets.only(right: 12.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                12.height,
                Container(
                  width: 180.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                8.height,
                Container(
                  width: double.infinity,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                8.height,
                Container(
                  width: 120.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference < 30) {
      return '$difference days';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = (difference / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'}';
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.35), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28.sp),
                8.width,
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            8.height,
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
            ),
            2.height,
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Today's Session Card
class _TodaySessionCard extends StatelessWidget {
  final TodaySession session;

  const _TodaySessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: session.attendanceTaken
              ? accentGreen.withOpacity(0.3)
              : accentOrange.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: session.attendanceTaken
                  ? accentGreen.withOpacity(0.15)
                  : accentOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              session.attendanceTaken ? Icons.check_circle_rounded : Icons.access_time_rounded,
              color: session.attendanceTaken ? accentGreen : accentOrange,
              size: 24.sp,
            ),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.groupName,
                  style: GoogleFonts.montserrat(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                4.height,
                Text(
                  session.time,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
                ),
                Text(
                  session.location,
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary),
                ),
              ],
            ),
          ),
          if (!session.attendanceTaken)
            ElevatedButton(
              onPressed: () => toast("Take attendance"),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                "Take",
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Upcoming Event Card
// class _UpcomingEventCard extends StatelessWidget {
//   final CoachEvent event;
//
//   const _UpcomingEventCard({required this.event});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: cardDark,
//         borderRadius: BorderRadius.circular(20.r),
//         border: Border.all(color: accentGreen.withOpacity(0.3), width: 1.5),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   event.title,
//                   style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 13.sp),
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//                 decoration: BoxDecoration(
//                   color: accentGreen.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(20.r),
//                 ),
//                 child: Text(
//                   event.type,
//                   style: GoogleFonts.poppins(
//                     fontSize: 11.sp,
//                     color: accentGreen,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           8.height,
//           Text(
//             event.groupName,
//             style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
//           ),
//           4.height,
//           Row(
//             children: [
//               Icon(Icons.calendar_today_rounded, size: 14.sp, color: textSecondary),
//               6.width,
//               Text(
//                 "In ${event.date.difference(DateTime.now()).inDays} days",
//                 style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// Quick Action Button

class _UpcomingEventCard extends StatelessWidget {
  final CoachEvent event;
  final VoidCallback onTap;

  const _UpcomingEventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate days difference
    final daysDiff = event.date.difference(DateTime.now()).inDays;
    final daysText = daysDiff == 0
        ? "Today"
        : daysDiff == 1
        ? "Tomorrow"
        : "In $daysDiff days";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: accentGreen.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(event.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    event.status,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: _getStatusColor(event.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            8.height,
            Text(
              event.location,
              style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
            ),
            4.height,
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14.sp, color: textSecondary),
                6.width,
                Text(
                  daysText,
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary),
                ),
                12.width,
                if (event.startTime.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14.sp, color: textSecondary),
                      4.width,
                      Text(
                        _formatTime(event.startTime),
                        style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary),
                      ),
                    ],
                  ),
              ],
            ),
            8.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Tap to view details",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: accentGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                4.width,
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10.sp,
                  color: accentGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'ONGOING':
        return Colors.green;
      case 'COMPLETED':
        return Colors.grey;
      case 'CANCELLED':
        return Colors.red;
      default:
        return accentGreen;
    }
  }

  String _formatTime(String time) {
    try {
      if (time.isEmpty) return '';
      final parts = time.split(':');
      if (parts.length < 2) return time;

      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time.length >= 5 ? time.substring(0, 5) : time;
    }
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
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
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: accentGreen, size: 28.sp),
          ),
          8.height,
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Shimmer Widgets
class _SessionCardShimmer extends StatelessWidget {
  const _SessionCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }
}

class _EventCardShimmer extends StatelessWidget {
  const _EventCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }
}

// Models
class CoachProfile {
  final String name;
  final String specialization;

  CoachProfile({required this.name, required this.specialization});
}

class TodaySession {
  final String groupName;
  final String time;
  final String location;
  final bool attendanceTaken;

  TodaySession({
    required this.groupName,
    required this.time,
    required this.location,
    required this.attendanceTaken,
  });
}

class CoachEvent {
  final int? eventId;
  final String title;  // maps to eventName in API
  final DateTime date; // maps to eventDate in API
  final String location;
  final String type;   // maps to eventType in API
  final int? clubId;
  final String startTime;
  final String endTime;
  final String status;
  final int? createdByUserId;
  final String? createdByUsername;
  final List<int>? coachIds;

  CoachEvent({
    this.eventId,
    required this.title,
    required this.date,
    required this.location,
    required this.type,
    this.clubId,
    this.startTime = '',
    this.endTime = '',
    this.status = 'SCHEDULED',
    this.createdByUserId,
    this.createdByUsername,
    this.coachIds,
  });

  // Convert from API response
  factory CoachEvent.fromJson(Map<String, dynamic> json) {
    return CoachEvent(
      eventId: json['eventId'] ?? 0,
      title: json['eventName'] ?? '',
      date: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'])
          : DateTime.now(),
      location: json['location'] ?? '',
      type: json['eventType'] ?? '',
      clubId: json['clubId'] ?? 0,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      status: json['status'] ?? 'SCHEDULED',
      createdByUserId: json['createdByUserId'],
      createdByUsername: json['createdByUsername'],
      coachIds: json['coachIds'] != null
          ? List<int>.from(json['coachIds'])
          : [],
    );
  }
}

class AttendanceSummary {
  final int pendingCount;
  final int completedToday;
  final int totalSessions;

  AttendanceSummary({
    required this.pendingCount,
    required this.completedToday,
    required this.totalSessions,
  });

  factory AttendanceSummary.empty() =>
      AttendanceSummary(pendingCount: 0, completedToday: 0, totalSessions: 0);
}


class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: color,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InfoCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.green,
                  size: AppConstants.iconSizeMedium,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.mediumGrey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
Widget _buildSessionCard(
    BuildContext context, {
      required String title,
      required String time,
      required String location,
      required int members,
      required String status,
    }) {
  return Card(
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 13.sp),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.mediumGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.mediumGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: AppColors.mediumGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  '$members members',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}