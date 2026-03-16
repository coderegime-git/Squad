// screens/guardian/guardian_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/colors.dart';
import '../../widgets/common.dart';

class GuardianHomeScreen extends StatefulWidget {
  const GuardianHomeScreen({super.key});

  @override
  State<GuardianHomeScreen> createState() => _GuardianHomeScreenState();
}

class _GuardianHomeScreenState extends State<GuardianHomeScreen> {
  String? _selectedChildId;
  late Future<List<Child>> _childrenFuture;
  late Future<List<Event>> _eventsFuture;
  late Future<List<NotificationItem>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _childrenFuture = _fetchChildren();
    _eventsFuture = _fetchUpcomingEvents();
    _notificationsFuture = _fetchNotifications();
  }

  Future<List<Child>> _fetchChildren() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Child(id: '1', name: 'Arjun', group: 'Under-14 A', activity: 'Football', club: 'XYZ FC', photoUrl: null),
      Child(id: '2', name: 'Sara', group: 'Under-10 B', activity: 'Swimming', club: 'ABC Sports', photoUrl: null),
    ];
  }

  Future<List<Event>> _fetchUpcomingEvents() async {
    // TODO: Replace with API call based on _selectedChildId
    await Future.delayed(const Duration(seconds: 1));
    return [
      Event(id: 'e1', title: 'Evening Training', type: 'Training', dateTime: DateTime.now().add(const Duration(days: 2)), location: 'Ground B', coach: 'Raj', rsvpStatus: RsvpStatus.pending),
      Event(id: 'e2', title: 'Weekend Match', type: 'Match', dateTime: DateTime.now().add(const Duration(days: 5)), location: 'Stadium A', coach: 'Raj', rsvpStatus: RsvpStatus.yes),
    ];
  }

  Future<List<NotificationItem>> _fetchNotifications() async {
    // TODO: Replace with API call
    await Future.delayed(const Duration(seconds: 1));
    return [
      NotificationItem(title: 'New match invite', subtitle: 'Coach invited to Saturday tournament', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
      NotificationItem(title: 'Performance note', subtitle: 'Coach added comment on dribbling', timestamp: DateTime.now().subtract(const Duration(hours: 5))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _childrenFuture = _fetchChildren();
            _eventsFuture = _fetchUpcomingEvents();
            _notificationsFuture = _fetchNotifications();
          });
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header + Child Selector
              FutureBuilder<List<Child>>(
                future: _childrenFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text('Error: ${snapshot.error}', style: secondaryTextStyle(color: Colors.red));
                  if (!snapshot.hasData) return const ChildSelectorShimmer();
                  final children = snapshot.data!;
                  _selectedChildId ??= children.first.id; // default to first
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back,', style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey)),
                      Text('Parent Name', style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                      16.height,
                      SizedBox(
                        height: 150.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: children.length,
                          itemBuilder: (context, index) {
                            final child = children[index];
                            final isSelected = child.id == _selectedChildId;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedChildId = child.id;
                                  _eventsFuture = _fetchUpcomingEvents(); // refresh events
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 140.w,
                                margin: EdgeInsets.only(right: 12.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: isSelected ? accentGreen : Colors.transparent, width: 2),
                                  color: isSelected ? accentGreen.withOpacity(0.1) : Colors.grey[100],
                                ),
                                padding: EdgeInsets.all(12.w),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(radius: 28.r, backgroundColor: Colors.grey[300]),
                                    8.height,
                                    Text(child.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                    5.height,
                                    Text('${child.group} • ${child.activity}', style: GoogleFonts.poppins(fontSize: 5.sp, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              24.height,

              // Quick Stats
              Text('Quick Stats', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600)),
              12.height,
              SizedBox(
                height: 120.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    QuickStatCard(title: 'Next Event', value: 'Sat 4:00 PM', icon: Icons.calendar_today, color: accentGreen),
                    QuickStatCard(title: 'Attendance', value: '8/10', icon: Icons.check_circle, color: Colors.blue),
                    QuickStatCard(title: 'Performance', value: '★★★☆☆', icon: Icons.star, color: Colors.orange),
                    QuickStatCard(title: 'Renewal', value: 'Due in 12d', icon: Icons.payment, color: Colors.green),
                  ],
                ),
              ),
              24.height,

              // Upcoming Events
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Upcoming Events', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {}, // navigates to schedule in bottom nav
                    child: Text('See All', style: GoogleFonts.poppins(color: accentGreen)),
                  ),
                ],
              ),
              12.height,
              FutureBuilder<List<Event>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                  if (!snapshot.hasData) return Column(children: List.generate(3, (_) => const EventCardShimmer()));
                  final events = snapshot.data!;
                  if (events.isEmpty) return Center(child: Text('No events', style: secondaryTextStyle(color: Colors.grey)));
                  return Column(
                    children: events.map((e) => EventCard(event: e)).toList(),
                  );
                },
              ),
              24.height,

              // Notifications Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Notifications', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {}, // navigates to alerts
                    child: Text('See All', style: GoogleFonts.poppins(color: accentGreen)),
                  ),
                ],
              ),
              12.height,
              FutureBuilder<List<NotificationItem>>(
                future: _notificationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                  if (!snapshot.hasData) return Column(children: List.generate(2, (_) => const NotificationTileShimmer()));
                  final notifications = snapshot.data!;
                  return Column(
                    children: notifications.take(3).map((n) => NotificationTile(notification: n)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Models
class Child {
  final String id;
  final String name;
  final String group;
  final String activity;
  final String club;
  final String? photoUrl;

  Child({required this.id, required this.name, required this.group, required this.activity, required this.club, this.photoUrl});
}

class Event {
  final String id;
  final String title;
  final String type;
  final DateTime dateTime;
  final String location;
  final String coach;
  final RsvpStatus rsvpStatus;

  Event({required this.id, required this.title, required this.type, required this.dateTime, required this.location, required this.coach, required this.rsvpStatus});
}

enum RsvpStatus { pending, yes, no, maybe }

class NotificationItem {
  final String title;
  final String subtitle;
  final DateTime timestamp;

  NotificationItem({required this.title, required this.subtitle, required this.timestamp});
}

// Reusable Widgets
class ChildSelectorShimmer extends StatelessWidget {
  const ChildSelectorShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(height: 140.h, color: Colors.white),
    );
  }
}

class QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const QuickStatCard({super.key, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade500)
        //boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32.sp, color: color),
          8.height,
          Text(value, style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold)),
          Text(title, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      //shadowColor: Colors.red,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(event.type, style: GoogleFonts.montserrat(fontSize: 12.sp,color: Colors.black)),
                  backgroundColor: event.type == 'Match' ? Colors.orange[100] : Colors.grey.shade200,
                  side: BorderSide.none,
                ),
                const Spacer(),
                if (event.rsvpStatus == RsvpStatus.pending)
                  Row(
                    children: [
                      _RsvpButton(label: 'Yes', color: Colors.green, onTap: () { toast('RSVP Yes'); }),
                      8.width,
                      _RsvpButton(label: 'No', color: Colors.orangeAccent, onTap: () { toast('RSVP No'); }),
                      8.width,
                      //_RsvpButton(label: 'Maybe', color: Colors.orange, onTap: () { toast('RSVP Maybe'); }),
                    ],
                  )
                else
                  Chip(
                    label: Text(event.rsvpStatus.name.toUpperCase()),
                    backgroundColor: event.rsvpStatus == RsvpStatus.yes ? Colors.green[100] : Colors.grey[300],
                  ),
              ],
            ),
            12.height,
            Text(event.title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600)),
            4.height,
            Text(DateFormat('MMM dd, yyyy - hh:mm a').format(event.dateTime), style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
            4.height,
            Text('Location: ${event.location}', style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
            4.height,
            Text('Coach: ${event.coach}', style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _RsvpButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RsvpButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: Size(45.w, 30.h),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 12.sp)),
    );
  }
}

class EventCardShimmer extends StatelessWidget {
  const EventCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: EdgeInsets.only(bottom: 12.h),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 80.w, height: 28.h, color: Colors.white),
              12.height,
              Container(width: 200.w, height: 20.h, color: Colors.white),
              8.height,
              Container(width: 140.w, height: 16.h, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationItem notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.notifications_outlined, color: accentGreen, size: 24.sp),
      title: Text(notification.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.sp)),
      subtitle: Text(notification.subtitle, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
      trailing: Text(DateFormat('hh:mm a').format(notification.timestamp), style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        // Deep link to event or detail
      },
    );
  }
}

class NotificationTileShimmer extends StatelessWidget {
  const NotificationTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: Container(width: 24.w, height: 24.h, color: Colors.white),
        title: Container(width: 200.w, height: 16.h, color: Colors.white),
        subtitle: Container(width: 150.w, height: 12.h, color: Colors.white),
      ),
    );
  }
}