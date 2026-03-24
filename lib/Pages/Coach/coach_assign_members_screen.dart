import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_members.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';

class CoachAssignMembersScreen extends StatefulWidget {
  final int teamId;
  final String teamName;
  final String subGroupName;

  const CoachAssignMembersScreen({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.subGroupName,
  });

  @override
  State<CoachAssignMembersScreen> createState() =>
      _CoachAssignMembersScreenState();
}

class _CoachAssignMembersScreenState extends State<CoachAssignMembersScreen> {
  final ClubApiService _api = ClubApiService();

  // All club members
  List<dynamic> _allMembers = [];
  // Already assigned members
  List<dynamic> _assignedMembers = [];
  // Selected member IDs for new assignment
  Set<int> _selectedIds = {};

  bool _loadingAll = true;
  bool _loadingAssigned = true;
  bool _assigning = false;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadAllMembers(), _loadAssignedMembers()]);
  }

  Future<void> _loadAllMembers() async {
    setState(() => _loadingAll = true);
    try {
      final result = await _api.getMembers();
      setState(() {
        _allMembers = result.data ?? [];
        _loadingAll = false;
      });
    } catch (e) {
      setState(() => _loadingAll = false);
    }
  }

  Future<void> _loadAssignedMembers() async {
    setState(() => _loadingAssigned = true);
    try {
      final result = await _api.getTeamMembers(widget.teamId);
      setState(() {
        _assignedMembers = result.data ?? [];
        _loadingAssigned = false;
      });
    } catch (e) {
      setState(() => _loadingAssigned = false);
    }
  }

  int? _getMemberId(dynamic member) {
    final id = member.memberId;
    if (id == null) return null;
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  Set<int> get _alreadyAssignedIds {
    return _assignedMembers
        .map<int>((m) => m.memberId as int)
        .toSet();
  }

  List<dynamic> get _filteredMembers {
    final query = _searchQuery.toLowerCase();
    return _allMembers.where((m) {
      final name = (m.username ?? '').toLowerCase();
      final email = (m.email ?? '').toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  Future<void> _assignMembers() async {
    if (_selectedIds.isEmpty) {
      toast("Please select at least one member", bgColor: accentOrange);
      return;
    }

    setState(() => _assigning = true);
    try {
      final success = await _api.assignMembersToTeam(
        widget.teamId,
        _selectedIds.toList(),
      );
      if (success) {
        AppUI.success(context, "Members assigned successfully!");
        setState(() {
          _selectedIds.clear();
        });
        // Reload assigned members
        await _loadAssignedMembers();
      } else {
        AppUI.error(context, "Failed to assign members");
      }
    } catch (e) {
      AppUI.error(context, "Something went wrong");
    } finally {
      setState(() => _assigning = false);
    }
  }

  Future<void> _removeMember(int memberId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Remove Member",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
        content: Text(
          "Remove $name from ${widget.teamName}?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Remove",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final success = await _api.removeTeamMember(widget.teamId, memberId);
      if (success) {
        AppUI.success(context, "$name removed from team");
        await _loadAssignedMembers();
      } else {
        AppUI.error(context, "Failed to remove member");
      }
    } catch (e) {
      AppUI.error(context, "Something went wrong");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            // Header
            Container(
              //height: 95.h,
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
                  padding:
                      EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                      ),
                      16.width,
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.teamName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.subGroupName,
                              style: GoogleFonts.poppins(
                                  fontSize: 11.sp, color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: accentGreen,
                unselectedLabelColor: Colors.grey,
                indicatorColor: accentGreen,
                labelStyle: GoogleFonts.poppins(
                    fontSize: 13.sp, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_add_rounded, size: 18),
                        6.width,
                        const Text("Assign"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_rounded, size: 18),
                        6.width,
                        Text(
                          "Assigned (${_assignedMembers.length})",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _buildAssignTab(),
                  _buildAssignedTab(),
                ],
              ),
            ),
          ],
        ),

        // Assign Button
        floatingActionButton: _selectedIds.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _assigning ? null : _assignMembers,
                backgroundColor: accentGreen,
                label: _assigning
                    ? AppUI.buttonSpinner()
                    : Text(
                        "Assign ${_selectedIds.length} Member${_selectedIds.length > 1 ? 's' : ''}",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                icon: _assigning
                    ? const SizedBox.shrink()
                    : const Icon(Icons.check_rounded, color: Colors.white),
              )
            : null,
      ),
    );
  }

  Widget _buildAssignTab() {
    if (_loadingAll) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48.sp, color: Colors.grey),
            12.height,
            Text("No members found",
                style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      );
    }

    final assignedIds = _alreadyAssignedIds;
    final available = _filteredMembers
        .where((m) => !assignedIds.contains(m.memberId))
        .toList();

    return Column(
      children: [
        // Search
        Padding(
          padding: EdgeInsets.all(16.w),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: "Search members...",
              hintStyle:
                  GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
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
                borderSide: BorderSide(color: accentGreen, width: 1.5),
              ),
            ),
          ),
        ),

        // Select All / Count row
        if (available.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${available.length} available",
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp, color: Colors.grey.shade600),
                ),
                if (_selectedIds.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _selectedIds.clear()),
                    child: Text(
                      "Clear selection",
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        8.height,

        // Members list
        Expanded(
          child: available.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isNotEmpty
                        ? "No results found"
                        : "All members are already assigned",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  itemCount: available.length,
                  itemBuilder: (_, i) {
                    final member = available[i];
                    // final memberId = member.memberId as int;
                    // final isSelected = _selectedIds.contains(memberId);
                    final int? memberId = _getMemberId(member);
                    if (memberId == null) return const SizedBox.shrink();

                    final isSelected = _selectedIds.contains(memberId);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(memberId);
                          } else {
                            _selectedIds.add(memberId);
                          }
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accentGreen.withOpacity(0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isSelected
                                ? accentGreen
                                : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22.r,
                              backgroundColor: isSelected
                                  ? accentGreen.withOpacity(0.2)
                                  : Colors.grey.shade200,
                              child: Text(
                                (member.username ?? 'M')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? accentGreen
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            14.width,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.username ?? '',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    member.email ?? '',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11.sp,
                                        color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24.r,
                              height: 24.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? accentGreen
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? accentGreen
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 14)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Bottom spacer for FAB
        if (_selectedIds.isNotEmpty) 80.height,
      ],
    );
  }

  Widget _buildAssignedTab() {
    if (_loadingAssigned) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assignedMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 48.sp, color: Colors.grey),
            12.height,
            Text("No members assigned yet",
                style: GoogleFonts.poppins(color: Colors.grey)),
            8.height,
            Text(
              "Go to Assign tab to add members",
              style: GoogleFonts.poppins(
                  fontSize: 12.sp, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadAssignedMembers(),
      color: accentGreen,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _assignedMembers.length,
        itemBuilder: (_, i) {
          final member = _assignedMembers[i];
          // final memberId = member.memberId as int;
          final int? memberId = _getMemberId(member);
          if (memberId == null) return const SizedBox.shrink();

          return Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: accentGreen.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: accentGreen.withOpacity(0.15),
                  child: Text(
                    (member.username ?? 'M').substring(0, 1).toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700,
                      color: accentGreen,
                    ),
                  ),
                ),
                14.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.username ?? '',
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        member.email ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      _removeMember(memberId, member.username ?? 'Member'),
                  icon: Icon(Icons.remove_circle_outline,
                      color: Colors.redAccent, size: 22.sp),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
