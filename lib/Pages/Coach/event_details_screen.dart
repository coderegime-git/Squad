import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../config/app_theme.dart';
import '../../config/colors.dart';
import '../../model/coach/coach_event.dart';
import '../../utills/api_service.dart';

class EventDetailsScreen extends StatefulWidget {
  final int clubId;
  final int eventId;
  final String clubName;

  const EventDetailsScreen({
    Key? key,
    required this.clubId,
    required this.eventId,
    required this.clubName,
  }) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final CoachApiService _apiService = CoachApiService();
  late Future<CoachEventModel?> _eventFuture;

  @override
  void initState() {
    super.initState();
    _eventFuture = _apiService.getEventDetails(widget.clubId, widget.eventId);
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
          "Event Details",
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: accentGreen),
            onPressed: () => _navigateToEditEvent(),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
      ),
      body: FutureBuilder<CoachEventModel?>(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentGreen));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60.sp, color: Colors.red),
                  16.height,
                  Text(
                    "Failed to load event details",
                    style: GoogleFonts.poppins(fontSize: 16.sp),
                  ),
                  16.height,
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _eventFuture = _apiService.getEventDetails(widget.clubId, widget.eventId);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    ),
                    child: Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final event = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // Event Header Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentGreen, accentGreen.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: accentGreen.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.event,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: Text(
                              event.eventName,
                              style: GoogleFonts.montserrat(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      16.height,
                      _buildEventStatusChip(event.status),
                      8.height,
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14.sp, color: Colors.white70),
                          8.width,
                          Text(
                            _formatEventDate(event.eventDate),
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      8.height,
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14.sp, color: Colors.white70),
                          8.width,
                          Text(
                            "${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}",
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      8.height,
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14.sp, color: Colors.white70),
                          8.width,
                          Expanded(
                            child: Text(
                              event.location,
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                16.height,

                // Event Type Card
                Container(
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
                        "Event Type",
                        style: GoogleFonts.montserrat(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      12.height,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: _getEventTypeColor(event.eventType).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          event.eventType,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: _getEventTypeColor(event.eventType),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                16.height,

                // Coaches Card
                Container(
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
                        "Assigned Coaches",
                        style: GoogleFonts.montserrat(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      12.height,
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: event.coachIds.map((coachId) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              "Coach #$coachId",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: AppColors.info,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                16.height,

                // Additional Info Card
                Container(
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
                        "Additional Information",
                        style: GoogleFonts.montserrat(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      12.height,
                      _buildInfoRow("Created By", event.createdByUsername),
                      _buildInfoRow("Club", widget.clubName),
                      if (event.createdAt != null)
                        _buildInfoRow("Created At", _formatDateTime(event.createdAt!)),
                    ],
                  ),
                ),

                24.height,

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.group_add,
                        label: "Assign Members",
                        color: accentGreen,
                        onTap: () => toast("Assign members to event"),
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.qr_code_scanner,
                        label: "Take Attendance",
                        color: AppColors.orange,
                        onTap: () => toast("Take attendance for event"),
                      ),
                    ),
                  ],
                ),
                12.height,
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.share,
                        label: "Share Event",
                        color: AppColors.info,
                        onTap: () => toast("Share event details"),
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.download,
                        label: "Export",
                        color: AppColors.warning,
                        onTap: () => toast("Export event data"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(
            ":",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
          8.width,
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventStatusChip(String status) {
    Color color;
    switch (status) {
      case 'SCHEDULED':
        color = Colors.blue;
        break;
      case 'ONGOING':
        color = Colors.green;
        break;
      case 'COMPLETED':
        color = Colors.grey;
        break;
      case 'CANCELLED':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
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
                fontSize: 11.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEventTypeColor(String eventType) {
    switch (eventType) {
      case 'TOURNAMENT':
        return Colors.purple;
      case 'SINGLE_EVENT':
        return Colors.blue;
      case 'PRACTICE':
        return Colors.green;
      case 'MATCH':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatEventDate(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)} ${date.year}";
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : hour;
      return '$displayHour:$minute $period';
    } catch (e) {
      return time.substring(0, 5);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  void _navigateToEditEvent() {
    // Navigate to edit event screen
    toast("Edit event feature coming soon");
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Event"),
        content: Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          // TextButton(
          //   onPressed: () async {
          //     Navigator.pop(context);
          //     final success = await _apiService.deleteEvent(widget.clubId, widget.eventId);
          //     if (success) {
          //       toast("Event deleted successfully");
          //       Navigator.pop(context, true);
          //     } else {
          //       toast("Failed to delete event");
          //     }
          //   },
          //   style: TextButton.styleFrom(foregroundColor: Colors.red),
          //   child: Text("Delete"),
          // ),
        ],
      ),
    );
  }
}