// screens/guardian/guardian_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/colors.dart';
import '../../model/guardian/getGuardianEvents.dart';
import '../../model/guardian/get_member_dashboard_data.dart';
import '../../model/guardian/get_your_member.dart';
import '../../utills/api_service.dart';
import '../../utills/shared_preference.dart';
import '../../widgets/common.dart';
import '../notification_screen.dart';
import 'demo.dart';

class GuardianDashboard extends StatefulWidget {
  const GuardianDashboard({super.key});

  @override
  State<GuardianDashboard> createState() => _GuardianDashboardState();
}

class _GuardianDashboardState extends State<GuardianDashboard> {
  final ParentApiService _api = ParentApiService();

  List<Data> _children = [];
  int? _selectedMemberId;
  bool _isLoadingChildren = true;

  GuardianDashboardData? _dashboardData;
  bool _isLoadingDashboard = false;

  List<GuardianEventData> _pendingEvents = [];
  bool _isLoadingEvents = false;
  // List<GuardianChildEvent> _upcomingEvents = [];
  bool _isLoadingUpcoming = false;
  String get _username => SharedPreferenceHelper.getUsername() ?? 'Guardian';
  GuardianDashboardBody? get _dashBody => _dashboardData?.data;
  SelectedChildData? get _selectedChild => _dashBody?.selectedChild;
  List<dynamic> _upcomingEvents = [];
  // bool _isLoadingUpcoming = false;
  @override
  void initState() {
    super.initState();
    _init();
  }
  Future<void> _init() async {
    setState(() => _isLoadingChildren = true);
    try {
      final result = await _api.getYourMembers();
      setState(() {
        _children = result.data;
        _isLoadingChildren = false;
      });
      if (_children.isNotEmpty) {
        _selectedMemberId = _children.first.memberId;
        await Future.wait([
          _loadDashboard(_selectedMemberId!),
          _loadPendingEvents(_selectedMemberId!),
          _loadUpcomingEvents(_selectedMemberId!), // ← add
        ]);
      }
    } catch (e) {
      setState(() => _isLoadingChildren = false);
      if (mounted) toast('Failed to load members');
    }
  }  Future<void> _loadUpcomingEvents(int memberId) async {
    setState(() => _isLoadingUpcoming = true);
    try {
      final response = await _api.getGuardianMemberEvents(memberId);
      final now = DateTime.now();
      final oneMonthLater = now.add(const Duration(days: 30));

      final List<dynamic> rawList =
      response is List ? response : (response['data'] ?? []);

      final filtered = rawList.where((item) {
        try {
          final date = DateTime.parse(item['eventDate'] ?? '');
          return date.isAfter(now.subtract(const Duration(days: 1))) &&
              date.isBefore(oneMonthLater);
        } catch (_) {
          return false;
        }
      }).map((item) => MemberEvent.fromJson(item as Map<String, dynamic>)).toList();

      setState(() {
        _upcomingEvents = filtered;
        _isLoadingUpcoming = false;
      });
    } catch (e) {
      setState(() => _isLoadingUpcoming = false);
      print("loadUpcomingEvents failed: $e");
    }
  }
  Future<void> _loadDashboard(int memberId) async {
    setState(() => _isLoadingDashboard = true);
    try {
      final result = await _api.getGuardianDashboard(memberId: memberId);
      setState(() {
        _dashboardData = result;
        _isLoadingDashboard = false;
      });
    } catch (e) {
      setState(() => _isLoadingDashboard = false);
      if (mounted) toast('Failed to load dashboard');
    }
  }

  Future<void> _loadPendingEvents(int memberId) async {
    setState(() => _isLoadingEvents = true);
    try {
      final result = await _api.getGuardianPendingEvents(memberId);
      setState(() {
        _pendingEvents = result.data;
        _isLoadingEvents = false;
      });
    } catch (e) {
      setState(() => _isLoadingEvents = false);
    }
  }

  Future<void> _updateStatus(int memberId, int eventId, String status) async {
    final success =
    await _api.updateGuardianEventStatus(memberId, eventId, status);
    if (mounted) {
      if (success) {
        toast(status == 'ACCEPT' ? 'Event accepted!' : 'Event declined');
        _loadPendingEvents(memberId);
      } else {
        toast('Failed to update status');
      }
    }
  }

  Future<void> _onRefresh() => _init();

  void _onChildTap(Data member) {
    if (_selectedMemberId == member.memberId) return;
    setState(() => _selectedMemberId = member.memberId);
    Future.wait([
      _loadDashboard(member.memberId),
      _loadPendingEvents(member.memberId),
      _loadUpcomingEvents(member.memberId), // ← add
    ]);
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
            // ── Header ───────────────────────────────────────────────
            _buildHeader(),

            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: accentGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      20.height,

                      // ── Children Selector ────────────────────────
                      if (_isLoadingChildren)
                        const ChildSelectorShimmer()
                      else if (_children.isEmpty)
                        _buildNoChildrenWidget()
                      else
                        _buildChildrenList(),

                      24.height,

                      // ── Stats Row ────────────────────────────────
                      if (_isLoadingDashboard)
                        _shimmerBox(height: 90.h)
                      else if (_selectedChild != null)
                        _buildStatsRow(_selectedChild!),

                      24.height,

                      // ── Pending Events ───────────────────────────
                      if (_children.isNotEmpty) ...[
                        Row(
                          children: [
                            _buildSectionHeader("Pending Events"),
                            8.width,
                            // if (_pendingEvents.isNotEmpty)
                            //   Container(
                            //     padding: EdgeInsets.symmetric(
                            //         horizontal: 8.w, vertical: 2.h),
                            //     decoration: BoxDecoration(
                            //       color: accentOrange.withOpacity(0.15),
                            //       borderRadius: BorderRadius.circular(20.r),
                            //     ),
                            //     child: Text(
                            //       '\${_pendingEvents.length}',
                            //       style: GoogleFonts.poppins(
                            //         fontSize: 11.sp,
                            //         color: accentOrange,
                            //         fontWeight: FontWeight.w700,
                            //       ),
                            //     ),
                            //   ),
                          ],
                        ),
                        12.height,
                        if (_isLoadingEvents)
                          _shimmerBox(height: 100.h)
                        else if (_pendingEvents.isEmpty)
                          _buildEmptyCard("No pending events for this child")
                        else
                          ..._pendingEvents.map(
                                (e) => _PendingEventCard(
                              event: e,
                              onAccept: () => _updateStatus(
                                  _selectedMemberId!, e.eventId, 'ACCEPT'),
                              onDecline: () => _updateStatus(
                                  _selectedMemberId!, e.eventId, 'REJECT'),
                            ),
                          ),
                        24.height,
                      ],

                      // ── Upcoming Events ───────────────────────────────
                      if (_children.isNotEmpty) ...[
                        _buildSectionHeader("Upcoming Events"),
                        12.height,
                        if (_isLoadingUpcoming)
                          _shimmerBox(height: 100.h)
                        else if (_upcomingEvents.isEmpty)
                          _buildEmptyCard("No upcoming events within the next month")
                        else
                          ...(_upcomingEvents as List<MemberEvent>).map(
                                (e) => Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: _UpcomingEventTile(event: e),
                            ),
                          ),
                        24.height,
                      ],

                      if (_children.isNotEmpty) ...[
                        _buildSectionHeader("Payments"),
                        12.height,
                        if (_isLoadingDashboard)
                          _shimmerBox(height: 80.h)
                        else if (_selectedChild != null)
                          _PaymentCard(payment: _selectedChild!.payments),
                        24.height,
                      ],

                      // ── Notifications / Club Updates ─────────────
                      _buildSectionHeader("Club Updates"),
                      16.height,
                      if (_isLoadingDashboard)
                        _shimmerBox(height: 120.h)
                      else if (_dashBody == null ||
                          _dashBody!.notifications.isEmpty)
                        _buildEmptyCard("No recent updates")
                      else
                        Column(
                          children: _dashBody!.notifications
                              .asMap()
                              .entries
                              .map(
                                (entry) => Padding(
                              padding: EdgeInsets.only(bottom: 14.h),
                              child: NotificationListTile(
                                title: entry.value,
                                time: '',
                              ),
                            ),
                          )
                              .toList(),
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

  // ── Header ─────────────────────────────────────────────────────────────────
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
          padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Hello, $_username",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              NotificationBellIcon(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Children horizontal list ───────────────────────────────────────────────
  Widget _buildChildrenList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My Children",
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
        12.height,
        SizedBox(
          height: 140.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _children.length,
            itemBuilder: (context, index) {
              final member = _children[index];
              final isSelected = member.memberId == _selectedMemberId;
              return GestureDetector(
                onTap: () => _onChildTap(member),
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
                    color: isSelected
                        ? accentGreen.withOpacity(0.05)
                        : Colors.white,
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28.r,
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          member.username.isNotEmpty
                              ? member.username[0].toUpperCase()
                              : '?',
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
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
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
    );
  }

  // ── Stats Row (Attendance + Performance Rating) ────────────────────────────
  Widget _buildStatsRow(SelectedChildData child) {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.check_circle_outline_rounded,
          label: "Attendance",
          value: "${child.attendancePercentage.toStringAsFixed(0)}%",
          color: accentOrange,
          subtitle: "This season",
        ),
        12.width,
        _buildStatCard(
          icon: Icons.star_rounded,
          label: "Performance",
          value: child.performanceRating != null
              ? "${child.performanceRating!.toStringAsFixed(1)} / 10"
              : "N/A",
          color: accentGreen,
          subtitle: "Coach rating",
        ),
      ],
    );
  }

  // ── Stat Card ──────────────────────────────────────────────────────────────
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
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
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: textSecondary,
              ),
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

  // ── No Children ────────────────────────────────────────────────────────────
  Widget _buildNoChildrenWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.child_care_rounded,
                size: 48.sp, color: Colors.grey.shade400),
            12.height,
            Text(
              "No children linked yet.",
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
    );
  }

  // ── Section Header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade700,
      ),
    );
  }

  // ── Empty State Card ───────────────────────────────────────────────────────
  Widget _buildEmptyCard(String message) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.poppins(color: textSecondary),
        ),
      ),
    );
  }

  // ── Shimmer Placeholder ────────────────────────────────────────────────────
  Widget _shimmerBox({required double height}) {
    return Container(
      height: height,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final GuardianChildEvent event;

  const _EventTile({required this.event});

  Color get _statusColor {
    switch (event.rsvpStatus.toUpperCase()) {
      case 'ACCEPTED':
        return accentGreen;
      case 'REJECTED':
        return Colors.red;
      default:
        return accentOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.event_rounded,
              color: _statusColor,
              size: 20.sp,
            ),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                4.height,
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 11.sp, color: textSecondary),
                    4.width,
                    Text(
                      event.eventDate,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              event.rsvpStatus,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: _statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final GuardianPayment payment;

  const _PaymentCard({required this.payment});

  Color get _statusColor {
    switch (payment.status.toUpperCase()) {
      case 'PAID':
        return accentGreen;
      case 'OVERDUE':
        return Colors.red;
      default:
        return accentOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _statusColor.withOpacity(0.35), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: _statusColor,
              size: 24.sp,
            ),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.due > 0 ? "Amount Due: ₹${payment.due}" : "No dues",
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                4.height,
                Text(
                  "Status: ${payment.status}",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              payment.status,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: _statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingEventCard extends StatelessWidget {
  final GuardianEventData event;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _PendingEventCard({
    required this.event,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accentOrange.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.eventName,
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: accentOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'PENDING',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: accentOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          8.height,
          Row(
            children: [
              Icon(Icons.sports_rounded, size: 13.sp, color: textSecondary),
              5.width,
              Text(
                event.teamName,
                style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
              ),
              16.width,
              Icon(Icons.calendar_today_rounded, size: 13.sp, color: textSecondary),
              5.width,
              Text(
                event.eventDate,
                style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
              ),
            ],
          ),
          12.height,
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Accept',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              12.width,
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Decline',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _UpcomingEventTile extends StatelessWidget {
  final MemberEvent event;
  const _UpcomingEventTile({required this.event});

  Color get _typeColor {
    switch (event.eventType.toUpperCase()) {
      case 'MATCH': return accentOrange;
      case 'TOURNAMENT': return Colors.purple;
      default: return accentGreen;
    }
  }

  IconData get _typeIcon {
    switch (event.eventType.toUpperCase()) {
      case 'MATCH': return Icons.sports_soccer_rounded;
      case 'TOURNAMENT': return Icons.emoji_events_rounded;
      default: return Icons.fitness_center_rounded;
    }
  }

  Color get _statusColor {
    switch (event.status.toUpperCase()) {
      case 'ACCEPTED':
      case 'CONFIRMED': return accentGreen;
      case 'REJECTED':
      case 'CANCELLED': return Colors.red;
      default: return accentOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _typeColor.withOpacity(0.35), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: _typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(_typeIcon, color: _typeColor, size: 20.sp),
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
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height,
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 11.sp, color: textSecondary),
                    4.width,
                    Text(
                      '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp, color: textSecondary),
                    ),
                    if (event.eventTime.isNotEmpty) ...[
                      12.width,
                      Icon(Icons.access_time_rounded,
                          size: 11.sp, color: textSecondary),
                      4.width,
                      Text(
                        event.eventTime,
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp, color: textSecondary),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              event.status,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: _statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class MemberEvent {
  final int eventId;
  final String eventName;
  final DateTime eventDate;
  final String eventTime;
  final String location;
  final String eventType;
  final String status;

  MemberEvent({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.location,
    required this.eventType,
    required this.status,
  });

  factory MemberEvent.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['eventDate'] ?? '');
    } catch (_) {
      parsedDate = DateTime.now();
    }
    return MemberEvent(
      eventId: json['eventId'] ?? 0,
      eventName: json['eventName'] ?? '',
      eventDate: parsedDate,
      eventTime: _parseTime(json['eventTime']),
      location: json['location'] ?? '',
      eventType: json['eventType'] ?? 'TRAINING',
      status: json['status'] ?? 'PENDING',
    );
  }

  static String _parseTime(dynamic t) {
    if (t == null) return '';
    if (t is String) return t;
    if (t is Map) {
      final h = (t['hour'] ?? 0).toString().padLeft(2, '0');
      final m = (t['minute'] ?? 0).toString().padLeft(2, '0');
      return '$h:$m';
    }
    return '';
  }
}
