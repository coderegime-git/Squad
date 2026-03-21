// screens/clubadmin/clubadmin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sports/Pages/Club_admin/payment_setup.dart';
import 'package:sports/Pages/Club_admin/payments.dart';
import 'package:sports/model/clubAdmin/dashboard_data.dart';
import 'package:sports/model/clubAdmin/get_event_details.dart';
import 'package:sports/utills/api_service.dart';

import '../../config/colors.dart';
import '../../utills/shared_preference.dart';
import '../splash.dart';
import 'activities_screen.dart';
import 'add_coach_screen.dart';
import 'add_guardian.dart';
import 'add_member_screen.dart';
import 'club_admin_schedule.dart';
import 'link_children.dart';

class ClubAdminDashboard extends StatefulWidget {
  const ClubAdminDashboard({super.key});

  @override
  State<ClubAdminDashboard> createState() => _ClubAdminDashboardState();
}

class _ClubAdminDashboardState extends State<ClubAdminDashboard> {
  DashboardData? dashboardData;
  GetEventDetails? eventDetails;
  final apiService = ClubApiService();
  bool isLoad = false;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => isLoad = true);
    try {
      dashboardData = await apiService.getDashboardData();
      print("dashboardDatadashboardData");
      print(dashboardData!.payments);
      print(dashboardData!.members);
      print(dashboardData!.alerts);
      eventDetails = await apiService.getEvents();
    } catch (e) {
      debugPrint('Dashboard load error: $e');
    } finally {
      if (mounted) setState(() => isLoad = false);
    }
  }

  // ── Upcoming events filtered to today or future ───────────────────────────
  List<Data> get _upcomingEvents {
    if (eventDetails == null) return [];
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return eventDetails!.data.where((e) {
      if (e.eventDate == null) return false;
      final eventDate = DateTime.parse(e.eventDate!);
      return !eventDate.isBefore(today);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: isLoad
            ? const Center(child: Loader())
            : Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadDashboard,
                      color: accentGreen,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            24.height,
                            _buildClubCard(),
                            20.height,
                            _buildStatPills(),
                            20.height,
                            _buildPaymentAlert(),
                            22.height,
                            _buildSectionTitle('Quick Actions'),
                            16.height,
                            _buildQuickActionsRow1(),
                            16.height,
                            _buildQuickActionsRow2(),
                            22.height,
                            _buildSectionTitle('Upcoming Events'),
                            12.height,
                            _buildEventList(),
                            22.height,
                            _buildSectionTitle('Pending Actions'),
                            12.height,
                            _buildPendingActions(),
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

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
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
            children: [
              Text(
                'Club Dashboard',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showProfileSheet(context),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentGreen.withOpacity(0.4)),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: accentGreen,
                    size: 22.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Club Info Card ────────────────────────────────────────────────────────

  Widget _buildClubCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: accentGreen.withOpacity(0.5)),
            ),
            child: Icon(
              Icons.sports_soccer_rounded,
              color: accentGreen,
              size: 28.sp,
            ),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'XYZ Sports Club',
                  style: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                4.height,
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: accentGreen,
                      size: 13.sp,
                    ),
                    4.width,
                    Text(
                      'Madurai, Tamil Nadu',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: accentGreen.withOpacity(0.4)),
            ),
            child: Text(
              'Active',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Pills ────────────────────────────────────────────────────────────

  Widget _buildStatPills() {
    if (dashboardData == null) {
      return Row(
        children: List.generate(
          5,
          (_) => Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      );
    }

    final d = dashboardData!;
    return Row(
      children: [
        _statPill('${d.members?.total ?? 0}', 'Members', accentGreen),
        _statPill('${d.coaches ?? 0}', 'Coaches', accentOrange),
        _statPill('${d.groups ?? 0}', 'Groups', Colors.blue),
        _statPill('${d.events?.upcomingCount ?? 0}', 'Events', Colors.brown),
        _statPill('${d.activities ?? 0}', 'Sports', Colors.purple),
      ],
    );
  }

  // ── Payment Alert ─────────────────────────────────────────────────────────

  Widget _buildPaymentAlert() {
    final payments = dashboardData?.payments;
    if (payments == null) return const SizedBox.shrink();

    final pending = payments.pending;
    final overdue = payments.overdue;
    if (pending == null && overdue == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: accentOrange.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: accentOrange.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: accentOrange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: accentOrange,
              size: 22.sp,
            ),
          ),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pending?.count ?? 0} Pending · ${overdue?.count ?? 0} Overdue',
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                4.height,
                Text(
                  'Tap to manage member payments',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: accentOrange, size: 22.sp),
        ],
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActionsRow1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _quickAction(
          Icons.person_add_rounded,
          'Add\nMember',
          accentGreen,
          () => _push(const ClubAdminAddMemberScreen()),
        ),
        _quickAction(
          Icons.people_rounded,
          'Add\nCoach',
          accentOrange,
          () => _push(const ClubAdminAddCoachScreen()),
        ),
        _quickAction(
          Icons.group_add_rounded,
          'Add\nGuardian',
          Colors.blue,
          () => _push(const ClubAdminAddGuardianScreen()),
        ),
        _quickAction(
          Icons.link_rounded,
          'Link\nChild',
          Colors.purple,
          () => _push(const ClubAdminLinkChildGuardianScreen()),
        ),
      ],
    );
  }

  Widget _buildQuickActionsRow2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _quickAction(
          Icons.qr_code_2_rounded,
          'QR Setup',
          Colors.teal,
          () => _push(const ClubAdminPaymentQRSetupScreen()),
        ),
        _quickAction(
          Icons.payment_rounded,
          'Payments',
          Colors.deepOrange,
          () => _push(const ClubAdminPaymentsScreen()),
        ),
        _quickAction(
          Icons.sports_rounded,
          'Activities',
          Colors.indigo,
          () => _push(const ClubAdminActivitiesScreen()),
        ),
        _quickAction(
          Icons.bar_chart_rounded,
          'Reports',
          Colors.brown,
          () => toast('Reports coming soon'),
        ),
      ],
    );
  }

  // ── Event List ────────────────────────────────────────────────────────────

  Widget _buildEventList() {
    final events = _upcomingEvents;
    if (events.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          'No upcoming events',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
        ),
      );
    }
    return Column(
      children: events
          .map(
            (e) => _eventStrip(
              e.eventName ?? '',
              e.eventDate ?? '',
              e.location ?? '',
              accentGreen,
              e,
            ),
          )
          .toList(),
    );
  }

  // ── Pending Actions ───────────────────────────────────────────────────────

  Widget _buildPendingActions() {
    final alerts = dashboardData?.alerts;
    if (alerts == null || alerts.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          'No pending actions',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
        ),
      );
    }
    return Column(
      children: alerts
          .map(
            (a) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _pendingCard(a),
            ),
          )
          .toList(),
    );
  }

  // ── Section Title ─────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade700,
      ),
    );
  }

  // ── Reusable Widgets ──────────────────────────────────────────────────────

  Widget _statPill(String val, String lbl, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: GoogleFonts.montserrat(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            4.height,
            Text(
              lbl,
              style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 26.sp),
          ),
          6.height,
          SizedBox(
            width: 68.w,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventStrip(
    String title,
    String time,
    String loc,
    Color color,
    Data data,
  ) {
    return GestureDetector(
      onTap: () => _showEventDetailSheet(data),
      child: Container(
        padding: EdgeInsets.all(14.w),
        margin: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.sports_soccer_rounded,
                color: color,
                size: 22.sp,
              ),
            ),
            14.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  4.height,
                  Text(
                    '$time · $loc',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'View',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pendingCard(String alert) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.pending_actions_outlined,
              color: Colors.red,
              size: 22.sp,
            ),
          ),
          14.width,
          Expanded(
            child: Text(
              alert,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          8.width,
          Icon(Icons.chevron_right_rounded, color: textSecondary),
        ],
      ),
    );
  }

  // ── Bottom Sheets ─────────────────────────────────────────────────────────

  void _showEventDetailSheet(Data event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => EventDetailSheet(
        eventId: event.eventId,
        event: event,
        apiService: apiService,
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            16.height,
            _sheetTile(
              context,
              Icons.person_rounded,
              'My Profile',
              accentGreen,
              () {},
            ),
            _sheetTile(
              context,
              Icons.settings_rounded,
              'Club Settings',
              Colors.blue,
              () {},
            ),
            _sheetTile(
              context,
              Icons.qr_code_2_rounded,
              'Payment QR Setup',
              Colors.teal,
              () {},
            ),
            _sheetTile(
              context,
              Icons.sports_rounded,
              'Manage Activities',
              Colors.purple,
              () {},
            ),
            _sheetTile(context, Icons.logout_rounded, 'Logout', Colors.red, () {
              SharedPreferenceHelper.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Splash()),
                (route) => false,
              );
            }, isRed: true),
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _sheetTile(
    BuildContext ctx,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap, {
    bool isRed = false,
  }) {
    return ListTile(
      onTap: () {
        Navigator.pop(ctx);
        onTap();
      },
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: isRed ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: textSecondary,
        size: 20.sp,
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

// ── Local Models ──────────────────────────────────────────────────────────────

class PendingAction {
  final String title, subtitle;
  final ActionType actionType;
  final int count;

  PendingAction(this.title, this.subtitle, this.actionType, this.count);
}

enum ActionType { payment, overdue, approval, event }
