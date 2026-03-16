// lib/pages/guardian/guardian_notifications.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/colors.dart';

class GuardianNotificationsScreen extends StatefulWidget {
  const GuardianNotificationsScreen({super.key});

  @override
  State<GuardianNotificationsScreen> createState() => _GuardianNotificationsScreenState();
}

class _GuardianNotificationsScreenState extends State<GuardianNotificationsScreen> {
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
  }

  Future<List<NotificationModel>> _fetchNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      NotificationModel(title: "Match Invite", message: "Your child is invited to Saturday tournament", time: "10 min ago", isRead: false, type: "event"),
      NotificationModel(title: "Performance Update", message: "Coach added new note for Gopal", time: "2h ago", isRead: true, type: "performance"),
      NotificationModel(title: "Group Announcement", message: "New training schedule updated", time: "3d ago", isRead: true, type: "group"),
      NotificationModel(
        title: "Performance Update",
        message: "Coach Ram added a new feedback note for Gopal: 'Improved passing accuracy – keep it up!' View full report.",
        time: "2h ago",
        isRead: true,
        type: "performance",
      ),
      NotificationModel(
        title: "Match Invite",
        message: "Your child (Abinesh) has been invited to the U-14 Inter-Club Tournament this Saturday at 3:00 PM. Please confirm availability soon.",
        time: "10 min ago",
        isRead: false,
        type: "event",
      ),

    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Container(
            height: 80.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.92),
              border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.08))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Notifications", style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold, color: accentGreen)),
                // TextButton(
                //   onPressed: () => toast("Marked all as read"),
                //   child: Text("Mark all read", style: GoogleFonts.poppins(color: accentGreen, fontSize: 14.sp)),
                // ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<NotificationModel>>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: 6,
                    itemBuilder: (_, __) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[850]!,
                        highlightColor: Colors.grey[700]!,
                        child: Container(height: 90.h, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16.r))),
                      ),
                    ),
                  );
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_rounded, size: 80.sp, color: Colors.grey[600]),
                        16.height,
                        Text("No new notifications", style: GoogleFonts.poppins(fontSize: 18.sp, color: textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    return _NotificationCard(notification: n);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
       // border: Border.all(color: notification.isRead ? Colors.transparent : accentGreen.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.normal, color: Colors.black)),
                4.height,
                Text(notification.message, style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary)),
                8.height,
                Text(notification.time, style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.deepOrangeAccent,fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              width: 10.r,
              height: 10.r,
              decoration: BoxDecoration(color: accentGreen, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case "event": return accentGreen;
      case "performance": return Colors.blue;
      case "payment": return accentOrange;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case "event": return Icons.event_rounded;
      case "performance": return Icons.trending_up_rounded;
      case "payment": return Icons.payment_rounded;
      default: return Icons.notifications_rounded;
    }
  }
}

class NotificationModel {
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final String type;

  NotificationModel({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });
}