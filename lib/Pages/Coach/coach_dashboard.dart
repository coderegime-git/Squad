// screens/coach/coach_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_theme.dart';
import '../../config/colors.dart';
import '../../routes/app_routes.dart';

class CoachDashboard extends StatefulWidget {
  const CoachDashboard({super.key});

  @override
  State<CoachDashboard> createState() => _CoachDashboardState();
}

class _CoachDashboardState extends State<CoachDashboard> {
  late Future<CoachProfile> _profileFuture;
  late Future<List<TodaySession>> _todaySessionsFuture;
  late Future<List<CoachEvent>> _upcomingEventsFuture;
  late Future<AttendanceSummary> _attendanceSummaryFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
    _todaySessionsFuture = _fetchTodaySessions();
    _upcomingEventsFuture = _fetchUpcomingEvents();
    _attendanceSummaryFuture = _fetchAttendanceSummary();
  }

  Future<CoachProfile> _fetchProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return CoachProfile(name: "Coach Raj", specialization: "Football");
  }

  Future<List<TodaySession>> _fetchTodaySessions() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      TodaySession(
        groupName: "Under-14 A",
        time: "4:00 PM - 6:00 PM",
        location: "Main Ground",
        attendanceTaken: false,
      ),
      TodaySession(
        groupName: "Under-12 B",
        time: "6:30 PM - 8:00 PM",
        location: "Side Pitch",
        attendanceTaken: true,
      ),
    ];
  }

  Future<List<CoachEvent>> _fetchUpcomingEvents() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      CoachEvent(
        title: "Weekend Tournament",
        date: DateTime.now().add(const Duration(days: 3)),
        groupName: "Under-14 A",
        type: "Match",
      ),
      CoachEvent(
        title: "Team Practice",
        date: DateTime.now().add(const Duration(days: 1)),
        groupName: "Under-12 B",
        type: "Training",
      ),
    ];
  }

  Future<AttendanceSummary> _fetchAttendanceSummary() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return AttendanceSummary(
      pendingCount: 2,
      completedToday: 1,
      totalSessions: 5,
    );
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
            // Header
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
                    top: 5.h,                      // same as your original top padding
                    left: 20.w,
                    right: 20.w,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ← We keep your exact same greeting text here
                      Text(
                        "Hello, Coach Ram",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,          // changed to white for visibility on black
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),

                      // ← Your exact same notifications widget (unchanged)
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.guardianNotifications);
                        },
                        child: Stack(
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,          // white on black
                              size: 26.sp,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
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

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 24.height,
                    //
                    // // Quick Stats
                    // FutureBuilder<AttendanceSummary>(
                    //   future: _attendanceSummaryFuture,
                    //   builder: (context, snapshot) {
                    //     final summary = snapshot.data ?? AttendanceSummary.empty();
                    //     return Row(
                    //       children: [
                    //         _buildStatCard(
                    //           icon: Icons.pending_actions_rounded,
                    //           label: "Pending",
                    //           value: "${summary.pendingCount}",
                    //           color: accentOrange,
                    //           subtitle: "Attendance",
                    //         ),
                    //         _buildStatCard(
                    //           icon: Icons.check_circle_outline_rounded,
                    //           label: "Completed",
                    //           value: "${summary.completedToday}",
                    //           color: accentGreen,
                    //           subtitle: "Today",
                    //         ),
                    //       ],
                    //     );
                    //   },
                    // ),

                    24.height,
                    Text(
                      "Overview ",
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
                            title: 'Today\'s Sessions',
                            value: '2',
                            icon: Icons.sports_soccer,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Pending',
                            value: '5',
                            icon: Icons.pending_actions,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    //
                    // FutureBuilder<List<TodaySession>>(
                    //   future: _todaySessionsFuture,
                    //   builder: (context, snapshot) {
                    //     if (!snapshot.hasData) {
                    //       return const _SessionCardShimmer();
                    //     }
                    //     final sessions = snapshot.data!;
                    //     if (sessions.isEmpty) {
                    //       return Container(
                    //         padding: EdgeInsets.all(20.w),
                    //         decoration: BoxDecoration(
                    //           color: cardDark,
                    //           borderRadius: BorderRadius.circular(20.r),
                    //           border: Border.all(color: Colors.grey.shade300),
                    //         ),
                    //         child: Center(
                    //           child: Text(
                    //             "No sessions scheduled today",
                    //             style: GoogleFonts.poppins(color: textSecondary),
                    //           ),
                    //         ),
                    //       );
                    //     }
                    //     return Column(
                    //       children: sessions.map((s) => _TodaySessionCard(session: s)).toList(),
                    //     );
                    //   },
                    // ),

                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Total Members',
                            value: '32',
                            icon: Icons.people_outline,
                            color: AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Groups',
                            value: '3',
                            icon: Icons.groups_outlined,
                            color: AppColors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Session ",
                          style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSessionCard(
                      context,
                      title: 'Under-14 A Training',
                      time: '4:00 PM - 5:30 PM',
                      location: 'Main Ground',
                      members: 15,
                      status: 'Upcoming',
                    ),
                    const SizedBox(height: 12),
                    _buildSessionCard(
                      context,
                      title: 'Under-16 Practice',
                      time: '6:00 PM - 7:30 PM',
                      location: 'Field B',
                      members: 17,
                      status: 'Upcoming',
                    ),
                    const SizedBox(height: 24),
                    // Upcoming Events
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
                          onPressed: () => toast("View all events"),
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
                        if (!snapshot.hasData) {
                          return const _EventCardShimmer();
                        }
                        final events = snapshot.data!;
                        return Column(
                          children: events.map((e) => _UpcomingEventCard(event: e)).toList(),
                        );
                      },
                    ),

                    24.height,

                    // Quick Actions
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
                          onTap: () => toast("Create new event"),
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

                    100.height,
                  ],
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
}

// Today's Session Card
class _TodaySessionCard extends StatelessWidget {
  final TodaySession session;

  const _TodaySessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: session.attendanceTaken
              ? accentGreen.withOpacity(0.3)
              : accentOrange.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: session.attendanceTaken
                  ? accentGreen.withOpacity(0.15)
                  : accentOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              session.attendanceTaken ? Icons.check_circle_rounded : Icons.access_time_rounded,
              color: session.attendanceTaken ? accentGreen : accentOrange,
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
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                4.height,
                Text(
                  session.time,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
                ),
                Text(
                  session.location,
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary),
                ),
              ],
            ),
          ),
          if (!session.attendanceTaken)
            ElevatedButton(
              onPressed: () => toast("Take attendance"),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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

// Upcoming Event Card
class _UpcomingEventCard extends StatelessWidget {
  final CoachEvent event;

  const _UpcomingEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accentGreen.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 13.sp),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: accentGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  event.type,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          8.height,
          Text(
            event.groupName,
            style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
          ),
          4.height,
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14.sp, color: textSecondary),
              6.width,
              Text(
                "In ${event.date.difference(DateTime.now()).inDays} days",
                style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Quick Action Button
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

// Shimmer Widgets
class _SessionCardShimmer extends StatelessWidget {
  const _SessionCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }
}

class _EventCardShimmer extends StatelessWidget {
  const _EventCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }
}

// Models
class CoachProfile {
  final String name;
  final String specialization;

  CoachProfile({required this.name, required this.specialization});
}

class TodaySession {
  final String groupName;
  final String time;
  final String location;
  final bool attendanceTaken;

  TodaySession({
    required this.groupName,
    required this.time,
    required this.location,
    required this.attendanceTaken,
  });
}

class CoachEvent {
  final String title;
  final DateTime date;
  final String groupName;
  final String type;

  CoachEvent({
    required this.title,
    required this.date,
    required this.groupName,
    required this.type,
  });
}

class AttendanceSummary {
  final int pendingCount;
  final int completedToday;
  final int totalSessions;

  AttendanceSummary({
    required this.pendingCount,
    required this.completedToday,
    required this.totalSessions,
  });

  factory AttendanceSummary.empty() =>
      AttendanceSummary(pendingCount: 0, completedToday: 0, totalSessions: 0);
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InfoCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.green,
                  size: AppConstants.iconSizeMedium,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.mediumGrey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
Widget _buildSessionCard(
    BuildContext context, {
      required String title,
      required String time,
      required String location,
      required int members,
      required String status,
    }) {
  return Card(
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 13.sp),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.mediumGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.mediumGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: AppColors.mediumGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  '$members members',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}