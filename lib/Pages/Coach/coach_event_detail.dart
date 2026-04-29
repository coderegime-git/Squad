// screens/coach/coach_event_detail_screen.dart
// Coach: Full event detail screen
// Tabs: Details | Attendees | Performance
// - Details: date, time, location (with map link), coaches
// - Attendees: list of invited members split by ACCEPTED / PENDING / REJECTED
// - Performance: list of attendees → tap → write performance note
// - FAB: Invite Groups → CoachInviteGroupsScreen
// - Edit button (coach can edit event)
// API:
//   GET  /api/events/{eventId}/members   → attendees
//   PUT  /api/events/{eventId}           → edit event
//   GET  /api/events/{eventId}/performance-notes
//   POST /api/events/{eventId}/members/{memberId}/performance

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/activities_data.dart';
import '../../model/clubAdmin/get_coaches.dart';
import '../../model/clubAdmin/get_event_details.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';
import 'coach_invite_groups.dart';
import 'coach_performance.dart';

class CoachEventDetailScreen extends StatefulWidget {
  final Data event;
  const CoachEventDetailScreen({super.key, required this.event});

  @override
  State<CoachEventDetailScreen> createState() => _CoachEventDetailScreenState();
}

class _CoachEventDetailScreenState extends State<CoachEventDetailScreen>
    with SingleTickerProviderStateMixin {
  final ClubApiService _api = ClubApiService();
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
      final result = await _api.getEventMembers(_event.eventId);
      if (mounted) setState(() { _attendees = result; _loadingAttendees = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingAttendees = false);
    }
  }
  Future<void> _loadPerformanceNotes() async {
    setState(() => _loadingNotes = true);
    try {
      final result = await _api.getEventsPerformanceNotes(
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
  bool get _isCompleted {
    try {
      final d = DateTime.parse(_event.eventDate);
      return d.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    } catch (_) { return false; }
  }

  String _fmtTime(String t) {
    try {
      final p = t.split(':');
      final dt = DateTime(0, 0, 0, int.parse(p[0]), int.parse(p[1]));
      return DateFormat('h:mm a').format(dt);
    } catch (_) { return t; }
  }

  String _fmtDate(String s) {
    try { return DateFormat('EEE, MMM d yyyy').format(DateTime.parse(s)); }
    catch (_) { return s; }
  }

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'ACCEPTED': return accentGreen;
      case 'REJECTED': return Colors.red;
      default: return Colors.orange;
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toUpperCase()) {
      case 'ACCEPTED': return Icons.check_circle_rounded;
      case 'REJECTED': return Icons.cancel_rounded;
      default: return Icons.hourglass_empty_rounded;
    }
  }

  void _openLocation() async {
    final loc = _event.location;
    final uri = loc.startsWith('http')
        ? Uri.parse(loc)
        : Uri.parse('https://maps.google.com/?q=${Uri.encodeComponent(loc)}');
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
      builder: (_) => _CoachEditEventSheet(
        event: _event,
        onUpdated: (Data updatedEvent) {
          if (mounted) setState(() => _event = updatedEvent); // update UI instantly
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attending = _attendees.where((m) => m['rsvpStatus'] == 'ACCEPTED').length;
    final declined = _attendees.where((m) => m['rsvpStatus'] == 'REJECTED').length;
    final pending = _attendees.where((m) => m['rsvpStatus'] == 'PENDING').length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(children: [
          Container(
            decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: SafeArea(
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  child: Row(children: [
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
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_event.eventName, // uses _event
                            style: GoogleFonts.montserrat(
                                color: Colors.white, fontSize: 17.sp,
                                fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        4.height,
                        Row(children: [
                          _chip(_isCompleted ? 'COMPLETED' : _event.status, // uses _event
                              _isCompleted ? Colors.grey : accentGreen),
                          8.width,
                          _chip(_event.eventType, accentOrange), // uses _event
                        ]),
                      ],
                    )),
                    if (!_isCompleted)
                      GestureDetector(
                        onTap: _showEditSheet,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                              color: accentGreen.withOpacity(0.2),
                              shape: BoxShape.circle),
                          child: Icon(Icons.edit_rounded,
                              color: accentGreen, size: 18.sp),
                        ),
                      ),
                  ]),
                ),
                12.height,
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
                  child: Row(children: [
                    _statChip(Icons.check_circle_rounded, '$attending Attending', accentGreen),
                    8.width,
                    _statChip(Icons.cancel_rounded, '$declined Declined', Colors.red),
                    8.width,
                    _statChip(Icons.hourglass_empty_rounded, '$pending Pending', Colors.orange),
                  ]),
                ),
                TabBar(
                  controller: _tabController,
                  indicatorColor: accentGreen,
                  labelColor: accentGreen,
                  unselectedLabelColor: Colors.grey.shade400,
                  labelStyle: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Details'),
                    Tab(text: 'Attendees'),
                    Tab(text: 'Performance'),
                  ],
                ),
              ]),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_detailsTab(), _attendeesTab(), _performanceTab()],
            ),
          ),
        ]),
        floatingActionButton: !_isCompleted
            ? FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CoachInviteGroupsScreen(event: _event)), // uses _event
          ).then((_) => _loadAttendees()),
          backgroundColor: accentGreen,
          icon: Icon(Icons.group_add_rounded, color: Colors.white, size: 20.sp),
          label: Text('Invite Groups',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        )
            : null,
      ),
    );
  }

  Widget _detailsTab() => SingleChildScrollView(
    padding: EdgeInsets.all(16.w),
    child: Column(children: [
      _infoCard(),
      if (!_isCompleted) ...[16.height, _actionsCard()],
      100.height,
    ]),
  );

  Widget _infoCard() => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100)),
    child: Column(children: [
      _infoRow(Icons.calendar_today_rounded, 'Date', _fmtDate(_event.eventDate)), // uses _event
      _divider(),
      _infoRow(Icons.access_time_rounded, 'Time',
          '${_fmtTime(_event.startTime)} – ${_fmtTime(_event.endTime)}'), // uses _event
      _divider(),
      _locationRow(),
      _divider(),
      _infoRow(Icons.person_rounded, 'Created by', _event.createdByUsername), // uses _event
      _divider(),
      _infoRow(Icons.group_rounded, 'Coaches', '${_event.coachIds.length} assigned'), // uses _event
    ]),
  );

  Widget _locationRow() {
    final loc = _event.location; // uses _event
    final isLink = loc.startsWith('http');
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.location_on_rounded, size: 18.sp, color: accentGreen),
        10.width,
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location', style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
            4.height,
            GestureDetector(
              onTap: _openLocation,
              child: Text(loc,
                  style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: isLink ? Colors.blue : Colors.black87,
                      decoration: isLink ? TextDecoration.underline : null,
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
                          fontSize: 11.sp, color: accentGreen, fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
          ],
        )),
      ]),
    );
  }

  Widget _actionsCard() => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quick Actions',
          style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.bold)),
      12.height,
      Row(children: [
        Expanded(child: _actionBtn(
          icon: Icons.group_add_rounded,
          label: 'Invite Groups',
          color: accentGreen,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CoachInviteGroupsScreen(event: _event))) // uses _event
              .then((_) => _loadAttendees()),
        )),
        12.width,
        Expanded(child: _actionBtn(
          icon: Icons.edit_rounded,
          label: 'Edit Event',
          color: Colors.blue,
          onTap: _showEditSheet,
        )),
      ]),
    ]),
  );

  Widget _actionBtn({required IconData icon, required String label,
    required Color color, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: color.withOpacity(0.3))),
          child: Column(children: [
            Icon(icon, color: color, size: 22.sp),
            6.height,
            Text(label, style: GoogleFonts.poppins(
                fontSize: 11.sp, color: color, fontWeight: FontWeight.w600)),
          ]),
        ),
      );

  Widget _attendeesTab() {
    if (_loadingAttendees) return const Center(child: CircularProgressIndicator(color: accentGreen));
    if (_attendees.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.people_outline_rounded, size: 52.sp, color: Colors.grey.shade300),
        12.height,
        Text('No members invited yet',
            style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.w600,
                color: Colors.grey.shade400)),
        8.height,
        Text('Use "Invite Groups" to add members',
            style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)),
      ]));
    }
    final accepted = _attendees.where((m) => m['rsvpStatus'] == 'ACCEPTED').toList();
    final pending = _attendees.where((m) => m['rsvpStatus'] == 'PENDING').toList();
    final rejected = _attendees.where((m) => m['rsvpStatus'] == 'REJECTED').toList();
    return RefreshIndicator(
      onRefresh: _loadAttendees,
      color: accentGreen,
      child: ListView(padding: EdgeInsets.all(16.w), children: [
        if (accepted.isNotEmpty) ...[
          _sectionHeader('Attending', accepted.length, accentGreen, Icons.check_circle_rounded),
          8.height, ...accepted.map((m) => _attendeeTile(m)), 16.height,
        ],
        if (pending.isNotEmpty) ...[
          _sectionHeader('Pending', pending.length, Colors.orange, Icons.hourglass_empty_rounded),
          8.height, ...pending.map((m) => _attendeeTile(m)), 16.height,
        ],
        if (rejected.isNotEmpty) ...[
          _sectionHeader('Declined', rejected.length, Colors.red, Icons.cancel_rounded),
          8.height, ...rejected.map((m) => _attendeeTile(m)),
        ],
      ]),
    );
  }

  Widget _sectionHeader(String title, int count, Color color, IconData icon) =>
      Row(children: [
        Icon(icon, color: color, size: 16.sp), 8.width,
        Text('$title ($count)', style: GoogleFonts.montserrat(
            fontSize: 13.sp, fontWeight: FontWeight.w700, color: color)),
      ]);

  Widget _attendeeTile(Map<String, dynamic> member) {
    final status = (member['rsvpStatus'] as String?) ?? 'PENDING';
    final name = (member['memberName'] as String?) ?? '';
    final email = (member['memberEmail'] as String?) ?? '';
    final color = _statusColor(status);
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Row(children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: color.withOpacity(0.1),
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: color)),
        ),
        12.width,
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600)),
          Text(email, style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
        ])),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r)),
          child: Row(children: [
            Icon(_statusIcon(status), size: 11.sp, color: color), 4.width,
            Text(status, style: GoogleFonts.poppins(
                fontSize: 10.sp, color: color, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

// Replace _performanceTab() in _CoachEventDetailScreenState:
  Widget _performanceTab() {
    if (_loadingAttendees || _loadingNotes) {
      return const Center(child: CircularProgressIndicator(color: accentGreen));
    }
    final eligible = _attendees.where((m) => m['rsvpStatus'] == 'ACCEPTED').toList();
    if (eligible.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.analytics_outlined, size: 52.sp, color: Colors.grey.shade300),
        12.height,
        Text('No attending members yet',
            style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w600,
                color: Colors.grey.shade400)),
        8.height,
        Text('Performance notes can be added for attending members',
            style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
            textAlign: TextAlign.center),
      ]));
    }
    return RefreshIndicator(
      onRefresh: () async {
        await _loadAttendees();
        await _loadPerformanceNotes();
      },
      color: accentGreen,
      child: ListView(padding: EdgeInsets.all(16.w), children: [
        Container(
          padding: EdgeInsets.all(12.w),
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: accentGreen.withOpacity(0.2))),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, color: accentGreen, size: 14.sp), 8.width,
            Expanded(child: Text('Tap a member to add a performance note.',
                style: GoogleFonts.poppins(fontSize: 11.sp))),
          ]),
        ),
        ...eligible.map((m) => _performanceTile(m)).toList(),
      ]),
    );
  }
// Replace _performanceTile() in _CoachEventDetailScreenState:
  Widget _performanceTile(Map<String, dynamic> member) {
    final name = (member['memberName'] as String?) ?? '';
    final email = (member['memberEmail'] as String?) ?? '';
    final memberId = member['memberId'] as int? ??
        int.tryParse(member['memberId']?.toString() ?? '0') ?? 0;
    final notes = _performanceNotes[memberId] ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Member header row
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: accentGreen.withOpacity(0.1),
                child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: GoogleFonts.montserrat(
                        fontSize: 15.sp, fontWeight: FontWeight.w800, color: accentGreen)),
              ),
              14.width,
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                Text(email, style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
                if (notes.isNotEmpty) ...[
                  4.height,
                  Text('${notes.length} note${notes.length > 1 ? 's' : ''} added',
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp, color: accentGreen, fontWeight: FontWeight.w600)),
                ],
              ])),
              // Add note button
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CoachPerformanceScreen(
                    eventId: _event.eventId, memberId: memberId,
                    memberName: name, memberEmail: email, eventName: _event.eventName,
                  ),
                )).then((_) => _loadPerformanceNotes()),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                      color: accentGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: accentGreen.withOpacity(0.25))),
                  child: Row(children: [
                    Icon(Icons.add_rounded, size: 13.sp, color: accentGreen), 4.width,
                    Text('Add Note', style: GoogleFonts.poppins(
                        fontSize: 11.sp, color: accentGreen, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
          ),
          // Show existing notes inline
          if (notes.isNotEmpty) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: notes.map((note) {
                  final noteText = note['note'] ?? '';
                  final rating = note['rating'] as int? ?? 0;
                  final coachName = note['coachName'] ?? '';
                  final createdAt = note['createdAt'] ?? '';
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey.shade200)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        // Stars
                        Row(children: List.generate(5, (i) => Icon(
                          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 13.sp,
                          color: i < rating ? Colors.amber : Colors.grey.shade300,
                        ))),
                        const Spacer(),
                        Text(coachName,
                            style: GoogleFonts.poppins(fontSize: 10.sp, color: accentGreen,
                                fontWeight: FontWeight.w600)),
                        6.width,
                        Text(createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt,
                            style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary)),
                      ]),
                      6.height,
                      Text(noteText,
                          style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black87)),
                    ]),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _chip(String label, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20.r)),
    child: Text(label, style: GoogleFonts.poppins(fontSize: 10.sp, color: color, fontWeight: FontWeight.w700)),
  );

  Widget _statChip(IconData icon, String label, Color color) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10.r)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 13.sp, color: color), 5.width,
        Text(label, style: GoogleFonts.poppins(fontSize: 10.sp, color: color, fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18.sp, color: accentGreen), 10.width,
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
        4.height,
        Text(value, style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black87, fontWeight: FontWeight.w500)),
      ])),
    ]),
  );

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100);
}


class _CoachEditEventSheet extends StatefulWidget {
  final Data event;
  final Function(Data updatedEvent) onUpdated; // now passes Data back

  const _CoachEditEventSheet({required this.event, required this.onUpdated});

  @override
  State<_CoachEditEventSheet> createState() => _CoachEditEventSheetState();
}

class _CoachEditEventSheetState extends State<_CoachEditEventSheet> {
  final _api = ClubApiService();
  late TextEditingController _nameCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _descCtrl;

  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  List<CoachData> _coaches = [];
  Set<int> _selectedCoachIds = {};
  bool _loadingCoaches = true;
  bool _submitting = false;

  // Activity
  List<ActivityData1> _activities = [];
  int? _selectedActivityId;
  bool _loadingActivities = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.event.eventName);
    _locationCtrl = TextEditingController(text: widget.event.location);
    _descCtrl = TextEditingController();
    try { _eventDate = DateTime.parse(widget.event.eventDate); } catch (_) {}
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
      final result = await _api.getActivities1();
      if (mounted) {
        setState(() {
          _activities = result;
          if (widget.event.activityId != null && widget.event.activityId != 0) {
            _selectedActivityId = widget.event.activityId;
          } else {
            _selectedActivityId = result.isNotEmpty ? result.first.id : null;
          }
          _loadingActivities = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingActivities = false);
    }
  }

  Future<void> _fetchCoaches() async {
    try {
      final result = await _api.getCoaches();
      if (mounted) setState(() { _coaches = result.data; _loadingCoaches = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCoaches = false);
    }
  }

  Widget _activityField() {
    if (_activities.length == 1) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Activity'),
        6.height,
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(_activities.first.name, style: GoogleFonts.poppins(fontSize: 13.sp)),
        ),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Activity'),
      6.height,
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedActivityId,
            isExpanded: true,
            items: _activities.map((activity) => DropdownMenuItem<int>(
              value: activity.id,
              child: Text(activity.name),
            )).toList(),
            onChanged: (value) => setState(() => _selectedActivityId = value),
          ),
        ),
      ),
    ]);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime(2024), lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: accentGreen)),
          child: child!),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
      builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: accentGreen)),
          child: child!),
    );
    if (picked != null) setState(() {
      if (isStart) _startTime = picked; else _endTime = picked;
    });
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) { toast('Enter event name'); return; }
    if (_locationCtrl.text.trim().isEmpty) { toast('Enter location'); return; }
    if (_eventDate == null) { toast('Select date'); return; }
    if (_startTime == null || _endTime == null) { toast('Select times'); return; }
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    if (endMinutes <= startMinutes) { toast('End time must be after start time'); return; }

    setState(() => _submitting = true);
    final data = {
      "eventName": _nameCtrl.text.trim(),
      "eventDate": DateFormat('yyyy-MM-dd').format(_eventDate!),
      "startTime": _fmtTime(_startTime!),
      "endTime": _fmtTime(_endTime!),
      "location": _locationCtrl.text.trim(),
      "eventType": widget.event.eventType,
      "status": widget.event.status,
      "clubId": widget.event.clubId,
      "activityId": _selectedActivityId ?? widget.event.activityId,
      "coachIds": _selectedCoachIds.toList(),
      if (_descCtrl.text.trim().isNotEmpty) "description": _descCtrl.text.trim(),
    };

    final success = await _api.updateEvent(widget.event.eventId, data);
    if (mounted) setState(() => _submitting = false);
    if (success) {
      final updatedEvent = Data(
        eventId: widget.event.eventId,
        eventName: _nameCtrl.text.trim(),
        eventDate: DateFormat('yyyy-MM-dd').format(_eventDate!),
        startTime: _fmtTime(_startTime!),
        endTime: _fmtTime(_endTime!),
        location: _locationCtrl.text.trim(),
        eventType: widget.event.eventType,
        status: widget.event.status,
        clubId: widget.event.clubId,
        activityId: _selectedActivityId ?? widget.event.activityId,
        coachIds: _selectedCoachIds.toList(),
        createdByUsername: widget.event.createdByUsername, createdByUserId: widget.event.createdByUserId, createdAt: widget.event.createdAt,
      );
      Navigator.pop(context);
      toast('Event updated!', bgColor: accentGreen);
      widget.onUpdated(updatedEvent);
    } else {
      toast('Failed to update event');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40.w, height: 4.h,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r)))),
          16.height,
          Row(children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r)),
              child: Icon(Icons.edit_rounded, color: Colors.blue, size: 20.sp),
            ),
            12.width,
            Text('Edit Event', style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ]),
          20.height,

          // Activity field
          _loadingActivities
              ? const Center(child: CircularProgressIndicator(color: accentGreen))
              : _activityField(),
          12.height,

          _label('Event Title'),
          6.height,
          _input('Event title', _nameCtrl),
          12.height,

          _label('Description (optional)'),
          6.height,
          _input('Add notes or description...', _descCtrl, maxLines: 2),
          12.height,

          _label('Location / Google Maps Link'),
          6.height,
          _input('Location or URL', _locationCtrl),
          12.height,

          _label('Event Date'),
          6.height,
          _tappable(Icons.calendar_today_rounded,
              _eventDate != null ? DateFormat('yyyy-MM-dd').format(_eventDate!) : 'Select date',
              _pickDate),
          12.height,

          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Start Time'),
              6.height,
              _tappable(Icons.access_time_rounded,
                  _startTime != null ? _fmtTime(_startTime!) : 'Start', () => _pickTime(true)),
            ])),
            12.width,
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('End Time'),
              6.height,
              _tappable(Icons.access_time_rounded,
                  _endTime != null ? _fmtTime(_endTime!) : 'End', () => _pickTime(false)),
            ])),
          ]),
          16.height,

          _label('Coaches'),
          8.height,
          _loadingCoaches
              ? const Center(child: CircularProgressIndicator(color: accentGreen))
              : _coaches.isEmpty
              ? Text('No coaches available',
              style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary))
              : Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200)),
            child: Column(children: _coaches.map((coach) {
              final selected = _selectedCoachIds.contains(coach.coachId);
              return CheckboxListTile(
                dense: true,
                value: selected,
                activeColor: accentGreen,
                onChanged: (_) => setState(() {
                  if (selected) _selectedCoachIds.remove(coach.coachId);
                  else _selectedCoachIds.add(coach.coachId);
                }),
                title: Text(coach.username, style: GoogleFonts.poppins(fontSize: 13.sp)),
                subtitle: Text(coach.specialization,
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
              );
            }).toList()),
          ),
          20.height,

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen, foregroundColor: Colors.white,
                  elevation: 0, padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
              child: _submitting
                  ? SizedBox(height: 20.h, width: 20.h,
                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Update Event',
                  style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700)),
            ),
          ),
          20.height,
        ]),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700));

  Widget _input(String hint, TextEditingController ctrl, {int maxLines = 1}) => TextField(
    controller: ctrl,
    maxLines: maxLines,
    style: GoogleFonts.poppins(fontSize: 13.sp),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary.withOpacity(0.5)),
      filled: true, fillColor: Colors.grey.shade50,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: accentGreen, width: 1.5)),
    ),
  );

  Widget _tappable(IconData icon, String text, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Icon(icon, size: 16.sp, color: textSecondary), 8.width,
        Text(text, style: GoogleFonts.poppins(fontSize: 13.sp,
            color: (text == 'Select date' || text == 'Start' || text == 'End')
                ? textSecondary.withOpacity(0.5) : Colors.black87)),
      ]),
    ),
  );
}