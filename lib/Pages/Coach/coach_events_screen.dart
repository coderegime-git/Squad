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
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'SCHEDULED', 'ONGOING', 'COMPLETED'];

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
      builder: (_) => CoachCreateEventSheet(onSuccess: _refresh),
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
                    Text(
                      "Events",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 50.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final f = _filters[i];
                final selected = _selectedFilter == f;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? accentGreen : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: selected ? accentGreen : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      f,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: selected ? Colors.white : Colors.black,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Events List
          Expanded(
            child: FutureBuilder<GetEventDetails>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40.sp,
                        ),
                        12.height,
                        Text(
                          "Failed to load events",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                        12.height,
                        ElevatedButton(
                          onPressed: _refresh,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                final allEvents = snapshot.data?.data ?? [];
                final filtered = _selectedFilter == 'All'
                    ? allEvents
                    : allEvents
                          .where(
                            (e) =>
                                (e.status ?? '').toUpperCase() ==
                                _selectedFilter,
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      "No events found",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  color: accentGreen,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _CoachEventCard(
                      event: filtered[i],
                      onTap: () {
                        print("evnt id ${filtered[i].eventId}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CoachEventGroupsScreen(
                              eventId: filtered[i].eventId!,
                              eventName: filtered[i].eventName ?? 'Event',
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

class _CoachEventCard extends StatelessWidget {
  final Data event;
  final VoidCallback onTap;

  const _CoachEventCard({required this.event, required this.onTap});

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
          border: Border.all(color: statusColor.withOpacity(0.35), width: 1.5),
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
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
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
            Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 14.sp,
                    color: Colors.grey,
                  ),
                ),
                6.width,
                Text(
                  event.eventDate ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                16.width,
                Icon(
                  Icons.location_on_outlined,
                  size: 14.sp,
                  color: Colors.grey,
                ),
                6.width,
                Flexible(
                  child: Text(
                    event.location ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (content) => CoachAttendanceScreen(
                          groupName: event.eventName,
                          eventName: event.eventName,
                          eventId: event.eventId.toString(),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Attendance",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "Tap to manage →",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: accentGreen,
                    fontWeight: FontWeight.w600,
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
