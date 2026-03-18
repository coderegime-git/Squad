// screens/clubadmin/clubadmin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sports/Pages/Club_admin/payment_setup.dart';
import 'package:sports/Pages/Club_admin/payments.dart';

import '../../config/colors.dart';
import 'activities_screen.dart';
import 'add_coach_screen.dart';
import 'add_guardian.dart';
import 'add_member_screen.dart';
import 'link_children.dart';


class ClubAdminDashboard extends StatefulWidget {
  const ClubAdminDashboard({super.key});

  @override
  State<ClubAdminDashboard> createState() => _ClubAdminDashboardState();
}

class _ClubAdminDashboardState extends State<ClubAdminDashboard> {
  late Future<ClubStats> _statsFuture;
  late Future<List<PendingAction>> _pendingFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStats();
    _pendingFuture = _fetchPending();
  }

  Future<ClubStats> _fetchStats() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return ClubStats(
      totalMembers: 156,
      activeMembers: 142,
      totalCoaches: 8,
      totalGroups: 12,
      totalActivities: 4,
      upcomingEvents: 5,
      pendingPayments: 12,
      overduePayments: 3,
      totalRevenue: 385000,
    );
  }

  Future<List<PendingAction>> _fetchPending() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      PendingAction(
          'Payment Reminders', '12 members due for renewal', ActionType.payment,
          12),
      PendingAction(
          'Overdue Payments', '3 members payment overdue', ActionType.overdue,
          3),
      //PendingAction('New Guardian Requests', '3 pending approvals', ActionType.approval, 3),
      //PendingAction('Event Confirmations', 'Weekend tournament needs review', ActionType.event, 1),
    ];
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
                        'Club Dashboard',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
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
                            border: Border.all(
                                color: accentGreen.withOpacity(0.4)),
                          ),
                          child: Icon(Icons.person_rounded, color: accentGreen,
                              size: 22.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _statsFuture = _fetchStats();
                    _pendingFuture = _fetchPending();
                  });
                },
                color: accentGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      24.height,

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all(color: Colors.grey.shade600)
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52.w,
                              height: 52.w,
                              decoration: BoxDecoration(
                                color: accentGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                    color: accentGreen.withOpacity(0.5)),
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
                                      Icon(Icons.location_on_rounded,
                                          color: accentGreen, size: 13.sp),
                                      4.width,
                                      Text(
                                        'Madurai, Tamil Nadu',
                                        style: GoogleFonts.poppins(
                                            fontSize: 11.sp,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: accentGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color: accentGreen.withOpacity(0.4)),
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
                      ),

                      20.height,

                      FutureBuilder<ClubStats>(
                        future: _statsFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Row(
                              children: List.generate(4, (_) =>
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 5.w),
                                      height: 80.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(
                                            16.r),
                                      ),
                                    ),
                                  )),
                            );
                          }
                          final s = snapshot.data!;
                          return Row(
                            children: [
                              _statPill(
                                  '${s.totalMembers}', 'Members', accentGreen),
                              _statPill(
                                  '${s.totalCoaches}', 'Coaches', accentOrange),
                              _statPill(
                                  '${s.totalGroups}', 'Groups', Colors.blue),
                              _statPill('${s.totalActivities}', 'Sports',
                                  Colors.purple),
                            ],
                          );
                        },
                      ),

                      20.height,

                      // ── Payment Alert ─────────────────────────────────
                      FutureBuilder<ClubStats>(
                        future: _statsFuture,
                        builder: (context, snapshot) {
                          final s = snapshot.data ?? ClubStats.empty();
                          return Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: accentOrange.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(
                                  color: accentOrange.withOpacity(0.25)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: accentOrange.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.warning_amber_rounded,
                                      color: accentOrange, size: 22.sp),
                                ),
                                14.width,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        '${s.pendingPayments} Pending · ${s
                                            .overduePayments} Overdue',
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
                                            color: textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded,
                                    color: accentOrange, size: 22.sp),
                              ],
                            ),
                          );
                        },
                      ),

                      22.height,

                      // ── Quick Actions ─────────────────────────────────
                      Text(
                        'Quick Actions',
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      16.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _quickAction(Icons.person_add_rounded, 'Add\nMember',
                              accentGreen,
                                  () =>
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (
                                          _) => const ClubAdminAddMemberScreen()))),
                          _quickAction(
                              Icons.people_rounded, 'Add\nCoach', accentOrange,
                                  () =>
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (
                                          _) => const ClubAdminAddCoachScreen()))),
                          _quickAction(Icons.group_add_rounded, 'Add\nGuardian',
                              Colors.blue,
                                  () =>
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (
                                          _) => const ClubAdminAddGuardianScreen()))),
                          _quickAction(
                              Icons.link_rounded, 'Link\nChild', Colors.purple,
                                  () =>
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (
                                          _) => const ClubAdminLinkChildGuardianScreen()))),
                        ],
                      ),
                      16.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _quickAction(
                              Icons.qr_code_2_rounded, 'QR Setup', Colors.teal,
                                  () =>
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (
                                          _) => const ClubAdminPaymentQRSetupScreen()))),
                          _quickAction(Icons.payment_rounded, 'Payments',
                              Colors.deepOrange,
                                  () =>
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (
                                          _) => const ClubAdminPaymentsScreen()))),
                          _quickAction(
                              Icons.sports_rounded, 'Activities', Colors.indigo,
                                  () =>
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (
                                          _) => const ClubAdminActivitiesScreen()))),
                          _quickAction(
                              Icons.bar_chart_rounded, 'Reports', Colors.brown,
                                  () => toast('Reports coming soon')),
                        ],
                      ),

                      22.height,

                      // ── Upcoming Events ───────────────────────────────
                      Text(
                        'Upcoming Events',
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      12.height,
                      _eventStrip('Football Training – U14', 'Today  5:00 PM',
                          'Ground B', accentGreen),
                      10.height,
                      _eventStrip(
                          'Inter-Club Match', 'Sat  3:00 PM', 'Stadium A',
                          accentOrange),

                      22.height,

                      // ── Pending Actions ───────────────────────────────
                      Text(
                        'Pending Actions',
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      12.height,
                      FutureBuilder<List<PendingAction>>(
                        future: _pendingFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox.shrink();
                          return Column(
                            children: snapshot.data!.map((a) =>
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: _pendingCard(a),
                                )).toList(),
                          );
                        },
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

  Widget _quickAction(IconData icon, String label, Color color,
      VoidCallback onTap) {
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
                  fontWeight: FontWeight.w500),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventStrip(String title, String time, String loc, Color color) {
    return Container(
      padding: EdgeInsets.all(14.w),
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
                borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.sports_soccer_rounded, color: color, size: 22.sp),
          ),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.montserrat(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
                4.height,
                Text('$time · $loc',
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp, color: textSecondary)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r)),
            child: Text('View',
                style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _pendingCard(PendingAction a) {
    final colorMap = {
      ActionType.payment: accentOrange,
      ActionType.overdue: Colors.red,
      ActionType.approval: accentGreen,
      ActionType.event: Colors.purple,
    };
    final iconMap = {
      ActionType.payment: Icons.payment_rounded,
      ActionType.overdue: Icons.warning_rounded,
      ActionType.approval: Icons.check_circle_outline_rounded,
      ActionType.event: Icons.event_rounded,
    };
    final color = colorMap[a.actionType]!;
    final icon = iconMap[a.actionType]!;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r)),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title,
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                4.height,
                Text(a.subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp, color: textSecondary)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r)),
            child: Text('${a.count}',
                style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ),
          8.width,
          Icon(Icons.chevron_right_rounded, color: textSecondary),
        ],
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) =>
          Padding(
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
                _sheetTile(context, Icons.person_rounded, 'My Profile',
                    accentGreen, () {}),
                _sheetTile(context, Icons.settings_rounded, 'Club Settings',
                    Colors.blue, () {}),
                _sheetTile(context, Icons.qr_code_2_rounded, 'Payment QR Setup',
                    Colors.teal, () {}),
                _sheetTile(context, Icons.sports_rounded, 'Manage Activities',
                    Colors.purple, () {}),
                _sheetTile(
                    context, Icons.logout_rounded, 'Logout', Colors.red, () {},
                    isRed: true),
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
      trailing: Icon(
          Icons.chevron_right_rounded, color: textSecondary, size: 20.sp),
    );
  }
}

// Models
class ClubStats {
  final int totalMembers, activeMembers, totalCoaches, totalGroups,
      totalActivities, upcomingEvents, pendingPayments, overduePayments,
      totalRevenue;

  ClubStats({
    required this.totalMembers, required this.activeMembers,
    required this.totalCoaches, required this.totalGroups,
    required this.totalActivities, required this.upcomingEvents,
    required this.pendingPayments, required this.overduePayments,
    required this.totalRevenue,
  });

  factory ClubStats.empty() =>
      ClubStats(
          totalMembers: 0,
          activeMembers: 0,
          totalCoaches: 0,
          totalGroups: 0,
          totalActivities: 0,
          upcomingEvents: 0,
          pendingPayments: 0,
          overduePayments: 0,
          totalRevenue: 0);
}

class PendingAction {
  final String title, subtitle;
  final ActionType actionType;
  final int count;

  PendingAction(this.title, this.subtitle, this.actionType, this.count);
}

enum ActionType { payment, overdue, approval, event }
