// screens/clubadmin/event_sub_groups_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/getSubGroups.dart';
import '../../model/clubAdmin/get_groups.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';
import 'event_team_screen.dart';

class EventSubGroupsScreen extends StatefulWidget {
  final GroupData group;
  final int eventId;

  const EventSubGroupsScreen({
    super.key,
    required this.group,
    required this.eventId,
  });

  @override
  State<EventSubGroupsScreen> createState() => _EventSubGroupsScreenState();
}

class _EventSubGroupsScreenState extends State<EventSubGroupsScreen> {
  final ClubApiService _apiService = ClubApiService();
  late Future<List<SubGroupData>> _subGroupsFuture;
  final Set<int> _deletingIds = {};
  bool isLoad = true;

  @override
  void initState() {
    super.initState();
    _subGroupsFuture = _fetchSubGroups();
  }

  Future<List<SubGroupData>> _fetchSubGroups() async {
    final result = await _apiService.getSubGroups(widget.group.groupId);
    setState(() {
      isLoad = false;
    });
    return result.data;
  }

  void _refresh() {
    final future = _fetchSubGroups();
    setState(() {
      _subGroupsFuture = future;
    });
  }

  // ── Create Sub-group Sheet ─────────────────────────────────────────────────
  void _showCreateSheet() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
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
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              16.height,
              Text(
                'Create Sub-group',
                style: GoogleFonts.montserrat(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              6.height,
              Text(
                'Group: ${widget.group.name}',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: textSecondary,
                ),
              ),
              20.height,
              _sheetField(
                'Sub-group Name *',
                nameCtrl,
                Icons.group_work_rounded,
                hint: 'e.g., Under 14 A',
              ),
              12.height,
              _sheetField(
                'Description (optional)',
                descCtrl,
                Icons.description_rounded,
                hint: 'Short description',
                required: false,
                maxLines: 2,
              ),
              20.height,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (nameCtrl.text.trim().isEmpty) {
                            toast('Please enter sub-group name');
                            return;
                          }
                          setSheet(() => isLoading = true);
                          final success = await _apiService
                              .createSubGroup(widget.group.groupId, {
                                "name": nameCtrl.text.trim(),
                                "description": descCtrl.text.trim(),
                              });
                          setSheet(() => isLoading = false);
                          if (success) {
                            Navigator.pop(ctx);
                            AppUI.success(
                              context,
                              'Sub-group "${nameCtrl.text}" created!',
                            );
                            _refresh();
                          } else {
                            AppUI.error(
                              context,
                              'Failed to create sub-group. Try again.',
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: isLoading
                      ? AppUI.buttonSpinner()
                      : Text(
                          'Create Sub-group',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Edit Sub-group Sheet ───────────────────────────────────────────────────
  void _showEditSheet(SubGroupData subGroup) {
    final nameCtrl = TextEditingController(text: subGroup.name);
    final descCtrl = TextEditingController(text: subGroup.description);
    String selectedStatus = subGroup.status;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
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
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              16.height,
              Text(
                'Edit Sub-group',
                style: GoogleFonts.montserrat(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              6.height,
              Text(
                'ID: ${subGroup.subGroupId}',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: textSecondary,
                ),
              ),
              20.height,
              _sheetField(
                'Sub-group Name *',
                nameCtrl,
                Icons.group_work_rounded,
                hint: 'e.g., Under 14 A',
              ),
              12.height,
              _sheetField(
                'Description (optional)',
                descCtrl,
                Icons.description_rounded,
                hint: 'Short description',
                required: false,
                maxLines: 2,
              ),
              12.height,
              Text(
                'Status',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              6.height,
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 13.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: accentGreen,
                      width: 1.5,
                    ),
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: Colors.black,
                ),
                items: ['ACTIVE', 'INACTIVE']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) =>
                    setSheet(() => selectedStatus = val ?? 'ACTIVE'),
              ),
              20.height,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (nameCtrl.text.trim().isEmpty) {
                            toast('Please enter sub-group name');
                            return;
                          }
                          setSheet(() => isLoading = true);
                          final success = await _apiService.updateSubGroup(
                            widget.group.groupId,
                            subGroup.subGroupId,
                            {
                              "name": nameCtrl.text.trim(),
                              "description": descCtrl.text.trim(),
                              "status": selectedStatus,
                            },
                          );
                          setSheet(() => isLoading = false);
                          if (success) {
                            Navigator.pop(ctx);
                            AppUI.success(context, 'Sub-group updated!');
                            _refresh();
                          } else {
                            AppUI.error(
                              context,
                              'Failed to update sub-group. Try again.',
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: isLoading
                      ? AppUI.buttonSpinner()
                      : Text(
                          'Update Sub-group',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Confirm Delete ─────────────────────────────────────────────────────────
  Future<void> _confirmDelete(SubGroupData subGroup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Sub-group',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${subGroup.name}"?',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _deletingIds.add(subGroup.subGroupId));
      final success = await _apiService.deleteSubGroup(
        widget.group.groupId,
        subGroup.subGroupId,
      );
      setState(() => _deletingIds.remove(subGroup.subGroupId));
      if (success) {
        toast('Sub-group "${subGroup.name}" deleted');
        _refresh();
      } else {
        AppUI.error(context, 'Failed to delete sub-group. Try again.');
      }
    }
  }

  // ── Sub-group Card ─────────────────────────────────────────────────────────
  Widget _subGroupCard(SubGroupData subGroup) {
    final isDeleting = _deletingIds.contains(subGroup.subGroupId);
    final statusColor = subGroup.status == 'ACTIVE' ? accentGreen : Colors.grey;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EventTeamsScreen(subGroup: subGroup, eventId: widget.eventId),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.blue.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  subGroup.name.isNotEmpty
                      ? subGroup.name[0].toUpperCase()
                      : 'S',
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            14.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subGroup.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  4.height,
                  if (subGroup.description.isNotEmpty)
                    Text(
                      subGroup.description,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  4.height,
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          subGroup.status,
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      8.width,
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10.sp,
                        color: textSecondary,
                      ),
                      4.width,
                      Flexible(
                        child: Text(
                          'Tap to manage teams',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      // Text('Tap to manage teams',
                      //     style: GoogleFonts.poppins(
                      //         fontSize: 10.sp, color: textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'ID: ${subGroup.subGroupId}',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                12.height,
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showEditSheet(subGroup),
                      child: Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.blue,
                          size: 16.sp,
                        ),
                      ),
                    ),
                    8.width,
                    GestureDetector(
                      onTap: isDeleting ? null : () => _confirmDelete(subGroup),
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
                            : Icon(
                                Icons.delete_forever,
                                color: Colors.red.shade600,
                                size: 18.sp,
                              ),
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
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        6.height,
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: textSecondary.withOpacity(0.5),
            ),
            prefixIcon: Icon(icon, color: textSecondary, size: 18.sp),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 13.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: accentGreen, width: 1.5),
            ),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sub-groups',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              widget.group.name,
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: Colors.grey.shade400,
                              ),
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

            // ── Group Info Strip ─────────────────────────────────────────
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
                    child: Icon(
                      Icons.group_rounded,
                      color: accentGreen,
                      size: 20.sp,
                    ),
                  ),
                  14.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        4.height,
                        if (widget.group.description.isNotEmpty)
                          Text(
                            widget.group.description,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Group ID: ${widget.group.groupId}',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: accentGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Sub-groups List ──────────────────────────────────────────
            Expanded(
              child: FutureBuilder<List<SubGroupData>>(
                future: _subGroupsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      isLoad) {
                    return const Center(
                      child: CircularProgressIndicator(color: accentGreen),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48.sp,
                            color: Colors.red.shade300,
                          ),
                          12.height,
                          Text(
                            'Failed to load sub-groups',
                            style: GoogleFonts.poppins(color: textSecondary),
                          ),
                          12.height,
                          ElevatedButton(
                            onPressed: _refresh,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentGreen,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Retry', style: GoogleFonts.poppins()),
                          ),
                        ],
                      ),
                    );
                  }

                  final subGroups = snapshot.data ?? [];

                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    color: accentGreen,
                    child: subGroups.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(height: 100.h),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.group_work_outlined,
                                      size: 60.sp,
                                      color: Colors.grey.shade400,
                                    ),
                                    16.height,
                                    Text(
                                      'No sub-groups yet',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    8.height,
                                    Text(
                                      'Tap + to create the first sub-group',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 8.h,
                            ),
                            itemCount: subGroups.length,
                            separatorBuilder: (_, __) => 10.height,
                            itemBuilder: (_, i) => _subGroupCard(subGroups[i]),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateSheet,
          backgroundColor: accentGreen,
          icon: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
          label: Text(
            'Add Sub-group',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
