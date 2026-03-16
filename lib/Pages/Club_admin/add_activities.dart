// screens/clubadmin/clubadmin_activities.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';

class ClubAdminActivitiesScreen extends StatefulWidget {
  const ClubAdminActivitiesScreen({super.key});

  @override
  State<ClubAdminActivitiesScreen> createState() =>
      _ClubAdminActivitiesScreenState();
}

class _ClubAdminActivitiesScreenState extends State<ClubAdminActivitiesScreen> {
  late Future<List<Activity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _fetchActivities();
  }

  Future<List<Activity>> _fetchActivities() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      Activity(
        id: '1',
        name: 'Football',
        icon: Icons.sports_soccer_rounded,
        memberCount: 85,
        groupCount: 6,
        coachCount: 3,
        color: accentGreen,
      ),
      Activity(
        id: '2',
        name: 'Swimming',
        icon: Icons.pool_rounded,
        memberCount: 42,
        groupCount: 4,
        coachCount: 2,
        color: Colors.blue,
      ),
      Activity(
        id: '3',
        name: 'Cricket',
        icon: Icons.sports_cricket_rounded,
        memberCount: 65,
        groupCount: 5,
        coachCount: 2,
        color: accentOrange,
      ),
      Activity(
        id: '4',
        name: 'Basketball',
        icon: Icons.sports_basketball_rounded,
        memberCount: 38,
        groupCount: 3,
        coachCount: 2,
        color: Colors.deepOrange,
      ),
    ];
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
                  padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 20.sp),
                      ),
                      16.width,
                      Text(
                        'Manage Activities',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                          color: Colors.white,
                          fontSize: 20.sp,
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
              child: FutureBuilder<List<Activity>>(
                future: _activitiesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final activities = snapshot.data!;

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() => _activitiesFuture = _fetchActivities());
                    },
                    color: accentGreen,
                    child: ListView.builder(
                      padding: EdgeInsets.all(20.w),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        return _ActivityCard(
                          activity: activities[index],
                          onEdit: () => _showEditDialog(activities[index]),
                          onDelete: () => _showDeleteDialog(activities[index]),
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

  void _showAddActivityDialog() {
    final nameCtrl = TextEditingController();
    String? selectedIcon = 'Football';
    final icons = {
      'Football': Icons.sports_soccer_rounded,
      'Swimming': Icons.pool_rounded,
      'Cricket': Icons.sports_cricket_rounded,
      'Basketball': Icons.sports_basketball_rounded,
      'Tennis': Icons.sports_tennis_rounded,
      'Badminton': Icons.sports_rounded,
    };

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Add New Activity',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Activity Name *',
                  hintText: 'e.g., Volleyball',
                  prefixIcon: Icon(Icons.sports_rounded, color: accentGreen),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: accentGreen, width: 2),
                  ),
                ),
              ),
              16.height,
              DropdownButtonFormField<String>(
                value: selectedIcon,
                decoration: InputDecoration(
                  labelText: 'Select Icon',
                  prefixIcon: Icon(icons[selectedIcon]!, color: accentGreen),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: accentGreen, width: 2),
                  ),
                ),
                items: icons.keys
                    .map((key) => DropdownMenuItem(
                  value: key,
                  child: Row(
                    children: [
                      Icon(icons[key], size: 20.sp),
                      12.width,
                      Text(key),
                    ],
                  ),
                ))
                    .toList(),
                onChanged: (val) => setDialogState(() => selectedIcon = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) {
                  toast('Please enter activity name');
                  return;
                }
                Navigator.pop(ctx);
                toast('✅ Activity "${nameCtrl.text}" added!',
                    bgColor: accentGreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Add',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Activity activity) {
    toast('Edit ${activity.name}');
  }

  void _showDeleteDialog(Activity activity) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Delete Activity?',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${activity.name}"? This will affect ${activity.memberCount} members.',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              toast('Activity deleted', bgColor: Colors.red);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// Activity Card Widget
class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActivityCard({
    required this.activity,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: activity.color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: activity.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(activity.icon, color: activity.color, size: 28.sp),
              ),
              16.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    6.height,
                    Row(
                      children: [
                        Icon(Icons.people_rounded,
                            size: 14.sp, color: textSecondary),
                        4.width,
                        Text(
                          '${activity.memberCount} members',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: textSecondary,
                          ),
                        ),
                        12.width,
                        Icon(Icons.group_work_rounded,
                            size: 14.sp, color: textSecondary),
                        4.width,
                        Text(
                          '${activity.groupCount} groups',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert_rounded, color: textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    onTap: onEdit,
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded,
                            size: 18.sp, color: Colors.black87),
                        12.width,
                        Text('Edit', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () => toast('View details'),
                    child: Row(
                      children: [
                        Icon(Icons.info_rounded,
                            size: 18.sp, color: Colors.black87),
                        12.width,
                        Text('View Details', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: onDelete,
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, size: 18.sp, color: Colors.red),
                        12.width,
                        Text('Delete',
                            style: GoogleFonts.poppins(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          14.height,
          Row(
            children: [
              _infoChip(
                Icons.sports_rounded,
                '${activity.coachCount} coaches',
                Colors.blue,
              ),
              10.width,
              _infoChip(
                Icons.trending_up_rounded,
                'Active',
                accentGreen,
              ),
            ],
          ),
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