// screens/clubadmin/event_groups_screen.dart
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
import 'event_sub_group.dart';

class EventGroupsScreen extends StatefulWidget {
  final Data event;

  const EventGroupsScreen({super.key, required this.event});

  @override
  State<EventGroupsScreen> createState() => _EventGroupsScreenState();
}

class _EventGroupsScreenState extends State<EventGroupsScreen> {
  final ClubApiService _apiService = ClubApiService();
  late Future<List<GroupData>> _groupsFuture;
  final Set<int> _deletingGroupIds = {};
  final ageCategoryCtrl = TextEditingController();

bool load=true;
  @override
  void initState() {
    super.initState();
    _groupsFuture = _fetchGroups();
  }

  Future<List<GroupData>> _fetchGroups() async {
    final result = await _apiService.getGroupsByEvent(widget.event.eventId);
    setState(() {
      load=false;
    });
    return result.data;
  }

   refreshData() {
     final future = _fetchGroups();

     setState(() {
       _groupsFuture = future;
     });  }

  // ── Confirm Delete ─────────────────────────────────────────────────────────
  Future<void> _confirmDeleteGroup(GroupData group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Group',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700, fontSize: 16.sp)),
        content: Text(
          'Are you sure you want to delete "${group.name}"?',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                    color: textSecondary, fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _deletingGroupIds.add(group.groupId));
      final success =
      await _apiService.deleteGroup(widget.event.eventId, group.groupId);
      setState(() => _deletingGroupIds.remove(group.groupId));
      if (success) {
        toast('Group "${group.name}" deleted');
        refreshData();
      } else {
        AppUI.error(context, 'Failed to delete group. Try again.');
      }
    }
  }
  void _showCreateGroupSheet() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r)),
                ),
              ),
              16.height,
              Text('Create Group',
                  style: GoogleFonts.montserrat(
                      fontSize: 18.sp, fontWeight: FontWeight.bold)),
              6.height,
              Text('Event: ${widget.event.eventName}',
                  style:
                  GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)),
              20.height,
              _sheetField('Group Name *', nameCtrl, Icons.group_rounded,
                  hint: 'e.g., Under 14'),
              12.height,
              // _sheetField('Description (optional)', descCtrl,
              //     Icons.description_rounded,
              //     hint: 'e.g., Group for U14 category',
              //     required: false,
              //     maxLines: 2),
              _sheetField('Age Category *', ageCategoryCtrl, Icons.cake_rounded,
                  hint: 'e.g., U14, U16, Senior'),
              20.height,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (nameCtrl.text.trim().isEmpty) {
                      toast('Please enter group name');
                      return;
                    }
                    setSheet(() => isLoading = true);
                    final success = await _apiService.createGroup(
                      widget.event.eventId,
                        {
                          "name": nameCtrl.text.trim(),
                          "ageCategory": ageCategoryCtrl.text.trim(),
                        }
                    );
                    setSheet(() => isLoading = false);
                    if (success) {
                      Navigator.pop(ctx);
                      AppUI.success(context,
                          'Group "${nameCtrl.text}" created!');
                      refreshData();
                    } else {
                      AppUI.error(
                          context, 'Failed to create group. Try again.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: isLoading
                      ? AppUI.buttonSpinner()
                      : Text('Create Group',
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Edit Group Sheet ───────────────────────────────────────────────────────
  void _showEditGroupSheet(GroupData group) {
    final nameCtrl = TextEditingController(text: group.name);
    final descCtrl = TextEditingController(text: group.description);
    String selectedStatus = group.status;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r)),
                ),
              ),
              16.height,
              Text('Edit Group',
                  style: GoogleFonts.montserrat(
                      fontSize: 18.sp, fontWeight: FontWeight.bold)),
              6.height,
              Text('Group ID: ${group.groupId}',
                  style:
                  GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)),
              20.height,
              _sheetField('Group Name *', nameCtrl, Icons.group_rounded,
                  hint: 'e.g., Under 14'),
              12.height,
              _sheetField('Description (optional)', descCtrl,
                  Icons.description_rounded,
                  hint: 'e.g., Group for U14 category',
                  required: false,
                  maxLines: 2),
              12.height,
              // Text('Status',
              //     style: GoogleFonts.poppins(
              //         fontSize: 12.sp,
              //         color: textSecondary,
              //         fontWeight: FontWeight.w500)),
              // 6.height,
              // DropdownButtonFormField<String>(
              //   value: selectedStatus,
              //   decoration: InputDecoration(
              //     filled: true,
              //     fillColor: Colors.grey.shade100,
              //     contentPadding:
              //     EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
              //     border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(12.r),
              //         borderSide: BorderSide(color: Colors.grey.shade300)),
              //     enabledBorder: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(12.r),
              //         borderSide: BorderSide(color: Colors.grey.shade300)),
              //     focusedBorder: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(12.r),
              //         borderSide:
              //         const BorderSide(color: accentGreen, width: 1.5)),
              //   ),
              //   style:
              //   GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
              //   items: ['ACTIVE', 'INACTIVE']
              //       .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              //       .toList(),
              //   onChanged: (val) =>
              //       setSheet(() => selectedStatus = val ?? 'ACTIVE'),
              // ),
              20.height,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (nameCtrl.text.trim().isEmpty) {
                      toast('Please enter group name');
                      return;
                    }
                    setSheet(() => isLoading = true);
                    final success = await _apiService.updateGroup(
                      widget.event.eventId,
                      group.groupId,
                      {
                        "name": nameCtrl.text.trim(),
                        "description": descCtrl.text.trim(),
                        "status": selectedStatus,
                      },
                    );
                    setSheet(() => isLoading = false);
                    if (success) {

                      if(!mounted) return;
                      Navigator.pop(ctx);

                      AppUI.success(context, 'Group updated!');

                      if(!mounted) return;

                      refreshData();
                    } else {
                      AppUI.error(
                          context, 'Failed to update group. Try again.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: isLoading
                      ? AppUI.buttonSpinner()
                      : Text('Update Group',
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Group Card ─────────────────────────────────────────────────────────────
  Widget _groupCard(GroupData group) {
    final isDeleting = _deletingGroupIds.contains(group.groupId);
    final statusColor =
    group.status == 'ACTIVE' ? accentGreen : Colors.grey;

    return GestureDetector(
      onTap: () {
        // Navigate to sub-groups for this group
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventSubGroupsScreen(
              group: group,
              eventId: widget.event.eventId,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: accentGreen.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: accentGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                  style: GoogleFonts.montserrat(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: accentGreen),
                ),
              ),
            ),
            14.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name,
                      style: GoogleFonts.montserrat(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  4.height,
                  if (group.description.isNotEmpty)
                    Text(group.description,
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp, color: textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  4.height,
                  Row(
                    children: [
                      Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(group.status,
                            style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: statusColor,
                                fontWeight: FontWeight.w600)),
                      ),
                      8.width,
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 10.sp, color: textSecondary),
                      4.width,
                      // AFTER (fixed):
                      Flexible(
                        child: Text('Tap to manage sub-groups',
                            style: GoogleFonts.poppins(
                                fontSize: 10.sp, color: textSecondary),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: accentGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r)),
                  child: Text('ID: ${group.groupId}',
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: accentGreen,
                          fontWeight: FontWeight.w600)),
                ),
                12.height,
                Row(
                  children: [
                    // Edit button
                    GestureDetector(
                      onTap: () => _showEditGroupSheet(group),
                      child: Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit_rounded,
                            color: Colors.blue, size: 16.sp),
                      ),
                    ),
                    8.width,
                    // Delete button
                    GestureDetector(
                      onTap: isDeleting
                          ? null
                          : () => _confirmDeleteGroup(group),
                      child: Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: isDeleting
                            ? Padding(
                          padding: EdgeInsets.all(7.w),
                          child: AppUI.buttonSpinner(),
                        )
                            : Icon(Icons.delete_forever,
                            color: Colors.red.shade600, size: 18.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Sheet Field ────────────────────────────────────────────────────────────
  Widget _sheetField(
      String label,
      TextEditingController ctrl,
      IconData icon, {
        String? hint,
        bool required = true,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: textSecondary,
                fontWeight: FontWeight.w500)),
        6.height,
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                fontSize: 12.sp, color: textSecondary.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: textSecondary, size: 18.sp),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: accentGreen, width: 1.5)),
          ),
        ),
      ],
    );
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Event Groups',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.event.eventName,
                              style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade400),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Event Info Strip ─────────────────────────────────────────
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: accentGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.event_rounded,
                        color: accentGreen, size: 20.sp),
                  ),
                  14.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.event.eventName,
                            style: GoogleFonts.montserrat(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        4.height,
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 11.sp, color: textSecondary),
                            4.width,
                            Text(widget.event.eventDate,
                                style: GoogleFonts.poppins(
                                    fontSize: 11.sp, color: textSecondary)),
                            10.width,
                            Icon(Icons.location_on_rounded,
                                size: 11.sp, color: textSecondary),
                            4.width,
                            Expanded(
                              child: Text(widget.event.location,
                                  style: GoogleFonts.poppins(
                                      fontSize: 11.sp, color: textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                    decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r)),
                    child: Text(widget.event.eventType,
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: Colors.purple,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            // ── Groups List ──────────────────────────────────────────────
            Expanded(
              child: FutureBuilder<List<GroupData>>(
                future: _groupsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting&&load) {
                    return const Center(
                        child: CircularProgressIndicator(color: accentGreen));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 48.sp, color: Colors.red.shade300),
                          12.height,
                          Text('Failed to load groups',
                              style:
                              GoogleFonts.poppins(color: textSecondary)),
                          12.height,
                          ElevatedButton(
                            onPressed: refreshData,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: accentGreen,
                                foregroundColor: Colors.white),
                            child: Text('Retry', style: GoogleFonts.poppins()),
                          ),
                        ],
                      ),
                    );
                  }

                  final groups = snapshot.data ?? [];

                  return RefreshIndicator(
                    onRefresh: () async => refreshData(),
                    color: accentGreen,
                    child: groups.isEmpty
                        ? ListView(
                      children: [
                        SizedBox(height: 100.h),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.group_off_rounded,
                                  size: 60.sp,
                                  color: Colors.grey.shade400),
                              16.height,
                              Text('No groups yet',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500)),
                              8.height,
                              Text('Tap + to create the first group',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    )
                        : ListView.separated(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 8.h),
                      itemCount: groups.length,
                      separatorBuilder: (_, __) => 15.height,
                      itemBuilder: (_, i) => _groupCard(groups[i]),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 30,)
          ],
        ),

        // ── FAB ─────────────────────────────────────────────────────────
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateGroupSheet,
          backgroundColor: accentGreen,
          icon: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
          label: Text('Add Group',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          elevation: 4,
        ),
      ),
    );
  }
}