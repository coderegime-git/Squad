// screens/coach/coach_invite_groups_screen.dart
// Coach: Invite Groups to an event
// - All members start UNCHECKED by default
// - Tap checkbox to select individual members
// - "Select All" / "Deselect All" button per group and subgroup
// - Floating badge shows how many members are currently selected
// - "Send Invites" shows a confirmation dialog listing selected members
// - Confirm → calls POST /api/events/{eventId}/members

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

class CoachInviteGroupsScreen extends StatefulWidget {
  final eventModel.Data event;

  const CoachInviteGroupsScreen({super.key, required this.event});

  @override
  State<CoachInviteGroupsScreen> createState() =>
      _CoachInviteGroupsScreenState();
}

class _CoachInviteGroupsScreenState extends State<CoachInviteGroupsScreen> {
  final ClubApiService _api = ClubApiService();

  List<GroupData> _groups = [];
  bool _loading = true;
  bool _submitting = false;
  final Map<int, List<memberModel.Data>?> _groupMembers = {};
  final Set<int> _loadingGroupMembers = {};
  final Map<int, Set<int>> _checkedGroupMembers = {};
  final Map<int, List<subMemberModel.SubMemData>?> _subMembers = {};
  final Set<int> _loadingSubMembers = {};
  final Map<int, Set<int>> _checkedSubMembers = {};

  // Subgroups per group
  final Map<int, List<SubGroupData>?> _subGroups = {};
  final Set<int> _loadingSubGroups = {};

  final Set<int> _expandedGroups = {};
  final Set<int> _expandedSubGroups = {};

  int get _totalSelected {
    final Set<int> all = {};
    _checkedGroupMembers.forEach((_, ids) => all.addAll(ids));
    _checkedSubMembers.forEach((_, ids) => all.addAll(ids));
    return all.length;
  }

  List<Map<String, String>> get _selectedMemberDetails {
    final Map<int, Map<String, String>> details = {};

    _checkedGroupMembers.forEach((gId, ids) {
      final members = _groupMembers[gId];
      if (members == null) return;
      for (final m in members) {
        if (ids.contains(m.memberId)) {
          details[m.memberId] = {'name': m.username, 'email': m.email};
        }
      }
    });

    _checkedSubMembers.forEach((sgId, ids) {
      final members = _subMembers[sgId];
      if (members == null) return;
      for (final m in members) {
        if (ids.contains(m.memberId)) {
          details[m.memberId] = {'name': m.name, 'email': m.email};
        }
      }
    });

    return details.values.toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    try {
      final groups = await _api.getAllGroups();
      if (mounted) setState(() { _groups = groups; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchSubGroups(int groupId) async {
    if (_subGroups.containsKey(groupId)) return;
    setState(() => _loadingSubGroups.add(groupId));
    try {
      final result = await _api.getSubGroups(groupId);
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
      final result = await _api.getGroupDirectMembers(groupId);
      if (mounted) setState(() {
        _groupMembers[groupId] = result;
        _checkedGroupMembers[groupId] = {}; // starts empty = all unchecked
      });
    } catch (_) {
      if (mounted) setState(() => _groupMembers[groupId] = []);
    } finally {
      if (mounted) setState(() => _loadingGroupMembers.remove(groupId));
    }
  }

  Future<void> _fetchSubGroupMembers(int subGroupId) async {
    if (_subMembers.containsKey(subGroupId)) return;
    setState(() => _loadingSubMembers.add(subGroupId));
    try {
      final result = await _api.getSubGroupMembers(subGroupId);
      if (mounted) setState(() {
        _subMembers[subGroupId] = result.data;
        _checkedSubMembers[subGroupId] = {}; // starts empty = all unchecked
      });
    } catch (_) {
      if (mounted) setState(() => _subMembers[subGroupId] = []);
    } finally {
      if (mounted) setState(() => _loadingSubMembers.remove(subGroupId));
    }
  }

  void _toggleGroup(int groupId) {
    setState(() {
      if (_expandedGroups.contains(groupId)) {
        _expandedGroups.remove(groupId);
      } else {
        _expandedGroups.add(groupId);
        _fetchSubGroups(groupId);
      }
    });
  }

  void _toggleSubGroup(int subGroupId) {
    setState(() {
      if (_expandedSubGroups.contains(subGroupId)) {
        _expandedSubGroups.remove(subGroupId);
      } else {
        _expandedSubGroups.add(subGroupId);
        _fetchSubGroupMembers(subGroupId);
      }
    });
  }

  // CHANGED: toggle adds/removes from CHECKED set
  void _toggleGroupMember(int groupId, int memberId) {
    setState(() {
      final s = _checkedGroupMembers[groupId] ?? {};
      s.contains(memberId) ? s.remove(memberId) : s.add(memberId);
      _checkedGroupMembers[groupId] = s;
    });
  }

  void _toggleSubMember(int subGroupId, int memberId) {
    setState(() {
      final s = _checkedSubMembers[subGroupId] ?? {};
      s.contains(memberId) ? s.remove(memberId) : s.add(memberId);
      _checkedSubMembers[subGroupId] = s;
    });
  }

  // ── Select All / Deselect All for a group's direct members ─────────────────
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

  // ── Select All / Deselect All for a subgroup ───────────────────────────────
  void _selectAllSubMembers(int subGroupId) {
    final members = _subMembers[subGroupId];
    if (members == null) return;
    final allIds = members.map((m) => m.memberId).toSet();
    final checked = _checkedSubMembers[subGroupId] ?? {};
    final allSelected = allIds.every((id) => checked.contains(id));
    setState(() {
      _checkedSubMembers[subGroupId] = allSelected ? {} : Set.from(allIds);
    });
  }

  // ── Show confirmation dialog before sending ────────────────────────────────
  Future<void> _showConfirmDialog() async {
    final memberDetails = _selectedMemberDetails;
    if (memberDetails.isEmpty) {
      toast('Please select at least one member to invite');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: accentGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: Column(children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 26.sp),
                ),
                10.height,
                Text(
                  'Confirm Invites',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                6.height,
                Text(
                  '${memberDetails.length} member${memberDetails.length > 1 ? 's' : ''} will be invited to',
                  style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 12.sp),
                  textAlign: TextAlign.center,
                ),
                4.height,
                Text(
                  widget.event.eventName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),

            // Member list
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300.h),
              child: Scrollbar(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: memberDetails.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (_, i) {
                    final m = memberDetails[i];
                    final name = m['name'] ?? '';
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 16.r,
                          backgroundColor: accentGreen.withOpacity(0.12),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: GoogleFonts.montserrat(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: accentGreen,
                            ),
                          ),
                        ),
                        10.width,
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: GoogleFonts.poppins(
                                    fontSize: 13.sp, fontWeight: FontWeight.w600)),
                            Text(m['email'] ?? '',
                                style: GoogleFonts.poppins(
                                    fontSize: 11.sp, color: textSecondary)),
                          ],
                        )),
                        Icon(Icons.check_circle_rounded, color: accentGreen, size: 16.sp),
                      ]),
                    );
                  },
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.poppins(
                            fontSize: 13.sp, fontWeight: FontWeight.w600)),
                  ),
                ),
                12.width,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('Confirm',
                        style: GoogleFonts.poppins(
                            fontSize: 13.sp, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      _sendInvites();
    }
  }

  Future<void> _sendInvites() async {
    setState(() => _submitting = true);
    final Set<int> invited = {};

    _checkedGroupMembers.forEach((_, ids) => invited.addAll(ids));
    _checkedSubMembers.forEach((_, ids) => invited.addAll(ids));

    try {
      final success = await _api.addMembersToEvent(
          widget.event.eventId, invited.toList());
      if (mounted) {
        setState(() => _submitting = false);
        if (success) {
          toast('Invites sent to ${invited.length} member(s)!', bgColor: accentGreen);
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
    final selected = _totalSelected;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            _buildHeader(),
            _buildInfoBanner(),
            Expanded(
              child: _loading
                  ? _shimmer()
                  : _groups.isEmpty
                  ? Center(
                  child: Text('No groups found',
                      style: GoogleFonts.poppins(color: textSecondary)))
                  : ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                itemCount: _groups.length,
                itemBuilder: (_, i) => _groupTile(_groups[i]),
              ),
            ),
            _buildSendButton(selected),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16)),
    ),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 14.h),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 20.sp),
          ),
          16.width,
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invite Groups',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontSize: 20.sp,
                      fontWeight: FontWeight.bold)),
              Text(widget.event.eventName,
                  style: GoogleFonts.poppins(
                      fontSize: 11.sp, color: Colors.grey.shade400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          )),
          // Live selected count badge in header
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
        ]),
      ),
    ),
  );

  Widget _buildInfoBanner() => Container(
    margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
    padding: EdgeInsets.all(11.w),
    decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2))),
    child: Row(children: [
      Icon(Icons.info_outline_rounded, color: Colors.blue, size: 15.sp),
      8.width,
      Expanded(
        child: Text(
          'Expand a group → check the members you want to invite. Use "Select All" to quickly pick everyone.',
          style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.black87),
        ),
      ),
    ]),
  );

  Widget _buildSendButton(int selected) => Container(
    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
    decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 10, offset: const Offset(0, -4))
        ]),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_submitting || selected == 0) ? null : _showConfirmDialog,
        style: ElevatedButton.styleFrom(
            backgroundColor: accentGreen,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r))),
        child: _submitting
            ? SizedBox(height: 20.h, width: 20.h,
            child: const CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.send_rounded, size: 16.sp, color: Colors.white),
          8.width,
          Text(
            selected == 0
                ? 'Select members to invite'
                : 'Send Invites ($selected)',
            style: GoogleFonts.poppins(
                fontSize: 14.sp, fontWeight: FontWeight.w700),
          ),
        ]),
      ),
    ),
  );

  Widget _groupTile(GroupData group) {
    final isExpanded = _expandedGroups.contains(group.groupId);
    final isLoading = _loadingSubGroups.contains(group.groupId);
    final subGroups = _subGroups[group.groupId];

    // Count selected in this group (direct + all subgroups)
    int groupSelectedCount = (_checkedGroupMembers[group.groupId] ?? {}).length;
    if (subGroups != null) {
      for (final sg in subGroups) {
        groupSelectedCount += (_checkedSubMembers[sg.subGroupId] ?? {}).length;
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
                  : accentGreen.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03),
                blurRadius: 6, offset: const Offset(0, 2))
          ]),
      child: Column(children: [
        // Header
        InkWell(
          onTap: () => _toggleGroup(group.groupId),
          borderRadius: isExpanded
              ? BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r))
              : BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(children: [
              Container(
                width: 40.w, height: 40.w,
                decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r)),
                child: Center(
                  child: Text(
                    group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                    style: GoogleFonts.montserrat(
                        fontSize: 16.sp, fontWeight: FontWeight.w800,
                        color: accentGreen),
                  ),
                ),
              ),
              12.width,
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name,
                      style: GoogleFonts.montserrat(
                          fontSize: 13.sp, fontWeight: FontWeight.w700)),
                  Text(
                    isExpanded
                        ? isLoading ? 'Loading...'
                        : '${subGroups?.length ?? 0} sub-group(s)'
                        : 'Tap to expand',
                    style: GoogleFonts.poppins(
                        fontSize: 10.sp, color: textSecondary),
                  ),
                ],
              )),
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
                          color: Colors.white, fontSize: 10.sp,
                          fontWeight: FontWeight.w600)),
                ),
                8.width,
              ],
              isLoading
                  ? SizedBox(width: 18.w, height: 18.w,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: accentGreen))
                  : Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: accentGreen, size: 22.sp),
            ]),
          ),
        ),

        // Expanded content
        if (isExpanded) ...[
          Divider(height: 1, color: Colors.grey.shade200),
          if (isLoading)
            _inlineShimmer()
          else ...[
            // Direct members
            _buildDirectMembers(group.groupId),
            // Sub-groups
            if (subGroups != null && subGroups.isNotEmpty)
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
                                fontSize: 11.sp, fontWeight: FontWeight.w600,
                                color: Colors.blue)),
                      ]),
                    ),
                    ...subGroups.map((sg) => _subGroupTile(sg)),
                  ],
                ),
              )
            else
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(children: [
                  Icon(Icons.info_outline_rounded, size: 13.sp, color: textSecondary),
                  8.width,
                  Text('No sub-groups',
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp, color: textSecondary)),
                ]),
              ),
          ],
        ],
      ]),
    );
  }

  Widget _buildDirectMembers(int groupId) {
    final isLoading = _loadingGroupMembers.contains(groupId);
    final members = _groupMembers[groupId];
    final checked = _checkedGroupMembers[groupId] ?? {};

    if (isLoading) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 4.h),
          child: Text('Direct Members',
              style: GoogleFonts.poppins(
                  fontSize: 11.sp, fontWeight: FontWeight.w600,
                  color: textSecondary)),
        ),
        _inlineShimmer(itemHeight: 44.h, itemCount: 2),
      ]);
    }

    if (members == null || members.isEmpty) return const SizedBox.shrink();

    final allSelected = members.every((m) => checked.contains(m.memberId));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header row with Select All button
      Padding(
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 4.h),
        child: Row(children: [
          Icon(Icons.person_rounded, size: 13.sp, color: accentGreen),
          6.width,
          Expanded(
            child: Text('Direct Members (${members.length})',
                style: GoogleFonts.poppins(
                    fontSize: 11.sp, fontWeight: FontWeight.w600,
                    color: accentGreen)),
          ),
          // Select All / Deselect All
          GestureDetector(
            onTap: () => _selectAllGroupMembers(groupId),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: allSelected
                    ? Colors.red.withOpacity(0.08)
                    : accentGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                    color: allSelected
                        ? Colors.red.withOpacity(0.3)
                        : accentGreen.withOpacity(0.3)),
              ),
              child: Text(
                allSelected ? 'Deselect All' : 'Select All',
                style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: allSelected ? Colors.red : accentGreen),
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
          onChanged: (_) => _toggleGroupMember(groupId, m.memberId),
          title: Text(m.username,
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
              m.username.isNotEmpty ? m.username[0].toUpperCase() : '?',
              style: GoogleFonts.montserrat(
                  fontSize: 10.sp, fontWeight: FontWeight.w700,
                  color: isChecked ? accentGreen : Colors.grey),
            ),
          ),
        );
      }),
      Divider(height: 1, color: Colors.grey.shade200),
    ]);
  }

  Widget _subGroupTile(SubGroupData sg) {
    final isExpanded = _expandedSubGroups.contains(sg.subGroupId);
    final isLoading = _loadingSubMembers.contains(sg.subGroupId);
    final members = _subMembers[sg.subGroupId];
    final checked = _checkedSubMembers[sg.subGroupId] ?? {};
    final checkedCount = checked.length;
    final totalCount = members?.length ?? 0;
    final allSelected = totalCount > 0 && members!.every((m) => checked.contains(m.memberId));

    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 0),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
              color: checkedCount > 0
                  ? Colors.blue.withOpacity(0.35)
                  : Colors.blue.withOpacity(0.15))),
      child: Column(children: [
        InkWell(
          onTap: () => _toggleSubGroup(sg.subGroupId),
          borderRadius: isExpanded
              ? BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r))
              : BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r)),
                child: Icon(Icons.group_work_rounded,
                    color: Colors.blue, size: 15.sp),
              ),
              10.width,
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sg.name,
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp, fontWeight: FontWeight.w600)),
                  Text(
                    isExpanded
                        ? isLoading ? 'Loading members...'
                        : members == null || members.isEmpty ? 'No members'
                        : checkedCount == 0
                        ? 'None selected · tap to choose'
                        : '$checkedCount of $totalCount selected'
                        : sg.ageCategory != null
                        ? 'Age: ${sg.ageCategory} · Tap to manage'
                        : 'Tap to select members',
                    style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: checkedCount > 0 ? accentGreen : textSecondary),
                  ),
                ],
              )),
              // Selected badge
              if (checkedCount > 0) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: accentGreen,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text('$checkedCount',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 10.sp,
                          fontWeight: FontWeight.w700)),
                ),
                6.width,
              ],
              isLoading
                  ? SizedBox(width: 16.w, height: 16.w,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.blue))
                  : Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.blue, size: 20.sp),
            ]),
          ),
        ),
        if (isExpanded) ...[
          Divider(height: 1, color: Colors.grey.shade200),
          if (isLoading)
            _inlineShimmer(itemHeight: 44.h, itemCount: 3)
          else if (members == null || members.isEmpty)
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(children: [
                Icon(Icons.people_outline_rounded,
                    size: 14.sp, color: textSecondary),
                8.width,
                Text('No members',
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp, color: textSecondary)),
              ]),
            )
          else
            Column(
              children: [
                // Select All bar for subgroup
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
                  child: Row(children: [
                    Text('${members.length} member${members.length > 1 ? 's' : ''}',
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp, color: textSecondary)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _selectAllSubMembers(sg.subGroupId),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: allSelected
                              ? Colors.red.withOpacity(0.08)
                              : Colors.blue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                              color: allSelected
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.3)),
                        ),
                        child: Text(
                          allSelected ? 'Deselect All' : 'Select All',
                          style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: allSelected ? Colors.red : Colors.blue),
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
                    onChanged: (_) => _toggleSubMember(sg.subGroupId, m.memberId),
                    title: Text(m.name,
                        style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: isChecked ? Colors.black87 : Colors.grey.shade500)),
                    subtitle: Text(m.email,
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp, color: textSecondary)),
                    controlAffinity: ListTileControlAffinity.leading,
                    secondary: CircleAvatar(
                      radius: 14.r,
                      backgroundColor:
                      (isChecked ? accentGreen : Colors.grey).withOpacity(0.12),
                      child: Text(
                        m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                        style: GoogleFonts.montserrat(
                            fontSize: 10.sp, fontWeight: FontWeight.w700,
                            color: isChecked ? accentGreen : Colors.grey),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
        ],
      ]),
    );
  }

  Widget _inlineShimmer({double? itemHeight, int itemCount = 2}) =>
      _ShimmerBlock(itemHeight: itemHeight ?? 48.h, itemCount: itemCount);

  Widget _shimmer() => ListView.builder(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    itemCount: 4,
    itemBuilder: (_, __) =>
        _ShimmerBlock(itemHeight: 64.h, itemCount: 1, radius: 16.r),
  );
}

// ── Shimmer ───────────────────────────────────────────────────────────────────
class _ShimmerBlock extends StatefulWidget {
  final double itemHeight;
  final int itemCount;
  final double? radius;
  const _ShimmerBlock({required this.itemHeight, required this.itemCount, this.radius});

  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.2, end: 0.55).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: Column(
          children: List.generate(widget.itemCount, (_) => Container(
            margin: EdgeInsets.only(bottom: 8.h),
            height: widget.itemHeight,
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(_anim.value),
                borderRadius: BorderRadius.circular(widget.radius ?? 10.r)),
          )),
        ),
      ),
    );
  }
}