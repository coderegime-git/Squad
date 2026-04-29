// screens/coach/coach_invite_groups_screen.dart
// Coach: Invite Groups to an event
// Same as ClubAdmin InviteGroupsScreen but for coach role
// - Expand group → see subgroups + direct members
// - Expand subgroup → see members with checkboxes
// - Uncheck to exclude
// - "Send Invites" calls POST /api/events/{eventId}/members

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

  // Group-level direct members
  final Map<int, List<memberModel.Data>?> _groupMembers = {};
  final Set<int> _loadingGroupMembers = {};
  final Map<int, Set<int>> _uncheckedGroupMembers = {};

  // Subgroup members
  final Map<int, List<subMemberModel.SubMemData>?> _subMembers = {};
  final Set<int> _loadingSubMembers = {};
  final Map<int, Set<int>> _uncheckedSubMembers = {};

  // Subgroups per group
  final Map<int, List<SubGroupData>?> _subGroups = {};
  final Set<int> _loadingSubGroups = {};

  final Set<int> _expandedGroups = {};
  final Set<int> _expandedSubGroups = {};

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
        _uncheckedGroupMembers[groupId] = {};
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
        _uncheckedSubMembers[subGroupId] = {};
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

  void _toggleGroupMember(int groupId, int memberId) {
    setState(() {
      final s = _uncheckedGroupMembers[groupId] ?? {};
      s.contains(memberId) ? s.remove(memberId) : s.add(memberId);
      _uncheckedGroupMembers[groupId] = s;
    });
  }

  void _toggleSubMember(int subGroupId, int memberId) {
    setState(() {
      final s = _uncheckedSubMembers[subGroupId] ?? {};
      s.contains(memberId) ? s.remove(memberId) : s.add(memberId);
      _uncheckedSubMembers[subGroupId] = s;
    });
  }

  Future<void> _sendInvites() async {
    setState(() => _submitting = true);
    final Set<int> invited = {};

    _groupMembers.forEach((gId, members) {
      if (members == null) return;
      final unchecked = _uncheckedGroupMembers[gId] ?? {};
      for (final m in members) {
        if (!unchecked.contains(m.memberId)) invited.add(m.memberId);
      }
    });

    _subMembers.forEach((sgId, members) {
      if (members == null) return;
      final unchecked = _uncheckedSubMembers[sgId] ?? {};
      for (final m in members) {
        if (!unchecked.contains(m.memberId)) invited.add(m.memberId);
      }
    });

    if (invited.isEmpty) {
      setState(() => _submitting = false);
      toast('No members selected to invite');
      return;
    }

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
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 12.h),
                itemCount: _groups.length,
                itemBuilder: (_, i) => _groupTile(_groups[i]),
              ),
            ),
            _buildSendButton(),
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
        ]),
      ),
    ),
  );

  Widget _buildInfoBanner() => Container(
    margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
    padding: EdgeInsets.all(11.w),
    decoration: BoxDecoration(
        color: accentGreen.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: accentGreen.withOpacity(0.2))),
    child: Row(children: [
      Icon(Icons.info_outline_rounded, color: accentGreen, size: 15.sp),
      8.width,
      Expanded(
        child: Text(
          'Expand a group to see members. Uncheck anyone you want to exclude.',
          style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.black87),
        ),
      ),
    ]),
  );

  Widget _buildSendButton() => Container(
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
        onPressed: _submitting ? null : _sendInvites,
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
            : Text('Send Invites',
            style: GoogleFonts.poppins(
                fontSize: 14.sp, fontWeight: FontWeight.w700)),
      ),
    ),
  );

  Widget _groupTile(GroupData group) {
    final isExpanded = _expandedGroups.contains(group.groupId);
    final isLoading = _loadingSubGroups.contains(group.groupId);
    final subGroups = _subGroups[group.groupId];

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: accentGreen.withOpacity(0.25)),
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
    final unchecked = _uncheckedGroupMembers[groupId] ?? {};

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

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 4.h),
        child: Row(children: [
          Icon(Icons.person_rounded, size: 13.sp, color: accentGreen),
          6.width,
          Text('Direct Members (${members.length})',
              style: GoogleFonts.poppins(
                  fontSize: 11.sp, fontWeight: FontWeight.w600,
                  color: accentGreen)),
        ]),
      ),
      ...members.map((m) {
        final checked = !unchecked.contains(m.memberId);
        return CheckboxListTile(
          dense: true,
          value: checked,
          activeColor: accentGreen,
          onChanged: (_) => _toggleGroupMember(groupId, m.memberId),
          title: Text(m.username,
              style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black87)),
          subtitle: Text(m.email,
              style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary)),
          controlAffinity: ListTileControlAffinity.leading,
          secondary: CircleAvatar(
            radius: 14.r,
            backgroundColor: (checked ? accentGreen : Colors.grey).withOpacity(0.12),
            child: Text(
              m.username.isNotEmpty ? m.username[0].toUpperCase() : '?',
              style: GoogleFonts.montserrat(
                  fontSize: 10.sp, fontWeight: FontWeight.w700,
                  color: checked ? accentGreen : Colors.grey),
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
    final unchecked = _uncheckedSubMembers[sg.subGroupId] ?? {};
    final checkedCount = (members?.length ?? 0) - unchecked.length;

    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 0),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.blue.withOpacity(0.2))),
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
                        : '$checkedCount of ${members.length} will be invited'
                        : sg.ageCategory != null
                        ? 'Age: ${sg.ageCategory} · Tap to manage'
                        : 'Tap to manage members',
                    style: GoogleFonts.poppins(
                        fontSize: 10.sp, color: textSecondary),
                  ),
                ],
              )),
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
              children: members.map((m) {
                final checked = !unchecked.contains(m.memberId);
                return CheckboxListTile(
                  dense: true,
                  value: checked,
                  activeColor: accentGreen,
                  onChanged: (_) => _toggleSubMember(sg.subGroupId, m.memberId),
                  title: Text(m.name,
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp, color: Colors.black87)),
                  subtitle: Text(m.email,
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp, color: textSecondary)),
                  controlAffinity: ListTileControlAffinity.leading,
                  secondary: CircleAvatar(
                    radius: 14.r,
                    backgroundColor:
                    (checked ? accentGreen : Colors.grey).withOpacity(0.12),
                    child: Text(
                      m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                      style: GoogleFonts.montserrat(
                          fontSize: 10.sp, fontWeight: FontWeight.w700,
                          color: checked ? accentGreen : Colors.grey),
                    ),
                  ),
                );
              }).toList(),
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