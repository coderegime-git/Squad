// screens/clubadmin/clubadmin_members.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_coaches.dart';
import '../../model/clubAdmin/get_members.dart';
import '../../model/clubAdmin/get_guardians.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';
import 'add_member_screen.dart';

class ClubAdminMembersScreen extends StatefulWidget {
  const ClubAdminMembersScreen({super.key});

  @override
  State<ClubAdminMembersScreen> createState() => _ClubAdminMembersScreenState();
}

class _ClubAdminMembersScreenState extends State<ClubAdminMembersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  late Future<List<Data>> _membersFuture;
  late Future<List<CoachData>> _coachesFuture;
  late Future<List<GuardianData>> _guardiansFuture;

  Set<int> _deletingMemberIds = {};
  Set<int> _deletingGuardianIds = {};
  Set<int> _deletingCoachIds = {};     // ← add this

  final ClubApiService _apiService = ClubApiService();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _membersFuture = _fetchMembers();
    _coachesFuture = _fetchCoaches();
    _guardiansFuture = _fetchGuardians();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<List<Data>> _fetchMembers() async {
    final result = await _apiService.getMembers();
    return result.data;
  }

// With real API call:
  Future<List<CoachData>> _fetchCoaches() async {
    final result = await _apiService.getCoaches();
    return result.data;
  }

  Future<List<GuardianData>> _fetchGuardians() async {
    final result = await _apiService.getGuardians();
    return result.data;
  }

  Future<void> _confirmDeleteMember(Data m) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Member',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16.sp)),
        content: Text(
          'Are you sure you want to delete "${m.username}"?',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: textSecondary, fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _deletingMemberIds.add(m.memberId));
      final success = await _apiService.deleteMembers(m.memberId);
      setState(() => _deletingMemberIds.remove(m.memberId));
      if (success) {
        setState(() => _coachesFuture = _fetchCoaches());
        toast('Member "${m.username}" deleted successfully');
      } else {
        toast('Failed to delete member');
      }
    }

  }

  Future<void> _confirmDeleteGuardian(GuardianData g) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Guardian',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16.sp)),
        content: Text(
          'Are you sure you want to delete "${g.username}"?',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: textSecondary, fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _deletingGuardianIds.add(g.guardianId));
      final success = await _apiService.deleteGuardians(g.guardianId);
      setState(() => _deletingGuardianIds.remove(g.guardianId));
      if (success) {
        setState(() => _guardiansFuture = _fetchGuardians());
        toast('Guardian "${g.username}" deleted successfully');
      } else {
        toast('Failed to delete guardian');
      }
    }
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
                      offset: const Offset(0, 5)),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Manage Members',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.search_rounded, color: Colors.white, size: 22.sp),
                        onPressed: () => toast('Search members'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Tab Bar ──────────────────────────────────────────────────
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(
                  color: accentGreen,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                labelPadding: EdgeInsets.zero,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade500,
                labelStyle:
                GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Members'),
                  Tab(text: 'Coaches'),
                  Tab(text: 'Guardians'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _membersList(),
                  _coachesList(),
                  _guardiansList(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addMenu(context),
          backgroundColor: accentGreen,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('Add',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  Widget _membersList() {
    return FutureBuilder<List<Data>>(
      future: _membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No members found'));
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() => _membersFuture = _fetchMembers()),
          color: accentGreen,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => 10.height,
            itemBuilder: (_, i) => _memberCard(snapshot.data![i]),
          ),
        );
      },
    );
  }

  Widget _coachesList() {
    return FutureBuilder<List<CoachData>>(
      future: _coachesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No coaches found'));
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() => _coachesFuture = _fetchCoaches()),
          color: accentGreen,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => 10.height,
            itemBuilder: (_, i) => _coachCard(snapshot.data![i]),
          ),
        );
      },
    );
  }

  Widget _guardiansList() {
    return FutureBuilder<List<GuardianData>>(
      future: _guardiansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No guardians found'));
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() => _guardiansFuture = _fetchGuardians()),
          color: accentGreen,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => 10.height,
            itemBuilder: (_, i) => _guardianCard(snapshot.data![i]),
          ),
        );
      },
    );
  }

  Widget _memberCard(Data m) {
    final isDeleting = _deletingMemberIds.contains(m.memberId);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: accentGreen.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.r,
            backgroundColor: accentGreen.withOpacity(0.12),
            child: Text(
              m.username.isNotEmpty ? m.username[0].toUpperCase() : '?',
              style: GoogleFonts.montserrat(
                  fontSize: 16.sp, fontWeight: FontWeight.w700, color: accentGreen),
            ),
          ),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.username,
                    style: GoogleFonts.montserrat(
                        fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                4.height,
                Text(m.email,
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
                4.height,
                Text('Gender: ${m.gender}  •  DOB: ${m.dob ?? 'N/A'}',
                    style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary)),
                4.height,
                if (m.medicalNotes.isNotEmpty)
                  Text('Notes: ${m.medicalNotes}',
                      style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r)),
                child: Text('ID: ${m.memberId}',
                    style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: accentGreen,
                        fontWeight: FontWeight.w600)),
              ),
              20.height,
              GestureDetector(
                onTap: isDeleting ? null : () => _confirmDeleteMember(m),
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
                    child: AppUI.buttonSpinner()
                  )
                      : Icon(Icons.delete_forever,
                      color: Colors.red.shade600, size: 18.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Future<void> _confirmDeleteCoach(CoachData c) async {    // ← change Data → CoachData
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Coach',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16.sp)),
        content: Text(
          'Are you sure you want to delete "${c.username}"?',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: textSecondary, fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _deletingCoachIds.add(c.coachId));
      final success = await _apiService.deleteCoaches(c.coachId);
      setState(() => _deletingCoachIds.remove(c.coachId));
      if (success) {
        setState(() => _coachesFuture = _fetchCoaches());
        toast('Coach "${c.username}" deleted successfully');
      } else {
        toast('Failed to delete coach');
      }
    }
  }
  Widget _coachCard(CoachData c) {
    final isDeleting = _deletingCoachIds.contains(c.coachId);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: accentOrange.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.r,
            backgroundColor: accentOrange.withOpacity(0.12),
            child: Text(
              c.username.isNotEmpty ? c.username[0].toUpperCase() : '?',
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: accentOrange,
              ),
            ),
          ),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.username,
                    style: GoogleFonts.montserrat(
                        fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                4.height,
                Text(c.specialization,
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
                4.height,
                Text('${c.experienceYears} years experience',
                    style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary)),
                4.height,
                if (c.bio.isNotEmpty)
                  Text(
                    c.bio,
                    style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                4.height,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: accentOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    c.status,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                  color: accentOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'ID: ${c.coachId}',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              20.height,
              GestureDetector(
                onTap: isDeleting ? null : () => _confirmDeleteCoach(c),
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
    );
  }

  Widget _guardianCard(GuardianData g) {
    final isDeleting = _deletingGuardianIds.contains(g.guardianId);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.blue.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.r,
            backgroundColor: Colors.blue.withOpacity(0.12),
            child: Text(
              g.username.isNotEmpty ? g.username[0].toUpperCase() : '?',
              style: GoogleFonts.montserrat(
                  fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.blue),
            ),
          ),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.username,
                    style: GoogleFonts.montserrat(
                        fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                4.height,
                Text('Relation: ${g.relation}',
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
                4.height,
                Text('Emergency: ${g.emergencyContact}',
                    style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary)),
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
                    borderRadius: BorderRadius.circular(20.r)),
                child: Text('ID: ${g.guardianId}',
                    style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600)),
              ),
              20.height,
              GestureDetector(
                onTap: isDeleting ? null : () => _confirmDeleteGuardian(g),
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
                    child: AppUI.buttonSpinner()
                  )
                      : Icon(Icons.delete_forever,
                      color: Colors.red.shade600, size: 18.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r))),
            16.height,
            Text('Add New',
                style: GoogleFonts.montserrat(fontSize: 17.sp, fontWeight: FontWeight.w700)),
            16.height,
            _menuTile(Icons.person_add_rounded, 'Add Member', accentGreen, () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ClubAdminAddMemberScreen()));
            }),
            _menuTile(Icons.people_rounded, 'Add Coach', accentOrange,
                    () { Navigator.pop(context); toast('Navigate to Add Coach Form'); }),
            _menuTile(Icons.group_add_rounded, 'Add Guardian', Colors.blue,
                    () { Navigator.pop(context); toast('Navigate to Add Guardian Form'); }),
            _menuTile(Icons.link_rounded, 'Link Child to Guardian', Colors.purple,
                    () { Navigator.pop(context); toast('Navigate to Link Form'); }),
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
            color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10.r)),
        child: Icon(icon, color: color, size: 20.sp),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black)),
      trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 18.sp),
    );
  }
}

// Coach model (dummy for now)
// class Coach {
//   final String id, name, specialization;
//   final List<String> groupsAssigned;
//   final int membersCount;
//   Coach(this.id, this.name, this.specialization, this.groupsAssigned, this.membersCount);
// }
