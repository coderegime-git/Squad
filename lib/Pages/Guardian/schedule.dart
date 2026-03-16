// screens/guardian/child_schedule.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../config/colors.dart';
import '../../config/constant.dart';
import '../../routes/app_routes.dart';

class ChildScheduleScreen extends StatefulWidget {
  const ChildScheduleScreen({super.key});

  @override
  State<ChildScheduleScreen> createState() => _ChildScheduleScreenState();
}

class _ChildScheduleScreenState extends State<ChildScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Event>> _events = {
    DateTime(2026, 1, 31): [
      Event(
        title: "Football Training",
        time: "17:30 - 19:00",
        location: "Main Ground",
        type: EventType.training,
        status: EventStatus.confirmed,
      ),
      Event(
        title: "U-12 Match vs Tigers",
        time: "16:00 - 17:30",
        location: "City Stadium",
        type: EventType.match,
        status: EventStatus.pending,
      ),
    ],
    DateTime(2026, 2, 2): [
      Event(
        title: "Swimming Session",
        time: "08:00 - 09:30",
        location: "Club Pool",
        type: EventType.training,
        status: EventStatus.confirmed,
      ),
    ],
  };

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      // appBar: AppBar(
      //   title: Text(
      //     "Child's Schedule",
      //     style: boldTextStyle(size: 20, color: textPrimary),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: scaffoldDark,
      //   elevation: 0,
      //   actions: [

      //   ],
      // ),
      body: Column(

        children: [
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
                  top: 5.h,
                  left: 20.w,
                  right: 20.w,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Child's Schedule",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //const Spacer(),

                    // GestureDetector(
                    //   onTap: () {
                    //     //Navigator.pushNamed(context, AppRoutes.guardianNotifications);
                    //   },
                    //   child: Stack(
                    //     children: [
                    //       Icon(
                    //         Icons.notifications_none_rounded,
                    //         color: Colors.white,
                    //         size: 26.sp,
                    //       ),
                    //       Positioned(
                    //         right: 0,
                    //         top: 0,
                    //         child: Container(
                    //           width: 10.r,
                    //           height: 10.r,
                    //           decoration: BoxDecoration(
                    //             color: accentOrange,
                    //             shape: BoxShape.circle,
                    //             border: Border.all(
                    //               color: Colors.black,
                    //               width: 1.5,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text("Child's Schedule",style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold,fontSize: 18.sp)),
          //     IconButton(
          //       icon: Icon(Icons.filter_list_rounded, color: Colors.green),
          //       onPressed: () {
          //         //toast("Filter: All / Training / Matches / Pending");
          //       },
          //     ),
          //   ],
          // ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            color: cardDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            child: TableCalendar(
              daysOfWeekVisible: true,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: textPrimary,
                  //fontWeight: FontWeight.w600,
                ),
                weekendStyle: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: accentOrange,
                  //fontWeight: FontWeight.w600,
                ),
                // Optional: give more breathing room
                dowTextFormatter: (date, locale) =>
                    DateFormat.E(locale).format(date).substring(0, 3).toUpperCase(),
              ),
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2027, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              eventLoader: _getEventsForDay,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() => _calendarFormat = format);
                }
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: accentGreen.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: accentGreen,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: accentOrange,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: accentOrange),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  color: accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                formatButtonTextStyle: TextStyle(color: textPrimary),
                titleTextStyle: boldTextStyle(size: 18, color: textPrimary),
                leftChevronIcon: Icon(Icons.chevron_left, color: textSecondary),
                rightChevronIcon: Icon(Icons.chevron_right, color: textSecondary),
              ),
            ),
          ),

          // Events list
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     toast("Add custom reminder / note (future feature)");
      //   },
      //   label: Text("Add Note", style: GoogleFonts.poppins(color: Colors.white)),
      //   icon: const Icon(Icons.add),
      //   backgroundColor: accentGreen,
      // ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay ?? _focusedDay);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, size: 64.sp, color: textSecondary),
            16.height,
            Text(
              "No events on this day",
              style: secondaryTextStyle(size: 16, color: textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Slidable(
            key: ValueKey(event.title),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => _confirmAvailability(event),
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.white,
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Confirm',
                ),
                SlidableAction(
                  onPressed: (_) => _showDetails(event),
                  backgroundColor: accentOrange,
                  foregroundColor: Colors.white,
                  icon: Icons.info_outline_rounded,
                  label: 'Details',
                ),
              ],
            ),
            child: EventListTile(event: event),
          ),
        );
      },
    );
  }

  void _confirmAvailability(Event event) {
    toast("Availability confirmed for ${event.title}", bgColor: accentGreen);
    // TODO: Update Firestore → set status to confirmed
    setState(() => event.status = EventStatus.confirmed);
  }

  void _showDetails(Event event) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        title: Text(event.title, style: boldTextStyle(color: textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Time: ${event.time}", style: primaryTextStyle(color: textSecondary)),
            8.height,
            Text("Location: ${event.location}", style: primaryTextStyle(color: textSecondary)),
            8.height,
            Text(
              "Status: ${event.status.toString().split('.').last.toUpperCase()}",
              style: boldTextStyle(
                color: event.status == EventStatus.confirmed ? accentGreen : accentOrange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: accentGreen)),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// Models
// ──────────────────────────────────────────

enum EventType { training, match, tournament, meeting }

enum EventStatus { pending, confirmed, cancelled }

class Event {
  final String title;
  final String time;
  final String location;
  final EventType type;
  EventStatus status;

  Event({
    required this.title,
    required this.time,
    required this.location,
    required this.type,
    required this.status,
  });
}

// ──────────────────────────────────────────
// Reusable Event Tile
// ──────────────────────────────────────────

class EventListTile extends StatelessWidget {
  final Event event;

  const EventListTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final isMatch = event.type == EventType.match;
    final color = isMatch ? accentOrange : accentGreen;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.5), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isMatch ? Icons.sports_soccer_rounded : Icons.fitness_center_rounded,
              color: color,
              size: 28.sp,
            ),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: boldTextStyle(size: 17, color: textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height,
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14.sp, color: textSecondary),
                    4.width,
                    Text(event.time, style: secondaryTextStyle(size: 13)),
                    16.width,
                    Icon(Icons.location_on_outlined, size: 14.sp, color: textSecondary),
                    4.width,
                    Expanded(
                      child: Text(
                        event.location,
                        style: secondaryTextStyle(size: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: event.status == EventStatus.confirmed
                  ? accentGreen.withOpacity(0.25)
                  : accentOrange.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              event.status == EventStatus.confirmed ? "Confirmed" : "Pending",
              style: secondaryTextStyle(
                size: 11,
                color: event.status == EventStatus.confirmed ? accentGreen : accentOrange,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}