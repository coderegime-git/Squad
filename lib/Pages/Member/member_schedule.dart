// screens/member/member_schedule.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../config/colors.dart';
import '../../model/member/get_events_members.dart';
import '../../utills/api_service.dart';

class MemberScheduleScreen extends StatefulWidget {
  const MemberScheduleScreen({super.key});

  @override
  State<MemberScheduleScreen> createState() => _MemberScheduleScreenState();
}

class _MemberScheduleScreenState extends State<MemberScheduleScreen> {
  final MemberApiService _api = MemberApiService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // eventDate → list of events for that date
  Map<DateTime, List<MemberEventData>> _eventsMap = {};
  List<MemberEventData> _allEvents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    try {
      final result = await _api.getMemberEvents();
      final map = <DateTime, List<MemberEventData>>{};
      for (final e in result.data) {
        // eventDate format: "2026-03-15"
        try {
          final parts = e.eventDate.split('-');
          if (parts.length == 3) {
            final day = DateTime(
                int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            map.putIfAbsent(day, () => []).add(e);
          }
        } catch (_) {}
      }
      setState(() {
        _allEvents = result.data;
        _eventsMap = map;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      toast('Failed to load events');
    }
  }

  Future<void> _updateStatus(int eventId, String status) async {
    final success = await _api.updateMemberEventStatus(eventId, status);
    if (mounted) {
      if (success) {
        toast(status == 'ACCEPTED' ? 'Event accepted!' : 'Event declined');
        _loadEvents();
      } else {
        toast('Failed to update status');
      }
    }
  }

  List<MemberEventData> _getEventsForDay(DateTime day) {
    return _eventsMap[DateTime(day.year, day.month, day.day)] ?? [];
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
                      Text(
                        "My Schedule",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
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
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                onRefresh: _loadEvents,
                color: accentGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(16.w),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: cardDark,
                          borderRadius: BorderRadius.circular(24.r),
                          border:
                          Border.all(color: Colors.grey.shade300),
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2024, 1, 1),
                          lastDay: DateTime.utc(2027, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onFormatChanged: (format) {
                            setState(
                                    () => _calendarFormat = format);
                          },
                          eventLoader: _getEventsForDay,
                          calendarStyle: CalendarStyle(
                            selectedDecoration: BoxDecoration(
                              color: accentGreen,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: accentGreen.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: accentOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle:
                            GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Events on ${_selectedDay?.day}/${_selectedDay?.month}/${_selectedDay?.year}",
                              style: GoogleFonts.montserrat(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            12.height,
                            _getEventsForDay(
                                _selectedDay ??
                                    DateTime.now())
                                .isEmpty
                                ? Container(
                              padding:
                              EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: cardDark,
                                borderRadius:
                                BorderRadius.circular(
                                    16.r),
                                border: Border.all(
                                    color: Colors
                                        .grey.shade300),
                              ),
                              child: Center(
                                child: Text(
                                  "No events on this day",
                                  style:
                                  GoogleFonts.poppins(
                                      color:
                                      textSecondary),
                                ),
                              ),
                            )
                                : Column(
                              children:
                              _getEventsForDay(
                                  _selectedDay ??
                                      DateTime
                                          .now())
                                  .map(
                                    (e) =>
                                    _ScheduleEventCard(
                                      event: e,
                                      onAccept: e.status ==
                                          'PENDING'
                                          ? () =>
                                          _updateStatus(
                                              e.eventId,
                                              'ACCEPT')
                                          : null,
                                      onDecline: e.status ==
                                          'PENDING'
                                          ? () =>
                                          _updateStatus(
                                              e.eventId,
                                              'REJECT')
                                          : null,
                                    ),
                              )
                                  .toList(),
                            ),
                          ],
                        ),
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
}

class _ScheduleEventCard extends StatelessWidget {
  final MemberEventData event;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const _ScheduleEventCard({
    required this.event,
    this.onAccept,
    this.onDecline,
  });

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED': return accentGreen;
      case 'REJECTED': return Colors.red;
      case 'PENDING': return accentOrange;
      default: return Colors.grey;
    }
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EventDetailSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(event.status);
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.eventName,
                    style: GoogleFonts.montserrat(
                      fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    event.status,
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: color, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            8.height,
            Row(
              children: [
                Icon(Icons.sports_rounded, size: 14.sp, color: textSecondary),
                6.width,
                Text(event.teamName, style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)),
              ],
            ),
            4.height,
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14.sp, color: textSecondary),
                6.width,
                Text(event.eventDate, style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)),
              ],
            ),
            if (event.status == 'PENDING' && onAccept != null && onDecline != null) ...[
              16.height,
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Text("Accept", style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text("Decline", style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EventDetailSheet extends StatelessWidget {
  final MemberEventData event;

  const _EventDetailSheet({required this.event});

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
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w, height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          16.height,
          Row(
            children: [
              Expanded(
                child: Text(
                  event.eventName,
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  event.status,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          20.height,
          _DetailRow(icon: Icons.sports_rounded, label: 'Team', value: event.teamName),
          12.height,
          _DetailRow(icon: Icons.calendar_today_rounded, label: 'Date', value: event.eventDate),
          12.height,
          _DetailRow(icon: Icons.confirmation_number_rounded, label: 'Event ID', value: '#${event.eventId}'),
          32.height,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 18.sp, color: Colors.black87),
        ),
        12.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade500)),
            Text(value, style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black)),
          ],
        ),
      ],
    );
  }
}