// screens/clubadmin/clubadmin_schedule.dart
// Changes:
// - "Manage Groups" renamed to "Invite Groups"
// - Three-dot menu: only "Cancel Event"
// - Removed filter button
// - Invite flow: groups/subgroups with ability to uncheck members

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/activities_data.dart';
import '../../model/clubAdmin/get_coaches.dart';
import '../../model/clubAdmin/get_event_details.dart';
import '../../model/clubAdmin/get_event_details_by_id.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';
import 'invite_groups.dart';

class ClubAdminScheduleScreen extends StatefulWidget {
  const ClubAdminScheduleScreen({super.key});

  @override
  State<ClubAdminScheduleScreen> createState() =>
      _ClubAdminScheduleScreenState();
}

class _ClubAdminScheduleScreenState extends State<ClubAdminScheduleScreen>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late TabController _tabController;

  final ClubApiService _apiService = ClubApiService();
  List<Data> _allEvents = [];
  bool _loadingEvents = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _tabController = TabController(length: 2, vsync: this);
    _fetchEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      if (!mounted) return;
      setState(() => _loadingEvents = false);
    }
  }

  List<Data> _getEventsForDay(DateTime day) {
    final now = DateTime.now();
    return _allEvents.where((event) {
      try {
        final eventDate = DateTime.parse(event.eventDate);
        final isScheduled = !eventDate.isBefore(DateTime(now.year, now.month, now.day));
        return isScheduled &&
            eventDate.year == day.year &&
            eventDate.month == day.month &&
            eventDate.day == day.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  List<Data> get _scheduledEvents {
    final now = DateTime.now();
    return _allEvents.where((e) {
      try {
        final d = DateTime.parse(e.eventDate);
        return !d.isBefore(DateTime(now.year, now.month, now.day));
      } catch (_) {
        return true;
      }
    }).toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
  }

  List<Data> get _completedEvents {
    final now = DateTime.now();
    final sixMonthsAgo = now.subtract(const Duration(days: 180));
    return _allEvents.where((e) {
      try {
        final d = DateTime.parse(e.eventDate);
        return d.isBefore(DateTime(now.year, now.month, now.day)) &&
            d.isAfter(sixMonthsAgo);
      } catch (_) {
        return false;
      }
    }).toList()
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: 5.h, left: 20.w, right: 20.w, bottom: 0),
                      child: Row(
                        children: [
                          Text('Events & Schedule',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    8.height,
                    // ── Tabs ──────────────────────────────────────
                    TabBar(
                      controller: _tabController,
                      indicatorColor: accentGreen,
                      labelColor: accentGreen,
                      unselectedLabelColor: Colors.grey.shade400,
                      labelStyle: GoogleFonts.poppins(
                          fontSize: 13.sp, fontWeight: FontWeight.w600),
                      tabs: [
                        Tab(
                            text:
                            'Scheduled (${_loadingEvents ? '...' : _scheduledEvents.length})'),
                        Tab(
                            text:
                            'Completed (${_loadingEvents ? '...' : _completedEvents.length})'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Tab content ──────────────────────────────────────
            Expanded(
              child: _loadingEvents
                  ? const Center(
                  child: CircularProgressIndicator(color: accentGreen))
                  : TabBarView(
                controller: _tabController,
                children: [
                  // ── Scheduled Tab ──────────────────────
                  _scheduledTab(),
                  // ── Completed Tab ──────────────────────
                  _eventListView(_completedEvents),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _createEventSheet(context),
          backgroundColor: accentGreen,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('Create Event',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _scheduledTab() {
    final now = DateTime.now();
    final dayEvents = _getEventsForDay(_selectedDay ?? _focusedDay).where((event) {
      try {
        final d = DateTime.parse(event.eventDate);
        return !d.isBefore(DateTime(now.year, now.month, now.day));
      } catch (_) {
        return true;
      }
    }).toList();
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          16.height,
          // Calendar
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
              selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
              onDaySelected: (sel, foc) =>
                  setState(() {
                    _selectedDay = sel;
                    _focusedDay = foc;
                  }),
              onFormatChanged: (f) => setState(() => _calendarFormat = f),
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.3),
                    shape: BoxShape.circle),
                selectedDecoration: const BoxDecoration(
                    color: accentGreen, shape: BoxShape.circle),
                markerDecoration:
                BoxDecoration(color: accentOrange, shape: BoxShape.circle),
                weekendTextStyle: TextStyle(color: accentOrange),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10.r)),
                formatButtonTextStyle: TextStyle(color: accentGreen),
                titleTextStyle: GoogleFonts.montserrat(
                    fontSize: 16.sp, fontWeight: FontWeight.bold),
                leftChevronIcon:
                Icon(Icons.chevron_left_rounded, color: textSecondary),
                rightChevronIcon:
                Icon(Icons.chevron_right_rounded, color: textSecondary),
              ),
            ),
          ),
          20.height,
          // Day header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  DateFormat('EEE, MMM d')
                      .format(_selectedDay ?? DateTime.now()),
                  style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700)),
              Text(
                  '${dayEvents.length} event${dayEvents.length != 1 ? 's' : ''}',
                  style:
                  GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)),
            ],
          ),
          14.height,
          // Day events
          dayEvents.isEmpty
              ? Container(
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(children: [
              Icon(Icons.event_busy_rounded,
                  size: 48.sp, color: textSecondary),
              12.height,
              Text('No events on this day',
                  style: GoogleFonts.poppins(color: textSecondary)),
            ]),
          )
              : Column(
              children: dayEvents
                  .map((e) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _eventCard(e),
              ))
                  .toList()),
          100.height,
        ],
      ),
    );
  }

  // ── Completed Tab — Simple List ───────────────────────────────
  Widget _eventListView(List<Data> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded,
                size: 52.sp, color: Colors.grey.shade300),
            12.height,
            Text('No completed events',
                style: GoogleFonts.poppins(color: textSecondary)),
            6.height,
            Text('Completed events from last 6 months appear here',
                style: GoogleFonts.poppins(
                    fontSize: 11.sp, color: textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchEvents,
      color: accentGreen,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 100.h),
        itemCount: events.length,
        itemBuilder: (_, i) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _eventCard(events[i]),
        ),
      ),
    );
  }

  // ── Event Card ─────────────────────────────────────────────────
  Widget _eventCard(Data e) {
    final color = e.eventType == 'TRAINING'
        ? accentGreen
        : e.eventType == 'MATCH'
        ? accentOrange
        : Colors.purple;

    final isCompleted = () {
      try {
        final d = DateTime.parse(e.eventDate);
        return d.isBefore(DateTime.now().subtract(const Duration(days: 1)));
      } catch (_) {
        return false;
      }
    }();

    return GestureDetector(
      onTap: () => _showEventDetailSheet(e),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: isCompleted
                  ? Colors.grey.withOpacity(0.3)
                  : color.withOpacity(0.3),
              width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r)),
                  child: Text(e.eventType,
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: color,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8)),
                ),
                if (isCompleted) ...[
                  8.width,
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r)),
                    child: Text('COMPLETED',
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
                const Spacer(),
                // Three-dot menu: ONLY Cancel Event
                PopupMenuButton(
                  color: Colors.grey.shade200,
                  icon: Icon(Icons.more_vert_rounded, color: textSecondary),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('Cancel Event',
                          style: GoogleFonts.poppins(color: Colors.red)),
                      onTap: () => _confirmDelete(e),
                    ),
                  ],
                ),
              ],
            ),
            10.height,
            Text(e.eventName,
                style: GoogleFonts.montserrat(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black)),
            8.height,
            _eRow(Icons.calendar_today_rounded, e.eventDate),
            4.height,
            _eRow(Icons.access_time_rounded,
                '${e.startTime} – ${e.endTime}'),
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
                        fontSize: 12.sp, color: textSecondary)),
                const Spacer(),
                Text(isCompleted ? 'COMPLETED' : e.status,
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: isCompleted ? Colors.grey : color,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _eRow(IconData icon, String text) => Row(children: [
    Icon(icon, size: 14.sp, color: textSecondary),
    6.width,
    Expanded(
      child: Text(text,
          style:
          GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
    ),
  ]);

  void _confirmDelete(Data e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        title: Text('Cancel Event',
            style: GoogleFonts.montserrat(color: Colors.black)),
        content: Text('Are you sure you want to cancel "${e.eventName}"?',
            style: GoogleFonts.poppins(color: textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
              Text('Back', style: GoogleFonts.poppins(color: textSecondary))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _apiService.deleteEvent(e.eventId);
              if (success) {
                toast('Event cancelled', bgColor: Colors.red);
                _fetchEvents();
              } else {
                toast('Failed to cancel event');
              }
            },
            child: Text('Cancel Event',
                style: GoogleFonts.poppins(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

// Replace _showEventDetailSheet() in _ClubAdminScheduleScreenState:
  void _showEventDetailSheet(Data event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailFullScreen(
          event: event,
          canEdit: true,
          onRefresh: _fetchEvents, // pass callback
        ),
      ),
    ).then((_) => _fetchEvents());
  }

  void _createEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => _CreateEventSheet(onCreated: _fetchEvents),
    );
  }
}

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
  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  List<CoachData> _coaches = [];
  Set<int> _selectedCoachIds = {};
  bool _loadingCoaches = true;
  bool _submitting = false;
  List<ActivityData1> _activities = [];
  int? _selectedActivityId;
  bool loadingActivity = false;
  final List<String> _eventTypes = ['SINGLE_EVENT','TOURNAMENT'];

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _fetchCoaches();
  }

  Future<void> _fetchCoaches() async {
    try {
      final result = await _apiService.getCoaches();
      setState(() { _coaches = result.data; _loadingCoaches = false; });
    } catch (e) {
      setState(() => _loadingCoaches = false);
    }
  }
  Future<void> _loadActivities() async {
    setState(() {
      loadingActivity = true;
    });
    final result = await _apiService.getActivities1();

    if (result.isNotEmpty) {
      setState(() {
        _activities = result;
        _selectedActivityId = result.first.id;
        loadingActivity = false;
      });
    }
  }
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: accentGreen)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }
  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: accentGreen)),
        child: child!,
      ),
    );
    if (picked != null) setState(() { if (isStart) _startTime = picked; else _endTime = picked; });
  }
  Widget _activityField() {
    if (_activities.length == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity',
              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          6.height,
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              _activities.first.name,
              style: GoogleFonts.poppins(fontSize: 13.sp),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity',
            style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: textSecondary,
                fontWeight: FontWeight.w500)),
        6.height,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedActivityId,
              isExpanded: true,
              items: _activities.map((activity) {
                return DropdownMenuItem<int>(
                  value: activity.id,
                  child: Text(activity.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActivityId = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }


  Future<void> _submit() async {
    if (_eventNameController.text.trim().isEmpty) { toast('Please enter event name'); return; }
    if (_locationController.text.trim().isEmpty) { toast('Please enter location'); return; }
    if (_selectedEventType == null) { toast('Please select event type'); return; }
    if (_eventDate == null) { toast('Please select event date'); return; }
    if (_startTime == null) { toast('Please select start time'); return; }
    if (_endTime == null) { toast('Please select end time'); return; }
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    if (endMinutes <= startMinutes) { toast('End time must be after start time'); return; }
    if (_selectedCoachIds.isEmpty) { toast('Please select at least one coach'); return; }

    setState(() => _submitting = true);
    final data = {
      "eventName": _eventNameController.text.trim(),
      "eventDate": DateFormat('yyyy-MM-dd').format(_eventDate!),
      "startTime": _formatTime(_startTime!),
      "endTime": _formatTime(_endTime!),
      "location": _locationController.text.trim(),
      "eventType": _selectedEventType,
      "status": "SCHEDULED",
      "activityId":_selectedActivityId,
      "coachIds": _selectedCoachIds.toList(),
    };
    final eventId = await _apiService.addEvent(data);
    setState(() => _submitting = false);
    if (eventId >= 0) {
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)))),
            16.height,
            Text('Create New Event', style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            20.height,
            loadingActivity? Center(child: CircularProgressIndicator(color: accentGreen)):_activityField(),
            10.height,
            _labelText('Event Title'),
            6.height,
            _inputField('Event Title', _eventNameController),
            12.height,
            _labelText('Add Location'),
            6.height,
            _inputField('Location (add Google Maps link if needed)', _locationController),
            12.height,
            _labelText('Event Date'),
            6.height,
            _tappableField(
              icon: Icons.calendar_today_rounded,
              text: _eventDate != null ? DateFormat('yyyy-MM-dd').format(_eventDate!) : 'Select date',
              onTap: _pickDate,
            ),
            12.height,
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _labelText('Start Time'),
                  6.height,
                  _tappableField(icon: Icons.access_time_rounded, text: _startTime != null ? _formatTime(_startTime!) : 'Start', onTap: () => _pickTime(true)),
                ])),
                12.width,
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _labelText('End Time'),
                  6.height,
                  _tappableField(icon: Icons.access_time_rounded, text: _endTime != null ? _formatTime(_endTime!) : 'End', onTap: () => _pickTime(false)),
                ])),
              ],
            ),
            12.height,
            _labelText('Event Type'),
            6.height,
            _dropField('Event Type', _eventTypes, _selectedEventType, (val) => setState(() => _selectedEventType = val)),
            12.height,
            // Status removed — always SCHEDULED
            _labelText('Assign Coaches'),
            6.height,
            _loadingCoaches
                ? Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const CircularProgressIndicator(color: accentGreen)))
                : _coaches.isEmpty
                ? Padding(padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text('No coaches available', style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)))
                : Container(
               height: 250.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: _coaches.map((coach) {
                    final isSelected = _selectedCoachIds.contains(coach.coachId);
                    return InkWell(
                      onTap: () => setState(() {
                        if (isSelected) _selectedCoachIds.remove(coach.coachId);
                        else _selectedCoachIds.add(coach.coachId);
                      }),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22.w, height: 22.w,
                              decoration: BoxDecoration(
                                color: isSelected ? accentGreen : Colors.white,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: isSelected ? accentGreen : Colors.grey.shade400, width: 1.5),
                              ),
                              child: isSelected ? Icon(Icons.check_rounded, size: 14.sp, color: Colors.white) : null,
                            ),
                            12.width,
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(coach.username, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                                Text(coach.specialization, style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
                              ],
                            )),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            20.height,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen, foregroundColor: Colors.white,
                  disabledBackgroundColor: accentGreen.withOpacity(0.6), elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: _submitting
                    ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Create Event', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700)),
              ),
            ),
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _labelText(String label) => Text(label, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700));

  Widget _inputField(String hint, TextEditingController controller) => TextField(
    controller: controller,
    style: GoogleFonts.poppins(fontSize: 13.sp),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary.withOpacity(0.5)),
      filled: true, fillColor: Colors.grey.shade100,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: accentGreen, width: 1.5)),
    ),
  );

  Widget _tappableField({required IconData icon, required String text, required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey.shade300)),
      child: Row(children: [
        Icon(icon, size: 16.sp, color: textSecondary),
        8.width,
        Text(text, style: GoogleFonts.poppins(fontSize: 13.sp,
            color: text.contains('Select') || text == 'Start' || text == 'End' ? textSecondary.withOpacity(0.5) : Colors.black)),
      ]),
    ),
  );

  Widget _dropField(String label, List<String> items, String? value, ValueChanged<String?> onChanged) =>
      DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
          filled: true, fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: accentGreen, width: 1.5)),
        ),
        style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
      );
}



class EventDetailFullScreen extends StatefulWidget {
  final Data event;
  final bool canEdit;
  final VoidCallback? onRefresh; // ADD THIS

  const EventDetailFullScreen({
    super.key,
    required this.event,
    this.canEdit = true,
    this.onRefresh, // ADD THIS
  });

  @override
  State<EventDetailFullScreen> createState() => _EventDetailFullScreenState();
}

class _EventDetailFullScreenState extends State<EventDetailFullScreen>
    with SingleTickerProviderStateMixin {
  final ClubApiService _apiService = ClubApiService();
  late TabController _tabController;
  late Data _event; // mutable local copy

  List<Map<String, dynamic>> _attendees = [];
  bool _loadingAttendees = true;
  Map<int, List<Map<String, dynamic>>> _performanceNotes = {};
  bool _loadingNotes = false;
  @override
  void initState() {
    super.initState();
    _event = widget.event; // initialize from widget
    _tabController = TabController(length: 3, vsync: this);
    _loadAttendees();
    _loadPerformanceNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendees() async {
    setState(() => _loadingAttendees = true);
    try {
      final result = await _apiService.getEventMembers(_event.eventId);
      if (mounted) setState(() { _attendees = result; _loadingAttendees = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingAttendees = false);
    }
  }
  Future<void> _loadPerformanceNotes() async {
    setState(() => _loadingNotes = true);
    try {
      final result = await _apiService.getEventsPerformanceNotes(
          eventId: _event.eventId.toString());
      if (mounted) {
        final Map<int, List<Map<String, dynamic>>> notesMap = {};
        for (final note in result.data ?? []) {
          final memberId = note.memberId ?? 0;
          notesMap.putIfAbsent(memberId, () => []);
          notesMap[memberId]!.add({
            'noteId': note.noteId,
            'note': note.note,
            'rating': note.rating,
            'coachName': note.coachName,
            'createdAt': note.createdAt,
            'memberName': note.memberName,
          });
        }
        setState(() {
          _performanceNotes = notesMap;
          _loadingNotes = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingNotes = false);
    }
  }
  String _formatTime(String t) {
    try {
      final parts = t.split(':');
      final dt = DateTime(0, 0, 0, int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('h:mm a').format(dt);
    } catch (_) { return t; }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACCEPTED': return accentGreen;
      case 'REJECTED': return Colors.red;
      case 'PENDING': return Colors.orange;
      default: return textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'ACCEPTED': return Icons.check_circle_rounded;
      case 'REJECTED': return Icons.cancel_rounded;
      default: return Icons.hourglass_empty_rounded;
    }
  }

  bool _isCompleted() {
    try {
      final eventDate = DateTime.parse(_event.eventDate); // uses _event
      return eventDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    } catch (_) { return false; }
  }

  void _openLocation() async {
    final loc = _event.location; // uses _event
    Uri uri;
    if (loc.startsWith('http')) {
      uri = Uri.parse(loc);
    } else {
      uri = Uri.parse('https://maps.google.com/?q=${Uri.encodeComponent(loc)}');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      toast('Could not open maps');
    }
  }

  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => _EditEventSheet(
        event: _event,
        onUpdated: (Data updatedEvent) {
          widget.onRefresh?.call();
          if (mounted) setState(() => _event = updatedEvent); // updates UI instantly
        },
      ),
    );
  }
// Add this method to _EventDetailFullScreenState:
  Widget _performanceTab() {
    if (_loadingAttendees || _loadingNotes) {
      return const Center(child: CircularProgressIndicator(color: accentGreen));
    }

    // Collect all members who have notes
    final allNoteEntries = _performanceNotes.entries.toList();

    if (allNoteEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 52.sp, color: Colors.grey.shade300),
            12.height,
            Text('No performance notes yet',
                style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400)),
            8.height,
            Text('Coaches can add performance notes for attending members',
                style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPerformanceNotes,
      color: accentGreen,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Info banner
          Container(
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.only(bottom: 14.h),
            decoration: BoxDecoration(
                color: accentGreen.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: accentGreen.withOpacity(0.2))),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, color: accentGreen, size: 14.sp),
              8.width,
              Expanded(
                child: Text(
                  'Performance notes added by coaches for this event.',
                  style: GoogleFonts.poppins(fontSize: 11.sp),
                ),
              ),
            ]),
          ),
          // Notes per member
          ...allNoteEntries.map((entry) {
            final notes = entry.value;
            final memberName = notes.isNotEmpty
                ? (notes.first['memberName'] ?? 'Member')
                : 'Member';
            return _adminMemberNoteCard(memberName, notes);
          }).toList(),
        ],
      ),
    );
  }

  Widget _adminMemberNoteCard(String memberName, List<Map<String, dynamic>> notes) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Member header
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: accentGreen.withOpacity(0.1),
                child: Text(
                  memberName.isNotEmpty ? memberName[0].toUpperCase() : '?',
                  style: GoogleFonts.montserrat(
                      fontSize: 14.sp, fontWeight: FontWeight.w800, color: accentGreen),
                ),
              ),
              12.width,
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(memberName,
                      style: GoogleFonts.montserrat(
                          fontSize: 13.sp, fontWeight: FontWeight.w700)),
                  Text('${notes.length} note${notes.length > 1 ? 's' : ''}',
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp, color: accentGreen, fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
          // Notes list
          Divider(height: 1, color: Colors.grey.shade100),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
            child: Column(
              children: notes.map((note) {
                final noteText = note['note'] ?? '';
                final rating = note['rating'] as int? ?? 0;
                final coachName = note['coachName'] ?? '';
                final createdAt = note['createdAt'] ?? '';
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade200)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      // Stars — read only
                      Row(children: List.generate(5, (i) => Icon(
                        i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 14.sp,
                        color: i < rating ? Colors.amber : Colors.grey.shade300,
                      ))),
                      const Spacer(),
                      Icon(Icons.person_rounded, size: 11.sp, color: accentGreen),
                      4.width,
                      Text(coachName,
                          style: GoogleFonts.poppins(
                              fontSize: 10.sp, color: accentGreen,
                              fontWeight: FontWeight.w600)),
                    ]),
                    6.height,
                    Text(noteText,
                        style: GoogleFonts.poppins(
                            fontSize: 13.sp, color: Colors.black87)),
                    6.height,
                    Row(children: [
                      Icon(Icons.access_time_rounded, size: 10.sp, color: textSecondary),
                      4.width,
                      Text(
                        createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt,
                        style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary),
                      ),
                    ]),
                  ]),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final attending = _attendees.where((m) => m['rsvpStatus'] == 'ACCEPTED').length;
    final declined = _attendees.where((m) => m['rsvpStatus'] == 'REJECTED').length;
    final pending = _attendees.where((m) => m['rsvpStatus'] == 'PENDING').length;
    final isCompleted = _isCompleted();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle),
                              child: Icon(Icons.arrow_back_ios_rounded,
                                  color: Colors.white, size: 18.sp),
                            ),
                          ),
                          16.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_event.eventName, // uses _event
                                    style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                4.height,
                                Row(children: [
                                  _headerChip(
                                      isCompleted ? 'COMPLETED' : _event.status, // uses _event
                                      isCompleted ? Colors.grey : accentGreen),
                                  8.width,
                                  _headerChip(_event.eventType, accentOrange), // uses _event
                                ]),
                              ],
                            ),
                          ),
                          if (widget.canEdit)
                            GestureDetector(
                              onTap: () => _showEditSheet(),
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                    color: accentGreen.withOpacity(0.2),
                                    shape: BoxShape.circle),
                                child: Icon(Icons.edit_rounded,
                                    color: accentGreen, size: 18.sp),
                              ),
                            ),
                        ],
                      ),
                    ),
                    12.height,
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      child: Row(
                        children: [
                          _statChip(Icons.check_circle_rounded,
                              '$attending Attending', accentGreen),
                          8.width,
                          _statChip(Icons.cancel_rounded,
                              '$declined Declined', Colors.red),
                          8.width,
                          _statChip(Icons.hourglass_empty_rounded,
                              '$pending Pending', Colors.orange),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: accentGreen,
                      labelColor: accentGreen,
                      unselectedLabelColor: Colors.grey.shade400,
                      labelStyle: GoogleFonts.poppins(
                          fontSize: 13.sp, fontWeight: FontWeight.w600),
                      tabs: const [
                        Tab(text: 'Details'),
                        Tab(text: 'Attendees'),
                        Tab(text: 'Performance'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _detailsTab(),
                  _attendeesTab(),
                  _performanceTab(), // ADD THIS

                ],
              ),
            ),
          ],
        ),
        floatingActionButton: widget.canEdit
            ? FloatingActionButton.extended(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => InviteGroupsScreen(event: _event))), // uses _event
          backgroundColor: accentGreen,
          icon: Icon(Icons.group_add_rounded, color: Colors.white, size: 20.sp),
          label: Text('Invite Groups',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        )
            : null,
      ),
    );
  }

  Widget _detailsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _infoCard(),
          16.height,
          if (widget.canEdit) _actionsCard(),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _infoRow(Icons.calendar_today_rounded, 'Date',
              _formatDisplayDate(_event.eventDate)), // uses _event
          _divider(),
          _infoRow(Icons.access_time_rounded, 'Time',
              '${_formatTime(_event.startTime)} – ${_formatTime(_event.endTime)}'), // uses _event
          _divider(),
          _locationRow(),
          _divider(),
          _infoRow(Icons.person_rounded, 'Created by',
              _event.createdByUsername), // uses _event
          _divider(),
          _infoRow(Icons.group_rounded, 'Coaches',
              '${_event.coachIds.length} assigned'), // uses _event
        ],
      ),
    );
  }

  Widget _locationRow() {
    final loc = _event.location; // uses _event
    final isLink = loc.startsWith('http');
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_rounded, size: 18.sp, color: accentGreen),
          10.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Location',
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp, color: textSecondary)),
                4.height,
                GestureDetector(
                  onTap: _openLocation,
                  child: Text(loc,
                      style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: isLink ? Colors.blue : Colors.black,
                          decoration: isLink
                              ? TextDecoration.underline
                              : TextDecoration.none,
                          fontWeight: FontWeight.w500)),
                ),
                if (!isLink) ...[
                  4.height,
                  GestureDetector(
                    onTap: _openLocation,
                    child: Row(children: [
                      Icon(Icons.map_rounded, size: 12.sp, color: accentGreen),
                      4.width,
                      Text('Open in Maps',
                          style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: accentGreen,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionsCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actions',
              style: GoogleFonts.montserrat(
                  fontSize: 14.sp, fontWeight: FontWeight.bold)),
          12.height,
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.group_add_rounded,
                  label: 'Invite Groups',
                  color: accentGreen,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => InviteGroupsScreen(event: _event))), // uses _event
                ),
              ),
              12.width,
              Expanded(
                child: _actionButton(
                  icon: Icons.edit_rounded,
                  label: 'Edit Event',
                  color: Colors.blue,
                  onTap: _showEditSheet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.sp),
            6.height,
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _attendeesTab() {
    if (_loadingAttendees) {
      return const Center(child: CircularProgressIndicator(color: accentGreen));
    }
    if (_attendees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded,
                size: 52.sp, color: Colors.grey.shade300),
            12.height,
            Text('No members invited yet',
                style: GoogleFonts.montserrat(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400)),
            8.height,
            Text('Use "Invite Groups" to add members',
                style: GoogleFonts.poppins(
                    fontSize: 12.sp, color: textSecondary)),
          ],
        ),
      );
    }
    final attending = _attendees.where((m) => m['rsvpStatus'] == 'ACCEPTED').toList();
    final declined = _attendees.where((m) => m['rsvpStatus'] == 'REJECTED').toList();
    final pending = _attendees.where((m) => m['rsvpStatus'] == 'PENDING').toList();

    return RefreshIndicator(
      onRefresh: _loadAttendees,
      color: accentGreen,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          if (attending.isNotEmpty) ...[
            _sectionHeader('Attending', attending.length, accentGreen, Icons.check_circle_rounded),
            8.height,
            ...attending.map((m) => _attendeeTile(m)),
            16.height,
          ],
          if (pending.isNotEmpty) ...[
            _sectionHeader('Pending', pending.length, Colors.orange, Icons.hourglass_empty_rounded),
            8.height,
            ...pending.map((m) => _attendeeTile(m)),
            16.height,
          ],
          if (declined.isNotEmpty) ...[
            _sectionHeader('Declined', declined.length, Colors.red, Icons.cancel_rounded),
            8.height,
            ...declined.map((m) => _attendeeTile(m)),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, int count, Color color, IconData icon) {
    return Row(children: [
      Icon(icon, color: color, size: 16.sp),
      8.width,
      Text('$title ($count)',
          style: GoogleFonts.montserrat(
              fontSize: 13.sp, fontWeight: FontWeight.w700, color: color)),
    ]);
  }

  Widget _attendeeTile(Map<String, dynamic> member) {
    final status = member['rsvpStatus'] as String? ?? 'PENDING';
    final name = member['memberName'] as String? ?? '';
    final email = member['memberEmail'] as String? ?? '';
    final color = _statusColor(status);
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: color.withOpacity(0.1),
            child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: GoogleFonts.montserrat(
                    fontSize: 14.sp, fontWeight: FontWeight.w700, color: color)),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.poppins(
                        fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black)),
                Text(email,
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r)),
            child: Row(children: [
              Icon(_statusIcon(status), size: 11.sp, color: color),
              4.width,
              Text(status,
                  style: GoogleFonts.poppins(
                      fontSize: 10.sp, color: color, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _headerChip(String label, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
        color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20.r)),
    child: Text(label,
        style: GoogleFonts.poppins(
            fontSize: 10.sp, color: color, fontWeight: FontWeight.w700)),
  );

  Widget _statChip(IconData icon, String label, Color color) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13.sp, color: color),
          5.width,
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10.sp, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: accentGreen),
          10.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
                4.height,
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 13.sp, color: Colors.black, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100);

  String _formatDisplayDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat('EEE, MMM d yyyy').format(d);
    } catch (_) { return dateStr; }
  }
}

class _EditEventSheet extends StatefulWidget {
  final Data event;
  final Function(Data updatedEvent) onUpdated;

  const _EditEventSheet({required this.event, required this.onUpdated});

  @override
  State<_EditEventSheet> createState() => _EditEventSheetState();
}

class _EditEventSheetState extends State<_EditEventSheet> {
  final _apiService = ClubApiService();
  late TextEditingController _nameCtrl;
  late TextEditingController _locationCtrl;

  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  List<CoachData> _coaches = [];
  Set<int> _selectedCoachIds = {};
  bool _loadingCoaches = true;
  bool _submitting = false;
  List<ActivityData1> _activities = [];
  int? _selectedActivityId;
  bool _loadingActivities = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.event.eventName);
    _locationCtrl = TextEditingController(text: widget.event.location);
    try {
      _eventDate = DateTime.parse(widget.event.eventDate);
    } catch (_) {}
    try {
      final sp = widget.event.startTime.split(':');
      _startTime = TimeOfDay(hour: int.parse(sp[0]), minute: int.parse(sp[1]));
      final ep = widget.event.endTime.split(':');
      _endTime = TimeOfDay(hour: int.parse(ep[0]), minute: int.parse(ep[1]));
    } catch (_) {}
    _selectedCoachIds = widget.event.coachIds.map((e) => e as int).toSet();
    _loadActivities();
    _fetchCoaches();
  }
  Future<void> _loadActivities() async {
    setState(() => _loadingActivities = true);
    try {
      final result = await _apiService.getActivities1();

      if (mounted) {
        setState(() {
          _activities = result;

          // Improved logic as per your requirement:
          if (widget.event.activityId != null && widget.event.activityId != 0) {
            // If event already has an activityId, use it
            _selectedActivityId = widget.event.activityId;
          } else {
            // If activityId is null or 0, use the first activity from the list
            _selectedActivityId = result.isNotEmpty ? result.first.id : null;
          }

          print("Selected Activity ID: $_selectedActivityId");
          _loadingActivities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingActivities = false);
      }
      print("Error loading activities: $e");
    }
  }
  Future<void> _fetchCoaches() async {
    try {
      final result = await _apiService.getCoaches();
      setState(() { _coaches = result.data; _loadingCoaches = false; });
    } catch (e) {
      setState(() => _loadingCoaches = false);
    }
  }
  Widget _activityField() {
    if (_activities.length == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity',
              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          6.height,
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              _activities.first.name,
              style: GoogleFonts.poppins(fontSize: 13.sp),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity',
            style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: textSecondary,
                fontWeight: FontWeight.w500)),
        6.height,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedActivityId,
              isExpanded: true,
              items: _activities.map((activity) {
                return DropdownMenuItem<int>(
                  value: activity.id,
                  child: Text(activity.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActivityId = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
          data: Theme.of(ctx)
              .copyWith(colorScheme: const ColorScheme.light(primary: accentGreen)),
          child: child!),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
      builder: (ctx, child) => Theme(
          data: Theme.of(ctx)
              .copyWith(colorScheme: const ColorScheme.light(primary: accentGreen)),
          child: child!),
    );
    if (picked != null) {
      setState(() { if (isStart) _startTime = picked; else _endTime = picked; });
    }
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      toast('Enter event name');
      return;
    }
    if (_locationCtrl.text.trim().isEmpty) {
      toast('Enter location');
      return;
    }
    if (_eventDate == null) {
      toast('Select event date');
      return;
    }
    if (_startTime == null || _endTime == null) { toast('Select times'); return; }
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    if (endMinutes <= startMinutes) { toast('End time must be after start time'); return; }
    if (_selectedActivityId == null) {
      toast('Please select an activity');
      return;
    }

    setState(() => _submitting = true);

    final data = {
      "eventName": _nameCtrl.text.trim(),
      "eventDate": DateFormat('yyyy-MM-dd').format(_eventDate!),
      "startTime": _formatTime(_startTime!),
      "endTime": _formatTime(_endTime!),
      "location": _locationCtrl.text.trim(),
      "eventType": widget.event.eventType,
      "status": widget.event.status,
      "clubId": widget.event.clubId,
      "activityId": _selectedActivityId,
      "coachIds": _selectedCoachIds.toList(),
    };

    final success = await _apiService.updateEvent(widget.event.eventId, data);
    setState(() => _submitting = false);

    // Replace the success block inside _submit():
    if (success) {
      final updatedEvent = Data(
        eventId: widget.event.eventId,
        eventName: _nameCtrl.text.trim(),
        eventDate: DateFormat('yyyy-MM-dd').format(_eventDate!),
        startTime: _formatTime(_startTime!),
        endTime: _formatTime(_endTime!),
        location: _locationCtrl.text.trim(),
        eventType: widget.event.eventType,
        status: widget.event.status,
        clubId: widget.event.clubId,
        activityId: _selectedActivityId ?? widget.event.activityId,
        coachIds: _selectedCoachIds.toList(),
        createdByUsername: widget.event.createdByUsername, createdByUserId: widget.event.createdByUserId, createdAt: widget.event.createdAt,
      );
      Navigator.pop(context);
      toast('Event updated successfully!', bgColor: accentGreen);
      widget.onUpdated(updatedEvent); // pass updated event back
    } else {
      toast('Failed to update event');
    }
  }
  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      borderRadius: BorderRadius.circular(2.r))),
            ),
            16.height,
            Row(children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r)),
                child: Icon(Icons.edit_rounded, color: Colors.blue, size: 20.sp),
              ),
              12.width,
              Text('Edit Event',
                  style: GoogleFonts.montserrat(
                      fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ]),
            20.height,
            _loadingActivities? Center(child: CircularProgressIndicator(color: accentGreen)):_activityField(),
            6.height,
            _fieldLabel('Event Title'),
            6.height,
            _inputField('Event title', _nameCtrl),
            12.height,
            _fieldLabel('Location (or Google Maps link)'),
            6.height,
            _inputField('Location', _locationCtrl),
            12.height,
            _fieldLabel('Event Date'),
            6.height,
            _tappable(
                Icons.calendar_today_rounded,
                _eventDate != null
                    ? DateFormat('yyyy-MM-dd').format(_eventDate!)
                    : 'Select date',
                _pickDate),
            12.height,
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Start Time'),
                      6.height,
                      _tappable(
                          Icons.access_time_rounded,
                          _startTime != null ? _formatTime(_startTime!) : 'Start',
                              () => _pickTime(true)),
                    ]),
              ),
              12.width,
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('End Time'),
                      6.height,
                      _tappable(
                          Icons.access_time_rounded,
                          _endTime != null ? _formatTime(_endTime!) : 'End',
                              () => _pickTime(false)),
                    ]),
              ),
            ]),
            16.height,
            _fieldLabel('Coaches'),
            8.height,
            _loadingCoaches
                ? const Center(
                child: CircularProgressIndicator(color: accentGreen))
                : Container(
              height: 250.h,
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300)),
              child: SingleChildScrollView(
                child: Column(
                  children: _coaches.map((coach) {
                    final selected =
                    _selectedCoachIds.contains(coach.coachId);
                    return CheckboxListTile(
                      dense: true,
                      value: selected,
                      activeColor: accentGreen,
                      onChanged: (_) => setState(() {
                        if (selected)
                          _selectedCoachIds.remove(coach.coachId);
                        else
                          _selectedCoachIds.add(coach.coachId);
                      }),
                      title: Text(coach.username,
                          style: GoogleFonts.poppins(fontSize: 13.sp)),
                      subtitle: Text(coach.specialization,
                          style: GoogleFonts.poppins(
                              fontSize: 11.sp, color: textSecondary)),
                    );
                  }).toList(),
                ),
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
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r))),
                child: _submitting
                    ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : Text('Update Event',
                    style: GoogleFonts.poppins(
                        fontSize: 14.sp, fontWeight: FontWeight.w700)),
              ),
            ),
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(label,
      style: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700));

  Widget _inputField(String hint, TextEditingController ctrl) => TextField(
    controller: ctrl,
    style: GoogleFonts.poppins(fontSize: 13.sp),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
          fontSize: 12.sp, color: textSecondary.withOpacity(0.5)),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding:
      EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: accentGreen, width: 1.5)),
    ),
  );

  Widget _tappable(IconData icon, String text, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300)),
          child: Row(children: [
            Icon(icon, size: 16.sp, color: textSecondary),
            8.width,
            Text(text,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: text == 'Select date' ||
                        text == 'Start' ||
                        text == 'End'
                        ? textSecondary.withOpacity(0.5)
                        : Colors.black)),
          ]),
        ),
      );
}