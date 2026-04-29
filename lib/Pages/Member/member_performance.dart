import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../config/app_theme.dart';
import '../../config/colors.dart';
import '../../model/member/metrics.dart';
import '../../utills/api_service.dart'; // same import as dashboard

class MemberMetricsScreen extends StatefulWidget {
  const MemberMetricsScreen({Key? key}) : super(key: key);

  @override
  State<MemberMetricsScreen> createState() => _MemberMetricsScreenState();
}

class _MemberMetricsScreenState extends State<MemberMetricsScreen> {
  final MemberApiService _api = MemberApiService();
  late Future<GetMetrics> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _metricsFuture = _api.getMetrics();
  }

  void _refresh() {
    setState(() {
      _metricsFuture = _api.getMetrics();
    });
  }

  // ── helpers ─────────────────────────────────────────────────────────────────

  String _toTitle(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  // ── build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // ── App bar ──────────────────────────────────────────────────────────
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
                      'Metrics',
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

          // ── Body ─────────────────────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<GetMetrics>(
              future: _metricsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load metrics.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final data = snapshot.data!.data;
                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: _buildContent(context, data),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Data data) {
    return ListView(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      children: [
        // ── Overall Performance ───────────────────────────────────────────────
        Text(
          'Overall Performance',
          style:
          Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Attendance',
                value: '${data.attendancePercentage}%',
                icon: Icons.check_circle_outline,
                color: AppColors.green,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Streak',
                value:
                '${data.currentStreak} day${data.currentStreak == 1 ? '' : 's'}',
                icon: Icons.local_fire_department,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // ── Activities ────────────────────────────────────────────────────────
        if (data.activities.isNotEmpty) ...[
          Text(
            'Activities',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: data.activities
                .map(
                  (a) => Chip(
                label: Text(
                  _toTitle(a),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: AppColors.green.withOpacity(0.10),
                side: BorderSide.none,
                avatar: const Icon(Icons.sports_soccer,
                    color: AppColors.green, size: 16),
              ),
            )
                .toList(),
          ),
          SizedBox(height: 24.h),
        ],

        // ── Upcoming Events ───────────────────────────────────────────────────
        if (data.upcomingEvents.isNotEmpty) ...[
          Text(
            'Upcoming Events',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),
          ...data.upcomingEvents.map(
                (e) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildUpcomingEventCard(context, e),
            ),
          ),
          SizedBox(height: 12.h),
        ],

        // ── Attendance History ────────────────────────────────────────────────
        if (data.attendanceHistory.isNotEmpty) ...[
          Text(
            'Attendance History',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontSize: 14.sp),
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
                    'Last ${data.attendanceHistory.length} Session${data.attendanceHistory.length == 1 ? '' : 's'}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  ...data.attendanceHistory.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final h = entry.value;
                    return Column(
                      children: [
                        if (idx != 0) SizedBox(height: 12.h),
                        _buildAttendanceRow(
                          context,
                          date: _formatDate(h.eventDate),
                          session: h.eventName,
                          status: _toTitle(h.status),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],

        // ── Coach Feedback ────────────────────────────────────────────────────
        if (data.coachFeedback.isNotEmpty) ...[
          Text(
            'Coach Feedback',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),
          ...data.coachFeedback.asMap().entries.map((entry) {
            final idx = entry.key;
            final f = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: idx < data.coachFeedback.length - 1 ? 12.h : 0),
              child: _buildFeedbackCard(
                context,
                coach: f.coachName,
                date: _formatDate(f.date),
                feedback: f.comment,
              ),
            );
          }),
          SizedBox(height: 100.h),
        ],
      ],
    );
  }

  // ── Card builders ─────────────────────────────────────────────────────────

  Widget _buildStatCard(
      BuildContext context, {
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
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontSize: 17.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 12.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventCard(BuildContext context, UpcomingEvents event) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child:
              const Icon(Icons.event, color: AppColors.orange, size: 24),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 13.sp),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 12, color: AppColors.mediumGrey),
                      SizedBox(width: 4.w),
                      Text(
                        '${_formatDate(event.eventDate)}  •  ${event.eventTime}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGrey,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: AppColors.mediumGrey),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          event.location,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: AppColors.mediumGrey,
                            fontSize: 11.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _toTitle(event.eventType),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRow(
      BuildContext context, {
        required String date,
        required String session,
        required String status,
      }) {
    final isPresent = status.toLowerCase() == 'present';
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
              Text(
                session,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.mediumGrey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isPresent ? AppColors.success : AppColors.error)
                .withOpacity(0.1),
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

  Widget _buildFeedbackCard(
      BuildContext context, {
        required String coach,
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
                  child: Text(
                    coach.isNotEmpty ? coach : 'Coach',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              feedback,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade800,
                fontSize: 12.sp,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.mediumGrey),
            ),
          ],
        ),
      ),
    );
  }
}