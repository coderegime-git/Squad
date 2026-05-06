// screens/coach/coach_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sports/model/coach/event_attendance_data.dart';
import 'package:sports/utills/api_service.dart';

import '../../config/colors.dart';

enum AttendanceStatus { present, absent, late }

class CoachAttendanceScreen extends StatefulWidget {
  final String groupName;
  final String eventName;
  final String eventId;
  final String date;

  const CoachAttendanceScreen({
    super.key,
    required this.groupName,
    required this.eventName,
    required this.eventId,
    this.date = '',
  });

  @override
  State<CoachAttendanceScreen> createState() => _CoachAttendanceScreenState();
}

class _CoachAttendanceScreenState extends State<CoachAttendanceScreen> {
  bool _isSubmitting = false;
  bool isLoad = false;
  final apiService = CoachApiService();
  late EventAttendanceData groupMembersData;
  List<Data> _members = [];

  int get _presentCount => _members.where((m) => m.status == "PRESENT").length;

  int get _absentCount => _members.where((m) => m.status == "ABSENT").length;

  int get _lateCount => _members.where((m) => m.status == "LATE").length;
  List<AttendanceData> attendanceData = [];

  void _markAll(String status) {
    setState(() {
      for (var m in _members) {
        m.status = status.toUpperCase();
      }
    });
  }

  void getMemberData() async {
    setState(() {
      isLoad = true;
    });
    groupMembersData = await apiService.getEventAttendance(widget.eventId);
    _members = groupMembersData.data ?? [];
    setState(() {
      isLoad = false;
    });
  }

  void _submitAttendance() async {
    try {
      setState(() => _isSubmitting = true);
      final List<AttendanceData> attendanceData = _members.map((m) {
        return AttendanceData(
          memberId: m.memberId.toString(), // or int if API expects int
          status: m.status ?? "ABSENT", // fallback safety
        );
      }).toList();

      final payload = attendanceData.map((e) => e.toJson()).toList();

      final success = await apiService.saveAttendance(widget.eventId, payload);
      setState(() => _isSubmitting = false);
      toast('Attendance saved successfully!', bgColor: accentGreen);
      Navigator.pop(context);
    } catch (e) {
      toast('Failed to save!', bgColor: Colors.red.shade400);

      setState(() => _isSubmitting = false);
    }
  }

  @override
  void initState() {
    getMemberData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final today = widget.date.isNotEmpty
        ? widget.date
        : '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: isLoad
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Container(
                  //height: 85.h,
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
                      padding: EdgeInsets.only(
                        top: 5.h,
                        left: 20.w,
                        right: 20.w,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Attendance',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${widget.groupName} • $today',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade400,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Summary row
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      _SummaryChip(
                        label: 'Present',
                        count: _presentCount,
                        color: accentGreen,
                      ),
                      8.width,
                      _SummaryChip(
                        label: 'Absent',
                        count: _absentCount,
                        color: Colors.redAccent,
                      ),
                      // 8.width,
                      // _SummaryChip(
                      //   label: 'Late',
                      //   count: _lateCount,
                      //   color: accentOrange,
                      // ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        color: Colors.white,
                        onSelected: (val) {
                          if (val == 'all_present') _markAll("PRESENT");
                          if (val == 'all_absent') _markAll("ABSENT");
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'all_present',
                            child: Text('Mark All Present'),
                          ),
                          const PopupMenuItem(
                            value: 'all_absent',
                            child: Text('Mark All Absent'),
                          ),
                        ],
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.more_vert_rounded, size: 20.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                _members.isEmpty
                    ? Expanded(child: Center(child: Text("No member found")))
                    : Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: _members.length,
                          itemBuilder: (context, index) {
                            final member = _members[index];
                            return _AttendanceTile(
                              member: member,
                              onStatusChanged: (status) =>
                                  setState(() => member.status = status),
                            );
                          },
                        ),
                      ),

                if (_members.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitAttendance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentGreen,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Attendance',
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            '$count',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          4.width,
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10.sp, color: color),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final Data member;
  final ValueChanged<String> onStatusChanged;

  const _AttendanceTile({required this.member, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: member.status == "PRESENT"
              ? accentGreen.withOpacity(0.4)
              : member.status == "ABSENT"
              ? Colors.redAccent.withOpacity(0.3)
              : accentOrange.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                '#${member.memberId}',
                style: GoogleFonts.montserrat(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: accentGreen,
                ),
              ),
            ),
          ),
          12.width,
          Expanded(
            child: Text(
              member.memberName ?? "",
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          // Status toggle buttons
          _StatusBtn(
            label: 'P',
            tooltip: 'Present',
            color: accentGreen,
            isSelected: member.status == "PRESENT",
            onTap: () => onStatusChanged("PRESENT"),
          ),
          6.width,
          // _StatusBtn(
          //   label: 'L',
          //   tooltip: 'Late',
          //   color: accentOrange,
          //   isSelected: member.status == "LATE",
          //   onTap: () => onStatusChanged("LATE"),
          // ),
          // 6.width,
          _StatusBtn(
            label: 'A',
            tooltip: 'Absent',
            color: Colors.redAccent,
            isSelected: member.status == "ABSENT",
            onTap: () => onStatusChanged("ABSENT"),
          ),
        ],
      ),
    );
  }
}

class _StatusBtn extends StatelessWidget {
  final String label, tooltip;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusBtn({
    required this.label,
    required this.tooltip,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34.r,
          height: 34.r,
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AttendanceMember {
  final String id, name;
  final int jerseyNumber;
  AttendanceStatus status;

  AttendanceMember({
    required this.id,
    required this.name,
    required this.jerseyNumber,
    this.status = AttendanceStatus.present,
  });
}

class AttendanceData {
  final String memberId;
  final String status;

  AttendanceData({required this.memberId, required this.status});

  Map<String, dynamic> toJson() {
    return {"memberId": memberId, "status": status};
  }
}
