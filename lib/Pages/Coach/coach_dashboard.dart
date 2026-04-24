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
import '../../model/coach/coach_dashboard_data.dart';
import '../../routes/app_routes.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';
import '../notification_screen.dart';
import 'club_members_list_screen.dart';
import 'coach_event_groups_screen.dart';

class CoachDashboard extends StatefulWidget {
  const CoachDashboard({super.key});

  @override
  State<CoachDashboard> createState() => _CoachDashboardState();
}

class _CoachDashboardState extends State<CoachDashboard> {
  bool _isNavigating = false;

  late Future<List<Club>> _clubsFuture;
  late Future<List<CoachEvent>> _upcomingEventsFuture;
  late Future<CoachDashboardData> _dashboardFuture;

  void _showLoader() => setState(() => _isNavigating = true);

  void _hideLoader() => setState(() => _isNavigating = false);

  final CoachApiService _coachApiService = CoachApiService();

  @override
  void initState() {
    super.initState();
    _clubsFuture = _fetchClubs();
    _upcomingEventsFuture = _fetchUpcomingEvents();
    _dashboardFuture = _fetchDashboard();
  }

  Future<List<Club>> _fetchClubs() async {
    try {
      return await _coachApiService.getCoachClubs();
    } catch (e) {
      print("Error fetching clubs: $e");
      return [];
    }
  }

  Future<CoachDashboardData> _fetchDashboard() async {
    try {
      final clubs = await _coachApiService.getCoachClubs();
      if (clubs.isEmpty) return CoachDashboardData.empty();
      return await _coachApiService.getCoachDashboard(clubs.first.clubId);
    } catch (e) {
      print("Error fetching dashboard: $e");
      return CoachDashboardData.empty();
    }
  }

  Future<List<CoachEvent>> _fetchUpcomingEvents() async {
    try {
      final clubs = await _coachApiService.getCoachClubs();
      if (clubs.isEmpty) return [];
      final events = await _coachApiService.getClubEvents(clubs.first.clubId);
      final oneMonthLater = DateTime.now().add(const Duration(days: 30));
      return events
          .where((e) =>
      e.eventDate.isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
          e.eventDate.isBefore(oneMonthLater))
          .take(3)
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
  void _refreshAll() {
    setState(() {
      _clubsFuture = _fetchClubs();
      _upcomingEventsFuture = _fetchUpcomingEvents();
      _dashboardFuture = _fetchDashboard();
    });
  }

  // ── Navigation helpers ─────────────────────────────────────────────────────
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
          builder: (_) => ClubMembersListScreen(
            clubId: clubs.first.clubId,
            clubName: clubs.first.clubName,
          ),
        ),
      );
    } else {
      _showClubPickerSheet(clubs, (club) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClubMembersListScreen(
              clubId: club.clubId,
              clubName: club.clubName,
            ),
          ),
        );
      });
    }
  }

  void _navigateToGroupsList() async {
    final clubs = await _coachApiService.getCoachClubs();
    if (clubs.isEmpty) {
      toast("No clubs available");
      return;
    }
    if (clubs.length == 1) {
      toast("Navigate to groups for ${clubs.first.clubName}");
    } else {
      _showClubPickerSheet(clubs, (club) {
        toast("Navigate to groups for ${club.clubName}");
      });
    }
  }

  void _navigateToAllEvents() async {
    final clubs = await _coachApiService.getCoachClubs();
    if (clubs.isEmpty) {
      toast("No clubs available");
      return;
    }
    if (clubs.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClubEventsListScreen(
            clubId: clubs.first.clubId,
            clubName: clubs.first.clubName,
          ),
        ),
      ).then(
            (_) => setState(() => _upcomingEventsFuture = _fetchUpcomingEvents()),
      );
    } else {
      _showClubPickerSheet(clubs, (club) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClubEventsListScreen(
              clubId: club.clubId,
              clubName: club.clubName,
            ),
          ),
        ).then(
              (_) => setState(() => _upcomingEventsFuture = _fetchUpcomingEvents()),
        );
      });
    }
  }

  void _handleCreateEvent() async {
    _showLoader();
    try {
      final clubs = await _coachApiService.getCoachClubs();
      _hideLoader();
      if (clubs.isEmpty) {
        toast("No clubs available");
        return;
      }
      if (clubs.length == 1) {
        _openCreateSheet(clubs.first);
      } else {
        _showClubPickerSheet(clubs, _openCreateSheet);
      }
    } catch (e) {
      _hideLoader();
      toast("Failed to load clubs");
    }
  }

  void _openCreateSheet(Club club) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoachCreateEditEventSheet(
        clubId: club.clubId,
        clubName: club.clubName,
        onSuccess: () {
          setState(() => _upcomingEventsFuture = _fetchUpcomingEvents());
          AppUI.success(context, "Event created successfully!");
        },
      ),
    );
  }

  void _handleEventTap(CoachEvent event) async {
    if (event.clubId == null || event.eventId == null) {
      toast("Event information not available");
      return;
    }
    _showLoader();
    final clubs = await _coachApiService.getCoachClubs();
    final club = clubs.firstWhere(
          (c) => c.clubId == event.clubId,
      orElse: () =>
          Club(clubId: event.clubId!, clubName: "Club", description: ""),
    );
    try {
      final fullEvent = await _coachApiService.getEventDetails(
        event.clubId!,
        event.eventId!,
      );
      _hideLoader();

      if (fullEvent == null) {
        toast("Could not load event details");
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CoachEventGroupsScreen(
            eventId: fullEvent.eventId!,
            eventName: fullEvent.eventName,
          ),
        ),
      );
    } catch (e) {
      print("Error loading event details: $e");
      toast("Error loading event details");
    }
  }

  void _handleEventEdit(CoachEvent event) async {
    if (event.clubId == null || event.eventId == null) {
      toast("Event information not available");
      return;
    }

    _showLoader();
    try {
      final clubs = await _coachApiService.getCoachClubs();
      final club = clubs.firstWhere(
            (c) => c.clubId == event.clubId,
        orElse: () =>
            Club(clubId: event.clubId!, clubName: "Club", description: ""),
      );
      final fullEvent = await _coachApiService.getEventDetails(
        event.clubId!,
        event.eventId!,
      );
      _hideLoader();

      if (fullEvent == null) {
        toast("Could not load event details");
        return;
      }

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

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CoachCreateEditEventSheet(
          clubId: event.clubId!,
          clubName: club.clubName,
          event: eventModel,
          onSuccess: () =>
              setState(() => _upcomingEventsFuture = _fetchUpcomingEvents()),
        ),
      );
    } catch (e) {
      _hideLoader();
      print("Error loading event for edit: $e");
      toast("Error loading event details");
    }
  }

  // ── Reusable club-picker bottom sheet ─────────────────────────────────────
  void _showClubPickerSheet(
      List<Club> clubs,
      void Function(Club) onSelect, {
        String title = "Select Club",
      }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Container(
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
              title,
              style: GoogleFonts.montserrat(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            16.height,
            ...clubs.map(
                  (club) => ListTile(
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
                  onSelect(club);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
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
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _refreshAll(),
                    color: accentGreen,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          24.height,
                          _buildMyClubsSection(),
                          24.height,
                          _buildOverviewSection(),
                          24.height,
                          _buildTodaySessionsSection(),
                          24.height,
                          _buildUpcomingEventsSection(),
                          24.height,
                          //_buildQuickActions(),
                          100.height,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_isNavigating)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
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
              Text(
                "Hello, Coach",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              NotificationBellIcon(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }

  // ── Overview stat cards (from dashboard API) ───────────────────────────────
  // Widget _buildOverviewSection() {
  //   return FutureBuilder<CoachDashboardData>(
  //     future: _dashboardFuture,
  //     builder: (context, snapshot) {
  //       final isLoading = snapshot.connectionState == ConnectionState.waiting;
  //       final data      = snapshot.data ?? CoachDashboardData.empty();
  //
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text("Overview",
  //               style: GoogleFonts.montserrat(
  //                 fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.grey.shade700,
  //               )),
  //           10.height,
  //
  //           // Row 1 — sessions + upcoming events
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: StatCard(
  //                   title: "Today's Sessions",
  //                   value: isLoading ? '...' : '${data.todaySessions.length}',
  //                   icon:  Icons.sports_soccer,
  //                   color: AppColors.info,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: StatCard(
  //                   title: 'Pending ',
  //                   value: isLoading ? '...' : '${data.attendance.pending}',
  //                   icon:  Icons.pending_actions_rounded,
  //                   color: AppColors.warning,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           16.height,
  //
  //           // Row 2 — members + groups (tappable)
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: GestureDetector(
  //                   onTap: _navigateToMembersList,
  //                   child: StatCard(
  //                     title: 'Total Members',
  //                     value: isLoading ? '...' : '${data.stats.totalMembers}',
  //                     icon:  Icons.people_outline,
  //                     color: AppColors.green,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: GestureDetector(
  //                   onTap: _navigateToGroupsList,
  //                   child: StatCard(
  //                     title: 'Groups',
  //                     value: isLoading ? '...' : '${data.stats.totalGroups}',
  //                     icon:  Icons.groups_outlined,
  //                     color: AppColors.orange,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           16.height,
  //
  //           // Attendance progress bar (only when data available)
  //           // if (!isLoading && data.attendance.totalSessions > 0)
  //           //   _AttendanceSummaryCard(attendance: data.attendance),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildOverviewSection() {
    return FutureBuilder<CoachDashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data ?? CoachDashboardData.empty();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Overview",
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
                    title: "Today's Sessions",
                    value: isLoading ? '...' : '${data.todaySessions.length}',
                    icon: Icons.sports_soccer,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Upcoming Events',
                    value: isLoading ? '...' : '${data.events.upcoming}',
                    icon: Icons.event_rounded,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            16.height,
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _navigateToMembersList,
                    child: StatCard(
                      title: 'Total Members',
                      value: isLoading ? '...' : '${data.stats.totalMembers}',
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
                      value: isLoading ? '...' : '${data.stats.totalGroups}',
                      icon: Icons.groups_outlined,
                      color: AppColors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  // ── Today's Sessions (from dashboard API) ─────────────────────────────────
  Widget _buildTodaySessionsSection() {
    return FutureBuilder<CoachDashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final sessions = snapshot.data?.todaySessions ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Sessions",
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            8.height,

            if (isLoading)
              const _SessionCardShimmer()
            else if (sessions.isEmpty)
              Container(
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
                        size: 40.sp,
                        color: Colors.grey.shade400,
                      ),
                      12.height,
                      Text(
                        "No sessions scheduled today",
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: sessions
                    .map((s) => _DashboardSessionCard(session: s))
                    .toList(),
              ),
          ],
        );
      },
    );
  }

  // ── Upcoming Events ────────────────────────────────────────────────────────
  Widget _buildUpcomingEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
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
                        child: const Text("Create Event"),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: snapshot.data!
                  .map(
                    (e) => _UpcomingEventCard(
                  event: e,
                  onTap: () => _handleEventTap(e),
                  onEdit: () => _handleEventEdit(e),
                ),
              )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  // ── My Clubs section ───────────────────────────────────────────────────────
  Widget _buildMyClubsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My Clubs",
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
        12.height,
        FutureBuilder<List<Club>>(
          future: _clubsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildClubShimmer();
            }
            if (snapshot.hasError) {
              return _buildClubError();
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildNoClubs();
            }
            final clubs = snapshot.data!;
            if (clubs.length > 2) {
              return SizedBox(
                height: 160.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: clubs.length,
                  itemBuilder: (_, i) => _buildClubCard(clubs[i], i),
                ),
              );
            }
            return Column(
              children: clubs
                  .asMap()
                  .entries
                  .map((e) => _buildClubCard(e.value, e.key))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildClubError() {
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
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 14.sp),
            ),
            TextButton(
              onPressed: () => setState(() => _clubsFuture = _fetchClubs()),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoClubs() {
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
            Icon(Icons.sports_soccer, size: 48.sp, color: Colors.grey.shade400),
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

  Widget _buildClubCard(Club club, int index) {
    final List<List<Color>> gradients = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
    ];
    final gradient = gradients[index % gradients.length];

    return Container(
      width: 350.w,
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
          Row(
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
            ],
          ),
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
              if (club.createdAt != null) ...[
                8.height,
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClubShimmer() {
    return SizedBox(
      height: 160.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        itemBuilder: (_, __) => Container(
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
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff < 30) return '$diff days ago';
    if (diff < 365) {
      final m = (diff / 30).floor();
      return '$m ${m == 1 ? 'month' : 'months'} ago';
    }
    final y = (diff / 365).floor();
    return '$y ${y == 1 ? 'year' : 'years'} ago';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

/// Session card driven by DashboardSession from the API
class _DashboardSessionCard extends StatelessWidget {
  final DashboardSession session;

  const _DashboardSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: session.attendanceMarked
              ? accentGreen.withOpacity(0.3)
              : accentOrange.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: session.attendanceMarked
                  ? accentGreen.withOpacity(0.12)
                  : accentOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              session.attendanceMarked
                  ? Icons.check_circle_rounded
                  : Icons.access_time_rounded,
              color: session.attendanceMarked ? accentGreen : accentOrange,
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
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                4.height,
                if (session.formattedTime.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                      4.width,
                      Text(
                        session.formattedTime,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                4.height,
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                    4.width,
                    Text(
                      session.location,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Take attendance button for unmarked sessions
          if (!session.attendanceMarked)
            ElevatedButton(
              onPressed: () =>
                  toast("Take attendance for ${session.groupName}"),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
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

class _UpcomingEventCard extends StatelessWidget {
  final CoachEvent event;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _UpcomingEventCard({
    required this.event,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: accentGreen.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(event.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    event.status,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: _statusColor(event.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            8.height,
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 13.sp,
                  color: Colors.grey.shade500,
                ),
                4.width,
                Text(
                  event.location,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            6.height,
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 13.sp,
                  color: Colors.grey.shade500,
                ),
                4.width,
                Text(
                  daysText,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (event.startTime.isNotEmpty) ...[
                  12.width,
                  Icon(
                    Icons.access_time,
                    size: 13.sp,
                    color: Colors.grey.shade500,
                  ),
                  4.width,
                  Text(
                    _formatTime(event.startTime),
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
            8.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onEdit, // → CoachCreateEditEventSheet
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                      4.width,
                      Text(
                        "Edit",
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      4.width,
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10.sp,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
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
      final parts = time.split(':');
      if (parts.length < 2) return time;
      final h = int.parse(parts[0]);
      final m = parts[1];
      final period = h >= 12 ? 'PM' : 'AM';
      final dh = h > 12
          ? h - 12
          : h == 0
          ? 12
          : h;
      return '$dh:$m $period';
    } catch (_) {
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

class _SessionCardShimmer extends StatelessWidget {
  const _SessionCardShimmer();

  @override
  Widget build(BuildContext context) => Container(
    height: 90.h,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(16.r),
    ),
  );
}

class _EventCardShimmer extends StatelessWidget {
  const _EventCardShimmer();

  @override
  Widget build(BuildContext context) => Container(
    height: 80.h,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(16.r),
    ),
  );
}

// ── Local models still needed (CoachProfile, TodaySession, AttendanceSummary removed) ──

class CoachEvent {
  final int? eventId;
  final String title;
  final DateTime date;
  final String location;
  final String type;
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

  factory CoachEvent.fromJson(Map<String, dynamic> json) => CoachEvent(
    eventId: json['eventId'],
    title: json['eventName'] ?? '',
    date: json['eventDate'] != null
        ? DateTime.parse(json['eventDate'])
        : DateTime.now(),
    location: json['location'] ?? '',
    type: json['eventType'] ?? '',
    clubId: json['clubId'],
    startTime: json['startTime'] ?? '',
    endTime: json['endTime'] ?? '',
    status: json['status'] ?? 'SCHEDULED',
    createdByUserId: json['createdByUserId'],
    createdByUsername: json['createdByUsername'],
    coachIds: json['coachIds'] != null ? List<int>.from(json['coachIds']) : [],
  );
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey,fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }
}
