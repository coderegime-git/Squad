// screens/clubadmin/clubadmin_activities.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sports/config/constant.dart';
import 'package:sports/model/clubAdmin/activities_data.dart';
import 'package:sports/model/clubAdmin/activity_mapped_event_data.dart';
import 'package:sports/utills/api_service.dart';

import '../../config/colors.dart';
import '../../utills/shared_preference.dart';
import 'add_activity_screen.dart';

class ClubAdminActivitiesScreen extends StatefulWidget {
  final bool? fromMap;
  final String? eventId;

  const ClubAdminActivitiesScreen({super.key, this.fromMap, this.eventId});

  @override
  State<ClubAdminActivitiesScreen> createState() =>
      _ClubAdminActivitiesScreenState();
}

class _ClubAdminActivitiesScreenState extends State<ClubAdminActivitiesScreen> {
  late Future<List<ActivityListData>> _activitiesFuture;
  final apiService = ClubApiService();
  late ActivityMappedEventData activityMappedEventData;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _fetchActivities();
  }

  Future<List<ActivityListData>> _fetchActivities() async {
    final clubId = SharedPreferenceHelper.getClubId();
    return await apiService.getActivities(clubId ?? "");
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
            // Header
            Container(
              height: widget.fromMap == true ? 50.h : 75.h,
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
                  padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                      16.width,
                      Text(
                        'Manage Activities',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                          color: Colors.white,
                          fontSize: widget.fromMap == true ? 14.sp : 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: FutureBuilder<List<ActivityListData>>(
                future: _activitiesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Loader());
                  }

                  final activities = snapshot.data!;

                  return RefreshIndicator(
                    onRefresh: () async {
                      final data = await _fetchActivities();

                      setState(() {
                        _activitiesFuture = Future.value(data);
                      });
                    },
                    color: accentGreen,
                    child: ListView.builder(
                      padding: EdgeInsets.all(20.w),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            if (widget.fromMap != true) return;

                            showDialog(
                              context: context,
                              barrierDismissible: false,

                              builder: (_) =>
                                  AlertDialog(
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    content: const Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ),
                            );

                            final res = await apiService.getMapActivitiesEvents(
                              activities[index].activityId.toString(),
                            );

                            Navigator.pop(context); // close loader

                            bool isAlreadyMapped = res.data!.any(
                                  (e) => e.eventId.toString() == widget.eventId,
                            );

                            // ✅ If already mapped → simple dialog
                            if (isAlreadyMapped) {
                              toast(
                                'Activity already mapped',
                                bgColor: Colors.orange,
                              );
                              return;
                            }

                            // ✅ If NOT mapped → show confirm dialog
                            showDialog(
                              context: context,
                              builder: (_) {
                                bool isLoad = false;

                                return StatefulBuilder(
                                  builder: (context, setStateDialog) {
                                    return AlertDialog(
                                      backgroundColor: cardDark,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      title: Text(
                                        'Map Activity',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to Map "${activities[index]
                                            .name}"?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.sp,
                                          color: textSecondary,
                                        ),
                                      ),
                                      actions: isLoad
                                          ? [
                                        const Center(
                                          child:
                                          CircularProgressIndicator(),
                                        ),
                                      ]
                                          : [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.poppins(
                                              color: textSecondary,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            setStateDialog(
                                                  () => isLoad = true,
                                            );

                                            final data = await apiService
                                                .mapActivitiesEvents(
                                              activities[index]
                                                  .activityId
                                                  .toString(),
                                              widget.eventId ?? "",
                                            );

                                            if (data['success']) {
                                              toast(
                                                'Activity Mapped successfully',
                                                bgColor: Colors.green,
                                              );
                                              Navigator.pop(context);
                                            } else {
                                              toast(
                                                'Failed to map',
                                                bgColor: Colors.red,
                                              );
                                              setStateDialog(
                                                    () => isLoad = false,
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                12.r,
                                              ),
                                            ),
                                          ),
                                          child: isLoad
                                              ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child:
                                            CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color:
                                              Colors.white,
                                            ),
                                          )
                                              : Text(
                                            'Yes',
                                            style:
                                            GoogleFonts.poppins(
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: _ActivityCard(
                            activity: activities[index],
                            onEdit: () => _showEditDialog(activities[index]),
                            onDelete: () =>
                                _showDeleteDialog(activities[index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddActivityDialog,
          backgroundColor: accentGreen,
          icon: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
          label: Text(
            'Add Activity',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  void _showAddActivityDialog() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActivityCreationPage()),
    );
    final data = await _fetchActivities();

    setState(() {
      _activitiesFuture = Future.value(data);
    });
  }

  void _showEditDialog(ActivityListData activity) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ActivityCreationPage(
              activityListData: activity,
              id: activity.activityId,
            ),
      ),
    );
    final data = await _fetchActivities();

    setState(() {
      _activitiesFuture = Future.value(data);
    });
  }

  bool isLoad = false;

  void _showDeleteDialog(ActivityListData activity) {
    showDialog(
      context: context,
      builder: (_) {
        bool isLoad = false; // local state

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: cardDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Text(
                'Delete Activity?',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to delete "${activity.name}"?',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: textSecondary,
                ),
              ),
              actions: isLoad
                  ? [Center(child: CircularProgressIndicator())]
                  : [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setStateDialog(() {
                      isLoad = true;
                    });

                    final data = await apiService.deleteActivities(
                      activity.activityId.toString(),
                    );

                    if (data['success']) {
                      toast(
                        'Activity deleted successfully',
                        bgColor: Colors.green,
                      );

                      final activities = await _fetchActivities();

                      setState(() {
                        _activitiesFuture = Future.value(activities);
                      });

                      Navigator.pop(context);
                    } else {
                      toast('Failed to delete', bgColor: Colors.red);

                      setStateDialog(() {
                        isLoad = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: isLoad
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'Delete',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// Activity Card Widget
class _ActivityCard extends StatelessWidget {
  final ActivityListData activity;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActivityCard({
    required this.activity,
    required this.onEdit,
    required this.onDelete,
  });

  String formatDateTime(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);

    String formatted = DateFormat('EEE dd yyyy hh:mm a').format(dateTime);

    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    print(activity.status);
    print(activity.startDateTime);
    final startTime = formatDateTime(activity.startDateTime ?? "");
    final endTime = formatDateTime(activity.endDateTime ?? "");
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: activity.status == "ACTIVE" ? Colors.green : Colors.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name ?? "",
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    6.height,
                    Row(
                      children: [
                        Icon(
                          Icons.group_work,
                          size: 14.sp,
                          color: textSecondary,
                        ),
                        4.width,
                        Text(
                          activity.activityType ?? "",
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: textSecondary,
                          ),
                        ),
                        Spacer(),
                        Text(
                          activity.status ?? "",
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: activity.status == "ACTIVE"
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    12.height,
                    Text(
                      "$startTime - $endTime",
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                color: Colors.white,
                icon: Icon(Icons.more_vert_rounded, color: textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                itemBuilder: (_) =>
                [
                  PopupMenuItem(
                    onTap: onEdit,
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 18.sp,
                          color: Colors.black87,
                        ),
                        12.width,
                        Text('Edit', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                  // PopupMenuItem(
                  //   onTap: () => toast('View details'),
                  //   child: Row(
                  //     children: [
                  //       Icon(
                  //         Icons.info_rounded,
                  //         size: 18.sp,
                  //         color: Colors.black87,
                  //       ),
                  //       12.width,
                  //       Text('View Details', style: GoogleFonts.poppins()),
                  //     ],
                  //   ),
                  // ),
                  PopupMenuItem(
                    onTap: onDelete,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_rounded,
                          size: 18.sp,
                          color: Colors.red,
                        ),
                        12.width,
                        Text(
                          'Delete',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Row(
          //   children: [
          //     _infoChip(
          //       Icons.sports_rounded,
          //       '${activity.createdRole} coaches',
          //       Colors.blue,
          //     ),
          //     10.width,
          //     _infoChip(Icons.trending_up_rounded, 'Active', accentGreen),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13.sp),
          6.width,
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Model
class Activity {
  final String id;
  final String name;
  final IconData icon;
  final int memberCount;
  final int groupCount;
  final int coachCount;
  final Color color;

  Activity({
    required this.id,
    required this.name,
    required this.icon,
    required this.memberCount,
    required this.groupCount,
    required this.coachCount,
    required this.color,
  });
}
