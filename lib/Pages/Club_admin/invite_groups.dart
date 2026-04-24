// screens/clubadmin/invite_groups_screen.dart
// Updated: Invite groups for an event
// - Uses GET /api/groups (standalone groups, not event-groups)
// - Expand group → see subgroups → expand subgroup → see members to uncheck
// - Then POST /api/events/{eventId}/members with selected member IDs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_event_details.dart' as eventModel;
import '../../model/clubAdmin/get_groups.dart';
import '../../model/clubAdmin/getSubGroups.dart';
import '../../model/clubAdmin/get_members.dart' as memberModel;
import '../../model/clubAdmin/get_subgroups_member.dart' as memberModel;
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

  // groupId -> list of subgroups
  Map<int, List<SubGroupData>> _subGroups = {};
  // subGroupId -> list of members
  Map<int, List<memberModel.SubMemData>> _members = {};
  // expanded subgroup ids
  Set<int> _expandedSubGroups = {};
  // unchecked member ids per subgroup
  Map<int, Set<int>> _uncheckedMembers = {};
  // expanded group ids
  Set<int> _expandedGroups = {};

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    try {
      // GET /api/groups — standalone groups (not tied to events)
      final groups = await _apiService.getAllGroups();
      setState(() {
        _groups = groups;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchSubGroups(int groupId) async {
    if (_subGroups.containsKey(groupId)) return;
    try {
      final result = await _apiService.getSubGroups(groupId);
      setState(() => _subGroups[groupId] = result.data);
    } catch (_) {}
  }

  Future<void> _fetchMembers(int subGroupId) async {
    if (_members.containsKey(subGroupId)) return;
    try {
      // GET /api/subgroups/{subGroupId}/members
      final result = await _apiService.getSubGroupMembers(subGroupId);
      setState(() {
        _members[subGroupId] = result.data;
        _uncheckedMembers[subGroupId] = {};
      });
    } catch (_) {}
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
        _fetchMembers(subGroupId);
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

    // Build list of checked (invited) member IDs across all expanded subgroups
    final Set<int> invitedMemberIds = {};
    _members.forEach((subGroupId, members) {
      final unchecked = _uncheckedMembers[subGroupId] ?? {};
      for (final m in members) {
        if (!unchecked.contains(m.memberId)) {
          invitedMemberIds.add(m.memberId);
        }
      }
    });

    if (invitedMemberIds.isEmpty) {
      setState(() => _submitting = false);
      toast('No members selected to invite');
      return;
    }

    // POST /api/events/{eventId}/members — add members to event
    try {
      final success = await _apiService.addMembersToEvent(widget.event.eventId, invitedMemberIds.toList());
      setState(() => _submitting = false);
      if (mounted) {
        if (success) {
          toast('Invites sent to ${invitedMemberIds.length} member(s)!', bgColor: accentGreen);
          Navigator.pop(context);
        } else {
          toast('Failed to send invites. Try again.');
        }
      }
    } catch (e) {
      setState(() => _submitting = false);
      toast('Failed to send invites');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    children: [
                      GestureDetector(onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20.sp)),
                      16.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Invite Groups', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                            Text(widget.event.eventName, style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade400),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: accentGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: accentGreen.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: accentGreen, size: 16.sp),
                  8.width,
                  Expanded(
                    child: Text(
                      'Expand a sub-group to uncheck members who should not receive this invite. All checked members will be invited.',
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: accentGreen))
                  : _groups.isEmpty
                  ? Center(child: Text('No groups available', style: GoogleFonts.poppins(color: textSecondary)))
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                itemCount: _groups.length,
                itemBuilder: (_, i) => _groupTile(_groups[i]),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _sendInvites,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen, foregroundColor: Colors.white, elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: _submitting ? AppUI.buttonSpinner() : Text('Send Invites', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700)),
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
    final subGroups = _subGroups[group.groupId] ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: cardDark, borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accentGreen.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => _toggleGroup(group.groupId),
            leading: Container(
              width: 40.w, height: 40.w,
              decoration: BoxDecoration(color: accentGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(10.r)),
              child: Center(
                child: Text(group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                    style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w800, color: accentGreen)),
              ),
            ),
            title: Text(group.name, style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black)),
            subtitle: Text(isExpanded ? '${subGroups.length} sub-group(s)' : 'Tap to expand sub-groups',
                style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary)),
            trailing: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: accentGreen),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            if (subGroups.isEmpty)
              Padding(padding: EdgeInsets.all(16.w),
                  child: Center(child: Text('No sub-groups', style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary))))
            else
              ...subGroups.map((sg) => _subGroupTile(sg)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _subGroupTile(SubGroupData subGroup) {
    final isExpanded = _expandedSubGroups.contains(subGroup.subGroupId);
    final members = _members[subGroup.subGroupId] ?? [];
    final unchecked = _uncheckedMembers[subGroup.subGroupId] ?? {};
    final checkedCount = members.length - unchecked.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            onTap: () => _toggleSubGroup(subGroup.subGroupId),
            leading: Icon(Icons.group_work_rounded, color: Colors.blue, size: 18.sp),
            title: Text(subGroup.name,
                style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black)),
            subtitle: Text(
              isExpanded
                  ? members.isEmpty ? 'Loading members...' : '$checkedCount of ${members.length} invited'
                  : 'Tap to manage members',
              style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: Colors.blue, size: 20.sp,
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            if (members.isEmpty)
              Padding(padding: EdgeInsets.all(12.w),
                  child: Center(child: Text('No members in this sub-group',
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary))))
            else
              ...members.map((m) {
                final isChecked = !unchecked.contains(m.memberId);
                return CheckboxListTile(
                  dense: true,
                  value: isChecked,
                  activeColor: accentGreen,
                  onChanged: (_) => _toggleMember(subGroup.subGroupId, m.memberId),
                  title: Text(m.name, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black87)),
                  subtitle: Text(m.email, style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary)),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
          ],
        ],
      ),
    );
  }
}