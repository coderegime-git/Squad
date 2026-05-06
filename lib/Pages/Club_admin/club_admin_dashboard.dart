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
import '../../model/get_clubs_data.dart';
import '../../utills/shared_preference.dart';
import '../notification_screen.dart';
import '../splash.dart';
import 'add_coach_screen.dart';
import 'add_guardian.dart';
import 'add_member_screen.dart';
import 'club_admin_groups_and_subgroups.dart';
import 'club_admin_schedule.dart';
import 'club_settings.dart';
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
  GetClubsData? _clubsData;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => isLoad = true);
    try {
      dashboardData = await apiService.getDashboardData();
      eventDetails  = await apiService.getEvents();
      _clubsData    = await apiService.getClubsData();
    } catch (e) {
      debugPrint('Dashboard load error: $e');
    } finally {
      if (mounted) setState(() => isLoad = false);
    }
  }

  List<Data> get _upcomingEvents {
    if (eventDetails == null) return [];
    final today        = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final oneMonthLater = today.add(const Duration(days: 30));
    return eventDetails!.data.where((e) {
      if (e.eventDate == null) return false;
      try {
        final eventDate = DateTime.parse(e.eventDate!);
        return !eventDate.isBefore(today) && eventDate.isBefore(oneMonthLater);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _accentBar(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED': return const Color(0xFF185FA5);
      case 'ONGOING':   return const Color(0xFF3B6D11);
      case 'CANCELLED': return const Color(0xFFA32D2D);
      default:          return const Color(0xFF5F5E5A);
    }
  }

  Color _statusBg(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED': return const Color(0xFFE6F1FB);
      case 'ONGOING':   return const Color(0xFFEAF3DE);
      case 'CANCELLED': return const Color(0xFFFCEBEB);
      default:          return const Color(0xFFF1EFE8);
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED': return const Color(0xFF185FA5);
      case 'ONGOING':   return const Color(0xFF3B6D11);
      case 'CANCELLED': return const Color(0xFFA32D2D);
      default:          return const Color(0xFF5F5E5A);
    }
  }

  Color _typeBg(String type) =>
      type.toUpperCase() == 'TOURNAMENT'
          ? const Color(0xFFEEEDFE)
          : const Color(0xFFE1F5EE);

  Color _typeColor(String type) =>
      type.toUpperCase() == 'TOURNAMENT'
          ? const Color(0xFF3C3489)
          : const Color(0xFF085041);

  IconData _typeIcon(String type) =>
      type.toUpperCase() == 'TOURNAMENT'
          ? Icons.emoji_events_rounded
          : Icons.sports_rounded;

  String _typeLabel(String type) =>
      type.toUpperCase() == 'TOURNAMENT' ? 'Tournament' : 'Single Event';

  String _formatDate(String? raw) {
    if (raw == null) return '';
    try {
      final date = DateTime.parse(raw);
      const months = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return raw;
    }
  }

  String _daysLabel(String? raw) {
    if (raw == null) return '';
    try {
      final date = DateTime.parse(raw);
      final diff = date.difference(DateTime.now()).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Tomorrow';
      if (diff > 1)  return 'In $diff days';
    } catch (_) {}
    return '';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
                      _buildSectionTitle('Quick Actions'),
                      16.height,
                      _buildQuickActionsGrid(),
                      22.height,
                      _buildSectionTitle('Upcoming Events'),
                      12.height,
                      _buildEventList(),
                      80.height,
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

  // ── App Bar ────────────────────────────────────────────────────────────────

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
              offset: const Offset(0, 5)),
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
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              NotificationBellIcon(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationScreen())),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showProfileSheet(context),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentGreen.withOpacity(0.4)),
                  ),
                  child: Icon(Icons.person_rounded,
                      color: accentGreen, size: 22.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Club Card ──────────────────────────────────────────────────────────────

  Widget _buildClubCard() {
    if (isLoad) {
      return Container(
        width: double.infinity,
        height: 90.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(22.r),
        ),
      );
    }

    final clubs = _clubsData?.data ?? [];

    if (clubs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            Icon(Icons.sports_soccer_rounded,
                color: Colors.grey.shade400, size: 28.sp),
            12.width,
            Text('No club assigned',
                style: GoogleFonts.poppins(
                    fontSize: 13.sp, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    if (clubs.length == 1) return _clubCardTile(clubs.first);

    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: clubs.length,
        itemBuilder: (_, i) => SizedBox(
          width: MediaQuery.of(context).size.width * 0.80,
          child: Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: _clubCardTile(clubs[i]),
          ),
        ),
      ),
    );
  }

  Widget _clubCardTile(GetClubsForRoles club) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
            child: Icon(Icons.sports_soccer_rounded,
                color: accentGreen, size: 28.sp),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.clubName,
                  style: GoogleFonts.montserrat(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height,
                if (club.description.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: accentGreen, size: 12.sp),
                      4.width,
                      Expanded(
                        child: Text(
                          club.description,
                          style: GoogleFonts.poppins(
                              fontSize: 11.sp, color: Colors.black87),
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
            padding:
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: accentGreen.withOpacity(0.4)),
            ),
            child: Text('Active',
                style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: accentGreen,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Stat Pills ─────────────────────────────────────────────────────────────

  Widget _buildStatPills() {
    if (dashboardData == null) {
      return Row(
        children: List.generate(
          3,
              (_) => Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 80.h,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16.r)),
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
      ],
    );
  }

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
            Text(val,
                style: GoogleFonts.montserrat(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: color)),
            4.height,
            Text(lbl,
                style: GoogleFonts.poppins(
                    fontSize: 10.sp, color: textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────────────

  Widget _buildQuickActionsGrid() {
    final actions = [
      _QuickActionItem(Icons.person_add_rounded, 'Add\nMember', accentGreen,
              () => _push(const ClubAdminAddMemberScreen())),
      _QuickActionItem(Icons.people_rounded, 'Add\nCoach', accentOrange,
              () => _push(const ClubAdminAddCoachScreen())),
      _QuickActionItem(Icons.group_add_rounded, 'Add\nGuardian', Colors.blue,
              () => _push(const ClubAdminAddGuardianScreen())),
      _QuickActionItem(Icons.link_rounded, 'Link\nChild', Colors.purple,
              () => _push(const ClubAdminLinkChildGuardianScreen())),
      _QuickActionItem(Icons.payment_rounded, 'Payments', Colors.deepOrange,
              () => _push(const ClubAdminPaymentsScreen())),
      _QuickActionItem(Icons.group_work_rounded, 'Groups', Colors.teal,
              () => _pushGroupsScreen()),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.75,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final item = actions[index];
        return _quickAction(item.icon, item.label, item.color, item.onTap);
      },
    );
  }

  void _pushGroupsScreen() => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const ClubAdminGroupsScreen()));

  Widget _quickAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          5.height,
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 9.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ── Event List ─────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700));
  }

  Widget _buildEventList() {
    final events = _upcomingEvents;
    if (events.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_busy_rounded,
                  size: 40.sp, color: Colors.grey.shade300),
              10.height,
              Text('No upcoming events',
                  style: GoogleFonts.poppins(
                      fontSize: 13.sp, color: Colors.grey.shade400)),
            ],
          ),
        ),
      );
    }
    return Column(
      children: events.map((e) => _eventCard(e)).toList(),
    );
  }

  Widget _eventCard(Data data) {
    final type      = data.eventType ?? '';
    final status    = data.status ?? '';
    final accent    = _accentBar(status);
    final daysLabel = _daysLabel(data.eventDate);
    final isMapLink = (data.location ?? '').startsWith('http');

    return GestureDetector(
      onTap: () => _showEventDetailSheet(data),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left accent bar ──────────────────────────────────
              Container(
                width: 4.w,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    bottomLeft: Radius.circular(16.r),
                  ),
                ),
              ),

              // ── Content ──────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Title + Status badge ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              data.eventName ?? '',
                              style: GoogleFonts.montserrat(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: _statusBg(status),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // ── Type chip + Days chip ──
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: _typeBg(type),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_typeIcon(type),
                                    size: 11.sp,
                                    color: _typeColor(type)),
                                SizedBox(width: 4.w),
                                Text(
                                  _typeLabel(type),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _typeColor(type),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (daysLabel.isNotEmpty) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: daysLabel == 'Today'
                                    ? const Color(0xFFFAEEDA)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                daysLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: daysLabel == 'Today'
                                      ? const Color(0xFF633806)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      SizedBox(height: 10.h),
                      Divider(height: 1, color: Colors.grey.shade100),
                      SizedBox(height: 10.h),

                      // ── Date & Time ──
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 12.sp, color: Colors.grey.shade500),
                          SizedBox(width: 5.w),
                          Text(
                            _formatDate(data.eventDate),
                            style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.grey.shade700),
                          ),
                          if ((data.startTime ?? '').isNotEmpty) ...[
                            SizedBox(width: 12.w),
                            Icon(Icons.access_time_rounded,
                                size: 12.sp, color: Colors.grey.shade500),
                            SizedBox(width: 5.w),
                            Text(
                              '${data.startTime} – ${data.endTime}',
                              style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade700),
                            ),
                          ],
                        ],
                      ),

                      SizedBox(height: 6.h),

                      // ── Location + View button ──
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 12.sp, color: Colors.grey.shade500),
                          SizedBox(width: 5.w),
                          Expanded(
                            child: Text(
                              isMapLink
                                  ? 'View on Maps'
                                  : (data.location ?? ''),
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: isMapLink
                                    ? const Color(0xFF185FA5)
                                    : Colors.grey.shade700,
                                decoration: isMapLink
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8.r),
                              border:
                              Border.all(color: accent.withOpacity(0.3)),
                            ),
                            child: Text(
                              'View',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Event Detail ───────────────────────────────────────────────────────────

  void _showEventDetailSheet(Data event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailFullScreen(event: event, canEdit: true),
      ),
    );
  }

  // ── Profile Sheet ──────────────────────────────────────────────────────────

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24.r))),
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
                    borderRadius: BorderRadius.circular(2.r))),
            16.height,
            _sheetTile(context, Icons.settings_rounded, 'Club Settings',
                Colors.blue, () => _push(const ClubSettingsScreen())),
            _sheetTile(
                context,
                Icons.qr_code_2_rounded,
                'Payment QR Setup',
                Colors.teal,
                    () => _push(const ClubAdminPaymentQRSetupScreen())),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10.r)),
                child: Icon(Icons.info_outline_rounded,
                    color: Colors.grey.shade600, size: 20.sp),
              ),
              title: Text('App Version',
                  style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500)),
              trailing: Text('v1.0.0',
                  style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: textSecondary,
                      fontWeight: FontWeight.w600)),
            ),
            _sheetTile(context, Icons.logout_rounded, 'Logout', Colors.red,
                    () {
                  SharedPreferenceHelper.clear();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Splash()),
                          (r) => false);
                }, isRed: true),
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _sheetTile(BuildContext ctx, IconData icon, String title, Color color,
      VoidCallback onTap,
      {bool isRed = false}) {
    return ListTile(
      onTap: () {
        Navigator.pop(ctx);
        onTap();
      },
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10.r)),
        child: Icon(icon, color: color, size: 20.sp),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: isRed ? Colors.red : Colors.black,
              fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: textSecondary, size: 20.sp),
    );
  }

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}


class _QuickActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _QuickActionItem(this.icon, this.label, this.color, this.onTap);
}

enum ActionType { payment, overdue, approval, event }