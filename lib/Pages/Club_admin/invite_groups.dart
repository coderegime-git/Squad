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

  bool _submitting = false;

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
          _uncheckedGroupMembers[groupId] = {};
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
      final set = _uncheckedGroupMembers[groupId] ?? {};
      if (set.contains(memberId)) set.remove(memberId);
      else set.add(memberId);
      _uncheckedGroupMembers[groupId] = set;
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
          _uncheckedMembers[subGroupId] = {};
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
      final set = _uncheckedMembers[subGroupId] ?? {};
      if (set.contains(memberId)) set.remove(memberId);
      else set.add(memberId);
      _uncheckedMembers[subGroupId] = set;
    });
  }

  Future<void> _sendInvites() async {
    setState(() => _submitting = true);

    final Set<int> invitedMemberIds = {};

    _members.forEach((subGroupId, members) {
      if (members == null) return;
      final unchecked = _uncheckedMembers[subGroupId] ?? {};
      for (final m in members) {
        if (!unchecked.contains(m.memberId)) invitedMemberIds.add(m.memberId);
      }
    });

    _groupMembers.forEach((groupId, members) {
      if (members == null) return;
      final unchecked = _uncheckedGroupMembers[groupId] ?? {};
      for (final m in members) {
        if (!unchecked.contains(m.memberId)) invitedMemberIds.add(m.memberId);
      }
    });

    if (invitedMemberIds.isEmpty) {
      setState(() => _submitting = false);
      toast('No members selected to invite');
      return;
    }

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
    } catch (e) {
      if (mounted) setState(() => _submitting = false);
      toast('Failed to send invites');
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
                  onPressed: _submitting ? null : _sendInvites,
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
                      : Text('Send Invites',
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Group tile ─────────────────────────────────────────────────
  Widget _groupTile(GroupData group) {
    final isExpanded = _expandedGroups.contains(group.groupId);
    final isLoadingSubs = _loadingSubGroups.contains(group.groupId);
    final subGroups = _subGroups[group.groupId];

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accentGreen.withOpacity(0.25)),
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
                final unchecked = _uncheckedGroupMembers[group.groupId] ?? {};

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
                          Text('Direct Members (${groupMembers.length})',
                              style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: accentGreen)),
                        ]),
                      ),
                      ...groupMembers.map((m) {
                        final isChecked = !unchecked.contains(m.memberId);
                        return CheckboxListTile(
                          dense: true,
                          value: isChecked,
                          activeColor: accentGreen,
                          onChanged: (_) => _toggleGroupMember(group.groupId, m.memberId),
                          title: Text(m.username,
                              style: GoogleFonts.poppins(
                                  fontSize: 12.sp, color: Colors.black87)),
                          subtitle: Text(m.email,
                              style: GoogleFonts.poppins(
                                  fontSize: 10.sp, color: textSecondary)),
                          controlAffinity: ListTileControlAffinity.leading,
                          secondary: CircleAvatar(
                            radius: 14.r,
                            backgroundColor:
                            (isChecked ? accentGreen : Colors.grey).withOpacity(0.12),
                            child: Text(
                                m.username.isNotEmpty ? m.username[0].toUpperCase() : '?',
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
                    Icon(Icons.info_outline_rounded, size: 14.sp, color: textSecondary),
                    8.width,
                    Text('No sub-groups in this group',
                        style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)),
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
                          Icon(Icons.group_work_rounded, size: 13.sp, color: Colors.blue),
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
    final unchecked = _uncheckedMembers[subGroup.subGroupId] ?? {};
    final checkedCount = (members?.length ?? 0) - unchecked.length;

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
                children: members.map((m) {
                  final isChecked = !unchecked.contains(m.memberId);
                  return CheckboxListTile(
                    dense: true,
                    value: isChecked,
                    activeColor: accentGreen,
                    onChanged: (_) =>
                        _toggleMember(subGroup.subGroupId, m.memberId),
                    title: Text(m.name,
                        style: GoogleFonts.poppins(
                            fontSize: 12.sp, color: Colors.black87)),
                    subtitle: Text(m.email,
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp, color: textSecondary)),
                    controlAffinity: ListTileControlAffinity.leading,
                    secondary: CircleAvatar(
                      radius: 14.r,
                      backgroundColor: (isChecked ? accentGreen : Colors.grey)
                          .withOpacity(0.12),
                      child: Text(
                          m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                          style: GoogleFonts.montserrat(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color:
                              isChecked ? accentGreen : Colors.grey)),
                    ),
                  );
                }).toList(),
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