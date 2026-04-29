// // screens/clubadmin/event_team_members_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:nb_utils/nb_utils.dart';
//
// import '../../config/colors.dart';
// import '../../model/clubAdmin/get_teams.dart';
// import '../../model/clubAdmin/get_members.dart';
// import '../../utills/api_service.dart';
// import '../../utills/helper.dart';
//
// class EventTeamMembersScreen extends StatefulWidget {
//   final TeamData team;
//
//   const EventTeamMembersScreen({super.key, required this.team});
//
//   @override
//   State<EventTeamMembersScreen> createState() => _EventTeamMembersScreenState();
// }
//
// class _EventTeamMembersScreenState extends State<EventTeamMembersScreen> {
//   final ClubApiService _apiService = ClubApiService();
//   late Future<List<Data>> _teamMembersFuture;
//
//   List<Data> _allMembers = [];
//   bool _loadingAllMembers = false;
//   final Set<int> _removingIds = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _teamMembersFuture = _fetchTeamMembers();
//   }
//
//   Future<List<Data>> _fetchTeamMembers() async {
//     final result = await _apiService.getTeamMembers(widget.team.teamId);
//     return result.data;
//   }
//
//   void _refresh() => setState(() => _teamMembersFuture = _fetchTeamMembers());
//   void _showAssignSheet() async {
//     setState(() => _loadingAllMembers = true);
//     List<Data> allMembers = [];
//     try {
//       final result = await _apiService.getMembers();
//       allMembers = result.data;
//     } catch (e) {
//       toast('Failed to load members');
//       setState(() => _loadingAllMembers = false);
//       return;
//     }
//     setState(() => _loadingAllMembers = false);
//
//     List<int> selectedIds = [];
//     bool isAssigning = false;
//
//     if (!mounted) return;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: cardDark,
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
//       builder: (_) => StatefulBuilder(
//         builder: (ctx, setSheet) => Padding(
//           padding: EdgeInsets.only(
//             left: 20.w,
//             right: 20.w,
//             top: 20.h,
//             bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40.w,
//                   height: 4.h,
//                   decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(2.r)),
//                 ),
//               ),
//               16.height,
//               Text('Assign Members',
//                   style: GoogleFonts.montserrat(
//                       fontSize: 18.sp, fontWeight: FontWeight.bold)),
//               6.height,
//               Text('Team: ${widget.team.name}',
//                   style: GoogleFonts.poppins(
//                       fontSize: 12.sp, color: textSecondary)),
//               16.height,
//               if (allMembers.isEmpty)
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 20.h),
//                   child: Center(
//                     child: Text('No members available',
//                         style: GoogleFonts.poppins(
//                             fontSize: 13.sp, color: textSecondary)),
//                   ),
//                 )
//               else ...[
//                 Text(
//                     '${selectedIds.length} member(s) selected',
//                     style: GoogleFonts.poppins(
//                         fontSize: 12.sp,
//                         color: accentGreen,
//                         fontWeight: FontWeight.w600)),
//                 8.height,
//                 Container(
//                   constraints: BoxConstraints(
//                     maxHeight: MediaQuery.of(ctx).size.height * 0.40,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12.r),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     physics: const ClampingScrollPhysics(),
//                     padding: EdgeInsets.zero,
//                     itemCount: allMembers.length,
//                     itemBuilder: (ctx, i) {
//                       final member = allMembers[i];
//                       final selected = selectedIds.contains(member.memberId);
//                       return CheckboxListTile(
//                         title: Text(
//                           member.username,
//                           style: GoogleFonts.poppins(
//                               fontSize: 13.sp, color: Colors.black87),
//                         ),
//                         subtitle: Text(
//                           member.email,
//                           style: GoogleFonts.poppins(
//                               fontSize: 11.sp, color: textSecondary),
//                         ),
//                         value: selected,
//                         activeColor: accentGreen,
//                         dense: true,
//                         visualDensity: VisualDensity.compact,
//                         contentPadding:
//                         EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
//                         onChanged: (bool? val) {
//                           setSheet(() {
//                             if (val == true) {
//                               selectedIds.add(member.memberId);
//                             } else {
//                               selectedIds.remove(member.memberId);
//                             }
//                           });
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//               20.height,
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: (isAssigning || selectedIds.isEmpty)
//                       ? null
//                       : () async {
//                     setSheet(() => isAssigning = true);
//                     final success =
//                     await _apiService.assignMembersToTeam(
//                       widget.team.teamId,
//                       selectedIds,
//                     );
//                     setSheet(() => isAssigning = false);
//                     if (success) {
//                       Navigator.pop(ctx);
//                       AppUI.success(context,
//                           '${selectedIds.length} member(s) assigned!');
//                       _refresh();
//                     } else {
//                       AppUI.error(
//                           context, 'Failed to assign members. Try again.');
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: accentGreen,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     padding: EdgeInsets.symmetric(vertical: 14.h),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14.r)),
//                   ),
//                   child: isAssigning
//                       ? AppUI.buttonSpinner()
//                       : Text(
//                       selectedIds.isEmpty
//                           ? 'Select members first'
//                           : 'Assign ${selectedIds.length} Member(s)',
//                       style: GoogleFonts.poppins(
//                           fontSize: 14.sp, fontWeight: FontWeight.w700)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Confirm Remove Member ──────────────────────────────────────────────────
//   Future<void> _confirmRemove(Data member) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: Colors.grey.shade200,
//         shape:
//         RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
//         title: Text('Remove Member',
//             style: GoogleFonts.montserrat(
//                 fontWeight: FontWeight.w700, fontSize: 16.sp)),
//         content: Text(
//           'Remove "${member.username}" from ${widget.team.name}?',
//           style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text('Cancel',
//                 style: GoogleFonts.poppins(
//                     color: textSecondary, fontWeight: FontWeight.w500)),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: Text('Remove',
//                 style: GoogleFonts.poppins(
//                     color: Colors.red, fontWeight: FontWeight.w700)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed == true) {
//       setState(() => _removingIds.add(member.memberId));
//       final success = await _apiService.removeTeamMember(
//           widget.team.teamId, member.memberId);
//       setState(() => _removingIds.remove(member.memberId));
//       if (success) {
//         toast('Member removed from team');
//         _refresh();
//       } else {
//         AppUI.error(context, 'Failed to remove member. Try again.');
//       }
//     }
//   }
//
//   // ── Member Card ────────────────────────────────────────────────────────────
//   Widget _memberCard(Data member) {
//     final isRemoving = _removingIds.contains(member.memberId);
//     return Container(
//       padding: EdgeInsets.all(14.w),
//       decoration: BoxDecoration(
//         color: cardDark,
//         borderRadius: BorderRadius.circular(18.r),
//         border: Border.all(color: accentGreen.withOpacity(0.25)),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 22.r,
//             backgroundColor: accentGreen.withOpacity(0.12),
//             child: Text(
//               member.username.isNotEmpty
//                   ? member.username[0].toUpperCase()
//                   : '?',
//               style: GoogleFonts.montserrat(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w700,
//                   color: accentGreen),
//             ),
//           ),
//           14.width,
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(member.username,
//                     style: GoogleFonts.montserrat(
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.black)),
//                 4.height,
//                 Text(member.email,
//                     style: GoogleFonts.poppins(
//                         fontSize: 11.sp, color: textSecondary)),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: isRemoving ? null : () => _confirmRemove(member),
//             child: Container(
//               width: 32.w,
//               height: 32.w,
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.12),
//                 shape: BoxShape.circle,
//               ),
//               child: isRemoving
//                   ? Padding(
//                 padding: EdgeInsets.all(7.w),
//                 child: AppUI.buttonSpinner(),
//               )
//                   : Icon(Icons.person_remove_rounded,
//                   color: Colors.red.shade600, size: 18.sp),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: Colors.white,
//         statusBarIconBrightness: Brightness.light,
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.grey.shade100,
//         body: Column(
//           children: [
//             Container(
//               //height: 85.h,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(16),
//                   bottomRight: Radius.circular(16),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.25),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: SafeArea(
//                 child: Padding(
//                   padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Icon(Icons.arrow_back_ios_rounded,
//                             color: Colors.white, size: 20.sp),
//                       ),
//                       16.width,
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Team Members',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .headlineMedium
//                                   ?.copyWith(
//                                 color: Colors.white,
//                                 fontSize: 20.sp,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               widget.team.name,
//                               style: GoogleFonts.poppins(
//                                   fontSize: 11.sp,
//                                   color: Colors.grey.shade400),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // ── Team Info Strip ──────────────────────────────────────────
//             Container(
//               margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
//               padding: EdgeInsets.all(14.w),
//               decoration: BoxDecoration(
//                 color: cardDark,
//                 borderRadius: BorderRadius.circular(16.r),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(10.w),
//                     decoration: BoxDecoration(
//                       color: accentOrange.withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Icon(Icons.sports_soccer_rounded,
//                         color: accentOrange, size: 20.sp),
//                   ),
//                   14.width,
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(widget.team.name,
//                             style: GoogleFonts.montserrat(
//                                 fontSize: 13.sp,
//                                 fontWeight: FontWeight.w700,
//                                 color: Colors.black)),
//                         if (widget.team.coachIds.isNotEmpty)
//                           Text('${widget.team.coachIds.length} coach(es) assigned',
//                               style: GoogleFonts.poppins(
//                                   fontSize: 11.sp, color: textSecondary)),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding:
//                     EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
//                     decoration: BoxDecoration(
//                         color: accentOrange.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20.r)),
//                     child: Text('Team ID: ${widget.team.teamId}',
//                         style: GoogleFonts.poppins(
//                             fontSize: 10.sp,
//                             color: accentOrange,
//                             fontWeight: FontWeight.w700)),
//                   ),
//                 ],
//               ),
//             ),
//
//             // ── Members List ─────────────────────────────────────────────
//             Expanded(
//               child: FutureBuilder<List<Data>>(
//                 future: _teamMembersFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(
//                         child: CircularProgressIndicator(color: accentGreen));
//                   }
//                   if (snapshot.hasError) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.error_outline_rounded,
//                               size: 48.sp, color: Colors.red.shade300),
//                           12.height,
//                           Text('Failed to load members',
//                               style:
//                               GoogleFonts.poppins(color: textSecondary)),
//                           12.height,
//                           ElevatedButton(
//                             onPressed: _refresh,
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: accentGreen,
//                                 foregroundColor: Colors.white),
//                             child: Text('Retry', style: GoogleFonts.poppins()),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   final members = snapshot.data ?? [];
//
//                   return RefreshIndicator(
//                     onRefresh: () async => _refresh(),
//                     color: accentGreen,
//                     child: members.isEmpty
//                         ? ListView(
//                       children: [
//                         SizedBox(height: 100.h),
//                         Center(
//                           child: Column(
//                             children: [
//                               Icon(Icons.people_outline_rounded,
//                                   size: 60.sp,
//                                   color: Colors.grey.shade400),
//                               16.height,
//                               Text('No members yet',
//                                   style: GoogleFonts.montserrat(
//                                       fontSize: 16.sp,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.grey.shade500)),
//                               8.height,
//                               Text('Tap + to assign members to this team',
//                                   style: GoogleFonts.poppins(
//                                       fontSize: 12.sp,
//                                       color: textSecondary)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     )
//                         : ListView.separated(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 20.w, vertical: 8.h),
//                       itemCount: members.length,
//                       separatorBuilder: (_, __) => 10.height,
//                       itemBuilder: (_, i) => _memberCard(members[i]),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//
//         floatingActionButton: _loadingAllMembers
//             ? FloatingActionButton(
//           onPressed: null,
//           backgroundColor: accentGreen,
//           child: const CircularProgressIndicator(color: Colors.white),
//         )
//             : FloatingActionButton.extended(
//           onPressed: _showAssignSheet,
//           backgroundColor: accentGreen,
//           icon: Icon(Icons.person_add_rounded,
//               color: Colors.white, size: 22.sp),
//           label: Text('Assign Members',
//               style: GoogleFonts.poppins(
//                   color: Colors.white, fontWeight: FontWeight.w600)),
//           elevation: 4,
//         ),
//       ),
//     );
//   }
// }