// screens/guardian/guardian_metrics.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../config/colors.dart';
import '../../config/app_theme.dart';
import '../../model/guardian/get_your_member.dart';
import '../../model/member/metrics.dart' hide Data;
import '../../utills/api_service.dart';

class GuardianMetricsScreen extends StatefulWidget {
  const GuardianMetricsScreen({super.key});

  @override
  State<GuardianMetricsScreen> createState() => _GuardianMetricsScreenState();
}

class _GuardianMetricsScreenState extends State<GuardianMetricsScreen>
    with SingleTickerProviderStateMixin {
  final ParentApiService _api = ParentApiService();
  final MemberApiService _memberApi = MemberApiService();

  List<Data> _children = [];
  bool _isLoadingChildren = true;
  int? _selectedMemberId;
  String _selectedMemberName = '';

  GetMetrics? _metrics;
  bool _isLoadingMetrics = false;
  String? _metricsError;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  bool _showAllAttendance = false;
  bool _showAllFeedback = false;
  bool _showAllEvents = false;
  bool _showAllActivities = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _loadChildren();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
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
  // ── Load guardian's children ──────────────────────────────────────
  Future<void> _loadChildren() async {
    setState(() => _isLoadingChildren = true);
    try {
      final result = await _api.getYourMembers();
      setState(() {
        _children = result.data;
        _isLoadingChildren = false;
      });
      if (_children.isNotEmpty) _selectChild(_children.first);
    } catch (e) {
      setState(() => _isLoadingChildren = false);
      if (mounted) toast('Failed to load children');
    }
  }

  void _selectChild(Data child) {
    setState(() {
      _selectedMemberId = child.memberId;
      _selectedMemberName = child.username;
      _metrics = null;
    });
    _loadMetrics(child.memberId);
  }

  // ── Load metrics by memberId ──────────────────────────────────────
  Future<void> _loadMetrics(int memberId) async {
    setState(() {
      _isLoadingMetrics = true;
      _metricsError = null;
    });
    try {
      final result = await _memberApi.getMemberMetricsById(memberId);
      setState(() {
        _metrics = result;
        _isLoadingMetrics = false;
      });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      setState(() {
        _isLoadingMetrics = false;
        _metricsError = 'Failed to load metrics';
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoadingChildren
                  ? _buildFullShimmer()
                  : _children.isEmpty
                  ? _buildNoChildrenState()
                  : _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
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
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Metrics",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_selectedMemberName.isNotEmpty)
                    Text(
                      _selectedMemberName,
                      style: GoogleFonts.poppins(
                        color: accentGreen,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────
  Widget _buildBody() {
    return Column(
      children: [
        _buildChildSelector(),
        Expanded(
          child: _isLoadingMetrics
              ? _buildFullShimmer()
              : _metricsError != null
              ? _buildErrorState()
              : _metrics == null
              ? const SizedBox()
              : FadeTransition(
            opacity: _fadeAnim,
            child: _buildMetricsContent(),
          ),
        ),
      ],
    );
  }

  // ── Child Selector ────────────────────────────────────────────────
  Widget _buildChildSelector() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded,
                  size: 14.sp, color: Colors.grey.shade600),
              6.width,
              Text(
                "Metrics for",
                style: GoogleFonts.poppins(
                    fontSize: 11.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          8.height,
          SizedBox(
            height: 42.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _children.length,
              itemBuilder: (context, index) {
                final child = _children[index];
                final isSelected = child.memberId == _selectedMemberId;
                return GestureDetector(
                  onTap: () => _selectChild(child),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.only(right: 10.w),
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color:
                      isSelected ? Colors.black : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(
                        color: isSelected
                            ? Colors.black
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 10.r,
                          backgroundColor:
                          isSelected ? accentGreen : Colors.grey.shade400,
                          child: Text(
                            child.username.isNotEmpty
                                ? child.username[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.montserrat(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        6.width,
                        Text(
                          child.username,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
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
    );
  }

  // ── Metrics Content ───────────────────────────────────────────────
  Widget _buildMetricsContent() {
    final data = _metrics!.data;
    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedMemberId != null) await _loadMetrics(_selectedMemberId!);
      },
      color: accentGreen,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
        children: [
          // ── Overview Cards ─────────────────────────────────────────
          _sectionTitle("Overview"),
          8.height,
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline_rounded,
                  label: "Attendance",
                  value: "${data.attendancePercentage}%",
                  color: accentGreen,
                ),
              ),
              12.width,
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  label: "Streak",
                  value: "${data.currentStreak}d",
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
          16.height,

          // ── Activities ─────────────────────────────────────────────
          // ── Activities ─────────────────────────────────────────────
          if (data.activities.isNotEmpty) ...[
            _sectionHeaderToggle("Activities", data.activities.length, _showAllActivities,
                    () => setState(() => _showAllActivities = !_showAllActivities)),
            8.height,
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: (_showAllActivities ? data.activities : data.activities.take(4).toList())
                  .map((act) => _ActivityChip(activity: act))
                  .toList(),
            ),
            20.height,
          ],

// ── Upcoming Events ────────────────────────────────────────
          if (data.upcomingEvents.isNotEmpty) ...[
            _sectionHeaderToggle("Upcoming Events", data.upcomingEvents.length, _showAllEvents,
                    () => setState(() => _showAllEvents = !_showAllEvents)),
            8.height,
            ...(_showAllEvents ? data.upcomingEvents : data.upcomingEvents.take(2).toList())
                .map((e) => _UpcomingEventCard(event: e)),
            12.height,
          ],

// ── Attendance History ─────────────────────────────────────
          if (data.attendanceHistory.isNotEmpty) ...[
            _sectionHeaderToggle("Attendance History", data.attendanceHistory.length, _showAllAttendance,
                    () => setState(() => _showAllAttendance = !_showAllAttendance)),
            8.height,
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: (_showAllAttendance
                      ? data.attendanceHistory
                      : data.attendanceHistory.take(3).toList())
                      .asMap()
                      .entries
                      .map((entry) {
                    final list = _showAllAttendance
                        ? data.attendanceHistory
                        : data.attendanceHistory.take(3).toList();
                    final isLast = entry.key == list.length - 1;
                    return Column(
                      children: [
                        _AttendanceRow(record: entry.value),
                        if (!isLast) Divider(height: 20.h, color: Colors.grey.shade200),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            20.height,
          ],

// ── Coach Feedback ─────────────────────────────────────────
          if (data.coachFeedback.isNotEmpty) ...[
            _sectionHeaderToggle("Coach Feedback", data.coachFeedback.length, _showAllFeedback,
                    () => setState(() => _showAllFeedback = !_showAllFeedback)),
            8.height,
            ...(_showAllFeedback ? data.coachFeedback : data.coachFeedback.take(2).toList())
                .map((f) => _CoachFeedbackCard(feedback: f)),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade700,
      ),
    );
  }

  // ── Placeholder / Error states ────────────────────────────────────
  Widget _buildNoChildrenState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.child_care_rounded,
                size: 64.sp, color: Colors.grey.shade400),
            16.height,
            Text(
              "No children linked yet",
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            8.height,
            Text(
              "Please wait while your club admin links a member to your account.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13.sp, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 52.sp, color: Colors.red.shade300),
          12.height,
          Text(
            _metricsError ?? 'Something went wrong',
            style:
            GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          16.height,
          ElevatedButton.icon(
            onPressed: () {
              if (_selectedMemberId != null) {
                _loadMetrics(_selectedMemberId!);
              }
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text("Retry", style: GoogleFonts.poppins()),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildFullShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
              12.width,
              Expanded(
                child: Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ]),
            16.height,
            ...List.generate(
              4,
                  (_) => Container(
                height: 70.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28.sp),
          8.height,
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          4.height,
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Activity Chip ─────────────────────────────────────────────────────────────
class _ActivityChip extends StatelessWidget {
  final String activity;

  const _ActivityChip({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: accentGreen.withOpacity(0.4), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_rounded, size: 14.sp, color: accentGreen),
          6.width,
          Text(
            activity,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: accentGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upcoming Event Card ───────────────────────────────────────────────────────
class _UpcomingEventCard extends StatelessWidget {
  final UpcomingEvents event;

  const _UpcomingEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14.r),
        border:
        Border.all(color: accentOrange.withOpacity(0.3), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: accentOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.event_rounded,
                color: accentOrange, size: 22.sp),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventName,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                5.height,
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 11.sp, color: textSecondary),
                    4.width,
                    Text(
                      event.eventDate,
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp, color: textSecondary),
                    ),
                    if (event.location.isNotEmpty) ...[
                      12.width,
                      Icon(Icons.location_on_outlined,
                          size: 11.sp, color: textSecondary),
                      4.width,
                      Expanded(
                        child: Text(
                          event.location,
                          style: GoogleFonts.poppins(
                              fontSize: 11.sp, color: textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: accentOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              event.eventType,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: accentOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Attendance Row ────────────────────────────────────────────────────────────
class _AttendanceRow extends StatelessWidget {
  final AttendanceHistory record;

  const _AttendanceRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final isPresent = record.status.toUpperCase() == 'PRESENT' ||
        record.status.toUpperCase() == 'ATTENDED';
    final color = isPresent ? accentGreen : Colors.red;

    return Row(
      children: [
        Icon(
          isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: color,
          size: 20.sp,
        ),
        10.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.eventName,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              2.height,
              Text(
                record.eventDate,
                style: GoogleFonts.poppins(
                    fontSize: 11.sp, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            record.status,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CoachFeedbackCard extends StatelessWidget {
  final CoachFeedback feedback;

  const _CoachFeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    String formattedDate = feedback.date;
    try {
      final parsed = DateTime.parse(feedback.date);
      formattedDate = DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {}

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accentGreen.withOpacity(0.3), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: accentGreen.withOpacity(0.12),
                child: Icon(Icons.person_rounded,
                    color: accentGreen, size: 18.sp),
              ),
              10.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.coachName,
                      style: GoogleFonts.montserrat(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    if (feedback.eventName != null &&
                        feedback.eventName!.isNotEmpty)
                      Text(
                        feedback.eventName!,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    Text(
                      formattedDate,
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              // ── Star Rating ──
              if (feedback.rating != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < feedback.rating!
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: i < feedback.rating!
                          ? Colors.amber
                          : Colors.grey.shade300,
                      size: 16.sp,
                    );
                  }),
                ),
            ],
          ),
          12.height,
          Text(
            feedback.comment,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}