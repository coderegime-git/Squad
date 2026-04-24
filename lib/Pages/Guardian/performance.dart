// lib/pages/guardian/guardian_metrics.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../config/colors.dart';

// lib/pages/guardian/guardian_metrics.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../config/app_theme.dart';

class GuardianMetricsScreen extends StatefulWidget {
  const GuardianMetricsScreen({super.key});

  @override
  State<GuardianMetricsScreen> createState() => _GuardianMetricsScreenState();
}

class _GuardianMetricsScreenState extends State<GuardianMetricsScreen> {
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
                  padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Metrics",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
              child: ListView(
                padding: EdgeInsets.all(AppConstants.paddingMedium),
                children: [
                  // ── Overall Performance ──────────────────────────────
                  Text(
                    'Overall Performance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Jan 2026 – Apr 2026',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Attendance',
                          value: '92%',
                          icon: Icons.check_circle_outline,
                          color: AppColors.green,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Sessions',
                          value: '24',
                          icon: Icons.sports_soccer,
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Streak',
                          value: '5 days',
                          icon: Icons.local_fire_department,
                          color: AppColors.error,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // ── Activity Breakdown ───────────────────────────────
                  Text(
                    'Activity Breakdown',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Jan 2026 – Apr 2026',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildActivityCard(context, activity: 'Football', attendance: 92, sessions: 18),
                  SizedBox(height: 12.h),
                  _buildActivityCard(context, activity: 'Swimming', attendance: 88, sessions: 6),
                  SizedBox(height: 24.h),

                  // ── Attendance History ───────────────────────────────
                  Text(
                    'Attendance History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14.sp),
                  ),
                  SizedBox(height: 12.h),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last 7 Sessions',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp),
                          ),
                          SizedBox(height: 16.h),
                          _buildAttendanceRow(context, date: 'Feb 5, 2026', session: 'Football Training', status: 'Present'),
                          SizedBox(height: 12.h),
                          _buildAttendanceRow(context, date: 'Feb 3, 2026', session: 'Swimming Practice', status: 'Present'),
                          SizedBox(height: 12.h),
                          _buildAttendanceRow(context, date: 'Feb 1, 2026', session: 'Football Training', status: 'Present'),
                          SizedBox(height: 12.h),
                          _buildAttendanceRow(context, date: 'Jan 30, 2026', session: 'Football Training', status: 'Absent'),
                          SizedBox(height: 12.h),
                          _buildAttendanceRow(context, date: 'Jan 28, 2026', session: 'Swimming Practice', status: 'Present'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // ── Coach Feedback ───────────────────────────────────
                  Text(
                    'Coach Feedback',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14.sp),
                  ),
                  SizedBox(height: 12.h),
                  _buildFeedbackCard(
                    context,
                    coach: 'Coach Michael',
                    activity: 'Football',
                    date: 'Feb 3, 2026',
                    feedback: 'Excellent progress in ball control and passing accuracy. Keep practicing dribbling techniques.',
                  ),
                  SizedBox(height: 12.h),
                  _buildFeedbackCard(
                    context,
                    coach: 'Coach Sarah',
                    activity: 'Swimming',
                    date: 'Feb 1, 2026',
                    feedback: 'Good improvement in freestyle stroke. Work on breathing technique for longer distances.',
                  ),
                  SizedBox(height: 12.h),
                  _buildFeedbackCard(
                    context,
                    coach: 'Coach Michael',
                    activity: 'Football',
                    date: 'Jan 28, 2026',
                    feedback: 'Strong defensive skills. Focus on positioning during corner kicks.',
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontSize: 17.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, {
    required String activity,
    required int attendance,
    required int sessions,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Icon(Icons.sports_soccer, color: AppColors.green, size: 24),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    activity,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attendance',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mediumGrey, fontSize: 12.sp)),
                    SizedBox(height: 4.h),
                    Text('$attendance%',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.green, fontSize: 15.sp)),
                  ],
                ),
                180.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sessions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mediumGrey, fontSize: 12.sp)),
                    SizedBox(height: 4.h),
                    Text(sessions.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.orange, fontSize: 15.sp)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRow(BuildContext context, {
    required String date,
    required String session,
    required String status,
  }) {
    final isPresent = status == 'Present';
    return Row(
      children: [
        Icon(
          isPresent ? Icons.check_circle : Icons.cancel,
          color: isPresent ? AppColors.success : AppColors.error,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black)),
              const SizedBox(height: 2),
              Text(date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mediumGrey)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isPresent ? AppColors.success : AppColors.error).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isPresent ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(BuildContext context, {
    required String coach,
    required String activity,
    required String date,
    required String feedback,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.green.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppColors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(coach, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(activity, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mediumGrey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              feedback,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800, fontSize: 12.sp),
            ),
            const SizedBox(height: 8),
            Text(date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mediumGrey)),
          ],
        ),
      ),
    );
  }
}

// Coach Note Card
class _CoachNoteCard extends StatelessWidget {
  final CoachNote note;

  const _CoachNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final isPositive = note.category == "Positive" || note.category == "Highlight";
    final color = isPositive ? accentGreen : accentOrange;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(note.date),
                style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
              ),
            ],
          ),
          8.height,
          Text(
            note.note,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
            ),
          ),
          12.height,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              note.category,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Models
class MetricsSummary {
  final int attendancePercentage;
  final int present;
  final int totalSessions;
  final int totalEvents;
  final int activitiesCount;
  final int currentStreak;

  MetricsSummary({
    required this.attendancePercentage,
    required this.present,
    required this.totalSessions,
    required this.totalEvents,
    required this.activitiesCount,
    required this.currentStreak,
  });

  factory MetricsSummary.empty() => MetricsSummary(
    attendancePercentage: 0,
    present: 0,
    totalSessions: 0,
    totalEvents: 0,
    activitiesCount: 0,
    currentStreak: 0,
  );
}

class CoachNote {
  final DateTime date;
  final String note;
  final String category;

  CoachNote({
    required this.date,
    required this.note,
    required this.category,
  });
}