// screens/member/member_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/colors.dart';
import '../../model/get_clubs_data.dart';
import '../../model/member/get_events_members.dart';
import '../../model/member/get_member_dashboard.dart';
import '../../routes/app_routes.dart';
import '../../utills/api_service.dart';
import '../../utills/shared_preference.dart';
import '../notification_screen.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  final MemberApiService _api = MemberApiService();
  late Future<List<MemberEventData>> _upcomingEventsFuture;
  late Future<GetMemberEvents> _pendingFuture;
  late Future<GetMemberDashboard> _dashboardFuture;
  late Future<GetClubsData?> _clubsFallbackFuture;

  String get _username => SharedPreferenceHelper.getUsername() ?? 'Member';

  int get _clubId {
    final raw = SharedPreferenceHelper.getClubId();
    return int.tryParse(raw ?? '0') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    _pendingFuture = _api.getMemberPendingEvents();
    _dashboardFuture = _api.getMemberDashboard(_clubId);
    _clubsFallbackFuture = _fetchClubsFallback();
    _upcomingEventsFuture = _fetchUpcomingEvents(); // ← add
  }

  Future<GetClubsData?> _fetchClubsFallback() async {
    try {
      return await _api.getClubsDataForMember();
    } catch (e) {
      print("Member clubs fallback failed: $e");
      return null;
    }
  }
  Future<List<MemberEventData>> _fetchUpcomingEvents() async {
    try {
      final result = await _api.getMemberEvents();
      final now = DateTime.now();
      final oneMonthLater = now.add(const Duration(days: 30));
      return result.data.where((e) {
        try {
          final parts = e.eventDate.split('-');
          if (parts.length != 3) return false;
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          return date.isAfter(now.subtract(const Duration(days: 1))) &&
              date.isBefore(oneMonthLater);
        } catch (_) {
          return false;
        }
      }).toList();
    } catch (e) {
      print("fetchUpcomingEvents failed: $e");
      return [];
    }
  }
  void _refresh() {
    setState(() => _loadAll());
  }

  Future<void> _updateStatus(int eventId, String status) async {
    final success = await _api.updateMemberEventStatus(eventId, status);
    if (mounted) {
      if (success) {
        toast(status == 'ACCEPT' ? 'Event accepted!' : 'Event declined');
        _refresh();
      } else {
        toast('Failed to update status');
      }
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
            // ── Header ───────────────────────────────────────────────
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
                      Text(
                        "Hello, $_username",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      NotificationBellIcon(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: FutureBuilder<GetMemberDashboard>(
                future: _dashboardFuture,
                builder: (context, dashSnap) {
                  final isLoading =
                      dashSnap.connectionState == ConnectionState.waiting;
                  final club = dashSnap.data?.data?.clubs.isNotEmpty == true
                      ? dashSnap.data!.data!.clubs.first
                      : null;
                  final dashEvents = club?.events ?? [];

                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    color: accentGreen,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          24.height,

                          // ── Club Card ──────────────────────────
                          if (isLoading)
                            _shimmerBox(height: 80.h)
                          else if (club != null)
                          // Dashboard returned club — show with attendance
                            _buildDashboardClubCard(club)
                          else
                          // Dashboard returned no club — fallback API
                            FutureBuilder<GetClubsData?>(
                              future: _clubsFallbackFuture,
                              builder: (context, fallbackSnap) {
                                if (fallbackSnap.connectionState ==
                                    ConnectionState.waiting) {
                                  return _shimmerBox(height: 80.h);
                                }
                                final fallbackClubs =
                                    fallbackSnap.data?.data ?? [];
                                if (fallbackClubs.isEmpty) {
                                  return const SizedBox();
                                }
                                // Show all fallback clubs
                                return Column(
                                  children: fallbackClubs
                                      .map((c) => _buildFallbackClubCard(c))
                                      .toList(),
                                );
                              },
                            ),

                          16.height,

                          if (isLoading)
                            _shimmerBox(height: 40.h)
                          else if (club != null &&
                              club.activities.isNotEmpty) ...[
                            Text(
                              "Activities",
                              style: GoogleFonts.montserrat(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            8.height,
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: club.activities
                                  .map(
                                    (a) => Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cardDark,
                                    borderRadius:
                                    BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: accentGreen.withOpacity(0.35),
                                    ),
                                  ),
                                  child: Text(
                                    a.activityName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                                  .toList(),
                            ),
                            16.height,
                          ],

                          // ── Stat Cards ──────────────────────────
                          if (!isLoading && club != null) ...[
                            Row(
                              children: [
                                _buildStatCard(
                                  icon: Icons.calendar_month_rounded,
                                  label: "Total",
                                  value: '${dashEvents.length}',
                                  color: Colors.blueGrey,
                                  subtitle: "Events",
                                ),
                                _buildStatCard(
                                  icon: Icons.pending_actions_rounded,
                                  label: "Sessions",
                                  value:
                                  '${club.attendanceStats.totalSessions}',
                                  color: accentOrange,
                                  subtitle: "Attended",
                                ),
                              ],
                            ),
                            24.height,
                          ],

                          // ── Pending Events ──────────────────────
                          FutureBuilder<GetMemberEvents>(
                            future: _pendingFuture,
                            builder: (context, pendSnap) {
                              if (pendSnap.connectionState ==
                                  ConnectionState.waiting) {
                                return _shimmerBox(height: 100.h);
                              }
                              final pending = pendSnap.data?.data ?? [];
                              if (pending.isEmpty) return const SizedBox();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Pending Events",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      8.width,
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                          accentOrange.withOpacity(0.15),
                                          borderRadius:
                                          BorderRadius.circular(20.r),
                                        ),
                                        child: Text(
                                          '${pending.length}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.sp,
                                            color: accentOrange,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  12.height,
                                  ...pending.map(
                                        (e) => _PendingEventCard(
                                      event: e,
                                      onAccept: () =>
                                          _updateStatus(e.eventId, 'ACCEPT'),
                                      onDecline: () =>
                                          _updateStatus(e.eventId, 'REJECT'),
                                    ),
                                  ),
                                  16.height,
                                ],
                              );
                            },
                          ),

                          // ── All Events ──────────────────────────
                          Text(
                            "All Events",
                            style: GoogleFonts.montserrat(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          16.height,

                          if (isLoading) ...[
                            _shimmerBox(height: 80.h),
                            8.height,
                            _shimmerBox(height: 80.h),
                          ] else if (dashEvents.isEmpty)
                            Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: cardDark,
                                borderRadius: BorderRadius.circular(16.r),
                                border:
                                Border.all(color: Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Text(
                                  "No events yet",
                                  style: GoogleFonts.poppins(
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: dashEvents
                                  .map((e) => _DashboardEventCard(event: e))
                                  .toList(),
                            ),
// ── Upcoming Events ─────────────────────────────
                          Text(
                            "Upcoming Events",
                            style: GoogleFonts.montserrat(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          8.height,
                          FutureBuilder<List<MemberEventData>>(
                            future: _upcomingEventsFuture,
                            builder: (context, snap) {
                              if (snap.connectionState == ConnectionState.waiting) {
                                return _shimmerBox(height: 80.h);
                              }
                              final events = snap.data ?? [];
                              if (events.isEmpty) {
                                return Container(
                                  padding: EdgeInsets.all(20.w),
                                  decoration: BoxDecoration(
                                    color: cardDark,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "No upcoming events",
                                      style: GoogleFonts.poppins(color: textSecondary),
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                children: events.map((e) => _MemberUpcomingEventCard(event: e)).toList(),
                              );
                            },
                          ),
                          16.height,
                          100.height,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Club card from dashboard (has attendance) ─────────────────────────────
  Widget _buildDashboardClubCard(club) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.sports_rounded, color: accentGreen, size: 22.sp),
          ),
          12.width,
          Expanded(
            child: Text(
              club.clubName,
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          // Attendance pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: accentGreen.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Text(
                  '${club.attendanceStats.percentage}%',
                  style: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: accentGreen,
                  ),
                ),
                Text(
                  'Attend.',
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Club card from fallback API (no attendance) ───────────────────────────
  Widget _buildFallbackClubCard(GetClubsForRoles club) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.sports_rounded, color: accentGreen, size: 22.sp),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.clubName,
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (club.description.isNotEmpty) ...[
                  4.height,
                  Text(
                    club.description,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.white60,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _shimmerBox({required double height}) {
    return Container(
      height: height,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}

// ── Dashboard Event Card ──────────────────────────────────────────────────────
class _DashboardEventCard extends StatelessWidget {
  final MemberEvent event;

  const _DashboardEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.event_rounded, color: accentGreen, size: 20.sp),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventName,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                4.height,
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 11.sp, color: textSecondary),
                    4.width,
                    Text(
                      event.eventDate,
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp, color: textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingEventCard extends StatefulWidget {
  final MemberEventData event;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _PendingEventCard({
    required this.event,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<_PendingEventCard> createState() => _PendingEventCardState();
}

class _PendingEventCardState extends State<_PendingEventCard> {
  bool _isAccepting = false;
  bool _isDeclined = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accentOrange.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.event.eventName,
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: accentOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'PENDING',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: accentOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          8.height,
          Row(
            children: [
              Icon(Icons.sports_rounded, size: 13.sp, color: textSecondary),
              5.width,
              Text(widget.event.teamName,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)),
              16.width,
              Icon(Icons.calendar_today_rounded, size: 13.sp, color: textSecondary),
              5.width,
              Text(widget.event.eventDate,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)),
            ],
          ),
          12.height,
          Row(
            children: [
              // ── Accept button with loader ──
              Expanded(
                child: ElevatedButton(
                  onPressed: (_isAccepting || _isDeclined)
                      ? null
                      : () async {
                    setState(() => _isAccepting = true);
                    await Future.microtask(() => widget.onAccept());
                    if (mounted) setState(() => _isAccepting = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    disabledBackgroundColor: accentGreen.withOpacity(0.6),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    elevation: 0,
                  ),
                  child: _isAccepting
                      ? SizedBox(
                    height: 18.h,
                    width: 18.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    'Accept',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              12.width,
              // ── Decline button with loader ──
              Expanded(
                child: OutlinedButton(
                  onPressed: (_isAccepting || _isDeclined)
                      ? null
                      : () async {
                    setState(() => _isDeclined = true);
                    await Future.microtask(() => widget.onDecline());
                    if (mounted) setState(() => _isDeclined = false);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _isDeclined
                          ? Colors.red.withOpacity(0.4)
                          : Colors.red,
                      width: 1.5,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: _isDeclined
                      ? SizedBox(
                    height: 18.h,
                    width: 18.h,
                    child: const CircularProgressIndicator(
                      color: Colors.red,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    'Decline',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _MemberUpcomingEventCard extends StatelessWidget {
  final MemberEventData event;
  const _MemberUpcomingEventCard({required this.event});

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED': return accentGreen;
      case 'REJECTED': return Colors.red;
      case 'PENDING': return accentOrange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(event.status);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.event_rounded, color: color, size: 20.sp),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventName,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                4.height,
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 11.sp, color: textSecondary),
                    4.width,
                    Text(
                      event.eventDate,
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp, color: textSecondary),
                    ),
                    12.width,
                    Icon(Icons.sports_rounded,
                        size: 11.sp, color: textSecondary),
                    4.width,
                    Expanded(
                      child: Text(
                        event.teamName,
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp, color: textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              event.status,
              style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: color,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}