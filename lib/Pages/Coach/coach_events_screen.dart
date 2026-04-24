// lib/screens/coach/coach_events_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sports/Pages/Coach/coach_attendance_screen.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_event_details.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';
import 'coach_event_groups_screen.dart';
import 'coach_create_event_sheet.dart';

class CoachEventsScreen extends StatefulWidget {
  const CoachEventsScreen({super.key});

  @override
  State<CoachEventsScreen> createState() => _CoachEventsScreenState();
}

class _CoachEventsScreenState extends State<CoachEventsScreen> {
  final ClubApiService _api = ClubApiService();
  late Future<GetEventDetails> _eventsFuture;

  // Only SCHEDULED and COMPLETED; default to SCHEDULED
  String _selectedFilter = 'SCHEDULED';
  final List<String> _filters = ['SCHEDULED', 'COMPLETED'];

  @override
  void initState() {
    super.initState();
    _eventsFuture = _api.getEvents();
  }

  void _refresh() {
    setState(() {
      _eventsFuture = _api.getEvents();
    });
  }

  void _showCreateEventSheet() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateEventSheet,
        backgroundColor: accentGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Create Event",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
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
                  top: 5.h,
                  left: 20.w,
                  right: 20.w,
                  bottom: 14.h,
                ),
                child: Text(
                  "Events",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // ── Filter chips: Scheduled | Completed ─────────────────────
          Container(
            color: Colors.white,
            padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: _filters.map((f) {
                final selected = _selectedFilter == f;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedFilter = f),
                    child: Container(
                      margin: EdgeInsets.only(
                          right: f == 'SCHEDULED' ? 8.w : 0),
                      padding:
                      EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? accentGreen
                            : Colors.grey.shade100,
                        borderRadius:
                        BorderRadius.circular(10.r),
                        border: Border.all(
                          color: selected
                              ? accentGreen
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        f == 'SCHEDULED'
                            ? 'Scheduled'
                            : 'Completed',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: selected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Events list ─────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<GetEventDetails>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red, size: 40.sp),
                        12.height,
                        Text("Failed to load events",
                            style: GoogleFonts.poppins(
                                color: Colors.grey)),
                        12.height,
                        ElevatedButton(
                          onPressed: _refresh,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentOrange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                final allEvents =
                    snapshot.data?.data ?? [];
                final now = DateTime.now();
                final sixMonthsAgo = now
                    .subtract(const Duration(days: 180));

                // Filter: SCHEDULED = future/today events
                // COMPLETED = past events within 6 months
                final filtered = allEvents.where((e) {
                  final status =
                  (e.status ?? '').toUpperCase();

                  if (_selectedFilter == 'SCHEDULED') {
                    // Show events whose date is today or in the future
                    // regardless of API status (handles cases where
                    // status hasn't been updated yet)
                    try {
                      final eventDate =
                      DateTime.parse(e.eventDate ?? '');
                      final isUpcoming = !eventDate.isBefore(
                          DateTime(
                              now.year, now.month, now.day));
                      return isUpcoming ||
                          status == 'SCHEDULED' ||
                          status == 'ONGOING';
                    } catch (_) {
                      return status == 'SCHEDULED' ||
                          status == 'ONGOING';
                    }
                  } else {
                    // COMPLETED tab: status is COMPLETED
                    // and event date is within last 6 months
                    if (status != 'COMPLETED') return false;
                    try {
                      final eventDate =
                      DateTime.parse(e.eventDate ?? '');
                      return eventDate.isAfter(sixMonthsAgo);
                    } catch (_) {
                      return true;
                    }
                  }
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedFilter == 'SCHEDULED'
                              ? Icons.event_available
                              : Icons.event_busy,
                          size: 52.sp,
                          color: Colors.grey.shade400,
                        ),
                        16.height,
                        Text(
                          _selectedFilter == 'SCHEDULED'
                              ? "No upcoming events"
                              : "No completed events in last 6 months",
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                              fontSize: 14.sp),
                          textAlign: TextAlign.center,
                        ),
                        if (_selectedFilter ==
                            'SCHEDULED') ...[
                          16.height,
                          ElevatedButton.icon(
                            onPressed: _showCreateEventSheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10.r),
                              ),
                            ),
                            icon: const Icon(Icons.add,
                                color: Colors.white, size: 16),
                            label: Text("Create Event",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight:
                                    FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  color: accentGreen,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                        16.w, 12.h, 16.w, 100.h),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _CoachEventCard(
                      event: filtered[i],
                      isCompleted:
                      _selectedFilter == 'COMPLETED',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CoachEventGroupsScreen(
                                  eventId: filtered[i].eventId!,
                                  eventName: filtered[i]
                                      .eventName ??
                                      'Event',
                                ),
                          ),
                        );
                      },
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Event Card
// ─────────────────────────────────────────────────────────────────────────────
class _CoachEventCard extends StatelessWidget {
  final Data event;
  final VoidCallback onTap;
  final bool isCompleted;

  const _CoachEventCard({
    required this.event,
    required this.onTap,
    this.isCompleted = false,
  });

  Color _statusColor(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'ONGOING':
        return accentGreen;
      case 'COMPLETED':
        return Colors.grey;
      default:
        return accentOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(event.status);

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
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + Status badge ───────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.eventName ?? '',
                    style: GoogleFonts.montserrat(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    event.status ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            10.height,

            // ── Date + Location ────────────────────────────────
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 13.sp, color: Colors.grey),
                6.width,
                Text(
                  event.eventDate ?? '',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600),
                ),
                16.width,
                Icon(Icons.location_on_outlined,
                    size: 13.sp, color: Colors.grey),
                6.width,
                Flexible(
                  child: Text(
                    event.location ?? '',
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            10.height,

            // ── Action row ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Show Attendance link only for non-completed events
                if (!isCompleted) ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CoachAttendanceScreen(
                            groupName: event.eventName ?? '',
                            eventName: event.eventName ?? '',
                            eventId:
                            event.eventId.toString(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(8.r),
                        border: Border.all(
                            color:
                            accentGreen.withOpacity(0.4)),
                      ),
                      child: Text(
                        "Attendance",
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  10.width,
                ],
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius:
                      BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isCompleted
                              ? "View Details"
                              : "Manage",
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        4.width,
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 10.sp, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}