import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../config/colors.dart';
import '../../model/coach/club_member.dart';
import '../../utills/api_service.dart';
import 'coach_detail_with_performance.dart';
import 'member_details_screen.dart';

/// Shows all members across all groups/subgroups assigned to this coach.
class CoachMyMembersScreen extends StatefulWidget {
  const CoachMyMembersScreen({super.key});

  @override
  State<CoachMyMembersScreen> createState() => _CoachMyMembersScreenState();
}

class _CoachMyMembersScreenState extends State<CoachMyMembersScreen> {
  final CoachApiService _api = CoachApiService();
  late Future<List<ClubMember>> _membersFuture;
  List<ClubMember> _all = [];
  List<ClubMember> _filtered = [];
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMembers();
    _search.addListener(_filter);
  }

  Future<List<ClubMember>> _fetchMembers() async {
    try {
      final clubs = await _api.getCoachClubs();
      if (clubs.isEmpty) return [];
      // Fetch members for first club — extend for multi-club as needed
      final members = await _api.getClubMembers(clubs.first.clubId);
      _all = members;
      _filtered = members;
      return members;
    } catch (e) {
      return [];
    }
  }

  void _filter() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all
          .where((m) =>
      m.username.toLowerCase().contains(q) ||
          m.email.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w, bottom: 12.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                    16.width,
                    Text(
                      "My Members",
                      style: GoogleFonts.montserrat(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: "Search members...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // List
          Expanded(
            child: FutureBuilder<List<ClubMember>>(
              future: _membersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: accentGreen));
                }
                if (_filtered.isEmpty) {
                  return Center(
                    child: Text("No members found",
                        style: GoogleFonts.poppins(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final m = _filtered[i];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 4)
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12.w),
                        leading: CircleAvatar(
                          radius: 22.r,
                          backgroundColor: accentGreen.withOpacity(0.1),
                          child: Text(
                            m.username.isNotEmpty
                                ? m.username[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: accentGreen,
                            ),
                          ),
                        ),
                        title: Text(m.username,
                            style: GoogleFonts.montserrat(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(m.email,
                            style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600)),
                        trailing: Icon(Icons.arrow_forward_ios,
                            size: 14.sp, color: Colors.grey),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CoachMemberDetailWithPerformance(
                              member: m,
                              clubId: 0, // pass actual clubId
                              clubName: '',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}