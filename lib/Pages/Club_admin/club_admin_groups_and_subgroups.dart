// screens/clubadmin/clubadmin_groups_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sports/model/clubAdmin/get_subgroups_member.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_groups.dart';
import '../../model/clubAdmin/getSubGroups.dart';
import '../../model/clubAdmin/get_members.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';

class ClubAdminGroupsScreen extends StatefulWidget {
  const ClubAdminGroupsScreen({super.key});

  @override
  State<ClubAdminGroupsScreen> createState() => _ClubAdminGroupsScreenState();
}

class _ClubAdminGroupsScreenState extends State<ClubAdminGroupsScreen> {
  final ClubApiService _apiService = ClubApiService();
  late Future<List<GroupData>> _groupsFuture;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _fetchGroups();
  }

  Future<List<GroupData>> _fetchGroups() async {
    final result = await _apiService.getAllGroups();
    setState(() => _isFirstLoad = false);
    return result;
  }

  void _refresh() => setState(() => _groupsFuture = _fetchGroups());

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
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              16.height,
              Text('Create Group',
                  style: GoogleFonts.montserrat(
                      fontSize: 18.sp, fontWeight: FontWeight.bold)),
              20.height,
              _sheetField('Group Name *', nameCtrl, Icons.group_rounded,
                  hint: 'e.g., Under 14'),
              12.height,
              _sheetField('Description (optional)', descCtrl,
                  Icons.description_rounded,
                  hint: 'Short description', required: false),
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
                    final success =
                    await _apiService.createStandaloneGroup({
                      "activityId": 1,
                      "name": nameCtrl.text.trim(),
                      "description": descCtrl.text.trim(),
                    });
                    setSheet(() => isLoading = false);
                    if (success) {
                      Navigator.pop(ctx);
                      AppUI.success(
                          context, 'Group "${nameCtrl.text}" created!');
                      _refresh();
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

  // ── Edit Group ──────────────────────────────────────────────────────────
  void _showEditGroupSheet(GroupData group) {
    final nameCtrl = TextEditingController(text: group.name);
    final descCtrl = TextEditingController(text: group.description);
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
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              16.height,
              Text('Edit Group',
                  style: GoogleFonts.montserrat(
                      fontSize: 18.sp, fontWeight: FontWeight.bold)),
              20.height,
              _sheetField('Group Name *', nameCtrl, Icons.group_rounded,
                  hint: 'e.g., Under 14'),
              12.height,
              _sheetField('Description (optional)', descCtrl,
                  Icons.description_rounded,
                  hint: 'Short description', required: false),
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
                    final success =
                    await _apiService.updateStandaloneGroup(
                        group.groupId, {
                      "name": nameCtrl.text.trim(),
                      "description": descCtrl.text.trim(),
                      "status": group.status,
                    });
                    setSheet(() => isLoading = false);
                    if (success) {
                      Navigator.pop(ctx);
                      AppUI.success(context, 'Group updated!');
                      _refresh();
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

  // ── Delete Group ────────────────────────────────────────────────────────
  Future<void> _confirmDeleteGroup(GroupData group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Group',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700, fontSize: 16.sp)),
        content: Text(
            'Are you sure you want to delete "${group.name}"?\n\nThis will also delete all sub-groups inside.',
            style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete',
                  style: GoogleFonts.poppins(
                      color: Colors.red, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await _apiService.deleteStandaloneGroup(group.groupId);
      if (success) {
        toast('Group "${group.name}" deleted');
        _refresh();
      } else {
        AppUI.error(context, 'Failed to delete group. Try again.');
      }
    }
  }

  // ── Group Card ──────────────────────────────────────────────────────────
  Widget _groupCard(GroupData group) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => GroupSubGroupsScreen(group: group)))
          .then((_) => _refresh()),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: accentGreen.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                  color: accentGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r)),
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

            // Info — uses Wrap so text never overflows
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name,
                      style: GoogleFonts.montserrat(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  if (group.description != null &&
                      group.description.isNotEmpty) ...[
                    4.height,
                    Text(group.description,
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp, color: textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                  6.height,
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                            color: accentGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r)),
                        child: Text(group.status,
                            style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: accentGreen,
                                fontWeight: FontWeight.w600)),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 10.sp, color: textSecondary),
                          4.width,
                          Text('Tap to manage sub-groups',
                              style: GoogleFonts.poppins(
                                  fontSize: 10.sp, color: textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            12.width,

            // Actions — edit + delete, no ID badge
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showEditGroupSheet(group),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.12),
                        shape: BoxShape.circle),
                    child: Icon(Icons.edit_rounded,
                        color: Colors.blue, size: 16.sp),
                  ),
                ),
                8.height,
                GestureDetector(
                  onTap: () => _confirmDeleteGroup(group),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        shape: BoxShape.circle),
                    child: Icon(Icons.delete_forever,
                        color: Colors.red.shade600, size: 18.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetHandle() => Center(
    child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2.r))),
  );

  Widget _sheetField(String label, TextEditingController ctrl, IconData icon,
      {String? hint, bool required = true, int maxLines = 1}) {
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
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                  EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    children: [
                      Text('Groups',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      GestureDetector(
                        onTap: _refresh,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                              color: accentGreen.withOpacity(0.2),
                              shape: BoxShape.circle),
                          child: Icon(Icons.refresh_rounded,
                              color: accentGreen, size: 20.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: FutureBuilder<List<GroupData>>(
                future: _groupsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _isFirstLoad) {
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
                              onPressed: _refresh,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: accentGreen,
                                  foregroundColor: Colors.white),
                              child: Text('Retry',
                                  style: GoogleFonts.poppins())),
                        ],
                      ),
                    );
                  }
                  final groups = snapshot.data ?? [];
                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    color: accentGreen,
                    child: groups.isEmpty
                        ? ListView(children: [
                      SizedBox(height: 100.h),
                      Center(
                        child: Column(children: [
                          Icon(Icons.group_off_rounded,
                              size: 60.sp, color: Colors.grey.shade400),
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
                        ]),
                      ),
                    ])
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 8.h),
                      itemCount: groups.length,
                      itemBuilder: (_, i) => _groupCard(groups[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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

// ══════════════════════════════════════════════════════════════════
// SUB-GROUPS SCREEN
// ══════════════════════════════════════════════════════════════════

class GroupSubGroupsScreen extends StatefulWidget {
  final GroupData group;
  const GroupSubGroupsScreen({super.key, required this.group});

  @override
  State<GroupSubGroupsScreen> createState() => _GroupSubGroupsScreenState();
}

class _GroupSubGroupsScreenState extends State<GroupSubGroupsScreen> {
  final ClubApiService _apiService = ClubApiService();
  late Future<List<SubGroupData>> _subGroupsFuture;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _subGroupsFuture = _fetchSubGroups();
  }

  Future<List<SubGroupData>> _fetchSubGroups() async {
    final result = await _apiService.getSubGroups(widget.group.groupId);
    setState(() => _isFirstLoad = false);
    return result.data;
  }

  void _refresh() => setState(() => _subGroupsFuture = _fetchSubGroups());

  // ── Create Sub-group ────────────────────────────────────────────────────
  void _showCreateSheet() {
    final nameCtrl = TextEditingController();
    final ageCatCtrl = TextEditingController();
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
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              16.height,
              Text('Create Sub-group',
                  style: GoogleFonts.montserrat(
                      fontSize: 18.sp, fontWeight: FontWeight.bold)),
              6.height,
              Text('Group: ${widget.group.name}',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp, color: textSecondary)),
              20.height,
              _sheetField('Sub-group Name *', nameCtrl,
                  Icons.group_work_rounded,
                  hint: 'e.g., Boys U14'),
              12.height,
              _sheetField('Age Category *', ageCatCtrl, Icons.cake_rounded,
                  hint: 'e.g., U14, U18, Senior'),
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
                    if (ageCatCtrl.text.trim().isEmpty) {
                      toast('Please enter age category');
                      return;
                    }
                    setSheet(() => isLoading = true);
                    final success = await _apiService.createSubGroup(
                        widget.group.groupId, {
                      "name": nameCtrl.text.trim(),
                      "ageCategory": ageCatCtrl.text.trim(),
                    });
                    setSheet(() => isLoading = false);
                    if (success) {
                      Navigator.pop(ctx);
                      AppUI.success(context, 'Sub-group created!');
                      _refresh();
                    } else {
                      AppUI.error(context,
                          'Failed to create sub-group. Try again.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r))),
                  child: isLoading
                      ? AppUI.buttonSpinner()
                      : Text('Create Sub-group',
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

  // ── Edit Sub-group ──────────────────────────────────────────────────────
  // PUT /api/groups/{groupId}/sub-groups/{subGroupId}
  // Body: { "name": "string", "ageCategory": "string", "status": "string" }
  void _showEditSheet(SubGroupData sg) {
    final nameCtrl = TextEditingController(text: sg.name);
    final ageCatCtrl = TextEditingController(text: sg.ageCategory ?? '');
    String selectedStatus = sg.status;
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
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              16.height,
              Text('Edit Sub-group',
                  style: GoogleFonts.montserrat(
                      fontSize: 18.sp, fontWeight: FontWeight.bold)),
              6.height,
              Text('Group: ${widget.group.name}',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp, color: textSecondary)),
              20.height,
              _sheetField('Sub-group Name *', nameCtrl,
                  Icons.group_work_rounded,
                  hint: 'e.g., Boys U14'),
              12.height,
              _sheetField('Age Category *', ageCatCtrl, Icons.cake_rounded,
                  hint: 'e.g., U14, U18, Senior'),
              12.height,

              // Status
              Text('Status',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: textSecondary,
                      fontWeight: FontWeight.w500)),
              6.height,
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 13.h),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide:
                      const BorderSide(color: accentGreen, width: 1.5)),
                ),
                style: GoogleFonts.poppins(
                    fontSize: 13.sp, color: Colors.black),
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
                    if (ageCatCtrl.text.trim().isEmpty) {
                      toast('Please enter age category');
                      return;
                    }
                    setSheet(() => isLoading = true);
                    // PUT /api/groups/{groupId}/sub-groups/{subGroupId}
                    final success = await _apiService.updateSubGroup(
                      widget.group.groupId,
                      sg.subGroupId,
                      {
                        "name": nameCtrl.text.trim(),
                        "ageCategory": ageCatCtrl.text.trim(),
                        "status": selectedStatus,
                      },
                    );
                    setSheet(() => isLoading = false);
                    if (success) {
                      Navigator.pop(ctx);
                      AppUI.success(context, 'Sub-group updated!');
                      _refresh();
                    } else {
                      AppUI.error(context,
                          'Failed to update sub-group. Try again.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r))),
                  child: isLoading
                      ? AppUI.buttonSpinner()
                      : Text('Update Sub-group',
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

  // ── Delete Sub-group ────────────────────────────────────────────────────
  Future<void> _confirmDelete(SubGroupData sg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Sub-group',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700, fontSize: 16.sp)),
        content: Text('Delete "${sg.name}"?',
            style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete',
                  style: GoogleFonts.poppins(
                      color: Colors.red, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await _apiService.deleteSubGroup(
          widget.group.groupId, sg.subGroupId);
      if (success) {
        toast('Sub-group deleted');
        _refresh();
      } else {
        AppUI.error(context, 'Failed to delete sub-group.');
      }
    }
  }

  Widget _subGroupCard(SubGroupData sg) {
    final statusColor = sg.status == 'ACTIVE' ? accentGreen : Colors.grey;
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  SubGroupMembersScreen(subGroup: sg, group: widget.group))),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.blue.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r)),
              child: Center(
                child: Text(
                  sg.name.isNotEmpty ? sg.name[0].toUpperCase() : 'S',
                  style: GoogleFonts.montserrat(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue),
                ),
              ),
            ),
            14.width,

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sg.name,
                      style: GoogleFonts.montserrat(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  if (sg.ageCategory != null &&
                      sg.ageCategory!.isNotEmpty) ...[
                    4.height,
                    Text('Age: ${sg.ageCategory}',
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp, color: textSecondary)),
                  ],
                  6.height,
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20.r)),
                        child: Text(sg.status,
                            style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: statusColor,
                                fontWeight: FontWeight.w600)),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 10.sp, color: textSecondary),
                          4.width,
                          Text('Tap to manage members',
                              style: GoogleFonts.poppins(
                                  fontSize: 10.sp, color: textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            12.width,

            // Actions — edit + delete, no ID badge
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showEditSheet(sg),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.12),
                        shape: BoxShape.circle),
                    child: Icon(Icons.edit_rounded,
                        color: Colors.blue, size: 16.sp),
                  ),
                ),
                8.height,
                GestureDetector(
                  onTap: () => _confirmDelete(sg),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        shape: BoxShape.circle),
                    child: Icon(Icons.delete_forever,
                        color: Colors.red.shade600, size: 18.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetHandle() => Center(
    child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2.r))),
  );

  Widget _sheetField(String label, TextEditingController ctrl, IconData icon,
      {String? hint, bool required = true}) {
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
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                  EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white, size: 20.sp)),
                      16.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sub-groups',
                                style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold)),
                            Text(widget.group.name,
                                style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade400),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Group info strip
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
                        borderRadius: BorderRadius.circular(12.r)),
                    child: Icon(Icons.group_rounded,
                        color: accentGreen, size: 20.sp),
                  ),
                  14.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.group.name,
                            style: GoogleFonts.montserrat(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        if (widget.group.description != null &&
                            widget.group.description.isNotEmpty)
                          Text(widget.group.description,
                              style: GoogleFonts.poppins(
                                  fontSize: 11.sp, color: textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder<List<SubGroupData>>(
                future: _subGroupsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _isFirstLoad) {
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
                              Text('Failed to load sub-groups',
                                  style:
                                  GoogleFonts.poppins(color: textSecondary)),
                              12.height,
                              ElevatedButton(
                                  onPressed: _refresh,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: accentGreen,
                                      foregroundColor: Colors.white),
                                  child: Text('Retry',
                                      style: GoogleFonts.poppins())),
                            ]));
                  }
                  final subGroups = snapshot.data ?? [];
                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    color: accentGreen,
                    child: subGroups.isEmpty
                        ? ListView(children: [
                      SizedBox(height: 100.h),
                      Center(
                          child: Column(children: [
                            Icon(Icons.group_work_outlined,
                                size: 60.sp, color: Colors.grey.shade400),
                            16.height,
                            Text('No sub-groups yet',
                                style: GoogleFonts.montserrat(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500)),
                            8.height,
                            Text('Tap + to create the first sub-group',
                                style: GoogleFonts.poppins(
                                    fontSize: 12.sp, color: textSecondary)),
                          ])),
                    ])
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 8.h),
                      itemCount: subGroups.length,
                      itemBuilder: (_, i) =>
                          _subGroupCard(subGroups[i]),
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
          label: Text('Add Sub-group',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          elevation: 4,
        ),
      ),
    );
  }
}


class SubGroupMembersScreen extends StatefulWidget {
  final SubGroupData subGroup;
  final GroupData group;

  const SubGroupMembersScreen(
      {super.key, required this.subGroup, required this.group});

  @override
  State<SubGroupMembersScreen> createState() => _SubGroupMembersScreenState();
}

class _SubGroupMembersScreenState extends State<SubGroupMembersScreen> {
  final ClubApiService _apiService = ClubApiService();
  late Future<List<SubMemData>> _membersFuture;
  bool _loadingAll = false;
  final Set<int> _removingIds = {};

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMembers();
  }

  Future<List<SubMemData>> _fetchMembers() async {
    final result =
    await _apiService.getSubGroupMembers(widget.subGroup.subGroupId);
    return result.data;
  }

  void _refresh() => setState(() => _membersFuture = _fetchMembers());

  void _showAddMembersSheet() async {
    setState(() => _loadingAll = true);
    List<Data> allMembers = [];
    try {
      final result = await _apiService.getMembers();
      allMembers = result.data;
    } catch (e) {
      toast('Failed to load members');
      setState(() => _loadingAll = false);
      return;
    }
    setState(() => _loadingAll = false);

    List<int> selectedIds = [];
    bool isAdding = false;

    if (!mounted) return;

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
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h),
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
                          borderRadius: BorderRadius.circular(2.r)))),
              16.height,
              Text('Add Members',
                  style: GoogleFonts.montserrat(
                      fontSize: 18.sp, fontWeight: FontWeight.bold)),
              6.height,
              Text('Sub-group: ${widget.subGroup.name}',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp, color: textSecondary)),
              16.height,
              if (allMembers.isEmpty)
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Center(
                        child: Text('No members available',
                            style: GoogleFonts.poppins(
                                fontSize: 13.sp, color: textSecondary))))
              else ...[
                Text('${selectedIds.length} member(s) selected',
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: accentGreen,
                        fontWeight: FontWeight.w600)),
                8.height,
                Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.40),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300)),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: allMembers.length,
                    itemBuilder: (ctx, i) {
                      final member = allMembers[i];
                      final selected = selectedIds.contains(member.memberId);
                      return CheckboxListTile(
                        title: Text(member.username,
                            style: GoogleFonts.poppins(
                                fontSize: 13.sp, color: Colors.black87)),
                        subtitle: Text(member.email,
                            style: GoogleFonts.poppins(
                                fontSize: 11.sp, color: textSecondary)),
                        value: selected,
                        activeColor: accentGreen,
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 2.h),
                        onChanged: (bool? val) {
                          setSheet(() {
                            if (val == true)
                              selectedIds.add(member.memberId);
                            else
                              selectedIds.remove(member.memberId);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
              20.height,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (isAdding || selectedIds.isEmpty)
                      ? null
                      : () async {
                    setSheet(() => isAdding = true);
                    final success =
                    await _apiService.addMembersToSubGroup(
                        widget.subGroup.subGroupId, selectedIds);
                    setSheet(() => isAdding = false);
                    if (success) {
                      Navigator.pop(ctx);
                      AppUI.success(context,
                          '${selectedIds.length} member(s) added!');
                      _refresh();
                    } else {
                      AppUI.error(context,
                          'Failed to add members. Try again.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r))),
                  child: isAdding
                      ? AppUI.buttonSpinner()
                      : Text(
                    selectedIds.isEmpty
                        ? 'Select members first'
                        : 'Add ${selectedIds.length} Member(s)',
                    style: GoogleFonts.poppins(
                        fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemove(SubMemData member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Remove Member',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700, fontSize: 16.sp)),
        content: Text('Remove "${member.name}" from ${widget.subGroup.name}?',
            style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Remove',
                  style: GoogleFonts.poppins(
                      color: Colors.red, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _removingIds.add(member.memberId));
      final success = await _apiService.removeMemberFromSubGroup(
          widget.subGroup.subGroupId, member.memberId);
      setState(() => _removingIds.remove(member.memberId));
      if (success) {
        toast('Member removed');
        _refresh();
      } else {
        AppUI.error(context, 'Failed to remove member.');
      }
    }
  }

  Widget _memberCard(SubMemData member) {
    final isRemoving = _removingIds.contains(member.memberId);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: accentGreen.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: accentGreen.withOpacity(0.12),
            child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: accentGreen)),
          ),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: GoogleFonts.montserrat(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
                4.height,
                Text(member.email,
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp, color: textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: isRemoving ? null : () => _confirmRemove(member),
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle),
              child: isRemoving
                  ? Padding(
                  padding: EdgeInsets.all(7.w),
                  child: AppUI.buttonSpinner())
                  : Icon(Icons.person_remove_rounded,
                  color: Colors.red.shade600, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                  EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white, size: 20.sp)),
                      16.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Members',
                                style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                '${widget.group.name} › ${widget.subGroup.name}',
                                style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade400),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: FutureBuilder<List<SubMemData>>(
                future: _membersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                              Text('Failed to load members',
                                  style:
                                  GoogleFonts.poppins(color: textSecondary)),
                              12.height,
                              ElevatedButton(
                                  onPressed: _refresh,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: accentGreen,
                                      foregroundColor: Colors.white),
                                  child: Text('Retry',
                                      style: GoogleFonts.poppins())),
                            ]));
                  }
                  final members = snapshot.data ?? [];
                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    color: accentGreen,
                    child: members.isEmpty
                        ? ListView(children: [
                      SizedBox(height: 100.h),
                      Center(
                          child: Column(children: [
                            Icon(Icons.people_outline_rounded,
                                size: 60.sp, color: Colors.grey.shade400),
                            16.height,
                            Text('No members yet',
                                style: GoogleFonts.montserrat(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500)),
                            8.height,
                            Text('Tap + to add members',
                                style: GoogleFonts.poppins(
                                    fontSize: 12.sp, color: textSecondary)),
                          ])),
                    ])
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 8.h),
                      itemCount: members.length,
                      itemBuilder: (_, i) => _memberCard(members[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _loadingAll
            ? FloatingActionButton(
            onPressed: null,
            backgroundColor: accentGreen,
            child: const CircularProgressIndicator(color: Colors.white))
            : FloatingActionButton.extended(
          onPressed: _showAddMembersSheet,
          backgroundColor: accentGreen,
          icon: Icon(Icons.person_add_rounded,
              color: Colors.white, size: 22.sp),
          label: Text('Add Members',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          elevation: 4,
        ),
      ),
    );
  }
}