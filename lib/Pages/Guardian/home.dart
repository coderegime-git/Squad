// screens/guardian/guardian_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sports/routes/app_routes.dart';

import '../../config/colors.dart';
import '../../model/guardian/getGuardianEvents.dart';
import '../../model/guardian/get_your_member.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';
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

  int? _selectedMemberId;
  List<Data> _children = [];
  bool _isLoadingChildren = true;
  List<GuardianEventData> _pendingEvents = [];
  bool _isLoadingEvents = false;

  String get _username => SharedPreferenceHelper.getUsername() ?? 'Guardian';

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final result = await _api.getYourMembers();
      setState(() {
        _children = result.data;
        if (_children.isNotEmpty) {
          _selectedMemberId = _children.first.memberId;
          _loadPendingEvents(_selectedMemberId!);
        }
        _isLoadingChildren = false;
      });
    } catch (e) {
      setState(() => _isLoadingChildren = false);
      if (mounted) toast('Failed to load children');
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
    final success = await _api.updateGuardianEventStatus(
      memberId,
      eventId,
      status,
    );
    if (mounted) {
      if (success) {
        toast(status == 'ACCEPT' ? 'Event accepted!' : 'Event declined');
        _loadPendingEvents(memberId);
      } else {
        toast('Failed to update status');
      }
    }
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
            // ── Header ──────────────────────────────────────────────────
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
                        "Hello, $_username",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
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
            ),

            // ── Body ────────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadChildren,
                color: accentGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      20.height,

                      // ── Children selector ────────────────────────────
                      if (_isLoadingChildren)
                        const ChildSelectorShimmer()
                      else if (_children.isEmpty)
                        _buildNoChildrenWidget()
                      else
                        _buildChildrenList(),

                      24.height,

                      // ── Quick Stats ──────────────────────────────────
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

                      24.height,

                      // ── Pending Events ───────────────────────────────
                      if (_children.isNotEmpty) ...[
                        Row(
                          children: [
                            Text(
                              "Pending Events",
                              style: GoogleFonts.montserrat(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            8.width,
                            if (_pendingEvents.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: accentOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  '${_pendingEvents.length}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: accentOrange,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        12.height,

                        if (_isLoadingEvents)
                          _shimmerBox(height: 100.h)
                        else if (_pendingEvents.isEmpty)
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: cardDark,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Center(
                              child: Text(
                                "No pending events for this child",
                                style: GoogleFonts.poppins(
                                  color: textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          ..._pendingEvents.map(
                            (e) => _PendingEventCard(
                              event: e,
                              onAccept: () => _updateStatus(
                                _selectedMemberId!,
                                e.eventId,
                                'ACCEPT',
                              ),
                              onDecline: () => _updateStatus(
                                _selectedMemberId!,
                                e.eventId,
                                'REJECT',
                              ),
                            ),
                          ),
                      ],

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
                                "Child promoted to starting lineup!",
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
            ),
          ],
        ),
      ),
    );
  }

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
                onTap: () {
                  setState(() => _selectedMemberId = member.memberId);
                  _loadPendingEvents(member.memberId);
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

  Widget _buildNoChildrenWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.child_care_rounded,
              size: 48.sp,
              color: Colors.grey.shade400,
            ),
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

// ── Pending Event Card ──────────────────────────────────────────────────────
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
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: textSecondary,
                ),
              ),
              16.width,
              Icon(
                Icons.calendar_today_rounded,
                size: 13.sp,
                color: textSecondary,
              ),
              5.width,
              Text(
                event.eventDate,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: textSecondary,
                ),
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
