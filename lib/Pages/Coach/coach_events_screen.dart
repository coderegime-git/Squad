// screens/coach/coach_events_screen.dart
// Coach: Events list — Scheduled & Completed tabs
// - Scheduled: today + future events
// - Completed: past events within last 6 months (hard-coded)
// - FAB: Create Event → CoachCreateEventSheet
// - Tap card → CoachEventDetailScreen (Details | Attendees | Performance)
// - Attendance button (scheduled only) → CoachAttendanceScreen

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_event_details.dart';
import '../../utills/api_service.dart';
import 'coach_attendance_screen.dart';
import 'coach_create_event_sheet.dart';
import 'coach_event_detail.dart';

class CoachEventsScreen extends StatefulWidget {
  const CoachEventsScreen({super.key});

  @override
  State<CoachEventsScreen> createState() => _CoachEventsScreenState();
}

class _CoachEventsScreenState extends State<CoachEventsScreen>
    with SingleTickerProviderStateMixin {
  final ClubApiService _api = ClubApiService();
  late TabController _tabController;
  late Future<GetEventDetails> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _eventsFuture = _api.getEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => _eventsFuture = _api.getEvents());

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoachCreateEventSheet(
        onSuccess: _refresh,
        clubId: 0,
        clubName: '',
      ),
    );
  }

  List<Data> _scheduled(List<Data> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return all.where((e) {
      try {
        final d = DateTime.parse(e.eventDate);
        return !d.isBefore(today);
      } catch (_) {
        return (e.status ?? '').toUpperCase() == 'SCHEDULED';
      }
    }).toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
  }

  List<Data> _completed(List<Data> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sixMonthsAgo = now.subtract(const Duration(days: 180));
    return all.where((e) {
      try {
        final d = DateTime.parse(e.eventDate);
        return d.isBefore(today) && d.isAfter(sixMonthsAgo);
      } catch (_) {
        return (e.status ?? '').toUpperCase() == 'COMPLETED';
      }
    }).toList()
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(children: [
        // ── Header ──────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.25),
                  blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: SafeArea(
            child: Column(children: [
              Padding(
                padding: EdgeInsets.only(
                    top: 5.h, left: 20.w, right: 20.w, bottom: 0),
                child: Row(children: [
                  Text('Events',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  // Refresh button
                  GestureDetector(
                    onTap: _refresh,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 18.sp),
                    ),
                  ),
                ]),
              ),
              8.height,
              TabBar(
                controller: _tabController,
                indicatorColor: accentGreen,
                labelColor: accentGreen,
                unselectedLabelColor: Colors.grey.shade400,
                labelStyle: GoogleFonts.poppins(
                    fontSize: 13.sp, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Scheduled'),
                  Tab(text: 'Completed'),
                ],
              ),
            ]),
          ),
        ),

        // ── Content ──────────────────────────────────────────────
        Expanded(
          child: FutureBuilder<GetEventDetails>(
            future: _eventsFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: accentGreen));
              }
              if (snap.hasError) {
                return Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
                    12.height,
                    Text('Failed to load events',
                        style: GoogleFonts.poppins(color: Colors.grey)),
                    12.height,
                    ElevatedButton(
                      onPressed: _refresh,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          foregroundColor: Colors.white),
                      child: const Text('Retry'),
                    ),
                  ],
                ));
              }

              final all = snap.data?.data ?? [];
              final scheduled = _scheduled(all);
              final completed = _completed(all);

              return TabBarView(
                controller: _tabController,
                children: [
                  _eventList(scheduled, isCompleted: false),
                  _eventList(completed, isCompleted: true),
                ],
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        backgroundColor: accentGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Create Event',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _eventList(List<Data> events, {required bool isCompleted}) {
    if (events.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCompleted ? Icons.event_busy : Icons.event_available,
            size: 52.sp, color: Colors.grey.shade300,
          ),
          16.height,
          Text(
            isCompleted
                ? 'No completed events in last 6 months'
                : 'No upcoming events',
            style: GoogleFonts.poppins(
                color: Colors.grey.shade500, fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          if (!isCompleted) ...[
            16.height,
            ElevatedButton.icon(
              onPressed: _showCreateSheet,
              style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r))),
              icon: const Icon(Icons.add, color: Colors.white, size: 16),
              label: Text('Create Event',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ));
    }

    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      color: accentGreen,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
        itemCount: events.length,
        itemBuilder: (_, i) => _CoachEventCard(
          event: events[i],
          isCompleted: isCompleted,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CoachEventDetailScreen(event: events[i]),
            ),
          ).then((_) => _refresh()),
          onAttendance: isCompleted ? null : () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CoachAttendanceScreen(
                groupName: events[i].eventName,
                eventName: events[i].eventName,
                eventId: events[i].eventId.toString(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoachEventCard extends StatelessWidget {
  final Data event;
  final VoidCallback onTap;
  final VoidCallback? onAttendance;
  final bool isCompleted;

  const _CoachEventCard({
    required this.event,
    required this.onTap,
    this.onAttendance,
    this.isCompleted = false,
  });

  Color _statusColor(String? s) {
    switch ((s ?? '').toUpperCase()) {
      case 'SCHEDULED': return Colors.blue;
      case 'ONGOING': return accentGreen;
      case 'COMPLETED': return Colors.grey;
      default: return accentOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = isCompleted ? Colors.grey : _statusColor(event.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
              color: statusColor.withOpacity(0.35), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Title + Status
          Row(children: [
            Expanded(
              child: Text(event.eventName,
                  style: GoogleFonts.montserrat(
                      fontSize: 15.sp, fontWeight: FontWeight.w700)),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r)),
              child: Text(
                isCompleted ? 'COMPLETED' : (event.status ?? ''),
                style: GoogleFonts.poppins(
                    fontSize: 11.sp, color: statusColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          10.height,

          // Date & Location
          Row(children: [
            Icon(Icons.calendar_today_rounded, size: 13.sp, color: Colors.grey),
            6.width,
            Text(event.eventDate,
                style: GoogleFonts.poppins(
                    fontSize: 12.sp, color: Colors.grey.shade600)),
            16.width,
            Icon(Icons.access_time_rounded, size: 13.sp, color: Colors.grey),
            6.width,
            Text('${event.startTime} – ${event.endTime}',
                style: GoogleFonts.poppins(
                    fontSize: 12.sp, color: Colors.grey.shade600)),
          ]),
          6.height,
          Row(children: [
            Icon(Icons.location_on_outlined, size: 13.sp, color: Colors.grey),
            6.width,
            Expanded(
              child: Text(event.location,
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          12.height,

          // Actions row
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (onAttendance != null) ...[
              GestureDetector(
                onTap: onAttendance,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                      color: accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: accentGreen.withOpacity(0.4))),
                  child: Text('Attendance',
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp, color: accentGreen,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              10.width,
            ],
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8.r)),
                child: Row(children: [
                  Text(
                    isCompleted ? 'View Details' : 'Manage',
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp, color: Colors.black87,
                        fontWeight: FontWeight.w600),
                  ),
                  4.width,
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 10.sp, color: Colors.black54),
                ]),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}