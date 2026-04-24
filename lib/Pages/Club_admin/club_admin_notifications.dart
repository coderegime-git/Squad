import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';

class ClubAdminNotificationsScreen extends StatefulWidget {
  const ClubAdminNotificationsScreen({super.key});

  @override
  State<ClubAdminNotificationsScreen> createState() =>
      _ClubAdminNotificationsScreenState();
}

class _ClubAdminNotificationsScreenState
    extends State<ClubAdminNotificationsScreen> {
  late Future<List<AdminNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
  }

  Future<List<AdminNotification>> _fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      AdminNotification(
        id: '1',
        title: 'Payment Reminder Sent',
        subtitle: '12 members were reminded about pending payments',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: NotificationType.payment,
        isRead: false,
      ),
      AdminNotification(
        id: '2',
        title: 'New Guardian Request',
        subtitle: 'Rajesh Sharma requested guardian access',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: NotificationType.request,
        isRead: false,
      ),
      AdminNotification(
        id: '3',
        title: 'Event Created',
        subtitle: 'Weekend tournament scheduled for all groups',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.event,
        isRead: true,
      ),
      AdminNotification(
        id: '4',
        title: 'Member Payment Received',
        subtitle: 'Abinesh Kumar - ₹2500 for Feb-Apr 2026',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.payment,
        isRead: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Container(
              height: 85.h,
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
                  padding:
                  EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Notifications',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => toast('Mark all as read'),
                        child: Text(
                          'Mark all read',
                          style: GoogleFonts.poppins(
                            color: accentGreen,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<AdminNotification>>(
                future: _notificationsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return RefreshIndicator(
                    onRefresh: () async => setState(
                            () => _notificationsFuture = _fetchNotifications()),
                    color: accentGreen,
                    child: ListView.builder(
                      padding: EdgeInsets.all(20.w),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) =>
                          _NotificationCard(notification: snapshot.data![index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AdminNotification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    IconData iconData;

    switch (notification.type) {
      case NotificationType.payment:
        iconColor = accentOrange;
        iconData = Icons.payment_rounded;
        break;
      case NotificationType.request:
        iconColor = accentGreen;
        iconData = Icons.person_add_rounded;
        break;
      case NotificationType.event:
        iconColor = Colors.purple;
        iconData = Icons.event_rounded;
        break;
      case NotificationType.system:
        iconColor = Colors.blue;
        iconData = Icons.info_rounded;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: notification.isRead
            ? cardDark
            : accentGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.shade300
              : accentGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          if (!notification.isRead)
            Container(
              width: 8.r,
              height: 8.r,
              decoration: const BoxDecoration(
                  color: accentGreen, shape: BoxShape.circle),
              margin: EdgeInsets.only(right: 12.w),
            ),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(iconData, color: iconColor, size: 24.sp),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title,
                    style: GoogleFonts.montserrat(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
                4.height,
                Text(notification.subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp, color: textSecondary)),
                4.height,
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: textSecondary.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

class AdminNotification {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  AdminNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
    required this.isRead,
  });
}

enum NotificationType { payment, request, event, system }