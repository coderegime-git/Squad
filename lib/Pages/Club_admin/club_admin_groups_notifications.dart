// /// screens/clubadmin/clubadmin_groups.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:nb_utils/nb_utils.dart';
//
// import '../../config/colors.dart';
//
// class ClubAdminGroupsScreen extends StatefulWidget {
//   const ClubAdminGroupsScreen({super.key});
//
//   @override
//   State<ClubAdminGroupsScreen> createState() => _ClubAdminGroupsScreenState();
// }
//
// class _ClubAdminGroupsScreenState extends State<ClubAdminGroupsScreen> {
//   late Future<List<ActivityGroup>> _groupsFuture;
//   String _activeFilter = 'All';
//   final List<String> _filters = ['All', 'Football', 'Swimming', 'Cricket', 'Basketball'];
//
//   @override
//   void initState() {
//     super.initState();
//     _groupsFuture = _fetchGroups();
//   }
//
//   Future<List<ActivityGroup>> _fetchGroups() async {
//     await Future.delayed(const Duration(milliseconds: 800));
//     return [
//       ActivityGroup('1', 'Under-14 A', 'Football', 'Coach Raj', 18, ['Team Alpha', 'Team Beta']),
//       ActivityGroup('2', 'Under-16', 'Football', 'Coach Michael', 22, ['Main Squad', 'Reserve Squad']),
//       ActivityGroup('3', 'Intermediate', 'Swimming', 'Coach Sarah', 15, ['Squad A', 'Squad B']),
//       ActivityGroup('4', 'Advanced', 'Swimming', 'Coach Sarah', 12, ['Squad A']),
//       ActivityGroup('5', 'Under-16', 'Cricket', 'Coach Arun', 20, ['Batting XI', 'Bowling XI']),
//     ];
//   }
//
//   static const Map<String, Color> _activityColors = {
//     'Football': accentGreen,
//     'Swimming': Colors.blue,
//     'Cricket': accentOrange,
//     'Basketball': Colors.deepOrange,
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: Colors.white,
//         statusBarIconBrightness: Brightness.light,
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.grey.shade50,
//         body: Column(
//           children: [
//             Container(
//               height: 85.h,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(16),
//                   bottomRight: Radius.circular(16),
//                 ),
//               ),
//               child: SafeArea(
//                 child: Padding(
//                   padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Groups & Sub-groups',
//                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                           color: Colors.white,
//                           fontSize: 20.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 55.h,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//                 itemCount: _filters.length,
//                 itemBuilder: (_, i) {
//                   final selected = _activeFilter == _filters[i];
//                   return GestureDetector(
//                     onTap: () => setState(() => _activeFilter = _filters[i]),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       margin: EdgeInsets.only(right: 10.w),
//                       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                       decoration: BoxDecoration(
//                         color: selected ? accentGreen.withOpacity(0.12) : Colors.white,
//                         borderRadius: BorderRadius.circular(20.r),
//                         border: Border.all(
//                           color: selected ? accentGreen : Colors.grey.shade300,
//                           width: 1.2,
//                         ),
//                       ),
//                       child: Text(
//                         _filters[i],
//                         style: GoogleFonts.poppins(
//                           fontSize: 12.5.sp,
//                           color: selected ? accentGreen : textSecondary,
//                           fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//             // ── Groups List ─────────────────────────────────────────────
//             Expanded(
//               child: FutureBuilder<List<ActivityGroup>>(
//                 future: _groupsFuture,
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   final all = snapshot.data!;
//                   final filtered = _activeFilter == 'All'
//                       ? all
//                       : all.where((g) => g.activity == _activeFilter).toList();
//
//                   return RefreshIndicator(
//                     onRefresh: () async => setState(() => _groupsFuture = _fetchGroups()),
//                     color: accentGreen,
//                     child: ListView.separated(
//                       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//                       itemCount: filtered.length,
//                       separatorBuilder: (_, __) => 12.height,
//                       itemBuilder: (_, i) => _groupCard(filtered[i]),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton.extended(
//           onPressed: () => _createGroupSheet(context),
//           backgroundColor: accentGreen,
//           icon: const Icon(Icons.add_rounded, color: Colors.white),
//           label: Text(
//             'Create Group',
//             style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _groupCard(ActivityGroup g) {
//     final color = _activityColors[g.activity] ?? accentGreen;
//
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(10.w),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 child: Icon(Icons.group_work_rounded, color: color, size: 24.sp),
//               ),
//               12.width,
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       g.name,
//                       style: GoogleFonts.montserrat(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     4.height,
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//                       decoration: BoxDecoration(
//                         color: color.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(16.r),
//                       ),
//                       child: Text(
//                         g.activity,
//                         style: GoogleFonts.poppins(
//                           fontSize: 11.sp,
//                           color: color,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               PopupMenuButton(
//                 color: Colors.white,
//                 icon: Icon(Icons.more_vert_rounded, color: textSecondary, size: 20.sp),
//                 itemBuilder: (_) => [
//                   PopupMenuItem(child: Text('Edit', style: GoogleFonts.poppins()), onTap: () => toast('Edit group')),
//                   PopupMenuItem(child: Text('Add Sub-group', style: GoogleFonts.poppins()), onTap: () => _addSubGroupSheet(context, g)),
//                   PopupMenuItem(child: Text('View Members', style: GoogleFonts.poppins()), onTap: () => toast('View members')),
//                   PopupMenuItem(
//                     child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
//                     onTap: () => toast('Delete group'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           14.height,
//           Row(
//             children: [
//               _chip(Icons.person_rounded, '${g.memberCount} members', Colors.grey.shade700),
//               12.width,
//               _chip(Icons.sports_rounded, g.coach, Colors.grey.shade700),
//             ],
//           ),
//           16.height,
//           Text(
//             'Sub-groups',
//             style: GoogleFonts.poppins(
//               fontSize: 12.sp,
//               color: textSecondary,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           8.height,
//           Wrap(
//             spacing: 8.w,
//             runSpacing: 8.h,
//             children: g.subGroups
//                 .map((s) => Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//               child: Text(
//                 s,
//                 style: GoogleFonts.poppins(
//                   fontSize: 11.5.sp,
//                   color: Colors.black87,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ))
//                 .toList(),
//           ),
//         ],
//       ),
//     );
//   }
//   void _addSubGroupSheet(BuildContext context, ActivityGroup g) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: cardDark,
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
//       builder: (_) => Padding(
//         padding:
//         EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//         child: Padding(
//           padding: EdgeInsets.all(20.w),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                     width: 40.w,
//                     height: 4.h,
//                     decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(2.r))),
//               ),
//               16.height,
//               Text('Add Sub-group to ${g.name}',
//                   style: GoogleFonts.montserrat(
//                       fontSize: 16.sp, fontWeight: FontWeight.bold)),
//               20.height,
//               _inputField('Sub-group Name (e.g., Team C)'),
//               20.height,
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     toast('Sub-group added!', bgColor: accentGreen);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: accentGreen,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     padding: EdgeInsets.symmetric(vertical: 15.h),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14.r)),
//                   ),
//                   child: Text('Add Sub-group',
//                       style: GoogleFonts.poppins(
//                           fontSize: 14.sp, fontWeight: FontWeight.w700)),
//                 ),
//               ),
//               20.height,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//   Widget _chip(IconData icon, String label, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(20.r),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: color, size: 14.sp),
//           6.width,
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 11.5.sp,
//               color: color,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // _createGroupSheet and _addSubGroupSheet remain the same
//   // ... (you can keep your existing bottom sheet code)
//   void _createGroupSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: cardDark,
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
//       builder: (_) => Padding(
//         padding:
//         EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                     width: 40.w,
//                     height: 4.h,
//                     decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(2.r))),
//               ),
//               16.height,
//               Text('Create New Group',
//                   style: GoogleFonts.montserrat(
//                       fontSize: 18.sp, fontWeight: FontWeight.bold)),
//               20.height,
//               _inputField('Group Name (e.g., Under-14 A)'),
//               12.height,
//               _dropField('Activity', ['Football', 'Swimming', 'Cricket', 'Basketball']),
//               12.height,
//               _dropField('Assign Coach', ['Coach Raj', 'Coach Michael', 'Coach Sarah']),
//               12.height,
//               _inputField('Sub-group names (comma separated)'),
//               20.height,
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     toast('Group created successfully!', bgColor: accentGreen);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: accentGreen,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     padding: EdgeInsets.symmetric(vertical: 15.h),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14.r)),
//                   ),
//                   child: Text('Create Group',
//                       style: GoogleFonts.poppins(
//                           fontSize: 14.sp, fontWeight: FontWeight.w700)),
//                 ),
//               ),
//               20.height,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//   Widget _inputField(String hint) => TextField(
//     style: GoogleFonts.poppins(fontSize: 13.sp),
//     decoration: InputDecoration(
//       hintText: hint,
//       hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary.withOpacity(0.6)),
//       filled: true,
//       fillColor: Colors.grey.shade50,
//       contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12.r),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12.r),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12.r),
//         borderSide: BorderSide(color: accentGreen, width: 1.5),
//       ),
//     ),
//   );
//
//   Widget _dropField(String label, List<String> items) => DropdownButtonFormField<String>(
//     decoration: InputDecoration(
//       labelText: label,
//       labelStyle: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
//       filled: true,
//       fillColor: Colors.grey.shade50,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12.r),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12.r),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12.r),
//         borderSide: BorderSide(color: accentGreen, width: 1.5),
//       ),
//     ),
//     style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
//     items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
//     onChanged: (_) {},
//   );
// }
//
// class ActivityGroup {
//   final String id, name, activity, coach;
//   final int memberCount;
//   final List<String> subGroups;
//
//   ActivityGroup(this.id, this.name, this.activity, this.coach, this.memberCount, this.subGroups);
// }
//
//
// class ClubAdminNotificationsScreen extends StatefulWidget {
//   const ClubAdminNotificationsScreen({super.key});
//
//   @override
//   State<ClubAdminNotificationsScreen> createState() => _ClubAdminNotificationsScreenState();
// }
//
// class _ClubAdminNotificationsScreenState extends State<ClubAdminNotificationsScreen> {
//   late Future<List<AdminNotification>> _notificationsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _notificationsFuture = _fetchNotifications();
//   }
//
//   Future<List<AdminNotification>> _fetchNotifications() async {
//     await Future.delayed(const Duration(milliseconds: 600));
//     return [
//       AdminNotification(
//         id: '1',
//         title: 'Payment Reminder Sent',
//         subtitle: '12 members were reminded about pending payments',
//         timestamp: DateTime.now().subtract(const Duration(hours: 1)),
//         type: NotificationType.payment,
//         isRead: false,
//       ),
//       AdminNotification(
//         id: '2',
//         title: 'New Guardian Request',
//         subtitle: 'Rajesh Sharma requested guardian access',
//         timestamp: DateTime.now().subtract(const Duration(hours: 3)),
//         type: NotificationType.request,
//         isRead: false,
//       ),
//       AdminNotification(
//         id: '3',
//         title: 'Event Created',
//         subtitle: 'Weekend tournament scheduled for all groups',
//         timestamp: DateTime.now().subtract(const Duration(days: 1)),
//         type: NotificationType.event,
//         isRead: true,
//       ),
//       AdminNotification(
//         id: '4',
//         title: 'Member Payment Received',
//         subtitle: 'Abinesh Kumar - ₹2500 for Feb-Apr 2026',
//         timestamp: DateTime.now().subtract(const Duration(days: 2)),
//         type: NotificationType.payment,
//         isRead: true,
//       ),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: Colors.white,
//         statusBarIconBrightness: Brightness.light,
//         statusBarBrightness: Brightness.dark,
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.grey.shade100,
//         body: Column(
//           children: [
//             // Header
//             Container(
//               height: 85.h,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(16),
//                   bottomRight: Radius.circular(16),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.25),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: SafeArea(
//                 child: Padding(
//                   padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Notifications",
//                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                           color: Colors.white,
//                           fontSize: 20.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const Spacer(),
//                       TextButton(
//                         onPressed: () => toast("Mark all as read"),
//                         child: Text(
//                           "Mark all read",
//                           style: GoogleFonts.poppins(
//                             color: accentGreen,
//                             fontSize: 12.sp,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // Notifications List
//             Expanded(
//               child: FutureBuilder<List<AdminNotification>>(
//                 future: _notificationsFuture,
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   final notifications = snapshot.data!;
//
//                   return RefreshIndicator(
//                     onRefresh: () async {
//                       setState(() => _notificationsFuture = _fetchNotifications());
//                     },
//                     color: accentGreen,
//                     child: ListView.builder(
//                       padding: EdgeInsets.all(20.w),
//                       itemCount: notifications.length,
//                       itemBuilder: (context, index) {
//                         return _NotificationCard(notification: notifications[index]);
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Notification Card Widget
// class _NotificationCard extends StatelessWidget {
//   final AdminNotification notification;
//
//   const _NotificationCard({required this.notification});
//
//   @override
//   Widget build(BuildContext context) {
//     Color iconColor;
//     IconData iconData;
//
//     switch (notification.type) {
//       case NotificationType.payment:
//         iconColor = accentOrange;
//         iconData = Icons.payment_rounded;
//         break;
//       case NotificationType.request:
//         iconColor = accentGreen;
//         iconData = Icons.person_add_rounded;
//         break;
//       case NotificationType.event:
//         iconColor = Colors.purple;
//         iconData = Icons.event_rounded;
//         break;
//       case NotificationType.system:
//         iconColor = Colors.blue;
//         iconData = Icons.info_rounded;
//         break;
//     }
//
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: notification.isRead ? cardDark : accentGreen.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: notification.isRead ? Colors.grey.shade300 : accentGreen.withOpacity(0.3),
//         ),
//       ),
//       child: Row(
//         children: [
//           if (!notification.isRead)
//             Container(
//               width: 8.r,
//               height: 8.r,
//               decoration: BoxDecoration(
//                 color: accentGreen,
//                 shape: BoxShape.circle,
//               ),
//               margin: EdgeInsets.only(right: 12.w),
//             ),
//           Container(
//             padding: EdgeInsets.all(12.w),
//             decoration: BoxDecoration(
//               color: iconColor.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: Icon(iconData, color: iconColor, size: 24.sp),
//           ),
//           16.width,
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   notification.title,
//                   style: GoogleFonts.montserrat(
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black,
//                   ),
//                 ),
//                 4.height,
//                 Text(
//                   notification.subtitle,
//                   style: GoogleFonts.poppins(
//                     fontSize: 12.sp,
//                     color: textSecondary,
//                   ),
//                 ),
//                 4.height,
//                 Text(
//                   _formatTimestamp(notification.timestamp),
//                   style: GoogleFonts.poppins(
//                     fontSize: 10.sp,
//                     color: textSecondary.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatTimestamp(DateTime timestamp) {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);
//
//     if (difference.inHours < 1) {
//       return "${difference.inMinutes}m ago";
//     } else if (difference.inHours < 24) {
//       return "${difference.inHours}h ago";
//     } else {
//       return "${difference.inDays}d ago";
//     }
//   }
// }
//
// // Models
// class AdminNotification {
//   final String id;
//   final String title;
//   final String subtitle;
//   final DateTime timestamp;
//   final NotificationType type;
//   final bool isRead;
//
//   AdminNotification({
//     required this.id,
//     required this.title,
//     required this.subtitle,
//     required this.timestamp,
//     required this.type,
//     required this.isRead,
//   });
// }
//
// enum NotificationType { payment, request, event, system }
// screens/clubadmin/club_admin_groups_notifications.dart
// NOTE: This file contains ClubAdminGroupsScreen + ClubAdminNotificationsScreen
// ClubAdminGroupsScreen now shows all events with group count summary
// Tap any event → navigates to EventGroupsScreen

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_event_details.dart';
import '../../model/clubAdmin/get_groups.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';
import 'event_groups.dart';

// ══════════════════════════════════════════════════════════════════════════════
// GROUPS TAB — Shows all events with group count summary
// ══════════════════════════════════════════════════════════════════════════════

class ClubAdminGroupsScreen extends StatefulWidget {
  const ClubAdminGroupsScreen({super.key});

  @override
  State<ClubAdminGroupsScreen> createState() => _ClubAdminGroupsScreenState();
}

class _ClubAdminGroupsScreenState extends State<ClubAdminGroupsScreen> {
  final ClubApiService _apiService = ClubApiService();
  late Future<List<_EventWithGroups>> _eventsFuture;

  String _activeFilter = 'All';
  final List<String> _filters = ['All', 'SCHEDULED', 'ONGOING', 'COMPLETED'];

  @override
  void initState() {
    super.initState();
    _eventsFuture = _fetchEventsWithGroups();
  }

  Future<List<_EventWithGroups>> _fetchEventsWithGroups() async {
    final eventsResult = await _apiService.getEvents();
    final events = eventsResult.data;

    final groupResults = await Future.wait(
      events.map((event) async {
        try {
          final groupsResult = await _apiService.getGroupsByEvent(event.eventId);
          return _EventWithGroups(
            event: event,
            groupCount: groupsResult.data.length,
            groups: groupsResult.data,
          );
        } catch (_) {
          return _EventWithGroups(
            event: event,
            groupCount: 0,
            groups: [],
          );
        }
      }),
    );

    return groupResults;
  }

  void _refresh() =>
      setState(() => _eventsFuture = _fetchEventsWithGroups());

  List<_EventWithGroups> _applyFilter(List<_EventWithGroups> all) {
    if (_activeFilter == 'All') return all;
    return all
        .where((e) => e.event.status == _activeFilter)
        .toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'ONGOING':
        return accentGreen;
      case 'COMPLETED':
        return Colors.grey;
      case 'CANCELLED':
        return Colors.red;
      default:
        return accentOrange;
    }
  }

  Color _eventTypeColor(String type) {
    return type == 'SINGLE_EVENT' ? Colors.purple : accentOrange;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              height: 85.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                  EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Events & Groups',
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
                      GestureDetector(
                        onTap: _refresh,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: accentGreen.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.refresh_rounded,
                              color: accentGreen, size: 20.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Filter Chips ─────────────────────────────────────────────
            SizedBox(
              height: 55.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                itemCount: _filters.length,
                itemBuilder: (_, i) {
                  final selected = _activeFilter == _filters[i];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _activeFilter = _filters[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: 10.w),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? accentGreen.withOpacity(0.12)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: selected
                              ? accentGreen
                              : Colors.grey.shade300,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        _filters[i],
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: selected ? accentGreen : textSecondary,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Events List ──────────────────────────────────────────────
            Expanded(
              child: FutureBuilder<List<_EventWithGroups>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                              color: accentGreen),
                          16.height,
                          Text('Loading events & groups...',
                              style: GoogleFonts.poppins(
                                  fontSize: 13.sp, color: textSecondary)),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 52.sp, color: Colors.red.shade300),
                          16.height,
                          Text('Failed to load events',
                              style: GoogleFonts.poppins(
                                  fontSize: 14.sp, color: textSecondary)),
                          16.height,
                          ElevatedButton(
                            onPressed: _refresh,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: accentGreen,
                                foregroundColor: Colors.white),
                            child: Text('Retry',
                                style: GoogleFonts.poppins()),
                          ),
                        ],
                      ),
                    );
                  }

                  final all = snapshot.data ?? [];
                  final filtered = _applyFilter(all);

                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async => _refresh(),
                      color: accentGreen,
                      child: ListView(
                        children: [
                          SizedBox(height: 100.h),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.event_busy_rounded,
                                    size: 60.sp,
                                    color: Colors.grey.shade400),
                                16.height,
                                Text('No events found',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade500)),
                                8.height,
                                Text(
                                    'Create events from the Schedule tab',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    color: accentGreen,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => 12.height,
                      itemBuilder: (_, i) => _eventGroupCard(filtered[i]),
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

  // ── Event + Group Summary Card ─────────────────────────────────────────────
  Widget _eventGroupCard(_EventWithGroups eg) {
    final statusColor = _statusColor(eg.event.status);
    final typeColor = _eventTypeColor(eg.event.eventType);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventGroupsScreen(event: eg.event),
          ),
        ).then((_) => _refresh()); // refresh when coming back
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row: Event name + status ───────────────────────────
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.event_rounded,
                      color: accentGreen, size: 22.sp),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eg.event.eventName,
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.height,
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              eg.event.status,
                              style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          8.width,
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              eg.event.eventType
                                  .replaceAll('_', ' '),
                              style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  color: typeColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: textSecondary, size: 22.sp),
              ],
            ),

            14.height,

            // ── Date + Location ────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 13.sp, color: textSecondary),
                6.width,
                Text(
                  eg.event.eventDate,
                  style: GoogleFonts.poppins(
                      fontSize: 11.sp, color: textSecondary),
                ),
                16.width,
                Icon(Icons.location_on_rounded,
                    size: 13.sp, color: textSecondary),
                4.width,
                Expanded(
                  child: Text(
                    eg.event.location,
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp, color: textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            14.height,

            // ── Group Summary ──────────────────────────────────────────
            Container(
              padding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Group count
                  _summaryItem(
                    Icons.group_work_rounded,
                    '${eg.groupCount}',
                    'Groups',
                    accentGreen,
                  ),
                  _divider(),
                  // Groups listed (up to 3)
                  Expanded(
                    child: eg.groups.isEmpty
                        ? Row(
                      children: [
                        Icon(Icons.add_circle_outline_rounded,
                            size: 14.sp, color: textSecondary),
                        6.width,
                        SizedBox(
                          width: 100.w,
                          child: Text(
                            'No groups yet — Tap to add',
                            style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: textSecondary,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    )
                        : Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        ...eg.groups.take(3).map(
                              (g) => Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color:
                              accentGreen.withOpacity(0.08),
                              borderRadius:
                              BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              g.name,
                              style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  color: accentGreen,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        if (eg.groups.length > 3)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color:
                              Colors.grey.withOpacity(0.12),
                              borderRadius:
                              BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              '+${eg.groups.length - 3} more',
                              style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            12.height,

            // ── Manage Button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EventGroupsScreen(event: eg.event),
                    ),
                  ).then((_) => _refresh());
                },
                icon: Icon(Icons.group_work_rounded,
                    size: 16.sp, color: accentGreen),
                label: Text(
                  eg.groupCount == 0
                      ? 'Create First Group'
                      : 'Manage Groups & Sub-groups',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: accentGreen,
                      fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: accentGreen.withOpacity(0.5)),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(
      IconData icon, String value, String label, Color color) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 14.sp),
          ),
          8.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 9.sp, color: textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 30.h,
    color: Colors.grey.shade300,
    margin: EdgeInsets.only(right: 12.w),
  );
}

// ── Internal model ─────────────────────────────────────────────────────────
class _EventWithGroups {
  final Data event;
  final int groupCount;
  final List<GroupData> groups;

  _EventWithGroups({
    required this.event,
    required this.groupCount,
    required this.groups,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS SCREEN — unchanged
// ══════════════════════════════════════════════════════════════════════════════

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