// screens/coach/coach_performance_screen.dart
// Coach: Write performance notes for a member
// - POST /api/events/{eventId}/members/{memberId}/performance
// - Shows member info, date, and text note input
// - Optionally fetches existing performance notes via GET

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../utills/api_service.dart';

class CoachPerformanceScreen extends StatefulWidget {
  final int eventId;
  final int memberId;
  final String memberName;
  final String memberEmail;
  final String eventName;

  const CoachPerformanceScreen({
    super.key,
    required this.eventId,
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    required this.eventName,
  });

  @override
  State<CoachPerformanceScreen> createState() => _CoachPerformanceScreenState();
}

class _CoachPerformanceScreenState extends State<CoachPerformanceScreen> {
  final ClubApiService _api = ClubApiService();
  final _noteCtrl = TextEditingController();
  int _rating = 0;
  bool _submitting = false;
  bool _loadingExisting = true;
  List<Map<String, dynamic>> _existingNotes = [];

  @override
  void initState() {
    super.initState();
    print("can existing notes here");
    _loadExistingNotes();

  }

  Future<void> _loadExistingNotes() async {
    setState(() => _loadingExisting = true);
    try {
      final result = await _api.getEventsPerformanceNotes(
          eventId: widget.eventId.toString());
      if (mounted) {
        final notes = (result.data ?? [])
            .where((n) => n.memberId == widget.memberId)
            .map((n) => {
          'noteId': n.noteId,
          'memberId': n.memberId,
          'memberName': n.memberName,
          'note': n.note,
          'rating': n.rating,
          'coachName': n.coachName,
          'createdAt': n.createdAt,
        })
            .toList();
        setState(() {
          _existingNotes = notes;
          _loadingExisting = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

// Replace _submit() in _CoachPerformanceScreenState:
  Future<void> _submit() async {
    if (_noteCtrl.text.trim().isEmpty) {
      toast('Please enter a performance note');
      return;
    }
    setState(() => _submitting = true);
    final data = {
      "note": _noteCtrl.text.trim(), // API expects "note" not "notes"
      "rating": _rating > 0 ? _rating : 1, // rating is required, default 1
    };
    final success = await _api.addPerformanceNotes(
      eventId: widget.eventId.toString(),
      memberId: widget.memberId.toString(),
      data: data,
    );
    if (mounted) setState(() => _submitting = false);
    if (success) {
      toast('Performance note saved!', bgColor: accentGreen);
      _noteCtrl.clear();
      setState(() => _rating = 0);
      _loadExistingNotes(); // reload notes after saving
    } else {
      toast('Failed to save note. Try again.');
    }
  }
  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(children: [
          _buildHeader(),
          // Replace build() body Column children in CoachPerformanceScreen:
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _memberCard(),
                  16.height,
                  _writeNoteCard(),
                  16.height,
                  // Always show existing notes section
                  _existingNotesSection(),
                  100.height,
                ],
              ),
            ),
          ),
        ]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _submitting ? null : _submit,
          backgroundColor: accentGreen,
          disabledElevation: 0,
          icon: _submitting
              ? SizedBox(width: 18.w, height: 18.w,
              child: const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.save_rounded, color: Colors.white),
          label: Text(_submitting ? 'Saving...' : 'Save Note',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16))),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 14.h),
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Performance Note',
                style: GoogleFonts.montserrat(
                    color: Colors.white, fontSize: 18.sp,
                    fontWeight: FontWeight.bold)),
            Text(widget.eventName,
                style: GoogleFonts.poppins(
                    fontSize: 11.sp, color: Colors.grey.shade400)),
          ]),
        ]),
      ),
    ),
  );

  Widget _memberCard() => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100)),
    child: Row(children: [
      CircleAvatar(
        radius: 28.r,
        backgroundColor: accentGreen.withOpacity(0.12),
        child: Text(
          widget.memberName.isNotEmpty
              ? widget.memberName[0].toUpperCase() : '?',
          style: GoogleFonts.montserrat(
              fontSize: 22.sp, fontWeight: FontWeight.w800,
              color: accentGreen),
        ),
      ),
      16.width,
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.memberName,
              style: GoogleFonts.montserrat(
                  fontSize: 15.sp, fontWeight: FontWeight.w700)),
          4.height,
          Text(widget.memberEmail,
              style: GoogleFonts.poppins(
                  fontSize: 12.sp, color: textSecondary)),
          6.height,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
                color: accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r)),
            child: Text('ID: ${widget.memberId}',
                style: GoogleFonts.poppins(
                    fontSize: 10.sp, color: accentGreen,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      )),
    ]),
  );

  Widget _writeNoteCard() => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.edit_note_rounded, color: accentGreen, size: 20.sp),
        10.width,
        Text('Write Performance Note',
            style: GoogleFonts.montserrat(
                fontSize: 14.sp, fontWeight: FontWeight.bold)),
      ]),
      12.height,

      // Rating stars
      Text('Rating (optional)',
          style: GoogleFonts.poppins(
              fontSize: 12.sp, fontWeight: FontWeight.w600,
              color: Colors.grey.shade600)),
      8.height,
      Row(children: List.generate(5, (i) {
        final starIndex = i + 1;
        return GestureDetector(
          onTap: () => setState(() => _rating = _rating == starIndex ? 0 : starIndex),
          child: Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Icon(
              starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: starIndex <= _rating ? Colors.amber : Colors.grey.shade400,
              size: 28.sp,
            ),
          ),
        );
      })),
      if (_rating > 0) ...[
        4.height,
        Text(_ratingLabel(_rating),
            style: GoogleFonts.poppins(
                fontSize: 11.sp, color: Colors.amber.shade700,
                fontWeight: FontWeight.w600)),
      ],
      16.height,

      // Note textarea
      Text('Performance Notes *',
          style: GoogleFonts.poppins(
              fontSize: 12.sp, fontWeight: FontWeight.w600,
              color: Colors.grey.shade600)),
      8.height,
      TextField(
        controller: _noteCtrl,
        maxLines: 6,
        style: GoogleFonts.poppins(fontSize: 13.sp),
        decoration: InputDecoration(
          hintText:
          'Describe performance, strengths, areas for improvement...',
          hintStyle: GoogleFonts.poppins(
              fontSize: 12.sp, color: textSecondary.withOpacity(0.5)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.all(14.w),
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
      ),
      8.height,
      Text('Today: ${DateFormat('EEE, MMM d yyyy').format(DateTime.now())}',
          style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
    ]),
  );

// Replace _existingNotesSection() in CoachPerformanceScreen:
  Widget _existingNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.history_rounded, color: textSecondary, size: 16.sp),
          8.width,
          Text(
            _loadingExisting
                ? 'Loading notes...'
                : 'My Notes (${_existingNotes.length})',
            style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700),
          ),
        ]),
        12.height,
        if (_loadingExisting)
          const Center(child: CircularProgressIndicator(color: accentGreen))
        else if (_existingNotes.isEmpty)
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200)),
            child: Center(
              child: Text('No notes added yet for this member',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp, color: textSecondary)),
            ),
          )
        else
          ..._existingNotes.map((note) => _noteCard(note)).toList(),
      ],
    );
  }
  Widget _noteCard(Map<String, dynamic> note) {
    final noteText = note['notes'] ?? note['note'] ?? note['comment'] ?? '';
    final date = note['date'] ?? note['createdAt'] ?? '';
    final rating = note['rating'];

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade100)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.note_rounded, size: 14.sp, color: accentGreen),
          6.width,
          Expanded(child: Text(date,
              style: GoogleFonts.poppins(
                  fontSize: 11.sp, color: textSecondary))),
          if (rating != null)
            Row(children: List.generate(5, (i) => Icon(
              i < (rating as num) ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 12.sp,
              color: i < (rating as num) ? Colors.amber : Colors.grey.shade300,
            ))),
        ]),
        8.height,
        Text(noteText.toString(),
            style: GoogleFonts.poppins(
                fontSize: 13.sp, color: Colors.black87)),
      ]),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1: return 'Poor';
      case 2: return 'Below Average';
      case 3: return 'Average';
      case 4: return 'Good';
      case 5: return 'Excellent';
      default: return '';
    }
  }
}