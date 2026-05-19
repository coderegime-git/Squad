import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_filex/open_filex.dart';
import '../../config/app_theme.dart';
import '../../config/colors.dart';
import '../../model/member/metrics.dart';
import '../../model/member_document.dart';
import '../../utills/api_service.dart'; // same import as dashboard

class MemberMetricsScreen extends StatefulWidget {
  const MemberMetricsScreen({Key? key}) : super(key: key);

  @override
  State<MemberMetricsScreen> createState() => _MemberMetricsScreenState();
}

class _MemberMetricsScreenState extends State<MemberMetricsScreen> {
  final MemberApiService _api = MemberApiService();
  late Future<GetMetrics> _metricsFuture;
  final DocumentApiService _docApi = DocumentApiService();
  List<MemberDocument> _documents = [];
  bool _isLoadingDocs = false;
  final Map<int, bool> _downloadingDocs = {};
  bool _showAllAttendance = false;
  bool _showAllFeedback = false;
  bool _showAllEvents = false;
  bool _showAllActivities = false;
  int? _memberId;


  @override
  void initState() {
    super.initState();
    _metricsFuture = _api.getMetrics();
    _loadDocuments();
  }
  Future<void> _loadDocuments() async {
    setState(() => _isLoadingDocs = true);
    try {
      // No memberId needed — API derives from JWT for members
      final docs = await _docApi.getDocuments1(memberId: 0);
      setState(() {
        _documents = docs;
        _isLoadingDocs = false;
      });
    } catch (e) {
      setState(() => _isLoadingDocs = false);
    }
  }
  Widget _buildPerformanceReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Reports',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 12.h),
        if (_isLoadingDocs)
          const Center(child: CircularProgressIndicator())
        else if (_documents.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Icon(Icons.folder_open_rounded, color: Colors.grey.shade400),
                  SizedBox(width: 12.w),
                  Text(
                    'No reports uploaded yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...(_documents.map((doc) => _buildDocCard(doc))),
      ],
    );
  }
  Widget _sectionHeaderToggle(String title, int total, bool expanded, VoidCallback onToggle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14.sp)),
        if (total > 2)
          GestureDetector(
            onTap: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expanded ? 'See less' : 'See all ($total)',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.green, fontWeight: FontWeight.w600),
                ),
                Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.green, size: 16.sp),
              ],
            ),
          ),
      ],
    );
  }
  Widget _buildDocCard(MemberDocument doc) {
    final isDownloading = _downloadingDocs[doc.documentId] == true;
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.picture_as_pdf, color: Colors.deepPurple, size: 24.sp),
        ),
        title: Text(
          doc.description.isNotEmpty ? doc.description : doc.fileName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${doc.formattedDate}  •  ${doc.formattedSize}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.sp),
        ),
        trailing: GestureDetector(
          onTap: isDownloading ? null : () => _openDoc(doc),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDownloading
                  ? Colors.grey.shade200
                  : AppColors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: isDownloading
                ? SizedBox(
              width: 18.w,
              height: 18.w,
              child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.green,
              ),
            )
                : Icon(Icons.download_rounded, color: AppColors.green, size: 18.sp),
          ),
        ),
      ),
    );
  }

  Future<void> _openDoc(MemberDocument doc) async {
    setState(() => _downloadingDocs[doc.documentId] = true);
    try {
      final path = await _docApi.downloadDocument(
        documentId: doc.documentId,
        memberId: doc.memberId,
        fileName: doc.fileName,
      );
      setState(() => _downloadingDocs[doc.documentId] = false);
      if (path == null) { ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download failed'))); return; }
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No PDF viewer installed')));
      }
    } catch (e) {
      setState(() => _downloadingDocs[doc.documentId] = false);
    }
  }
  void _refresh() {
    setState(() {
      _metricsFuture = _api.getMetrics();
    });
  }


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
        // ── Activities ─────────────────────────────────────────────
        if (data.activities.isNotEmpty) ...[
          _sectionHeaderToggle('Activities', data.activities.length, _showAllActivities,
                  () => setState(() => _showAllActivities = !_showAllActivities)),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: (_showAllActivities ? data.activities : data.activities.take(4).toList())
                .map((a) => Chip(
              label: Text(_toTitle(a),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.green, fontWeight: FontWeight.w600)),
              backgroundColor: AppColors.green.withOpacity(0.10),
              side: BorderSide.none,
              avatar: const Icon(Icons.sports_soccer, color: AppColors.green, size: 16),
            ))
                .toList(),
          ),
          SizedBox(height: 24.h),
        ],

// ── Upcoming Events ────────────────────────────────────────
        if (data.upcomingEvents.isNotEmpty) ...[
          _sectionHeaderToggle('Upcoming Events', data.upcomingEvents.length, _showAllEvents,
                  () => setState(() => _showAllEvents = !_showAllEvents)),
          SizedBox(height: 12.h),
          ...(_showAllEvents ? data.upcomingEvents : data.upcomingEvents.take(2).toList())
              .map((e) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildUpcomingEventCard(context, e),
          )),
          SizedBox(height: 12.h),
        ],

// ── Attendance History ─────────────────────────────────────
        if (data.attendanceHistory.isNotEmpty) ...[
          _sectionHeaderToggle('Attendance History', data.attendanceHistory.length, _showAllAttendance,
                  () => setState(() => _showAllAttendance = !_showAllAttendance)),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  ...(_showAllAttendance ? data.attendanceHistory : data.attendanceHistory.take(3).toList())
                      .asMap()
                      .entries
                      .map((entry) => Column(
                    children: [
                      if (entry.key != 0) SizedBox(height: 12.h),
                      _buildAttendanceRow(context,
                          date: _formatDate(entry.value.eventDate),
                          session: entry.value.eventName,
                          status: _toTitle(entry.value.status)),
                    ],
                  )),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],

// ── Coach Feedback ─────────────────────────────────────────
        if (data.coachFeedback.isNotEmpty) ...[
          _sectionHeaderToggle('Coach Feedback', data.coachFeedback.length, _showAllFeedback,
                  () => setState(() => _showAllFeedback = !_showAllFeedback)),
          SizedBox(height: 12.h),
          ...(_showAllFeedback ? data.coachFeedback : data.coachFeedback.take(2).toList())
              .asMap()
              .entries
              .map((entry) => Padding(
            padding: EdgeInsets.only(
                bottom: entry.key < data.coachFeedback.length - 1 ? 12.h : 0),
            child: _buildFeedbackCard(context,
                coach: entry.value.coachName,
                date: _formatDate(entry.value.date),
                feedback: entry.value.comment,
                rating: entry.value.rating,
                eventName: entry.value.eventName),
          )),
          //SizedBox(height: 100.h),
        ],
        SizedBox(height: 24.h),
        _buildPerformanceReports(),
        //SizedBox(height: 100.h),
      ],
    );
  }



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
        int? rating,
        String? eventName,
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
                      Text(
                        coach.isNotEmpty ? coach : 'Coach',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (eventName != null && eventName.isNotEmpty)
                        Text(
                          eventName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.black,
                            fontSize: 11.sp,
                          ),
                        ),
                    ],
                  ),
                ),
                // ── Star Rating ──
                if (rating != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      return Icon(
                        i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: i < rating ? Colors.amber : Colors.grey.shade300,
                        size: 16.sp,
                      );
                    }),
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