// // screens/clubadmin/link_child_guardian_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:nb_utils/nb_utils.dart';
//
// import '../../config/colors.dart';
//
// class ClubAdminLinkChildGuardianScreen extends StatefulWidget {
//   const ClubAdminLinkChildGuardianScreen({super.key});
//
//   @override
//   State<ClubAdminLinkChildGuardianScreen> createState() => _ClubAdminLinkChildGuardianScreenState();
// }
//
// class _ClubAdminLinkChildGuardianScreenState extends State<ClubAdminLinkChildGuardianScreen> {
//   String? _selectedGuardian;
//   List<String> _selectedChildren = [];
//
//   final List<String> _guardians = ['Nandha Kumar', 'Rajesh Sharma', 'Priya Menon', 'Suresh Babu'];
//   final List<String> _children = [
//     'Abinesh Kumar (Under-14 A)',
//     'Gopal Singh (Under-10 B)',
//     'Priya Sharma (Under-12 A)',
//     'Ravi Kumar (Under-16)',
//     'Aarav Patel (Intermediate)',
//     'Saanvi Reddy (Under-8)',
//     'Karthik Raja (Advanced)',
//   ];
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
//               height: 85.h,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(16),
//                   bottomRight: Radius.circular(16),
//                 ),
//               ),
//               child: SafeArea(
//                 child: Padding(
//                   padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Icon(
//                           Icons.arrow_back_ios_rounded,
//                           color: Colors.white,
//                           size: 20.sp,
//                         ),
//                       ),
//                       16.width,
//                       Text(
//                         'Link Child to Guardian',
//                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                           color: Colors.white,
//                           fontSize: 20.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // ── Main Content ────────────────────────────────────────────
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Guardian Section – more compact
//                     Text(
//                       'Select Guardian',
//                       style: GoogleFonts.montserrat(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     8.height,
//                     DropdownButtonFormField<String>(
//                       value: _selectedGuardian,
//                       hint: Text(
//                         'Choose guardian',
//                         style: GoogleFonts.poppins(
//                           fontSize: 13.sp,
//                           color: textSecondary,
//                         ),
//                       ),
//                       isExpanded: true,
//                       items: _guardians
//                           .map((g) => DropdownMenuItem(
//                         value: g,
//                         child: Text(
//                           g,
//                           style: GoogleFonts.poppins(fontSize: 13.sp),
//                         ),
//                       ))
//                           .toList(),
//                       onChanged: (v) => setState(() => _selectedGuardian = v),
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white,
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 14.w,
//                           vertical: 12.h,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: BorderSide(color: accentGreen, width: 1.5),
//                         ),
//                       ),
//                     ),
//                     24.height,
//
//                     // Children Section
//                     Text(
//                       'Select Children',
//                       style: GoogleFonts.montserrat(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     8.height,
//
//                     Container(
//                       constraints: BoxConstraints(
//                         maxHeight: MediaQuery.of(context).size.height * 0.50,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(color: Colors.grey.shade300),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.04),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         physics: const ClampingScrollPhysics(),
//                         padding: EdgeInsets.zero,
//                         itemCount: _children.length,
//                         itemBuilder: (ctx, i) {
//                           final child = _children[i];
//                           final selected = _selectedChildren.contains(child);
//                           return CheckboxListTile(
//                             title: Text(
//                               child,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 13.sp,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             value: selected,
//                             activeColor: accentGreen,
//                             dense: true,
//                             visualDensity: VisualDensity.compact,
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 16.w,
//                               vertical: 2.h,
//                             ),
//                             onChanged: (bool? val) {
//                               setState(() {
//                                 if (val == true) {
//                                   _selectedChildren.add(child);
//                                 } else {
//                                   _selectedChildren.remove(child);
//                                 }
//                               });
//                             },
//                           );
//                         },
//                       ),
//                     ),
//
//                     28.height,
//
//                     // Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         icon:  Icon(Icons.link_rounded, size: 20.sp),
//                         label: Text(
//                           'Link Children',
//                           style: GoogleFonts.poppins(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: accentGreen,
//                           foregroundColor: Colors.white,
//                           padding: EdgeInsets.symmetric(vertical: 14.h),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14.r),
//                           ),
//                           elevation: 0,
//                         ),
//                         onPressed: () {
//                           if (_selectedGuardian == null || _selectedChildren.isEmpty) {
//                             toast('Please select guardian and at least one child');
//                             return;
//                           }
//                           toast(
//                             'Linked ${_selectedChildren.length} children to $_selectedGuardian',
//                             bgColor: accentGreen,
//                           );
//                           Navigator.pop(context);
//                         },
//                       ),
//                     ),
//
//                     40.height,
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// screens/clubadmin/link_child_guardian_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_members.dart';
import '../../model/clubAdmin/get_guardians.dart';
import '../../utills/api_service.dart';

class ClubAdminLinkChildGuardianScreen extends StatefulWidget {
  const ClubAdminLinkChildGuardianScreen({super.key});

  @override
  State<ClubAdminLinkChildGuardianScreen> createState() =>
      _ClubAdminLinkChildGuardianScreenState();
}

class _ClubAdminLinkChildGuardianScreenState
    extends State<ClubAdminLinkChildGuardianScreen> {
  final ClubApiService _apiService = ClubApiService();

  GuardianData? _selectedGuardian;
  List<Data> _selectedMembers = [];

  List<GuardianData> _guardians = [];
  List<Data> _members = [];

  bool _loadingGuardians = true;
  bool _loadingMembers = true;
  bool _isLinking = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final guardianResult = await _apiService.getGuardians();
      setState(() {
        _guardians = guardianResult.data;
        _loadingGuardians = false;
      });
    } catch (e) {
      setState(() => _loadingGuardians = false);
      toast('Failed to load guardians');
    }

    try {
      final membersResult = await _apiService.getMembers();
      setState(() {
        _members = membersResult.data;
        _loadingMembers = false;
      });
    } catch (e) {
      setState(() => _loadingMembers = false);
      toast('Failed to load members');
    }
  }

  Future<void> _linkChildren() async {
    if (_selectedGuardian == null || _selectedMembers.isEmpty) {
      toast('Please select guardian and at least one child');
      return;
    }

    setState(() => _isLinking = true);

    int successCount = 0;
    int failCount = 0;

    for (final member in _selectedMembers) {
      final success = await _apiService.mapGuardian(
        member.memberId,
        _selectedGuardian!.guardianId,
      );
      if (success) {
        successCount++;
      } else {
        failCount++;
      }
    }

    setState(() => _isLinking = false);

    if (failCount == 0) {
      toast(
        'Linked $successCount ${successCount == 1 ? 'child' : 'children'} to ${_selectedGuardian!.username}',
        bgColor: accentGreen,
      );
      Navigator.pop(context);
    } else if (successCount > 0) {
      toast(
        '$successCount linked, $failCount failed',
        bgColor: Colors.orange,
      );
    } else {
      toast('Failed to link children. Please try again.');
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
            Container(
              //height: 85.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                      16.width,
                      Text(
                        'Link Child to Guardian',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: (_loadingGuardians || _loadingMembers)
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Guardian',
                      style: GoogleFonts.montserrat(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    8.height,
                    _guardians.isEmpty
                        ? _emptyBox('No guardians available')
                        : DropdownButtonFormField<GuardianData>(
                      value: _selectedGuardian,
                      hint: Text(
                        'Choose guardian',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: textSecondary,
                        ),
                      ),
                      isExpanded: true,
                      items: _guardians
                          .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(
                          g.username,
                          style: GoogleFonts.poppins(
                              fontSize: 13.sp),
                        ),
                      ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedGuardian = v),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                              color: accentGreen, width: 1.5),
                        ),
                      ),
                    ),
                    24.height,

                    Text(
                      'Select Children',
                      style: GoogleFonts.montserrat(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    8.height,
                    _members.isEmpty
                        ? _emptyBox('No members available')
                        : Container(
                      constraints: BoxConstraints(
                        maxHeight:
                        MediaQuery.of(context).size.height *
                            0.50,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                            color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics:
                        const ClampingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: _members.length,
                        itemBuilder: (ctx, i) {
                          final member = _members[i];
                          final selected =
                          _selectedMembers.contains(member);
                          return CheckboxListTile(
                            title: Text(
                              member.username,
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              member.email,
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: textSecondary,
                              ),
                            ),
                            value: selected,
                            activeColor: accentGreen,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding:
                            EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 2.h,
                            ),
                            onChanged: (bool? val) {
                              setState(() {
                                if (val == true) {
                                  _selectedMembers.add(member);
                                } else {
                                  _selectedMembers.remove(member);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),

                    28.height,

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isLinking
                            ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Icon(Icons.link_rounded, size: 20.sp),
                        label: Text(
                          _isLinking ? 'Linking...' : 'Link Children',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentGreen,
                          foregroundColor: Colors.white,
                          padding:
                          EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLinking ? null : _linkChildren,
                      ),
                    ),

                    40.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyBox(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
      ),
    );
  }
}