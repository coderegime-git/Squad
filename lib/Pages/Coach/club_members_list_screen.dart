import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../config/app_theme.dart';
import '../../config/colors.dart';
import '../../model/coach/club_member.dart';
import '../../utills/api_service.dart';
import 'member_details_screen.dart';

class ClubMembersListScreen extends StatefulWidget {
  final int clubId;
  final String clubName;

  const ClubMembersListScreen({
    Key? key,
    required this.clubId,
    required this.clubName,
  }) : super(key: key);

  @override
  State<ClubMembersListScreen> createState() => _ClubMembersListScreenState();
}

class _ClubMembersListScreenState extends State<ClubMembersListScreen> {
  final CoachApiService _apiService = CoachApiService();
  late Future<List<ClubMember>> _membersFuture;
  List<ClubMember> _allMembers = [];
  List<ClubMember> _filteredMembers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMembers();
    _searchController.addListener(_filterMembers);
  }

  Future<List<ClubMember>> _fetchMembers() async {
    final members = await _apiService.getClubMembers(widget.clubId);
    _allMembers = members;
    _filteredMembers = members;
    return members;
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMembers = _allMembers;
      } else {
        _filteredMembers = _allMembers.where((member) {
          return member.username.toLowerCase().contains(query) ||
              member.email.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Club Members",
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Club Info Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.clubName,
                  style: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                4.height,
                Text(
                  "Club ID: #${widget.clubId}",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search members...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),

          // Members List
          Expanded(
            child: FutureBuilder<List<ClubMember>>(
              future: _membersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: accentGreen));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60.sp, color: Colors.red),
                        16.height,
                        Text(
                          "Failed to load members",
                          style: GoogleFonts.poppins(fontSize: 16.sp),
                        ),
                        16.height,
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _membersFuture = _fetchMembers();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                          ),
                          child: Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredMembers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 60.sp, color: Colors.grey.shade400),
                        16.height,
                        Text(
                          _searchController.text.isEmpty
                              ? "No members found"
                              : "No matching members",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = _filteredMembers[index];
                    return _buildMemberCard(member);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(ClubMember member) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12.w),
        leading: CircleAvatar(
          radius: 25.r,
          backgroundColor: accentGreen.withOpacity(0.1),
          child: Text(
            member.username[0].toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: accentGreen,
            ),
          ),
        ),
        title: Text(
          member.username,
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.email,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
            4.height,
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    "ID: ${member.memberId}",
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: AppColors.info,
                    ),
                  ),
                ),
                8.width,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    member.gender,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: AppColors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
        onTap: () {
          // Pass the entire member object to details screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemberDetailsScreen(
                clubId: widget.clubId,
                clubName: widget.clubName,
                member: member, // Pass the full member object
              ),
            ),
          );
        },
      ),
    );
  }
}