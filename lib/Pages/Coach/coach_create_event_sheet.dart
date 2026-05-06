// screens/coach/coach_create_event_sheet.dart
// Coach: Create Event Bottom Sheet
// - Single event type only (SINGLE_EVENT)
// - No status field (always SCHEDULED)
// - Location supports Google Maps links
// - Assign coaches (fetched from API)
// - Date, start/end time pickers

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/activities_data.dart';
import '../../model/clubAdmin/get_coaches.dart';
import '../../utills/api_service.dart';

class CoachCreateEventSheet extends StatefulWidget {
  final VoidCallback? onSuccess;
  final int clubId;
  final String clubName;

  const CoachCreateEventSheet({
    super.key,
    this.onSuccess,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<CoachCreateEventSheet> createState() => _CoachCreateEventSheetState();
}

class _CoachCreateEventSheetState extends State<CoachCreateEventSheet> {
  final _apiService = ClubApiService();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

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
  String _selectedEventType = 'SINGLE_EVENT';
  final List<String> _eventTypes = ['SINGLE_EVENT', 'TOURNAMENT'];

  @override
  void initState() {
    super.initState();
   // _fetchCoaches();
    _loadActivities();
  }

  Future<void> _fetchCoaches() async {
    try {
      final result = await _apiService.getCoaches();
      if (mounted) setState(() { _coaches = result.data; _loadingCoaches = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCoaches = false);
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
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 100));
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: accentGreen)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 100));
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? TimeOfDay.now()
          : (_startTime != null
          ? TimeOfDay(
        hour: _startTime!.hour + 1,
        minute: _startTime!.minute,
      )
          : TimeOfDay.now()),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: accentGreen)),
        child: child!,
      ),
    );
    if (picked != null) {
      // If picking end time, validate immediately
      if (!isStart && _startTime != null) {
        final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
        final endMinutes = picked.hour * 60 + picked.minute;
        if (endMinutes <= startMinutes) {
          toast('End time must be after start time');
          return;
        }
      }
      setState(() {
        if (isStart) {
          _startTime = picked;
          if (_endTime != null) {
            final startMinutes = picked.hour * 60 + picked.minute;
            final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
            if (endMinutes <= startMinutes) {
              _endTime = null;
              toast('End time cleared — please re-select');
            }
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }
  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) { toast('Enter event title'); return; }
    if (_locationCtrl.text.trim().isEmpty) { toast('Enter location'); return; }
    if (_eventDate == null) { toast('Select event date'); return; }
    if (_startTime == null) { toast('Select start time'); return; }
    if (_endTime == null) { toast('Select end time'); return; }

    // ── Validate start time is before end time ──
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    if (endMinutes <= startMinutes) {
      toast('End time must be after start time');
      return;
    }

    setState(() => _submitting = true);

    final data = {
      "eventName": _nameCtrl.text.trim(),
      "eventDate": DateFormat('yyyy-MM-dd').format(_eventDate!),
      "startTime": _fmtTime(_startTime!),
      "endTime": _fmtTime(_endTime!),
      "location": _locationCtrl.text.trim(),
      "eventType": _selectedEventType,
      "activityId": _selectedActivityId,
      "status": "SCHEDULED",
      "coachIds": [],
      if (_descCtrl.text.trim().isNotEmpty) "description": _descCtrl.text.trim(),
      if (widget.clubId > 0) "clubId": widget.clubId,
    };

    final eventId = await _apiService.addEvent(data);
    if (mounted) setState(() => _submitting = false);

    if (eventId >= 0) {
      if (mounted) Navigator.pop(context);
      toast('Event created!', bgColor: accentGreen);
      widget.onSuccess?.call();
    } else {
      toast('Failed to create event. Try again.');
    }
  }  Widget _activityField() {
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            16.height,

            // Title row
            Row(children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r)),
                child: Icon(Icons.event_rounded, color: accentGreen, size: 20.sp),
              ),
              12.width,
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Create Event',
                    style: GoogleFonts.montserrat(
                        fontSize: 18.sp, fontWeight: FontWeight.bold)),
                if (widget.clubName.isNotEmpty)
                  Text(widget.clubName,
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
              ]),
            ]),
            20.height,
            loadingActivity? Center(child: CircularProgressIndicator(color: accentGreen)):_activityField(),
            6.height,
            // Event Title
            _label('Event Title'),
            6.height,
            _input('e.g. Morning Training Session', _nameCtrl),
            12.height,

            // Description
            _label('Description (optional)'),
            6.height,
            _input('Add details, notes, or instructions...', _descCtrl, maxLines: 3),
            12.height,

            // Location
            _label('Location / Google Maps Link'),
            6.height,
            _input(
              'Address or paste a Google Maps link',
              _locationCtrl,
              textInputAction: TextInputAction.done, // ← closes keyboard
            ),
            12.height,
// Add after location _input and before Date section:
            _label('Event Type'),
            6.height,
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedEventType = 'SINGLE_EVENT'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _selectedEventType == 'SINGLE_EVENT'
                            ? accentGreen.withOpacity(0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: _selectedEventType == 'SINGLE_EVENT'
                              ? accentGreen
                              : Colors.grey.shade200,
                          width: _selectedEventType == 'SINGLE_EVENT' ? 1.5 : 1,
                        ),
                      ),
                      child: Column(children: [
                        Icon(Icons.event_rounded,
                            color: _selectedEventType == 'SINGLE_EVENT'
                                ? accentGreen
                                : Colors.grey,
                            size: 20.sp),
                        4.height,
                        Text('Single Event',
                            style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: _selectedEventType == 'SINGLE_EVENT'
                                    ? accentGreen
                                    : Colors.grey,
                                fontWeight: _selectedEventType == 'SINGLE_EVENT'
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                      ]),
                    ),
                  ),
                ),
                12.width,
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedEventType = 'TOURNAMENT'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _selectedEventType == 'TOURNAMENT'
                            ? accentGreen.withOpacity(0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: _selectedEventType == 'TOURNAMENT'
                              ? accentGreen
                              : Colors.grey.shade200,
                          width: _selectedEventType == 'TOURNAMENT' ? 1.5 : 1,
                        ),
                      ),
                      child: Column(children: [
                        Icon(Icons.emoji_events_rounded,
                            color: _selectedEventType == 'TOURNAMENT'
                                ? accentGreen
                                : Colors.grey,
                            size: 20.sp),
                        4.height,
                        Text('Tournament',
                            style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: _selectedEventType == 'TOURNAMENT'
                                    ? accentGreen
                                    : Colors.grey,
                                fontWeight: _selectedEventType == 'TOURNAMENT'
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
            12.height,            _label('Event Date'),
            6.height,
            _tappable(Icons.calendar_today_rounded,
                _eventDate != null ? DateFormat('EEE, MMM d yyyy').format(_eventDate!) : 'Select date',
                _pickDate),
            12.height,

            // Times
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Start Time'),
                6.height,
                _tappable(Icons.access_time_rounded,
                    _startTime != null ? _fmtTime(_startTime!) : 'Start',
                        () => _pickTime(true)),
              ])),
              12.width,
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('End Time'),
                6.height,
                _tappable(Icons.access_time_rounded,
                    _endTime != null ? _fmtTime(_endTime!) : 'End',
                        () => _pickTime(false)),
              ])),
            ]),
            16.height,

            // Assign Coaches
            // _label('Assign Coaches'),
            // 4.height,
            // Text('Select coaches to assign to this event',
            //     style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
            // 8.height,
            //
            // if (_loadingCoaches)
            //   Center(
            //     child: Padding(
            //       padding: EdgeInsets.symmetric(vertical: 20.h),
            //       child: const CircularProgressIndicator(color: accentGreen),
            //     ),
            //   )
            // else if (_coaches.isEmpty)
            //   Container(
            //     padding: EdgeInsets.all(14.w),
            //     decoration: BoxDecoration(
            //         color: Colors.grey.shade50,
            //         borderRadius: BorderRadius.circular(10.r),
            //         border: Border.all(color: Colors.grey.shade200)),
            //     child: Text('No coaches available',
            //         style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)),
            //   )
            // else
            //   Container(
            //     decoration: BoxDecoration(
            //         color: Colors.grey.shade50,
            //         borderRadius: BorderRadius.circular(12.r),
            //         border: Border.all(color: Colors.grey.shade200)),
            //     child: Column(
            //       children: _coaches.map((coach) {
            //         final selected = _selectedCoachIds.contains(coach.coachId);
            //         return InkWell(
            //           onTap: () => setState(() {
            //             if (selected) _selectedCoachIds.remove(coach.coachId);
            //             else _selectedCoachIds.add(coach.coachId);
            //           }),
            //           borderRadius: BorderRadius.circular(12.r),
            //           child: Padding(
            //             padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            //             child: Row(children: [
            //               AnimatedContainer(
            //                 duration: const Duration(milliseconds: 200),
            //                 width: 22.w, height: 22.w,
            //                 decoration: BoxDecoration(
            //                   color: selected ? accentGreen : Colors.white,
            //                   borderRadius: BorderRadius.circular(6.r),
            //                   border: Border.all(
            //                       color: selected ? accentGreen : Colors.grey.shade400,
            //                       width: 1.5),
            //                 ),
            //                 child: selected
            //                     ? Icon(Icons.check_rounded, size: 14.sp, color: Colors.white)
            //                     : null,
            //               ),
            //               12.width,
            //               CircleAvatar(
            //                 radius: 16.r,
            //                 backgroundColor: accentGreen.withOpacity(0.1),
            //                 child: Text(
            //                   coach.username.isNotEmpty ? coach.username[0].toUpperCase() : 'C',
            //                   style: GoogleFonts.montserrat(
            //                       fontSize: 12.sp,
            //                       fontWeight: FontWeight.w700,
            //                       color: accentGreen),
            //                 ),
            //               ),
            //               10.width,
            //               Expanded(child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text(coach.username,
            //                       style: GoogleFonts.poppins(
            //                           fontSize: 13.sp, fontWeight: FontWeight.w600)),
            //                   Text(coach.specialization,
            //                       style: GoogleFonts.poppins(
            //                           fontSize: 10.sp, color: textSecondary)),
            //                 ],
            //               )),
            //             ]),
            //           ),
            //         );
            //       }).toList(),
            //     ),
            //   ),
            24.height,

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: accentGreen.withOpacity(0.5),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                ),
                child: _submitting
                    ? SizedBox(
                    height: 20.h, width: 20.h,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.add_rounded, color: Colors.white),
                  8.width,
                  Text('Create Event',
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.poppins(
          fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700));

  Widget _input(String hint, TextEditingController ctrl,
      {int maxLines = 1, TextInputAction textInputAction = TextInputAction.next}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        textInputAction: textInputAction,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        style: GoogleFonts.poppins(fontSize: 13.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
              fontSize: 12.sp, color: textSecondary.withOpacity(0.5)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200)),
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
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200)),
          child: Row(children: [
            Icon(icon, size: 16.sp, color: textSecondary),
            8.width,
            Text(text,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: (text == 'Select date' || text == 'Start' || text == 'End')
                        ? textSecondary.withOpacity(0.5)
                        : Colors.black87)),
          ]),
        ),
      );
}