// screens/guardian/guardian_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sports/routes/app_routes.dart';

import '../../config/colors.dart';
import '../../model/guardian/get_your_member.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';
import '../../widgets/common.dart';
import 'demo.dart';

class GuardianDashboard extends StatefulWidget {
  const GuardianDashboard({super.key});

  @override
  State<GuardianDashboard> createState() => _GuardianDashboardState();
}

class _GuardianDashboardState extends State<GuardianDashboard> {
  String? _selectedChildId;
  List<Data> _children = [];
  bool _isLoadingChildren = true;
  late Future<List<Event>> _eventsFuture;
  late Future<List<NotificationItem>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadChildren();
    _eventsFuture = _fetchUpcomingEvents();
    _notificationsFuture = _fetchNotifications();
  }

  Future<void> _loadChildren() async {
    try {
      final result = await ParentApiService().getYourMembers();
      setState(() {
        _children = result.data;
        _selectedChildId ??= _children.isNotEmpty ? _children.first.memberId.toString() : null;
        _isLoadingChildren = false;
      });
    } catch (e) {
      setState(() => _isLoadingChildren = false);
      if (mounted) AppUI.error(context, "Failed to load children.");
    }
  }

  Future<List<Event>> _fetchUpcomingEvents() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Event(id: 'e1', title: 'Evening Training', type: 'Training', dateTime: DateTime.now().add(const Duration(days: 2)), location: 'Ground B', coach: 'Raj', rsvpStatus: RsvpStatus.pending),
      Event(id: 'e2', title: 'Weekend Match', type: 'Match', dateTime: DateTime.now().add(const Duration(days: 5)), location: 'Stadium A', coach: 'Raj', rsvpStatus: RsvpStatus.pending),
    ];
  }

  Future<List<NotificationItem>> _fetchNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      NotificationItem(title: 'New match invite', subtitle: 'Coach invited to Saturday tournament', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
      NotificationItem(title: 'Performance note', subtitle: 'Coach added comment on dribbling', timestamp: DateTime.now().subtract(const Duration(hours: 5))),
    ];
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
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: scaffoldDark),
            Column(
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
                      padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Hello, Nandhakumar",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.guardianNotifications);
                            },
                            child: Stack(
                              children: [
                                Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26.sp),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10.r,
                                    height: 10.r,
                                    decoration: BoxDecoration(
                                      color: accentOrange,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black, width: 1.5),
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
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        20.height,

                        // ── CHILDREN ──
                        if (_isLoadingChildren)
                          const ChildSelectorShimmer()
                        else if (_children.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.child_care_rounded, size: 48.sp, color: Colors.grey.shade400),
                                  12.height,
                                  Text(
                                    "No children available for you just yet.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  6.height,
                                  Text(
                                    "Please wait while your club admin links a member to your account.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              16.height,
                              SizedBox(
                                height: 140.h,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _children.length,
                                  itemBuilder: (context, index) {
                                    final member = _children[index];
                                    final isSelected = member.memberId.toString() == _selectedChildId;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedChildId = member.memberId.toString();
                                          _eventsFuture = _fetchUpcomingEvents();
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: 150.w,
                                        margin: EdgeInsets.only(right: 12.w),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16.r),
                                          border: Border.all(
                                            color: isSelected ? accentGreen : Colors.grey.shade200,
                                            width: 1.5,
                                          ),
                                          color: isSelected ? accentGreen.withOpacity(0.05) : Colors.white,
                                        ),
                                        padding: EdgeInsets.all(12.w),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 28.r,
                                              backgroundColor: Colors.grey[300],
                                              child: Text(
                                                member.username.isNotEmpty ? member.username[0].toUpperCase() : '?',
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.sp,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                            8.height,
                                            Text(
                                              member.username,
                                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold,fontSize: 13.sp),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            5.height,
                                            Text(
                                              member.gender,
                                              style: GoogleFonts.poppins(
                                                fontSize: 10.sp,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                        32.height,

                        // Stats
                        Row(
                          children: [
                            _buildStatCard(
                              icon: Icons.check_circle_outline_rounded,
                              label: "Attendance",
                              value: "94%",
                              color: accentGreen,
                              subtitle: "This season",
                            ),
                            _buildStatCard(
                              icon: Icons.trending_up_rounded,
                              label: "Performance",
                              value: "8.4",
                              color: accentOrange,
                              subtitle: "Avg rating",
                            ),
                          ],
                        ),

                        20.height,
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
                            16.height,
                            TextButton(
                              onPressed: () {},
                              child: Text('See All', style: GoogleFonts.montserrat(color: accentGreen, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        FutureBuilder<List<Event>>(
                          future: _eventsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                            if (!snapshot.hasData) return Column(children: List.generate(3, (_) => const EventCardShimmer()));
                            final events = snapshot.data!;
                            if (events.isEmpty) return Center(child: Text('No events', style: secondaryTextStyle(color: Colors.grey)));
                            return Column(children: events.map((e) => EventCard(event: e)).toList());
                          },
                        ),
                        24.height,

                        Text(
                          'Quick Stats',
                          style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        12.height,
                        SizedBox(
                          height: 120.h,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: const [
                              QuickStatCard(title: 'Next Event', value: 'Sat 4:00 PM', icon: Icons.calendar_today, color: accentGreen),
                              QuickStatCard(title: 'Attendance', value: '8/10', icon: Icons.check_circle, color: Colors.blue),
                              QuickStatCard(title: 'Performance', value: '★★★☆☆', icon: Icons.star, color: Colors.orange),
                            ],
                          ),
                        ),
                        24.height,

                        Text(
                          "Recent Club Updates",
                          style: GoogleFonts.montserrat(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        16.height,

                        Column(
                          children: List.generate(3, (index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 14.h),
                              child: NotificationListTile(
                                title: [
                                  "Payment due in 4 days – ₹2500",
                                  "Match availability needed by tomorrow",
                                  "Gopal promoted to starting lineup!",
                                ][index],
                                time: ["3h ago", "Yesterday", "2d ago"][index],
                              ),
                            );
                          }),
                        ),

                        100.height,
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
            Text(label, style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary)),
            2.height,
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildNextEventCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: accentGreen,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Next Event", style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
          8.height,
          Text("League Match", style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          4.height,
          Text("Chennai vs Mumbai", style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          8.height,
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: Colors.white70, size: 18.sp),
              6.width,
              Text("Madurai velammal Pitch N0 :3", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.deepOrange)),
            ],
          ),
        ],
      ),
    );
  }
}