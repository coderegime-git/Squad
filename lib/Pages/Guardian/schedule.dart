// screens/guardian/child_schedule.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../config/colors.dart';
import '../../model/guardian/get_your_member.dart';
import '../../utills/api_service.dart';

class ChildScheduleScreen extends StatefulWidget {
  const ChildScheduleScreen({super.key});

  @override
  State<ChildScheduleScreen> createState() => _ChildScheduleScreenState();
}

class _ChildScheduleScreenState extends State<ChildScheduleScreen>
    with SingleTickerProviderStateMixin {
  final ParentApiService _api = ParentApiService();
  List<Data> _children = [];
  bool _isLoadingChildren = true;
  int? _selectedMemberId;
  String _selectedMemberName = '';
  Map<DateTime, List<MemberEvent>> _eventMap = {};
  bool _isLoadingEvents = false;
  String? _eventsError;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _loadChildren();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
  Future<void> _loadChildren() async {
    setState(() => _isLoadingChildren = true);
    try {
      final result = await _api.getYourMembers();
      setState(() {
        _children = result.data;
        _isLoadingChildren = false;
      });
      if (_children.isNotEmpty) {
        _selectChild(_children.first);
      }
    } catch (e) {
      setState(() => _isLoadingChildren = false);
      if (mounted) toast('Failed to load children');
    }
  }
  void _selectChild(Data child) {
    setState(() {
      _selectedMemberId = child.memberId;
      _selectedMemberName = child.username;
      _eventMap = {};
      _selectedDay = null;
    });
    _loadMemberEvents(child.memberId);
  }

  Future<void> _loadMemberEvents(int memberId) async {
    setState(() {
      _isLoadingEvents = true;
      _eventsError = null;
    });
    try {
      final response = await _api.getGuardianMemberEvents(memberId);
      final map = <DateTime, List<MemberEvent>>{};

      if (response != null) {
        final List<dynamic> rawList =
        response is List ? response : (response['data'] ?? []);

        for (final item in rawList) {
          final event = MemberEvent.fromJson(item as Map<String, dynamic>);
          final key = DateTime(
            event.eventDate.year,
            event.eventDate.month,
            event.eventDate.day,
          );
          map.putIfAbsent(key, () => []).add(event);
        }
      }

      setState(() {
        _eventMap = map;
        _isLoadingEvents = false;
      });
      _fadeController.forward(from: 0);
    } catch (e) {
      setState(() {
        _isLoadingEvents = false;
        _eventsError = 'Failed to load schedule';
      });
    }
  }

  List<MemberEvent> _getEventsForDay(DateTime day) {
    return _eventMap[DateTime(day.year, day.month, day.day)] ?? [];
  }

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
                  ? _buildNoChildrenPlaceholder()
                  : _buildMainContent(),
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
                    "Schedule",
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

  // ── Main content (child selector + calendar + events) ────────────
  Widget _buildMainContent() {
    return Column(
      children: [
        // Children horizontal selector
        _buildChildSelector(),
        // Calendar
        _buildCalendar(),
        // Events list
        Expanded(child: _buildEventList()),
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
              Icon(Icons.child_care_rounded,
                  size: 14.sp, color: Colors.grey.shade600),
              6.width,
              Text(
                "Viewing schedule for",
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
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
                    padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(
                        color:
                        isSelected ? Colors.black : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 10.r,
                          backgroundColor: isSelected
                              ? accentGreen
                              : Colors.grey.shade400,
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
                            color:
                            isSelected ? Colors.white : Colors.grey.shade700,
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

  // ── Calendar ──────────────────────────────────────────────────────
  Widget _buildCalendar() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: cardDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r)),
      child: _isLoadingEvents
          ? _buildCalendarShimmer()
          : TableCalendar<MemberEvent>(
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.utc(2027, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        eventLoader: _getEventsForDay,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: textPrimary,
          ),
          weekendStyle: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: accentOrange,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            color: accentGreen.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          selectedTextStyle:
          GoogleFonts.poppins(color: Colors.white, fontSize: 13.sp),
          markerDecoration: BoxDecoration(
            color: accentOrange,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(color: accentOrange),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            color: accentGreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          formatButtonTextStyle:
          GoogleFonts.poppins(color: textPrimary, fontSize: 12.sp),
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          leftChevronIcon:
          Icon(Icons.chevron_left, color: textSecondary),
          rightChevronIcon:
          Icon(Icons.chevron_right, color: textSecondary),
        ),
      ),
    );
  }

  // ── Events List ───────────────────────────────────────────────────
  Widget _buildEventList() {
    if (_isLoadingEvents) {
      return _buildListShimmer();
    }
    if (_eventsError != null) {
      return _buildErrorState();
    }

    final events = _getEventsForDay(_selectedDay ?? _focusedDay);
    final dateLabel = _selectedDay != null
        ? DateFormat('MMMM d, yyyy').format(_selectedDay!)
        : DateFormat('MMMM d, yyyy').format(_focusedDay);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: accentGreen,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                8.width,
                Text(
                  dateLabel,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
                8.width,
                if (events.isNotEmpty)
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: accentGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${events.length} event${events.length > 1 ? 's' : ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: accentGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? _buildEmptyDay()
                : ListView.builder(
              padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _MemberEventTile(event: events[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty / Error / Placeholder states ───────────────────────────
  Widget _buildEmptyDay() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded, size: 52.sp, color: Colors.grey.shade400),
          12.height,
          Text(
            "No events on this day",
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
          6.height,
          Text(
            "Select another date to view events",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoChildrenPlaceholder() {
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
                fontSize: 13.sp,
                color: Colors.grey.shade400,
              ),
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
            _eventsError ?? 'Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
          16.height,
          ElevatedButton.icon(
            onPressed: () {
              if (_selectedMemberId != null) {
                _loadMemberEvents(_selectedMemberId!);
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

  // ── Shimmer placeholders ──────────────────────────────────────────
  Widget _buildFullShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: List.generate(
            5,
                (_) => Container(
              height: 60.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }

  Widget _buildListShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: List.generate(
            3,
                (_) => Container(
              height: 80.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
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

// ── Event Tile ────────────────────────────────────────────────────────────────
class _MemberEventTile extends StatelessWidget {
  final MemberEvent event;

  const _MemberEventTile({required this.event});

  Color get _typeColor {
    switch (event.eventType.toUpperCase()) {
      case 'MATCH':
        return accentOrange;
      case 'TOURNAMENT':
        return Colors.purple;
      default:
        return accentGreen;
    }
  }

  IconData get _typeIcon {
    switch (event.eventType.toUpperCase()) {
      case 'MATCH':
        return Icons.sports_soccer_rounded;
      case 'TOURNAMENT':
        return Icons.emoji_events_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }

  Color get _statusColor {
    switch (event.status.toUpperCase()) {
      case 'ACCEPTED':
      case 'CONFIRMED':
        return accentGreen;
      case 'REJECTED':
      case 'CANCELLED':
        return Colors.red;
      default:
        return accentOrange;
    }
  }

  String get _statusLabel {
    switch (event.status.toUpperCase()) {
      case 'ACCEPTED':
        return 'Confirmed';
      case 'REJECTED':
        return 'Declined';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _typeColor.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: _typeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(_typeIcon, color: _typeColor, size: 24.sp),
          ),
          14.width,
          // Info
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
                6.height,
                Row(
                  children: [
                    if (event.eventTime.isNotEmpty) ...[
                      Icon(Icons.access_time_rounded,
                          size: 12.sp, color: textSecondary),
                      4.width,
                      Text(
                        event.eventTime,
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp, color: textSecondary),
                      ),
                      12.width,
                    ],
                    if (event.location.isNotEmpty) ...[
                      Icon(Icons.location_on_outlined,
                          size: 12.sp, color: textSecondary),
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
          10.width,
          // Status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _statusLabel,
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