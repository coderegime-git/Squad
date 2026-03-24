// screens/clubadmin/clubadmin_schedule.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_coaches.dart';
import '../../model/clubAdmin/get_event_details.dart';
import '../../model/clubAdmin/get_event_details_by_id.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';
import 'activities_screen.dart';
import 'event_groups.dart';

class ClubAdminScheduleScreen extends StatefulWidget {
  const ClubAdminScheduleScreen({super.key});

  @override
  State<ClubAdminScheduleScreen> createState() =>
      _ClubAdminScheduleScreenState();
}

class _ClubAdminScheduleScreenState extends State<ClubAdminScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final ClubApiService _apiService = ClubApiService();
  List<Data> _allEvents = [];
  bool _loadingEvents = true;
  EventData? _event;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _loadingEvents = true);
    try {
      final result = await _apiService.getEvents();
      if (!mounted) return;
      setState(() {
        _allEvents = result.data;
        _loadingEvents = false;
      });
    } catch (e) {
      print("Dashboard load error: ");
      print(e.toString());
      if (!mounted) return;

      setState(() => _loadingEvents = false);
    }
  }

  List<Data> _getEventsForDay(DateTime day) {
    return _allEvents.where((event) {
      try {
        final eventDate = DateTime.parse(event.eventDate);
        return eventDate.year == day.year &&
            eventDate.month == day.month &&
            eventDate.day == day.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dayEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
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
                        'Events & Schedule',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.filter_list_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                        onPressed: () => _showFilterSheet(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: _loadingEvents
                  ? const Center(
                      child: CircularProgressIndicator(color: accentGreen),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        children: [
                          16.height,

                          // ── Calendar ─────────────────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: cardDark,
                              borderRadius: BorderRadius.circular(22.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TableCalendar<Data>(
                              firstDay: DateTime(2024),
                              lastDay: DateTime(2027),
                              focusedDay: _focusedDay,
                              calendarFormat: _calendarFormat,
                              selectedDayPredicate: (d) =>
                                  isSameDay(_selectedDay, d),
                              onDaySelected: (sel, foc) {
                                setState(() {
                                  _selectedDay = sel;
                                  _focusedDay = foc;
                                });
                              },
                              onFormatChanged: (f) =>
                                  setState(() => _calendarFormat = f),
                              eventLoader: _getEventsForDay,
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: accentGreen.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: const BoxDecoration(
                                  color: accentGreen,
                                  shape: BoxShape.circle,
                                ),
                                markerDecoration: BoxDecoration(
                                  color: accentOrange,
                                  shape: BoxShape.circle,
                                ),
                                weekendTextStyle: TextStyle(
                                  color: accentOrange,
                                ),
                              ),
                              headerStyle: HeaderStyle(
                                formatButtonVisible: true,
                                titleCentered: true,
                                formatButtonDecoration: BoxDecoration(
                                  color: accentGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                formatButtonTextStyle: TextStyle(
                                  color: accentGreen,
                                ),
                                titleTextStyle: GoogleFonts.montserrat(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                leftChevronIcon: Icon(
                                  Icons.chevron_left_rounded,
                                  color: textSecondary,
                                ),
                                rightChevronIcon: Icon(
                                  Icons.chevron_right_rounded,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                          ),

                          20.height,

                          // ── Events List ───────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat(
                                  'EEE, MMM d',
                                ).format(_selectedDay ?? DateTime.now()),
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                '${dayEvents.length} event${dayEvents.length != 1 ? 's' : ''}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          14.height,

                          dayEvents.isEmpty
                              ? Container(
                                  padding: EdgeInsets.all(40.w),
                                  decoration: BoxDecoration(
                                    color: cardDark,
                                    borderRadius: BorderRadius.circular(18.r),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.event_busy_rounded,
                                        size: 48.sp,
                                        color: textSecondary,
                                      ),
                                      12.height,
                                      Text(
                                        'No events scheduled',
                                        style: GoogleFonts.poppins(
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: dayEvents
                                      .map(
                                        (e) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 12.h,
                                          ),
                                          child: _eventCard(e),
                                        ),
                                      )
                                      .toList(),
                                ),

                          100.height,
                        ],
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _createEventSheet(context),
          backgroundColor: accentGreen,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'Create Event',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ── Event Card ─────────────────────────────────────────────────────────────
  Widget _eventCard(Data e) {
    final color = e.eventType == 'TRAINING'
        ? accentGreen
        : e.eventType == 'MATCH'
        ? accentOrange
        : Colors.purple;

    return GestureDetector(
      onTap: () => _showEventDetailSheet(e),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    e.eventType,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton(
                  color: Colors.grey.shade200,
                  icon: Icon(Icons.more_vert_rounded, color: textSecondary),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('View Details', style: GoogleFonts.poppins()),
                      onTap: () => _showEventDetailSheet(e),
                    ),
                    PopupMenuItem(
                      child: Text(
                        'Manage Groups',
                        style: GoogleFonts.poppins(),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventGroupsScreen(event: e),
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      child: Text(
                        'Map to Activities',
                        style: GoogleFonts.poppins(),
                      ),
                      onTap: () => showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return ClubAdminActivitiesScreen(
                            eventId: e.eventId.toString(),
                            fromMap: true,
                          );
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: Text(
                        'Delete',
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                      onTap: () => _confirmDelete(e),
                    ),
                  ],
                ),
              ],
            ),
            10.height,
            Text(
              e.eventName,
              style: GoogleFonts.montserrat(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            8.height,
            _eRow(Icons.access_time_rounded, '${e.startTime} – ${e.endTime}'),
            4.height,
            _eRow(Icons.location_on_outlined, e.location),
            4.height,
            _eRow(Icons.person_rounded, e.createdByUsername),
            4.height,
            Row(
              children: [
                Icon(Icons.group_rounded, size: 14.sp, color: textSecondary),
                6.width,
                Text(
                  '${e.coachIds.length} coach${e.coachIds.length != 1 ? 'es' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  e.status,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _eRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 14.sp, color: textSecondary),
      6.width,
      Text(
        text,
        style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
      ),
    ],
  );

  // ── Delete Event — now calls real API ─────────────────────────────────────
  void _confirmDelete(Data e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Delete Event',
          style: GoogleFonts.montserrat(color: Colors.black),
        ),
        content: Text(
          'Delete "${e.eventName}"?',
          style: GoogleFonts.poppins(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _apiService.deleteEvent(e.eventId);
              if (success) {
                toast('Event deleted', bgColor: Colors.red);
                _fetchEvents();
              } else {
                toast('Failed to delete event');
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
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
            Text(
              'Filter Events',
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            16.height,
            for (final f in [
              'All Events',
              'Training Sessions',
              'Matches',
              'Tournaments',
            ])
              ListTile(
                leading: Icon(
                  Icons.circle_outlined,
                  color: accentGreen,
                  size: 18.sp,
                ),
                title: Text(f, style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  toast('Filter: $f');
                },
              ),
            20.height,
          ],
        ),
      ),
    );
  }

  // ── Event Detail Sheet — added Manage Groups button ────────────────────────
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
        apiService: _apiService,
      ),
    );
  }

  void _createEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => _CreateEventSheet(onCreated: _fetchEvents),
    );
  }
}

// ── Event Detail Sheet ─────────────────────────────────────────────────────
// CHANGE: added `event` parameter + "Manage Groups" button at the bottom
class EventDetailSheet extends StatefulWidget {
  final int eventId;
  final Data event; // ← added
  final ClubApiService apiService;

  const EventDetailSheet({
    required this.eventId,
    required this.event, // ← added
    required this.apiService,
  });

  @override
  State<EventDetailSheet> createState() => EventDetailSheetState();
}

class EventDetailSheetState extends State<EventDetailSheet> {
  bool _loading = true;
  String? _error;
  EventData? _event;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await widget.apiService.getEventById(widget.eventId);
      setState(() {
        _event = result.data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load event details.';
        _loading = false;
      });
    }
  }

  String _formatTime(String t) {
    try {
      final parts = t.split(':');
      final dt = DateTime(0, 0, 0, int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return t;
    }
  }

  Color _typeColor(String type) => type == 'TRAINING'
      ? accentGreen
      : type == 'MATCH'
      ? accentOrange
      : Colors.purple;

  Color _statusColor(String status) {
    switch (status) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'ONGOING':
        return accentGreen;
      case 'COMPLETED':
        return Colors.grey;
      case 'CANCELLED':
        return Colors.red;
      default:
        return textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: _loading
          ? SizedBox(
              height: 180.h,
              child: const Center(
                child: CircularProgressIndicator(color: accentGreen),
              ),
            )
          : _error != null
          ? SizedBox(
              height: 180.h,
              child: Center(
                child: Text(
                  _error!,
                  style: GoogleFonts.poppins(color: textSecondary),
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // drag handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                16.height,
                Row(
                  children: [
                    _badge(_event!.eventType, _typeColor(_event!.eventType)),
                    8.width,
                    _badge(_event!.status, _statusColor(_event!.status)),
                  ],
                ),
                12.height,
                Text(
                  _event!.eventName,
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                16.height,
                _detailRow(
                  Icons.calendar_today_rounded,
                  'Date',
                  _event!.eventDate,
                ),
                10.height,
                _detailRow(
                  Icons.access_time_rounded,
                  'Time',
                  '${_formatTime(_event!.startTime)} – ${_formatTime(_event!.endTime)}',
                ),
                10.height,
                _detailRow(
                  Icons.location_on_outlined,
                  'Location',
                  _event!.location,
                ),
                10.height,
                _detailRow(
                  Icons.person_rounded,
                  'Created by',
                  _event!.createdByUsername,
                ),
                10.height,
                _detailRow(
                  Icons.group_rounded,
                  'Coaches',
                  '${_event!.coachIds.length} assigned  •  IDs: ${_event!.coachIds.join(', ')}',
                ),
                10.height,
                _detailRow(
                  Icons.business_rounded,
                  'Club ID',
                  _event!.clubId.toString(),
                ),
                20.height,

                // ── Manage Groups Button — newly added ──────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EventGroupsScreen(event: widget.event),
                        ),
                      );
                    },
                    icon: Icon(Icons.group_work_rounded, size: 20.sp),
                    label: Text(
                      'Manage Groups',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _badge(String label, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 11.sp,
        color: color,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _detailRow(IconData icon, String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16.sp, color: textSecondary),
      8.width,
      Text(
        '$label: ',
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
        ),
      ),
    ],
  );
}

// ── Create Event Sheet — exactly same as original, zero changes ───────────
class _CreateEventSheet extends StatefulWidget {
  final VoidCallback? onCreated;

  const _CreateEventSheet({this.onCreated});

  @override
  State<_CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends State<_CreateEventSheet> {
  final _apiService = ClubApiService();

  final _eventNameController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedEventType;
  String? _selectedStatus;
  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  List<CoachData> _coaches = [];
  Set<int> _selectedCoachIds = {};
  bool _loadingCoaches = true;
  bool _submitting = false;
  bool _showDateErrors = false;

  final List<String> _eventTypes = ['TRAINING', 'MATCH', 'TOURNAMENT','SINGLE_EVENT'];
  final List<String> _statusOptions = [
    'SCHEDULED',
    'ONGOING',
    'COMPLETED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCoaches();
  }

  Future<void> _fetchCoaches() async {
    try {
      final result = await _apiService.getCoaches();
      setState(() {
        _coaches = result.data;
        _loadingCoaches = false;
      });
    } catch (e) {
      setState(() => _loadingCoaches = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: accentGreen)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: accentGreen)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          _startTime = picked;
        else
          _endTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  Future<bool> _showConfirmDialog(String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF57C00),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Confirm Schedule',
              style: GoogleFonts.montserrat(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Go Back',
              style: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Yes, Continue',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }
  Widget _buildDateValidationBanner_PATCH() {
    final error = EventDateTimeValidator.validate(
      date: _eventDate,
      startTime: _startTime,
      endTime: _endTime,
    );
    final isWarn =
        error != null && !EventDateTimeValidator.isBlockingError(error);
    final isError =
        error != null && EventDateTimeValidator.isBlockingError(error);
    final isOk = error == null &&
        _eventDate != null &&
        _startTime != null &&
        _endTime != null;

    if (!isOk && !isWarn && !isError) return const SizedBox.shrink();

    Color bgColor, borderColor, iconColor, textColor;
    IconData icon;

    if (isOk) {
      bgColor = accentGreen.withOpacity(0.07);
      borderColor = accentGreen.withOpacity(0.25);
      iconColor = accentGreen;
      textColor = accentGreen;
      icon = Icons.check_circle_outline;
    } else if (isWarn) {
      bgColor = const Color(0xFFFFF8E1);
      borderColor = const Color(0xFFFFCC02).withOpacity(0.6);
      iconColor = const Color(0xFFF57C00);
      textColor = const Color(0xFFE65100);
      icon = Icons.info_outline;
    } else {
      bgColor = Colors.red.withOpacity(0.07);
      borderColor = Colors.red.withOpacity(0.3);
      iconColor = Colors.red;
      textColor = Colors.red;
      icon = Icons.error_outline;
    }

    final label = isOk
        ? 'Duration: ${EventDateTimeValidator.durationLabel(_eventDate!, _startTime!, _endTime!)}'
        : error!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: bgColor,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _submit() async {
    setState(() => _showDateErrors = true);

    if (_eventNameController.text.trim().isEmpty) {
      toast('Please enter event name');
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      toast('Please enter location');
      return;
    }
    if (_selectedEventType == null) {
      toast('Please select event type');
      return;
    }
    if (_selectedStatus == null) {
      toast('Please select status');
      return;
    }
    if (_selectedCoachIds.isEmpty) {
      toast('Please select at least one coach');
      return;
    }

    final dateMsg = EventDateTimeValidator.validate(
      date: _eventDate,
      startTime: _startTime,
      endTime: _endTime,
    );

    if (EventDateTimeValidator.isBlockingError(dateMsg)) {
      toast(dateMsg!, bgColor: Colors.red);
      return;
    }

    if (dateMsg != null) {
      final confirmed = await _showConfirmDialog(dateMsg);
      if (!confirmed) return;
    }

    setState(() => _submitting = true);

    final data = {
      "eventName": _eventNameController.text.trim(),
      "eventDate": DateFormat('yyyy-MM-dd').format(_eventDate!),
      "startTime": _formatTime(_startTime!),
      "endTime": _formatTime(_endTime!),
      "location": _locationController.text.trim(),
      "eventType": _selectedEventType,
      "status": _selectedStatus,
      "coachIds": _selectedCoachIds.toList(),
    };

    final success = await _apiService.AddEvents(data);

    setState(() => _submitting = false);

    if (success) {
      Navigator.pop(context);
      toast('Event created successfully!', bgColor: accentGreen);
      widget.onCreated?.call();
    } else {
      toast('Failed to create event. Please try again.');
    }
  }


  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            16.height,
            Text(
              'Create New Event',
              style: GoogleFonts.montserrat(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            20.height,
            _inputField('Event Title', _eventNameController),
            12.height,
            _inputField('Location', _locationController),
            12.height,
            _labelText('Event Date'),
            6.height,
            _tappableField(
              icon: Icons.calendar_today_rounded,
              text: _eventDate != null
                  ? DateFormat('yyyy-MM-dd').format(_eventDate!)
                  : 'Select date',
              onTap: _pickDate,
            ),
            12.height,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labelText('Start Time'),
                      6.height,
                      _tappableField(
                        icon: Icons.access_time_rounded,
                        text: _startTime != null
                            ? _formatTime(_startTime!)
                            : 'Start',
                        onTap: () => _pickTime(true),
                      ),
                    ],
                  ),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labelText('End Time'),
                      6.height,
                      _tappableField(
                        icon: Icons.access_time_rounded,
                        text: _endTime != null ? _formatTime(_endTime!) : 'End',
                        onTap: () => _pickTime(false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            12.height,
            _dropField(
              'Event Type',
              _eventTypes,
              _selectedEventType,
              (val) => setState(() => _selectedEventType = val),
            ),
            12.height,
            _dropField(
              'Status',
              _statusOptions,
              _selectedStatus,
              (val) => setState(() => _selectedStatus = val),
            ),
            12.height,
            _labelText('Assign Coaches'),
            6.height,
            _loadingCoaches
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: const CircularProgressIndicator(
                        color: accentGreen,
                      ),
                    ),
                  )
                : _coaches.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      'No coaches available',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: textSecondary,
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: _coaches.map((coach) {
                        final isSelected = _selectedCoachIds.contains(
                          coach.coachId,
                        );
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected)
                                _selectedCoachIds.remove(coach.coachId);
                              else
                                _selectedCoachIds.add(coach.coachId);
                            });
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22.w,
                                  height: 22.w,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? accentGreen
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? accentGreen
                                          : Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check_rounded,
                                          size: 14.sp,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                12.width,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        coach.username,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        coach.specialization,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.sp,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
            20.height,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: accentGreen.withOpacity(0.6),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: _submitting
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Create Event',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _labelText(String label) => Text(
    label,
    style: GoogleFonts.poppins(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade700,
    ),
  );

  Widget _inputField(String hint, TextEditingController controller) =>
      TextField(
        controller: controller,
        style: GoogleFonts.poppins(fontSize: 13.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: textSecondary.withOpacity(0.5),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 13.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: accentGreen, width: 1.5),
          ),
        ),
      );

  Widget _tappableField({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: textSecondary),
          8.width,
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: text.contains('Select') || text == 'Start' || text == 'End'
                  ? textSecondary.withOpacity(0.5)
                  : Colors.black,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _dropField(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) => DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: accentGreen, width: 1.5),
      ),
    ),
    style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
    items: items
        .map((i) => DropdownMenuItem(value: i, child: Text(i)))
        .toList(),
    onChanged: onChanged,
  );
}
