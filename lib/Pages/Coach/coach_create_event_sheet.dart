import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';

class CoachCreateEventSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final int clubId;
  final String clubName;

  const CoachCreateEventSheet({
    super.key,
    required this.onSuccess,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<CoachCreateEventSheet> createState() => _CoachCreateEventSheetState();
}

class _CoachCreateEventSheetState extends State<CoachCreateEventSheet> {
  final CoachApiService _api = CoachApiService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mapsLinkController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  bool _isRecurring = false;
  bool _loading = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final data = {
        "eventName": _nameController.text.trim(),
        "eventDate":
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
        "startTime":
        "${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}",
        "endTime":
        "${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}",
        "location": _locationController.text.trim(),
        "mapsLink": _mapsLinkController.text.trim(),
        "description": _descriptionController.text.trim(),
        "eventType": _isRecurring ? 'RECURRING' : 'SINGLE_EVENT',
        "coachIds": [],
      };

      print("Submitting event data: $data");
      final eventId = await _api.createEvent(data);

      if (eventId > 0) {
        AppUI.success(context, "Event created successfully!");
        Navigator.pop(context);
        widget.onSuccess();
      } else {
        AppUI.error(context, "Failed to create event");
      }
    } catch (e) {
      print("Error creating event: $e");
      AppUI.error(context, "Something went wrong: ${e.toString()}");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _mapsLinkController.dispose();
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
              // ── Handle ────────────────────────────────────────────────
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

              // ── Title ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Create Event",
                            style: GoogleFonts.montserrat(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          if (widget.clubName.isNotEmpty) ...[
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
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close,
                          color: Colors.grey, size: 22.sp),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ── Form ──────────────────────────────────────────────────
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 16.h),
                    children: [
                      // Event Name
                      _buildLabel("Event Name *"),
                      8.height,
                      TextFormField(
                        controller: _nameController,
                        validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? "Required"
                            : null,
                        decoration:
                        _inputDecor("e.g., Morning Training"),
                        style:
                        GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                      16.height,

                      // Description
                      _buildLabel("Description"),
                      8.height,
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: _inputDecor(
                            "Describe the event, match details, etc."),
                        style:
                        GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                      16.height,

                      // Location
                      _buildLabel("Location *"),
                      8.height,
                      TextFormField(
                        controller: _locationController,
                        validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? "Required"
                            : null,
                        decoration:
                        _inputDecor("e.g., Main Ground, Sports Complex"),
                        style:
                        GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                      8.height,

                      // Google Maps Link
                      _buildLabel("Google Maps Link (optional)"),
                      8.height,
                      TextFormField(
                        controller: _mapsLinkController,
                        keyboardType: TextInputType.url,
                        decoration:
                        _inputDecor("https://maps.google.com/...")
                            .copyWith(
                          prefixIcon: Icon(
                            Icons.map_outlined,
                            color: Colors.green.shade600,
                            size: 18.sp,
                          ),
                        ),
                        style:
                        GoogleFonts.poppins(fontSize: 13.sp),
                      ),
                      20.height,

                      // Event Type — Single or Recurring
                      _buildLabel("Event Type"),
                      12.height,
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                      () => _isRecurring = false),
                              child: _typeCard(
                                icon: Icons.event_rounded,
                                label: "Single Event",
                                selected: !_isRecurring,
                              ),
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                      () => _isRecurring = true),
                              child: _typeCard(
                                icon: Icons.repeat_rounded,
                                label: "Recurring",
                                selected: _isRecurring,
                              ),
                            ),
                          ),
                        ],
                      ),
                      20.height,

                      // Event Date
                      _buildLabel("Event Date"),
                      8.height,
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade400),
                            borderRadius:
                            BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  color: accentGreen, size: 18.sp),
                              10.width,
                              Text(
                                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                                style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      16.height,

                      // Start & End Time
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Start Time"),
                                8.height,
                                GestureDetector(
                                  onTap: _pickStartTime,
                                  child: Container(
                                    padding:
                                    EdgeInsets.all(14.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors
                                              .grey.shade400),
                                      borderRadius:
                                      BorderRadius.circular(
                                          12.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                            Icons
                                                .access_time_rounded,
                                            color: accentGreen,
                                            size: 16.sp),
                                        8.width,
                                        Text(
                                          _startTime
                                              .format(context),
                                          style:
                                          GoogleFonts.poppins(
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
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                _buildLabel("End Time"),
                                8.height,
                                GestureDetector(
                                  onTap: _pickEndTime,
                                  child: Container(
                                    padding:
                                    EdgeInsets.all(14.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors
                                              .grey.shade400),
                                      borderRadius:
                                      BorderRadius.circular(
                                          12.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                            Icons
                                                .access_time_rounded,
                                            color: accentOrange,
                                            size: 16.sp),
                                        8.width,
                                        Text(
                                          _endTime.format(context),
                                          style:
                                          GoogleFonts.poppins(
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
                      20.height,

                      // Club info banner
                      if (widget.clubName.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius:
                            BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 16.sp, color: accentGreen),
                              8.width,
                              Expanded(
                                child: Text(
                                  "Event will be created for ${widget.clubName}",
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
                              borderRadius:
                              BorderRadius.circular(14.r),
                            ),
                          ),
                          child: _loading
                              ? AppUI.buttonSpinner()
                              : Text(
                            "Create Event",
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

  Widget _typeCard({
    required IconData icon,
    required String label,
    required bool selected,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: selected
            ? accentGreen.withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: selected ? accentGreen : Colors.grey.shade300,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon,
              color: selected ? accentGreen : Colors.grey,
              size: 22.sp),
          6.height,
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: selected ? accentGreen : Colors.grey.shade600,
              fontWeight: selected
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
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
      hintStyle:
      GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey),
      contentPadding:
      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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