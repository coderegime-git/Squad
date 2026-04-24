import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../config/colors.dart';
import '../../model/coach/club_member.dart';

class CoachMemberDetailWithPerformance extends StatefulWidget {
  final ClubMember member;
  final int clubId;
  final String clubName;

  const CoachMemberDetailWithPerformance({
    super.key,
    required this.member,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<CoachMemberDetailWithPerformance> createState() =>
      _CoachMemberDetailWithPerformanceState();
}

class _CoachMemberDetailWithPerformanceState
    extends State<CoachMemberDetailWithPerformance>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();

  // In-memory performance entries (replace with API persistence)
  final List<Map<String, String>> _performanceEntries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;
    setState(() {
      _performanceEntries.insert(0, {
        'comment': _commentController.text.trim(),
        'date': DateTime.now().toString().substring(0, 10),
        'type': 'comment',
      });
      _commentController.clear();
    });
    toast("Comment saved", bgColor: accentGreen);
  }

  void _uploadReport() {
    // Integrate with file_picker package
    toast("PDF upload — integrate file_picker");
    setState(() {
      _performanceEntries.insert(0, {
        'comment': 'Performance Report',
        'date': DateTime.now().toString().substring(0, 10),
        'type': 'pdf',
        'filename': 'report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                    top: 5.h, left: 20.w, right: 20.w, bottom: 12.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.username,
                              style: GoogleFonts.montserrat(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text(m.email,
                              style: GoogleFonts.poppins(
                                  fontSize: 11.sp, color: Colors.white60)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: accentGreen,
              unselectedLabelColor: Colors.grey,
              indicatorColor: accentGreen,
              tabs: [
                Tab(
                    child: Text("Profile",
                        style: GoogleFonts.poppins(
                            fontSize: 13.sp, fontWeight: FontWeight.w600))),
                Tab(
                    child: Text("Performance",
                        style: GoogleFonts.poppins(
                            fontSize: 13.sp, fontWeight: FontWeight.w600))),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Profile Tab ──
                SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      _infoCard("Personal Information", [
                        _row("Member ID", "#${m.memberId}"),
                        _row("User ID", "#${m.userId}"),
                        _row("Email", m.email),
                        _row("Gender", m.gender),
                        _row("Date of Birth", m.dob),
                      ]),
                      16.height,
                      _infoCard("Medical Notes", [],
                          customChild: Text(
                            m.medicalNotes.isEmpty
                                ? "No medical notes"
                                : m.medicalNotes,
                            style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: m.medicalNotes.isEmpty
                                    ? Colors.grey
                                    : Colors.black87),
                          )),
                    ],
                  ),
                ),

                // ── Performance Tab ──
                Column(
                  children: [
                    // Input area
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          TextField(
                            controller: _commentController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Add performance comment...",
                              hintStyle: GoogleFonts.poppins(
                                  fontSize: 13.sp, color: Colors.grey),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                      color: accentGreen, width: 1.5)),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            style: GoogleFonts.poppins(fontSize: 13.sp),
                          ),
                          8.height,
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _addComment,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentGreen,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10.r)),
                                  ),
                                  icon: const Icon(Icons.save_outlined,
                                      color: Colors.white, size: 16),
                                  label: Text("Save Comment",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 13.sp)),
                                ),
                              ),
                              12.width,
                              ElevatedButton.icon(
                                onPressed: _uploadReport,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10.r)),
                                ),
                                icon: const Icon(Icons.upload_file,
                                    color: Colors.white, size: 16),
                                label: Text("Upload PDF",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 13.sp)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Entries list
                    Expanded(
                      child: _performanceEntries.isEmpty
                          ? Center(
                        child: Text("No performance records yet",
                            style: GoogleFonts.poppins(
                                color: Colors.grey, fontSize: 14.sp)),
                      )
                          : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _performanceEntries.length,
                        itemBuilder: (_, i) {
                          final entry = _performanceEntries[i];
                          final isPdf = entry['type'] == 'pdf';
                          return Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: isPdf
                                      ? Colors.deepPurple.withOpacity(0.3)
                                      : accentGreen.withOpacity(0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: isPdf
                                        ? Colors.deepPurple
                                        .withOpacity(0.1)
                                        : accentGreen.withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    isPdf
                                        ? Icons.picture_as_pdf
                                        : Icons.comment_outlined,
                                    color: isPdf
                                        ? Colors.deepPurple
                                        : accentGreen,
                                    size: 18.sp,
                                  ),
                                ),
                                12.width,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry['comment'] ?? '',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      4.height,
                                      Text(
                                        entry['date'] ?? '',
                                        style: GoogleFonts.poppins(
                                            fontSize: 11.sp,
                                            color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> rows,
      {Widget? customChild}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.montserrat(
                  fontSize: 15.sp, fontWeight: FontWeight.w600)),
          12.height,
          if (customChild != null) customChild,
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12.sp, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}