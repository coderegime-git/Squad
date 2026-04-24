import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../config/colors.dart';

class CoachGroupChatListScreen extends StatelessWidget {
  const CoachGroupChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace hardcoded items with API-driven group/subgroup list
    final groups = [
      {'name': 'Under-14 A', 'type': 'Group'},
      {'name': 'Under-14 A — Boys', 'type': 'Sub-Group'},
      {'name': 'Under-12 B', 'type': 'Group'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
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
                padding: EdgeInsets.only(
                    top: 5.h, left: 20.w, right: 20.w, bottom: 12.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                    16.width,
                    Text("Group Chats",
                        style: GoogleFonts.montserrat(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: groups.length,
              itemBuilder: (_, i) {
                final g = groups[i];
                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: accentGreen.withOpacity(0.25)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: accentGreen.withOpacity(0.15),
                      child: Icon(Icons.group_rounded,
                          color: accentGreen, size: 20.sp),
                    ),
                    title: Text(g['name']!,
                        style: GoogleFonts.montserrat(
                            fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    subtitle: Text(g['type']!,
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp, color: Colors.grey.shade500)),
                    trailing: Icon(Icons.chat_bubble_outline,
                        color: accentGreen, size: 18.sp),
                    onTap: () => toast("Open chat for ${g['name']}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}