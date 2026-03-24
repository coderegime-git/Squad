import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../config/colors.dart';
import '../../model/coach/coach_event.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';

class CoachCreateEditEventSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final int clubId;
  final String clubName;
  final CoachEventModel? event;

  const CoachCreateEditEventSheet({
    Key? key,
    required this.onSuccess,
    required this.clubId,
    required this.clubName,
    this.event,
  }) : super(key: key);

  @override
  State<CoachCreateEditEventSheet> createState() => _CoachCreateEditEventSheetState();
}

class _CoachCreateEditEventSheetState extends State<CoachCreateEditEventSheet> {
  final CoachApiService _api = CoachApiService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  String _selectedType = 'SINGLE_EVENT';
  String _selectedStatus = 'SCHEDULED';
  bool _loading = false;

  final List<String> _eventTypes = [
    'SINGLE_EVENT',
    'TOURNAMENT',
    'PRACTICE',
    'MATCH',
  ];

  final List<String> _statusOptions = [
    'SCHEDULED',
    'ONGOING',
    'COMPLETED',
    'CANCELLED',
  ];

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final event = widget.event!;
    _nameController.text = event.eventName;
    _locationController.text = event.location;
    _selectedDate = event.eventDate;
    _selectedType = event.eventType;
    _selectedStatus = event.status;

    // Parse time strings
    try {
      if (event.startTime.isNotEmpty) {
        final startParts = event.startTime.split(':');
        if (startParts.length >= 2) {
          _startTime = TimeOfDay(
            hour: int.parse(startParts[0]),
            minute: int.parse(startParts[1]),
          );
        }
      }

      if (event.endTime.isNotEmpty) {
        final endParts = event.endTime.split(':');
        if (endParts.length >= 2) {
          _endTime = TimeOfDay(
            hour: int.parse(endParts[0]),
            minute: int.parse(endParts[1]),
          );
        }
      }
    } catch (e) {
      print("Error parsing time: $e");
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  String _formatTimeForApi(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String _formatDateForApi(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final data = {
        "eventName": _nameController.text.trim(),
        "eventDate": _formatDateForApi(_selectedDate),
        "startTime": _formatTimeForApi(_startTime),
        "endTime": _formatTimeForApi(_endTime),
        "location": _locationController.text.trim(),
        "eventType": _selectedType,
        "status": _selectedStatus,
      };

      print("Submitting event data: $data");

      bool success = false;

      if (_isEditing) {
        // Update existing event
        success = await _api.updateEvent(widget.clubId, widget.event!.eventId, data);
        if (success) {
          AppUI.success(context, "Event updated successfully!");
        }
      } else {
        // Create new event
        final eventId = await _api.createEvent(data);
        success = eventId > 0;
        if (success) {
          AppUI.success(context, "Event created successfully!");
        }
      }

      if (success) {
        Navigator.pop(context, true);
        widget.onSuccess();
      } else {
        AppUI.error(context, _isEditing ? "Failed to update event" : "Failed to create event");
      }
    } catch (e) {
      print("Error submitting event: $e");
      AppUI.error(context, "Something went wrong: ${e.toString()}");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),

              // Title with Club Name
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _isEditing ? "Edit Event" : "Create Event",
                          style: GoogleFonts.montserrat(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, color: Colors.grey, size: 22.sp),
                        ),
                      ],
                    ),
                    4.height,
                    Text(
                      widget.clubName,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: accentGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    children: [
                      // Event Name
                      _buildLabel("Event Name *"),
                      8.height,
                      TextFormField(
                        controller: _nameController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                        decoration: _inputDecor("e.g., Morning Training"),
                        style: GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                      16.height,

                      // Location
                      _buildLabel("Location *"),
                      8.height,
                      TextFormField(
                        controller: _locationController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                        decoration: _inputDecor("e.g., Ground A"),
                        style: GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                      16.height,

                      _buildLabel("Event Type"),
                      8.height,
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        items: _eventTypes
                            .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t,
                              style: GoogleFonts.poppins(fontSize: 13.sp)),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedType = v ?? _selectedType),
                        decoration: _inputDecor(""),
                      ),
                      16.height,
                      _buildLabel("Status"),
                      8.height,
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        items: _statusOptions
                            .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s,
                              style: GoogleFonts.poppins(fontSize: 13.sp)),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedStatus = v ?? _selectedStatus),
                        decoration: _inputDecor(""),
                      ),
                      16.height,

                      // Date
                      _buildLabel("Event Date"),
                      8.height,
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  color: accentGreen, size: 18.sp),
                              10.width,
                              Text(
                                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                                style: GoogleFonts.poppins(
                                    fontSize: 14.sp, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      16.height,

                      // Times
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Start Time"),
                                8.height,
                                GestureDetector(
                                  onTap: _pickStartTime,
                                  child: Container(
                                    padding: EdgeInsets.all(14.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.access_time_rounded,
                                            color: accentGreen, size: 16.sp),
                                        8.width,
                                        Text(
                                          _startTime.format(context),
                                          style: GoogleFonts.poppins(
                                              fontSize: 13.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          16.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("End Time"),
                                8.height,
                                GestureDetector(
                                  onTap: _pickEndTime,
                                  child: Container(
                                    padding: EdgeInsets.all(14.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.access_time_rounded,
                                            color: accentOrange, size: 16.sp),
                                        8.width,
                                        Text(
                                          _endTime.format(context),
                                          style: GoogleFonts.poppins(
                                              fontSize: 13.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      16.height,

                      // Club Info
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16.sp, color: accentGreen),
                            8.width,
                            Expanded(
                              child: Text(
                                _isEditing
                                    ? "Editing event for ${widget.clubName}"
                                    : "Event will be created for ${widget.clubName}",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      32.height,

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: _loading
                              ? AppUI.buttonSpinner()
                              : Text(
                            _isEditing ? "Update Event" : "Create Event",
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      24.height,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: accentGreen, width: 1.5),
      ),
    );
  }
}