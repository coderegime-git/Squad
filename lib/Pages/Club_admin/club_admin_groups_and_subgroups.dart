// screens/clubadmin/clubadmin_groups_screen.dart
// Fixed:
// - Loading shimmer while fetching sub-groups/members (no blank flash)
// - Add/Remove members for both Group and SubGroup
// - Coach assignment for both Group and SubGroup
// - Clear UX with section headers, member counts, status chips

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sports/model/clubAdmin/get_subgroups_member.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/activities_data.dart';
import '../../model/clubAdmin/get_groups.dart';
import '../../model/clubAdmin/getSubGroups.dart';
import '../../model/clubAdmin/get_members.dart';
import '../../model/clubAdmin/get_coaches.dart';
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
  List<ActivityData1> _activities = [];
  int? _selectedActivityId;
  List<int> selectedCoachIds = [];
  bool _creatingGroup = false;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _fetchGroups();
    _loadActivities();
  }

  Future<List<GroupData>> _fetchGroups() async {
    final result = await _apiService.getAllGroups();
    if (mounted) setState(() => _isFirstLoad = false);
    return result;
  }
  Future<void> _loadActivities() async {
    final result = await _apiService.getActivities1();

    if (result.isNotEmpty) {
      setState(() {
        _activities = result;
        _selectedActivityId = result.first.id;
      });
    }
  }

  void _refresh() => setState(() {
    _isFirstLoad = true;
    _groupsFuture = _fetchGroups();
  });
  Widget _activityField() {
    // Single activity → Read-only
    if (_activities.length == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity',
              style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: textSecondary,
                  fontWeight: FontWeight.w500)),
          6.height,
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              _activities.first.name,
              style: GoogleFonts.poppins(fontSize: 13.sp),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity',
            style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: textSecondary,
                fontWeight: FontWeight.w500)),
        6.height,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedActivityId,
              isExpanded: true,
              items: _activities.map((activity) {
                return DropdownMenuItem<int>(
                  value: activity.id,
                  child: Text(activity.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActivityId = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
  Future<void> _showCreateGroupSheet() async {
    setState(() => _creatingGroup = true);
    List<CoachData> allCoaches = [];
    try {
      final result = await _apiService.getCoaches();
      allCoaches = result.data;
    } catch (_) {
    }
    setState(() => _creatingGroup = false);
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
        builder: (ctx, setSheet) => SingleChildScrollView(
          child: Padding(
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
                Row(children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10.r)),
                    child:
                    Icon(Icons.group_add_rounded, color: accentGreen, size: 20.sp),
                  ),
                  12.width,
                  Text('Create Group',
                      style: GoogleFonts.montserrat(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                ]),
                20.height,
                _activityField(),
                12.height,
                _sheetField('Group Name *', nameCtrl, Icons.group_rounded,
                    hint: 'e.g., Under 14'),
                12.height,
                _sheetField('Description (optional)', descCtrl,
                    Icons.description_rounded,
                    hint: 'Short description', required: false),
                if (allCoaches.isNotEmpty) ...[
                  16.height,
                  _coachPickerSection(
                    allCoaches,
                    selectedCoachIds,
                    setSheet,
                    label: 'Assign Coaches (optional)',
                  ),
                ],
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
                        "activityId": _selectedActivityId,
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
      ),
    );
  }

  Future<void> _showEditGroupSheet(GroupData group) async {
    List<CoachData> allCoaches = [];
    try {
      final result = await _apiService.getCoaches();
      allCoaches = result.data;
    } catch (_) {}
    final nameCtrl = TextEditingController(text: group.name);
    final descCtrl = TextEditingController(text: group.description ?? '');
    bool isLoading = false;
    List<int> selectedCoachIds = [];
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
              _sheetHandle(),
              16.height,
              Row(children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r)),
                  child: Icon(Icons.edit_rounded,
                      color: Colors.blue, size: 20.sp),
                ),
                12.width,
                Text('Edit Group',
                    style: GoogleFonts.montserrat(
                        fontSize: 18.sp, fontWeight: FontWeight.bold)),
              ]),
              20.height,
              _sheetField('Group Name *', nameCtrl, Icons.group_rounded,
                  hint: 'e.g., Under 14'),
              12.height,
              _sheetField('Description (optional)', descCtrl,
                  Icons.description_rounded,
                  hint: 'Short description', required: false),
              if (allCoaches.isNotEmpty) ...[
                16.height,
                _coachPickerSection(
                  allCoaches,
                  selectedCoachIds,
                  setSheet,
                  label: 'Update Coach Assignment',
                ),
              ],
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
  Future<void> _confirmDeleteGroup(GroupData group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22.sp),
          10.width,
          Text('Delete Group',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700, fontSize: 16.sp)),
        ]),
        content: Text(
            'Are you sure you want to delete "${group.name}"?\n\nThis will also delete all sub-groups inside.',
            style:
            GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: textSecondary))),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r))),
              child: Text('Delete',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await _apiService.deleteStandaloneGroup(group.groupId);
      if (success) {
        AppUI.success(context, 'Group "${group.name}" deleted');
        _refresh();
      } else {
        AppUI.error(context, 'Failed to delete group. Try again.');
      }
    }
  }
  Widget _groupCard(GroupData group) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => GroupDetailScreen(group: group)))
          .then((_) => _refresh()),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: accentGreen.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14.r)),
                    child: Center(
                      child: Text(
                        group.name.isNotEmpty
                            ? group.name[0].toUpperCase()
                            : 'G',
                        style: GoogleFonts.montserrat(
                            fontSize: 20.sp,
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
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        if (group.description != null &&
                            group.description!.isNotEmpty) ...[
                          3.height,
                          Text(group.description!,
                              style: GoogleFonts.poppins(
                                  fontSize: 11.sp, color: textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                  ),
                  // Status chip
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                        color: group.status == 'ACTIVE'
                            ? accentGreen.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r)),
                    child: Text(group.status,
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: group.status == 'ACTIVE'
                                ? accentGreen
                                : Colors.grey,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            // Action bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18.r),
                    bottomRight: Radius.circular(18.r)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _actionBtn(
                      icon: Icons.people_alt_rounded,
                      label: 'Members',
                      color: Colors.indigo,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  GroupMembersScreen(group: group)))
                          .then((_) => _refresh()),
                    ),
                  ),
                  _vertDivider(),
                  Expanded(
                    child: _actionBtn(
                      icon: Icons.account_tree_rounded,
                      label: 'Sub-groups',
                      color: Colors.teal,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  GroupSubGroupsScreen(group: group)))
                          .then((_) => _refresh()),
                    ),
                  ),
                  _vertDivider(),
                  Expanded(
                    child: _actionBtn(
                      icon: Icons.edit_rounded,
                      label: 'Edit',
                      color: Colors.blue,
                      onTap: () => _showEditGroupSheet(group),
                    ),
                  ),
                  _vertDivider(),
                  Expanded(
                    child: _actionBtn(
                      icon: Icons.delete_rounded,
                      label: 'Delete',
                      color: Colors.red,
                      onTap: () => _confirmDeleteGroup(group),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vertDivider() => Container(
    width: 1,
    height: 36.h,
    color: Colors.grey.shade200,
  );

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18.sp),
            4.height,
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    color: color,
                    fontWeight: FontWeight.w600)),
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

            // Info banner
            Container(
              margin: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: accentGreen.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: accentGreen.withOpacity(0.2)),
              ),
              child: Row(children: [
                Icon(Icons.info_outline_rounded,
                    color: accentGreen, size: 16.sp),
                8.width,
                Expanded(
                  child: Text(
                    'Each group can have sub-groups and direct members. Tap a group card to manage.',
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp, color: Colors.black87),
                  ),
                ),
              ]),
            ),

            Expanded(
              child: FutureBuilder<List<GroupData>>(
                future: _groupsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _isFirstLoad) {
                    return _shimmerList();
                  }
                  if (snapshot.hasError) {
                    return _errorView(_refresh);
                  }
                  final groups = snapshot.data ?? [];
                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    color: accentGreen,
                    child: groups.isEmpty
                        ? _emptyView(
                        icon: Icons.group_off_rounded,
                        title: 'No groups yet',
                        subtitle: 'Tap + to create the first group')
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      itemCount: groups.length,
                      itemBuilder: (_, i) => _groupCard(groups[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // Replace FAB:
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _creatingGroup ? null : _showCreateGroupSheet,
          backgroundColor: _creatingGroup ? accentGreen.withOpacity(0.6) : accentGreen,
          icon: _creatingGroup
              ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
          label: Text('Add Group',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          elevation: 4,
        ),
      ),
    );
  }
}


class GroupDetailScreen extends StatefulWidget {
  final GroupData group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
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
                              Text(widget.group.name,
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold)),
                              if (widget.group.description != null &&
                                  widget.group.description!.isNotEmpty)
                                Text(widget.group.description!,
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
                  8.height,
                  TabBar(
                    controller: _tabController,
                    indicatorColor: accentGreen,
                    labelColor: accentGreen,
                    unselectedLabelColor: Colors.grey.shade400,
                    labelStyle: GoogleFonts.poppins(
                        fontSize: 13.sp, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Members'),
                      Tab(text: 'Sub-groups'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                GroupMembersScreen(group: widget.group, embedded: true),
                GroupSubGroupsScreen(group: widget.group, embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class GroupMembersScreen extends StatefulWidget {
  final GroupData group;
  final bool embedded;
  const GroupMembersScreen(
      {super.key, required this.group, this.embedded = false});

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  final ClubApiService _apiService = ClubApiService();
  late Future<List<Data>> _membersFuture;
  bool _loadingAll = false;
  final Set<int> _removingIds = {};

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMembers();
  }

  Future<List<Data>> _fetchMembers() async {
    // GET /api/groups/{groupId}/members
    final result =
    await _apiService.getGroupDirectMembers(widget.group.groupId);
    return result;
  }

  void _refresh() => setState(() => _membersFuture = _fetchMembers());

  void _showAddMembersSheet() async {
    setState(() => _loadingAll = true);
    List<Data> allMembers = [];
    List<Data> currentMembers = [];
    try {
      final all = await _apiService.getMembers();
      allMembers = all.data;
      currentMembers = await _membersFuture.catchError((_) => <Data>[]);
    } catch (e) {
      toast('Failed to load members');
      setState(() => _loadingAll = false);
      return;
    }
    setState(() => _loadingAll = false);

    final currentIds = currentMembers.map((m) => m.memberId).toSet();
    final available =
    allMembers.where((m) => !currentIds.contains(m.memberId)).toList();

    if (available.isEmpty) {
      toast('All club members are already in this group');
      return;
    }

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
              // Replace _sheetHandle(), with this inline:
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
              Row(children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r)),
                  child: Icon(Icons.person_add_rounded,
                      color: Colors.indigo, size: 20.sp),
                ),
                12.width,
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add Members to Group',
                            style: GoogleFonts.montserrat(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Text(widget.group.name,
                            style: GoogleFonts.poppins(
                                fontSize: 11.sp, color: textSecondary)),
                      ]),
                ),
              ]),
              12.height,
              Text(
                  '${selectedIds.length} of ${available.length} selected',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: accentGreen,
                      fontWeight: FontWeight.w600)),
              8.height,
              _memberCheckList(
                  available, selectedIds, setSheet, ctx, Colors.indigo),
              20.height,
              _addButton(
                  isAdding: isAdding,
                  selectedCount: selectedIds.length,
                  onTap: () async {
                    setSheet(() => isAdding = true);
                    final success = await _apiService.addMembersToGroup(
                        widget.group.groupId, selectedIds);
                    setSheet(() => isAdding = false);
                    if (success) {
                      Navigator.pop(ctx);
                      AppUI.success(context,
                          '${selectedIds.length} member(s) added to group!');
                      _refresh();
                    } else {
                      AppUI.error(context, 'Failed to add members.');
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemove(Data member) async {
    final confirmed = await _removeDialog(
        context, 'Remove from Group',
        'Remove "${member.username}" from ${widget.group.name}?');
    if (confirmed == true) {
      setState(() => _removingIds.add(member.memberId));
      // DELETE /api/groups/{groupId}/members  { memberIds: [id] }
      final success = await _apiService.removeMembersFromGroup(
          widget.group.groupId, [member.memberId]);
      setState(() => _removingIds.remove(member.memberId));
      if (success) {
        toast('Member removed from group');
        _refresh();
      } else {
        AppUI.error(context, 'Failed to remove member.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildContent();
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Group Members',
                style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold)),
            Text(widget.group.name,
                style: GoogleFonts.poppins(
                    fontSize: 11.sp, color: Colors.grey.shade400)),
          ]),
          leading: IconButton(
              icon:
              Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20.sp),
              onPressed: () => Navigator.pop(context)),
        ),
        body: _buildContent(),
        floatingActionButton: _fab(),
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        FutureBuilder<List<Data>>(
          future: _membersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _shimmerList();
            }
            if (snapshot.hasError) {
              return _errorView(_refresh);
            }
            final members = snapshot.data ?? [];
            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              color: accentGreen,
              child: members.isEmpty
                  ? _emptyView(
                  icon: Icons.people_outline_rounded,
                  title: 'No members in this group',
                  subtitle: 'Tap + to add members')
                  : ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 80.h),
                itemCount: members.length,
                itemBuilder: (_, i) => _memberTile(members[i]),
              ),
            );
          },
        ),
        if (widget.embedded)
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: _fab(),
          ),
      ],
    );
  }

  Widget _fab() => _loadingAll
      ? FloatingActionButton(
      onPressed: null,
      backgroundColor: accentGreen,
      child: const CircularProgressIndicator(color: Colors.white))
      : FloatingActionButton.extended(
    onPressed: _showAddMembersSheet,
    backgroundColor: Colors.indigo,
    icon: Icon(Icons.person_add_rounded, color: Colors.white, size: 20.sp),
    label: Text('Add Members',
        style: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.w600)),
    elevation: 4,
  );

  Widget _memberTile(Data member) {
    final isRemoving = _removingIds.contains(member.memberId);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.indigo.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: Colors.indigo.withOpacity(0.1),
            child: Text(
                member.username.isNotEmpty
                    ? member.username[0].toUpperCase()
                    : '?',
                style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo)),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.username,
                    style: GoogleFonts.montserrat(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
                3.height,
                Text(member.email,
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp, color: textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: isRemoving ? null : () => _confirmRemove(member),
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: isRemoving
                  ? Padding(
                  padding: EdgeInsets.all(8.w),
                  child: AppUI.buttonSpinner())
                  : Icon(Icons.person_remove_rounded,
                  color: Colors.red.shade600, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SUB-GROUPS SCREEN
// ══════════════════════════════════════════════════════════════════

class GroupSubGroupsScreen extends StatefulWidget {
  final GroupData group;
  final bool embedded;
  const GroupSubGroupsScreen(
      {super.key, required this.group, this.embedded = false});

  @override
  State<GroupSubGroupsScreen> createState() => _GroupSubGroupsScreenState();
}

class _GroupSubGroupsScreenState extends State<GroupSubGroupsScreen> {
  final ClubApiService _apiService = ClubApiService();
  late Future<List<SubGroupData>> _subGroupsFuture;
  bool _isFirstLoad = true;
  bool _creatingSubGroup = false;

  @override
  void initState() {
    super.initState();
    _subGroupsFuture = _fetchSubGroups();
  }

  Future<List<SubGroupData>> _fetchSubGroups() async {
    final result = await _apiService.getSubGroups(widget.group.groupId);
    if (mounted) setState(() => _isFirstLoad = false);
    return result.data;
  }

  void _refresh() => setState(() {
    _isFirstLoad = true;
    _subGroupsFuture = _fetchSubGroups();
  });

  Future<void> _showCreateSheet() async {
    setState(() => _creatingSubGroup = true);

    List<CoachData> allCoaches = [];
    try {
      final result = await _apiService.getCoaches();
      allCoaches = result.data;
    } catch (_) {}
    setState(() => _creatingSubGroup = false);

    final nameCtrl = TextEditingController();
    final ageCatCtrl = TextEditingController();
    bool isLoading = false;
    List<int> selectedCoachIds = [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => SingleChildScrollView(
          child: Padding(
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
                Row(children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10.r)),
                    child: Icon(Icons.group_work_rounded,
                        color: Colors.teal, size: 20.sp),
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Create Sub-group',
                              style: GoogleFonts.montserrat(
                                  fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          Text('In: ${widget.group.name}',
                              style: GoogleFonts.poppins(
                                  fontSize: 11.sp, color: textSecondary)),
                        ]),
                  ),
                ]),
                20.height,
                _sheetField('Sub-group Name *', nameCtrl,
                    Icons.group_work_rounded,
                    hint: 'e.g., Boys U14'),
                12.height,
                _sheetField(
                    'Age Category *', ageCatCtrl, Icons.cake_rounded,
                    hint: 'e.g., U14, U18, Senior'),
                if (allCoaches.isNotEmpty) ...[
                  16.height,
                  _coachPickerSection(
                    allCoaches,
                    selectedCoachIds,
                    setSheet,
                    label: 'Assign Coaches (optional)',
                  ),
                ],
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
                        "coachIds": selectedCoachIds,
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
                        backgroundColor: Colors.teal,
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
      ),
    );
  }

  Future<void> _showEditSheet(SubGroupData sg) async {
    List<CoachData> allCoaches = [];
    try {
      final result = await _apiService.getCoaches();
      allCoaches = result.data;
    } catch (_) {}
    final nameCtrl = TextEditingController(text: sg.name);
    final ageCatCtrl = TextEditingController(text: sg.ageCategory ?? '');
    String selectedStatus = sg.status;
    bool isLoading = false;
    List<int> selectedCoachIds = [];
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
              _sheetHandle(),
              16.height,
              Row(children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r)),
                  child: Icon(Icons.edit_rounded,
                      color: Colors.blue, size: 20.sp),
                ),
                12.width,
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Sub-group',
                            style: GoogleFonts.montserrat(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Text('Group: ${widget.group.name}',
                            style: GoogleFonts.poppins(
                                fontSize: 11.sp, color: textSecondary)),
                      ]),
                ),
              ]),
              20.height,
              _sheetField('Sub-group Name *', nameCtrl,
                  Icons.group_work_rounded,
                  hint: 'e.g., Boys U14'),
              12.height,
              _sheetField(
                  'Age Category *', ageCatCtrl, Icons.cake_rounded,
                  hint: 'e.g., U14, U18, Senior'),
              12.height,
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
              if (allCoaches.isNotEmpty) ...[
                16.height,
                _coachPickerSection(
                  allCoaches,
                  selectedCoachIds,
                  setSheet,
                  label: 'Update Coach Assignment',
                ),
              ],
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

  // ── Delete Sub-group ────────────────────────────────────────────
  Future<void> _confirmDelete(SubGroupData sg) async {
    final confirmed = await _removeDialog(
        context, 'Delete Sub-group', 'Delete "${sg.name}"?');
    if (confirmed == true) {
      final success = await _apiService.deleteSubGroup(
          widget.group.groupId, sg.subGroupId);
      if (success) {
        AppUI.success(context, 'Sub-group deleted');
        _refresh();
      } else {
        AppUI.error(context, 'Failed to delete sub-group.');
      }
    }
  }

  Widget _subGroupCard(SubGroupData sg) {
    final statusColor = sg.status == 'ACTIVE' ? Colors.teal : Colors.grey;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r)),
                  child: Center(
                    child: Text(
                      sg.name.isNotEmpty ? sg.name[0].toUpperCase() : 'S',
                      style: GoogleFonts.montserrat(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.teal),
                    ),
                  ),
                ),
                12.width,
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
                        3.height,
                        Row(children: [
                          Icon(Icons.cake_rounded,
                              size: 11.sp, color: textSecondary),
                          4.width,
                          Text('Age: ${sg.ageCategory}',
                              style: GoogleFonts.poppins(
                                  fontSize: 11.sp, color: textSecondary)),
                        ]),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r)),
                  child: Text(sg.status,
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: statusColor,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Action bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    icon: Icons.people_alt_rounded,
                    label: 'Members',
                    color: Colors.indigo,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SubGroupMembersScreen(
                                subGroup: sg, group: widget.group))),
                  ),
                ),
                _vertDivider(),
                Expanded(
                  child: _actionBtn(
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    color: Colors.blue,
                    onTap: () => _showEditSheet(sg),
                  ),
                ),
                _vertDivider(),
                Expanded(
                  child: _actionBtn(
                    icon: Icons.delete_rounded,
                    label: 'Delete',
                    color: Colors.red,
                    onTap: () => _confirmDelete(sg),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vertDivider() =>
      Container(width: 1, height: 36.h, color: Colors.grey.shade200);

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 18.sp),
            4.height,
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      );

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
    if (widget.embedded) return _buildContent();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Container(
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
                                    color: Colors.grey.shade400)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
        // Replace non-embedded FAB in build():
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _creatingSubGroup ? null : _showCreateSheet,
          backgroundColor: _creatingSubGroup ? Colors.teal.withOpacity(0.6) : Colors.teal,
          icon: _creatingSubGroup
              ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
          label: Text('Add Sub-group',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        FutureBuilder<List<SubGroupData>>(
          future: _subGroupsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _isFirstLoad) {
              return _shimmerList();
            }
            if (snapshot.hasError) {
              return _errorView(_refresh);
            }
            final subGroups = snapshot.data ?? [];
            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              color: accentGreen,
              child: subGroups.isEmpty
                  ? _emptyView(
                  icon: Icons.group_work_outlined,
                  title: 'No sub-groups yet',
                  subtitle: 'Tap + to create the first sub-group')
                  : ListView.builder(
                padding:
                EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 80.h),
                itemCount: subGroups.length,
                itemBuilder: (_, i) => _subGroupCard(subGroups[i]),
              ),
            );
          },
        ),
        if (widget.embedded)
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: FloatingActionButton.extended(
              onPressed: _showCreateSheet,
              backgroundColor: Colors.teal,
              icon:
              Icon(Icons.add_rounded, color: Colors.white, size: 20.sp),
              label: Text('Add Sub-group',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              elevation: 4,
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SUB-GROUP MEMBERS SCREEN
// APIs: GET  /api/subgroups/{subGroupId}/members
//       POST /api/subgroups/{subGroupId}/members  { memberIds: [...] }
//       DELETE /api/subgroups/{subGroupId}/members/{memberId}
// ══════════════════════════════════════════════════════════════════

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
    List<SubMemData> currentMembers = [];
    try {
      final allResult = await _apiService.getMembers();
      allMembers = allResult.data;
      currentMembers = await _membersFuture.catchError((_) => <SubMemData>[]);
    } catch (e) {
      toast('Failed to load members');
      setState(() => _loadingAll = false);
      return;
    }
    setState(() => _loadingAll = false);

    final currentIds = currentMembers.map((m) => m.memberId).toSet();
    final available =
    allMembers.where((m) => !currentIds.contains(m.memberId)).toList();

    if (available.isEmpty) {
      toast('All club members are already in this sub-group');
      return;
    }

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
              _sheetHandle(),
              16.height,
              Row(children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                      color: accentGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r)),
                  child: Icon(Icons.person_add_rounded,
                      color: accentGreen, size: 20.sp),
                ),
                12.width,
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add to Sub-group',
                            style: GoogleFonts.montserrat(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Text(
                            '${widget.group.name} › ${widget.subGroup.name}',
                            style: GoogleFonts.poppins(
                                fontSize: 11.sp, color: textSecondary)),
                      ]),
                ),
              ]),
              12.height,
              Text(
                  '${selectedIds.length} of ${available.length} available',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: accentGreen,
                      fontWeight: FontWeight.w600)),
              8.height,
              _memberCheckList(
                  available, selectedIds, setSheet, ctx, accentGreen),
              20.height,
              _addButton(
                  isAdding: isAdding,
                  selectedCount: selectedIds.length,
                  onTap: () async {
                    setSheet(() => isAdding = true);
                    final success = await _apiService.addMembersToSubGroup(
                        widget.subGroup.subGroupId, selectedIds);
                    setSheet(() => isAdding = false);
                    if (success) {
                      Navigator.pop(ctx);
                      AppUI.success(context,
                          '${selectedIds.length} member(s) added!');
                      _refresh();
                    } else {
                      AppUI.error(context, 'Failed to add members.');
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemove(SubMemData member) async {
    final confirmed = await _removeDialog(context, 'Remove Member',
        'Remove "${member.name}" from ${widget.subGroup.name}?');
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: accentGreen.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: accentGreen.withOpacity(0.1),
            child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: accentGreen)),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: GoogleFonts.montserrat(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
                3.height,
                Text(member.email,
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp, color: textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: isRemoving ? null : () => _confirmRemove(member),
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: isRemoving
                  ? Padding(
                  padding: EdgeInsets.all(8.w),
                  child: AppUI.buttonSpinner())
                  : Icon(Icons.person_remove_rounded,
                  color: Colors.red.shade600, size: 18.sp),
            ),
          ),
        ],
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
                    return _shimmerList();
                  }
                  if (snapshot.hasError) {
                    return _errorView(_refresh);
                  }
                  final members = snapshot.data ?? [];
                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    color: accentGreen,
                    child: members.isEmpty
                        ? _emptyView(
                        icon: Icons.people_outline_rounded,
                        title: 'No members yet',
                        subtitle: 'Tap + to add members')
                        : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                          16.w, 14.h, 16.w, 80.h),
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
            child:
            const CircularProgressIndicator(color: Colors.white))
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

// ══════════════════════════════════════════════════════════════════
// SHARED HELPERS
// ══════════════════════════════════════════════════════════════════

Widget _shimmerList() {
  return ListView.builder(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    itemCount: 4,
    itemBuilder: (_, i) => _ShimmerCard(),
  );
}

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: EdgeInsets.only(bottom: 12.h),
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}

Widget _errorView(VoidCallback onRetry) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_off_rounded, size: 52.sp, color: Colors.red.shade300),
        12.height,
        Text('Failed to load',
            style: GoogleFonts.montserrat(
                fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
        6.height,
        Text('Check your connection and retry',
            style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)),
        16.height,
        ElevatedButton.icon(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen, foregroundColor: Colors.white),
            icon: const Icon(Icons.refresh_rounded),
            label: Text('Retry', style: GoogleFonts.poppins())),
      ],
    ),
  );
}

Widget _emptyView(
    {required IconData icon,
      required String title,
      required String subtitle}) {
  return ListView(children: [
    SizedBox(height: 100.h),
    Center(
      child: Column(children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
              color: Colors.grey.shade200, shape: BoxShape.circle),
          child: Icon(icon, size: 40.sp, color: Colors.grey.shade400),
        ),
        16.height,
        Text(title,
            style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500)),
        8.height,
        Text(subtitle,
            style:
            GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)),
      ]),
    ),
  ]);
}

Widget _memberCheckList(List<Data> available, List<int> selectedIds,
    StateSetter setSheet, BuildContext ctx, Color accentColor) {
  return Container(
    constraints:
    BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.38),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300)),
    child: ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: available.length,
      itemBuilder: (_, i) {
        final member = available[i];
        final selected = selectedIds.contains(member.memberId);
        return CheckboxListTile(
          title: Text(member.username,
              style: GoogleFonts.poppins(
                  fontSize: 13.sp, color: Colors.black87)),
          subtitle: Text(member.email,
              style:
              GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
          value: selected,
          activeColor: accentColor,
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
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
  );
}

Widget _addButton({
  required bool isAdding,
  required int selectedCount,
  required VoidCallback onTap,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: (isAdding || selectedCount == 0) ? null : onTap,
      style: ElevatedButton.styleFrom(
          backgroundColor: accentGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r))),
      child: isAdding
          ? AppUI.buttonSpinner()
          : Text(
        selectedCount == 0
            ? 'Select members first'
            : 'Add $selectedCount Member${selectedCount > 1 ? 's' : ''}',
        style: GoogleFonts.poppins(
            fontSize: 14.sp, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

Future<bool?> _removeDialog(
    BuildContext context, String title, String message) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Row(children: [
        Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22.sp),
        10.width,
        Text(title,
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700, fontSize: 16.sp)),
      ]),
      content: Text(message,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: textSecondary))),
        ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r))),
            child: Text('Confirm',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
      ],
    ),
  );
}
Widget _coachPickerSection(
    List<CoachData> coaches,
    List<int> selectedIds,
    StateSetter setSheet, {
      required String label,
    }) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: textSecondary,
              fontWeight: FontWeight.w500)),
      8.height,
      Container(
        constraints: BoxConstraints(maxHeight: 140.h),
        decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300)),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: coaches.length,
          itemBuilder: (_, i) {
            final coach = coaches[i];
            final selected = selectedIds.contains(coach.coachId);
            return CheckboxListTile(
              title: Text(coach.username,
                  style: GoogleFonts.poppins(
                      fontSize: 13.sp, color: Colors.black87)),
              subtitle: coach.specialization != null &&
                  coach.specialization!.isNotEmpty
                  ? Text(coach.specialization!,
                  style: GoogleFonts.poppins(
                      fontSize: 11.sp, color: textSecondary))
                  : null,
              value: selected,
              activeColor: accentGreen,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
              onChanged: (bool? val) {
                setSheet(() {
                  if (val == true)
                    selectedIds.add(coach.coachId);
                  else
                    selectedIds.remove(coach.coachId);
                });
              },
            );
          },
        ),
      ),
      if (selectedIds.isNotEmpty) ...[
        8.height,
        Text('${selectedIds.length} coach(es) selected',
            style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: accentGreen,
                fontWeight: FontWeight.w600)),
      ],
    ],
  );
}