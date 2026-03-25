// screens/coach/member_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../config/app_theme.dart';
import '../../config/colors.dart';
import '../../model/coach/club_member.dart';
import 'club_events_list_screen.dart';

class MemberDetailsScreen extends StatefulWidget {
  final int clubId;
  final String clubName;
  final ClubMember member; // Receive the full member object

  const MemberDetailsScreen({
    Key? key,
    required this.clubId,
    required this.clubName,
    required this.member, // Make it required
  }) : super(key: key);

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
  // No need for FutureBuilder anymore since we have the data directly
  late ClubMember member;

  @override
  void initState() {
    super.initState();
    member = widget.member;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Member Details",
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Member Avatar and Basic Info
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: accentGreen.withOpacity(0.1),
                    child: Text(
                      member.username.isNotEmpty
                          ? member.username[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.montserrat(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        color: accentGreen,
                      ),
                    ),
                  ),
                  16.height,
                  Text(
                    member.username,
                    style: GoogleFonts.montserrat(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  4.height,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      widget.clubName,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: accentGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            16.height,

            // Personal Information
            _buildInfoSection(
              title: "Personal Information",
              children: [
                _buildInfoRow("Member ID", "#${member.memberId}"),
                _buildInfoRow("User ID", "#${member.userId}"),
                _buildInfoRow("Email", member.email),
                _buildInfoRow("Gender", member.gender),
                _buildInfoRow("Date of Birth", _formatDate(member.dob)),
                _buildInfoRow(
                  "Member Since",
                  _formatDateTime(member.createdAt),
                ),
              ],
            ),

            16.height,

            // Medical Notes
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: Colors.orange,
                        size: 20.sp,
                      ),
                      8.width,
                      Text(
                        "Medical Notes",
                        style: GoogleFonts.montserrat(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  12.height,
                  Text(
                    member.medicalNotes.isEmpty
                        ? "No medical notes available"
                        : member.medicalNotes,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: member.medicalNotes.isEmpty
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            24.height,

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.message_outlined,
                    label: "Message",
                    color: accentGreen,
                    onTap: () => toast("Send message to ${member.username}"),
                  ),
                ),
                12.width,
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.history,
                    label: "Attendance",
                    color: AppColors.info,
                    onTap: () => toast("View attendance history"),
                  ),
                ),
              ],
            ),
            12.height,
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.event,
                    label: "Events",
                    color: AppColors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClubEventsListScreen(
                            clubId: widget.clubId,
                            clubName: widget.clubName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                12.width,
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.feedback_outlined,
                    label: "Feedback",
                    color: AppColors.warning,
                    onTap: () => toast("Add feedback"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
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
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          12.height,
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20.sp),
            4.height,
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return 'N/A';
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}
