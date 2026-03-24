// screens/member/member_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/colors.dart';
import '../../model/member/get_events_members.dart';
import '../../routes/app_routes.dart';
import '../../utills/api_service.dart';
import '../../utills/shared_preference.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  final MemberApiService _api = MemberApiService();

  late Future<GetMemberEvents> _pendingFuture;
  late Future<GetMemberEvents> _allEventsFuture;

  String get _username => SharedPreferenceHelper.getUsername() ?? 'Member';

  @override
  void initState() {
    super.initState();
    _pendingFuture = _api.getMemberPendingEvents();
    _allEventsFuture = _api.getMemberEvents();
  }

  void _refresh() {
    setState(() {
      _pendingFuture = _api.getMemberPendingEvents();
      _allEventsFuture = _api.getMemberEvents();
    });
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
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.guardianNotifications,
                        ),
                        child: Stack(
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 26.sp,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: FutureBuilder<GetMemberEvents>(
                                future: _pendingFuture,
                                builder: (_, snap) {
                                  final count = snap.data?.data.length ?? 0;
                                  if (count == 0) return const SizedBox();
                                  return Container(
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
                                  );
                                },
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

            // ── Body ────────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refresh(),
                color: accentGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      24.height,

                      // ── Pending Events Banner ────────────────────────
                      FutureBuilder<GetMemberEvents>(
                        future: _pendingFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _shimmerBox(height: 100.h);
                          }
                          final pending = snapshot.data?.data ?? [];
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
                                      color: accentOrange.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20.r),
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

                      // ── Quick Stats ──────────────────────────────────
                      FutureBuilder<GetMemberEvents>(
                        future: _allEventsFuture,
                        builder: (context, snapshot) {
                          final all = snapshot.data?.data ?? [];
                          final accepted = all
                              .where((e) => e.status == 'ACCEPT')
                              .length;
                          final pending = all
                              .where((e) => e.status == 'PENDING')
                              .length;
                          return Row(
                            children: [
                              _buildStatCard(
                                icon: Icons.check_circle_outline_rounded,
                                label: "Accepted",
                                value: "$accepted",
                                color: accentGreen,
                                subtitle: "Events",
                              ),
                              _buildStatCard(
                                icon: Icons.pending_actions_rounded,
                                label: "Pending",
                                value: "$pending",
                                color: accentOrange,
                                subtitle: "Events",
                              ),
                            ],
                          );
                        },
                      ),

                      24.height,

                      // ── All Events ───────────────────────────────────
                      Text(
                        "All Events",
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      16.height,

                      FutureBuilder<GetMemberEvents>(
                        future: _allEventsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Column(
                              children: [
                                _shimmerBox(height: 80.h),
                                8.height,
                                _shimmerBox(height: 80.h),
                              ],
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                "Failed to load events",
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                            );
                          }
                          final events = snapshot.data?.data ?? [];
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
                                  "No events yet",
                                  style: GoogleFonts.poppins(
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: events
                                .map(
                                  (e) => _EventSummaryCard(
                                    event: e,
                                    onAccept: e.status == 'PENDING'
                                        ? () => _updateStatus(
                                            e.eventId,
                                            'ACCEPT',
                                          )
                                        : null,
                                    onDecline: e.status == 'PENDING'
                                        ? () => _updateStatus(
                                            e.eventId,
                                            'REJECT',
                                          )
                                        : null,
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),

                      100.height,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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

// ── Pending Event Card ──────────────────────────────────────────────────────
class _PendingEventCard extends StatelessWidget {
  final MemberEventData event;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _PendingEventCard({
    required this.event,
    required this.onAccept,
    required this.onDecline,
  });

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
                  event.eventName,
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
              Text(
                event.teamName,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: textSecondary,
                ),
              ),
              16.width,
              Icon(
                Icons.calendar_today_rounded,
                size: 13.sp,
                color: textSecondary,
              ),
              5.width,
              Text(
                event.eventDate,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          12.height,
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
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
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
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

// ── Event Summary Card ──────────────────────────────────────────────────────
class _EventSummaryCard extends StatelessWidget {
  final MemberEventData event;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const _EventSummaryCard({required this.event, this.onAccept, this.onDecline});

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return accentGreen;
      case 'REJECTED':
        return Colors.red;
      case 'PENDING':
        return accentOrange;
      default:
        return Colors.grey;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.eventName,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  event.status,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          6.height,
          Row(
            children: [
              Icon(Icons.sports_rounded, size: 13.sp, color: textSecondary),
              5.width,
              Text(
                event.teamName,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: textSecondary,
                ),
              ),
              16.width,
              Icon(
                Icons.calendar_today_rounded,
                size: 13.sp,
                color: textSecondary,
              ),
              5.width,
              Text(
                event.eventDate,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          if (event.status == 'PENDING' &&
              onAccept != null &&
              onDecline != null) ...[
            10.height,
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Accept',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                10.width,
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.2),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Decline',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
