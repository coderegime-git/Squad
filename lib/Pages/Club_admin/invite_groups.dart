// screens/clubadmin/invite_groups.dart
// Fixed:
// - Inline shimmer loading when expanding a group (while fetching sub-groups)
// - Inline shimmer loading when expanding a sub-group (while fetching members)
// - No more blank flash / sudden pop-in after 5 seconds

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_event_details.dart' as eventModel;
import '../../model/clubAdmin/get_groups.dart';
import '../../model/clubAdmin/getSubGroups.dart';
import '../../model/clubAdmin/get_subgroups_member.dart' as subMemberModel;
import '../../model/clubAdmin/get_members.dart' as memberModel;
import '../../utills/api_service.dart';
import '../../utills/helper.dart';

class InviteGroupsScreen extends StatefulWidget {
  final eventModel.Data event;
  const InviteGroupsScreen({super.key, required this.event});

  @override
  State<InviteGroupsScreen> createState() => _InviteGroupsScreenState();
}

class _InviteGroupsScreenState extends State<InviteGroupsScreen> {
  final ClubApiService _apiService = ClubApiService();
  List<GroupData> _groups = [];
  bool _loading = true;
  final Map<int, List<memberModel.Data>?> _groupMembers = {};
  final Set<int> _loadingGroupMembers = {};
  final Map<int, Set<int>> _uncheckedGroupMembers = {};
  final Map<int, List<SubGroupData>?> _subGroups = {};
  final Map<int, List<subMemberModel.SubMemData>?> _members = {};
  final Set<int> _loadingSubGroups = {};
  final Set<int> _loadingMembers = {};
  final Set<int> _expandedGroups = {};
  final Set<int> _expandedSubGroups = {};
  final Map<int, Set<int>> _uncheckedMembers = {};
  final Map<int, Set<int>> _checkedGroupMembers = {};
  final Map<int, Set<int>> _checkedMembers = {};

  bool _submitting = false;
  int get _totalSelected {
    final Set<int> all = {};
    _checkedGroupMembers.forEach((_, ids) => all.addAll(ids));
    _checkedMembers.forEach((_, ids) => all.addAll(ids));
    return all.length;
  }
  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    try {
      final groups = await _apiService.getAllGroups();
      if (mounted) setState(() { _groups = groups; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchSubGroups(int groupId) async {
    if (_subGroups.containsKey(groupId)) return;
    setState(() => _loadingSubGroups.add(groupId));
    try {
      final result = await _apiService.getSubGroups(groupId);
      if (mounted) setState(() => _subGroups[groupId] = result.data);
    } catch (_) {
      if (mounted) setState(() => _subGroups[groupId] = []);
    } finally {
      if (mounted) setState(() => _loadingSubGroups.remove(groupId));
    }
    _fetchGroupDirectMembers(groupId);
  }
  Future<void> _fetchGroupDirectMembers(int groupId) async {
    if (_groupMembers.containsKey(groupId)) return;
    setState(() => _loadingGroupMembers.add(groupId));
    try {
      final result = await _apiService.getGroupDirectMembers(groupId);
      if (mounted) {
        setState(() {
          _groupMembers[groupId] = result;
          //_uncheckedGroupMembers[groupId] = {};
          _checkedGroupMembers[groupId] = {};
        });
      }
    } catch (_) {
      if (mounted) setState(() => _groupMembers[groupId] = []);
    } finally {
      if (mounted) setState(() => _loadingGroupMembers.remove(groupId));
    }
  }
  void _toggleGroupMember(int groupId, int memberId) {
    setState(() {
      final set = _checkedGroupMembers[groupId] ?? {};
      set.contains(memberId) ? set.remove(memberId) : set.add(memberId);
      _checkedGroupMembers[groupId] = set;
    });
  }
  Future<void> _fetchMembers(int subGroupId) async {
    if (_members.containsKey(subGroupId)) return; // already loaded
    setState(() => _loadingMembers.add(subGroupId));
    try {
      final result = await _apiService.getSubGroupMembers(subGroupId);
      if (mounted) {
        setState(() {
          _members[subGroupId] = result.data;
         // _uncheckedMembers[subGroupId] = {};
          _checkedMembers[subGroupId] = {};
        });
      }
    } catch (_) {
      if (mounted) setState(() => _members[subGroupId] = []);
    } finally {
      if (mounted) setState(() => _loadingMembers.remove(subGroupId));
    }
  }

  void _toggleGroup(int groupId) {
    setState(() {
      if (_expandedGroups.contains(groupId)) {
        _expandedGroups.remove(groupId);
      } else {
        _expandedGroups.add(groupId);
        _fetchSubGroups(groupId); // starts loading, shows shimmer inside tile
      }
    });
  }

  void _toggleSubGroup(int subGroupId) {
    setState(() {
      if (_expandedSubGroups.contains(subGroupId)) {
        _expandedSubGroups.remove(subGroupId);
      } else {
        _expandedSubGroups.add(subGroupId);
        _fetchMembers(subGroupId); // starts loading, shows shimmer inside tile
      }
    });
  }

  void _toggleMember(int subGroupId, int memberId) {
    setState(() {
      final set = _checkedMembers[subGroupId] ?? {};
      set.contains(memberId) ? set.remove(memberId) : set.add(memberId);
      _checkedMembers[subGroupId] = set;
    });
  }
  void _selectAllGroupMembers(int groupId) {
    final members = _groupMembers[groupId];
    if (members == null) return;
    final allIds = members.map((m) => m.memberId).toSet();
    final checked = _checkedGroupMembers[groupId] ?? {};
    final allSelected = allIds.every((id) => checked.contains(id));
    setState(() {
      _checkedGroupMembers[groupId] = allSelected ? {} : Set.from(allIds);
    });
  }

  void _selectAllSubMembers(int subGroupId) {
    final members = _members[subGroupId];
    if (members == null) return;
    final allIds = members.map((m) => m.memberId).toSet();
    final checked = _checkedMembers[subGroupId] ?? {};
    final allSelected = allIds.every((id) => checked.contains(id));
    setState(() {
      _checkedMembers[subGroupId] = allSelected ? {} : Set.from(allIds);
    });
  }
  Future<void> _sendInvites() async {
    final Set<int> invitedMemberIds = {};
    _checkedGroupMembers.forEach((_, ids) => invitedMemberIds.addAll(ids));
    _checkedMembers.forEach((_, ids) => invitedMemberIds.addAll(ids));

    if (invitedMemberIds.isEmpty) {
      toast('Please select at least one member to invite');
      return;
    }

    setState(() => _submitting = true);
    try {
      final success = await _apiService.addMembersToEvent(
          widget.event.eventId, invitedMemberIds.toList());
      if (mounted) {
        setState(() => _submitting = false);
        if (success) {
          toast('Invites sent to ${invitedMemberIds.length} member(s)!', bgColor: accentGreen);
          Navigator.pop(context);
        } else {
          toast('Failed to send invites. Try again.');
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        toast('Failed to send invites');
      }
    }
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
            // ── Header ──────────────────────────────────────────────
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
                  padding: EdgeInsets.only(
                      top: 5.h, left: 20.w, right: 20.w, bottom: 12.h),
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
                            Text('Invite Groups',
                                style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold)),
                            Text(widget.event.eventName,
                                style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade400),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      // In the header Row, after the Expanded column, add:
                      if (_totalSelected > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: accentGreen,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(children: [
                            Icon(Icons.people_rounded, color: Colors.white, size: 13.sp),
                            4.width,
                            Text('$_totalSelected',
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 12.sp,
                                    fontWeight: FontWeight.w700)),
                          ]),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Info banner ──────────────────────────────────────────
            Container(
              margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              padding: EdgeInsets.all(11.w),
              decoration: BoxDecoration(
                color: accentGreen.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: accentGreen.withOpacity(0.2)),
              ),
              child: Row(children: [
                Icon(Icons.info_outline_rounded,
                    color: accentGreen, size: 15.sp),
                8.width,
                Expanded(
                  child: Text(
                    'Expand a group → expand a sub-group → uncheck any members you want to exclude. All checked members will be invited.',
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp, color: Colors.black87),
                  ),
                ),
              ]),
            ),

            // ── Group list ───────────────────────────────────────────
            Expanded(
              child: _loading
                  ? _shimmerList()
                  : _groups.isEmpty
                  ? Center(
                  child: Text('No groups available',
                      style: GoogleFonts.poppins(
                          color: textSecondary)))
                  : ListView.builder(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 12.h),
                itemCount: _groups.length,
                itemBuilder: (_, i) => _groupTile(_groups[i]),
              ),
            ),

            // ── Send button ──────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -4))
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_submitting || _totalSelected == 0) ? null : _sendInvites,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: _submitting
                      ? AppUI.buttonSpinner()
                      : Text(
                      _totalSelected == 0
                          ? 'Select members to invite'
                          : 'Send Invites ($_totalSelected)',
                      style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupTile(GroupData group) {
    final isExpanded = _expandedGroups.contains(group.groupId);
    final isLoadingSubs = _loadingSubGroups.contains(group.groupId);
    final subGroups = _subGroups[group.groupId];

    // Count selected in this group (direct + all subgroups)
    int groupSelectedCount = (_checkedGroupMembers[group.groupId] ?? {}).length;
    if (subGroups != null) {
      for (final sg in subGroups) {
        groupSelectedCount += (_checkedMembers[sg.subGroupId] ?? {}).length;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: groupSelectedCount > 0
                ? accentGreen.withOpacity(0.4)
                : accentGreen.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // Group header row
          InkWell(
            onTap: () => _toggleGroup(group.groupId),
            borderRadius: isExpanded
                ? BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r))
                : BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r)),
                    child: Center(
                      child: Text(
                          group.name.isNotEmpty
                              ? group.name[0].toUpperCase()
                              : 'G',
                          style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: accentGreen)),
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.name,
                            style: GoogleFonts.montserrat(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        Text(
                          isExpanded
                              ? isLoadingSubs
                              ? 'Loading sub-groups...'
                              : '${subGroups?.length ?? 0} sub-group(s)'
                              : 'Tap to expand',
                          style: GoogleFonts.poppins(
                              fontSize: 10.sp, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Selected badge for group
                  if (groupSelectedCount > 0) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: accentGreen,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text('$groupSelectedCount selected',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600)),
                    ),
                    8.width,
                  ],
                  // Chevron or spinner
                  isLoadingSubs
                      ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: accentGreen))
                      : Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: accentGreen,
                      size: 22.sp),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200),

            if (isLoadingSubs)
              _inlineShimmer()
            else ...[
              Builder(builder: (_) {
                final groupMembers = _groupMembers[group.groupId];
                final isLoadingGM = _loadingGroupMembers.contains(group.groupId);
                final checked = _checkedGroupMembers[group.groupId] ?? {};

                if (isLoadingGM) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 4.h),
                        child: Text('Direct Members',
                            style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: textSecondary)),
                      ),
                      _inlineShimmer(itemHeight: 44.h, itemCount: 2),
                    ],
                  );
                }

                if (groupMembers != null && groupMembers.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 4.h),
                        child: Row(children: [
                          Icon(Icons.person_rounded, size: 13.sp, color: accentGreen),
                          6.width,
                          Expanded(
                            child: Text(
                                'Direct Members (${groupMembers.length})',
                                style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: accentGreen)),
                          ),
                          GestureDetector(
                            onTap: () => _selectAllGroupMembers(group.groupId),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: (checked.length == groupMembers.length &&
                                    groupMembers.isNotEmpty)
                                    ? Colors.red.withOpacity(0.08)
                                    : accentGreen.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                    color: (checked.length == groupMembers.length &&
                                        groupMembers.isNotEmpty)
                                        ? Colors.red.withOpacity(0.3)
                                        : accentGreen.withOpacity(0.3)),
                              ),
                              child: Text(
                                (checked.length == groupMembers.length &&
                                    groupMembers.isNotEmpty)
                                    ? 'Deselect All'
                                    : 'Select All',
                                style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: (checked.length == groupMembers.length &&
                                        groupMembers.isNotEmpty)
                                        ? Colors.red
                                        : accentGreen),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      ...groupMembers.map((m) {
                        final isChecked = checked.contains(m.memberId);
                        return CheckboxListTile(
                          dense: true,
                          value: isChecked,
                          activeColor: accentGreen,
                          onChanged: (_) =>
                              _toggleGroupMember(group.groupId, m.memberId),
                          title: Text(m.username,
                              style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: isChecked
                                      ? Colors.black87
                                      : Colors.grey.shade500)),
                          subtitle: Text(m.email,
                              style: GoogleFonts.poppins(
                                  fontSize: 10.sp, color: textSecondary)),
                          controlAffinity: ListTileControlAffinity.leading,
                          secondary: CircleAvatar(
                            radius: 14.r,
                            backgroundColor:
                            (isChecked ? accentGreen : Colors.grey)
                                .withOpacity(0.12),
                            child: Text(
                                m.username.isNotEmpty
                                    ? m.username[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.montserrat(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isChecked ? accentGreen : Colors.grey)),
                          ),
                        );
                      }),
                      Divider(height: 1, color: Colors.grey.shade200),
                    ],
                  );
                }

                return const SizedBox.shrink();
              }),

              if (subGroups == null || subGroups.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14.sp, color: textSecondary),
                    8.width,
                    Text('No sub-groups in this group',
                        style: GoogleFonts.poppins(
                            fontSize: 12.sp, color: textSecondary)),
                  ]),
                )
              else
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 4.h),
                        child: Row(children: [
                          Icon(Icons.group_work_rounded,
                              size: 13.sp, color: Colors.blue),
                          6.width,
                          Text('Sub-groups (${subGroups.length})',
                              style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue)),
                        ]),
                      ),
                      ...subGroups.map((sg) => _subGroupTile(sg)),
                    ],
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }

  // ── Sub-group tile ─────────────────────────────────────────────
  Widget _subGroupTile(SubGroupData subGroup) {
    final isExpanded = _expandedSubGroups.contains(subGroup.subGroupId);
    final isLoadingMems = _loadingMembers.contains(subGroup.subGroupId);
    final members = _members[subGroup.subGroupId];
    // final unchecked = _uncheckedMembers[subGroup.subGroupId] ?? {};
    // final checkedCount = (members?.length ?? 0) - unchecked.length;
    final checked = _checkedMembers[subGroup.subGroupId] ?? {};
    final checkedCount = checked.length;
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Sub-group header row
          InkWell(
            onTap: () => _toggleSubGroup(subGroup.subGroupId),
            borderRadius: isExpanded
                ? BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r))
                : BorderRadius.circular(12.r),
            child: Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r)),
                    child: Icon(Icons.group_work_rounded,
                        color: Colors.blue, size: 15.sp),
                  ),
                  10.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subGroup.name,
                            style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                        Text(
                          isExpanded
                              ? isLoadingMems
                              ? 'Loading members...'
                              : members == null || members.isEmpty
                              ? 'No members'
                              : '$checkedCount of ${members.length} will be invited'
                              : subGroup.ageCategory != null
                              ? 'Age: ${subGroup.ageCategory} · Tap to manage'
                              : 'Tap to manage members',
                          style: GoogleFonts.poppins(
                              fontSize: 10.sp, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Chevron or spinner
                  isLoadingMems
                      ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.blue))
                      : Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.blue,
                      size: 20.sp),
                ],
              ),
            ),
          ),

          // Expanded member list
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200),

            // Shimmer while loading members
            if (isLoadingMems)
              _inlineShimmer(itemHeight: 44.h, itemCount: 3)
            else if (members == null || members.isEmpty)
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(children: [
                  Icon(Icons.people_outline_rounded,
                      size: 14.sp, color: textSecondary),
                  8.width,
                  Text('No members in this sub-group',
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp, color: textSecondary)),
                ]),
              )
            else
              Column(
                children: [
                  // Select All bar
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
                    child: Row(children: [
                      Text('${members.length} member${members.length > 1 ? 's' : ''}',
                          style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _selectAllSubMembers(subGroup.subGroupId),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: (checked.length == members.length && members.isNotEmpty)
                                ? Colors.red.withOpacity(0.08)
                                : Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                                color: (checked.length == members.length && members.isNotEmpty)
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.blue.withOpacity(0.3)),
                          ),
                          child: Text(
                            (checked.length == members.length && members.isNotEmpty)
                                ? 'Deselect All' : 'Select All',
                            style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: (checked.length == members.length && members.isNotEmpty)
                                    ? Colors.red : Colors.blue),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  ...members.map((m) {
                    final isChecked = checked.contains(m.memberId);
                    return CheckboxListTile(
                      dense: true,
                      value: isChecked,
                      activeColor: accentGreen,
                      onChanged: (_) => _toggleMember(subGroup.subGroupId, m.memberId),
                      title: Text(m.name,
                          style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: isChecked ? Colors.black87 : Colors.grey.shade500)),
                      subtitle: Text(m.email,
                          style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary)),
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: CircleAvatar(
                        radius: 14.r,
                        backgroundColor: (isChecked ? accentGreen : Colors.grey).withOpacity(0.12),
                        child: Text(
                            m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                            style: GoogleFonts.montserrat(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: isChecked ? accentGreen : Colors.grey)),
                      ),
                    );
                  }).toList(),
                ],
              ),
          ],
        ],
      ),
    );
  }

  // ── Inline shimmer (shown inside expanded tiles while loading) ──
  Widget _inlineShimmer({double? itemHeight, int itemCount = 2}) {
    return _InlineShimmer(
        itemHeight: itemHeight ?? 48.h, itemCount: itemCount);
  }

  // ── Full-page shimmer (initial load) ───────────────────────────
  Widget _shimmerList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: 4,
      itemBuilder: (_, __) => _InlineShimmer(
          itemHeight: 64.h, itemCount: 1, radius: 16.r),
    );
  }
}

// ── Shimmer widget ─────────────────────────────────────────────────────────

class _InlineShimmer extends StatefulWidget {
  final double itemHeight;
  final int itemCount;
  final double? radius;

  const _InlineShimmer({
    required this.itemHeight,
    required this.itemCount,
    this.radius,
  });

  @override
  State<_InlineShimmer> createState() => _InlineShimmerState();
}

class _InlineShimmerState extends State<_InlineShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 0.6).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
      builder: (_, __) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: Column(
          children: List.generate(
            widget.itemCount,
                (i) => Container(
              margin: EdgeInsets.only(bottom: 8.h),
              height: widget.itemHeight,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(_anim.value),
                borderRadius:
                BorderRadius.circular(widget.radius ?? 10.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}