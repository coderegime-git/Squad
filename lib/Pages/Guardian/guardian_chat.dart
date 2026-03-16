// lib/pages/guardian/guardian_chat.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';

class GuardianChat extends StatefulWidget {
  const GuardianChat({super.key});

  @override
  State<GuardianChat> createState() => _GuardianChatState();
}

class _GuardianChatState extends State<GuardianChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Container(
            height: 80.h,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.08),
                  width: 0.5,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  // Icon(
                  //   Icons.menu_outlined,
                  //   color: Colors.white,
                  //   size: 20.sp,
                  // ),
                  // 10.width,

                  Text("Group Chats",style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: cardDark,fontSize: 20.sp,fontWeight: FontWeight.bold,),),
                  const Spacer(),


                  //20.width,

                  // Child switcher
                  // GestureDetector(
                  //   onTap: () => toast("Switch child"),
                  //   child: CircleAvatar(
                  //     radius: 20.r,
                  //     backgroundColor: accentGreen.withOpacity(0.3),
                  //     child: Icon(
                  //       Icons.swap_horiz_rounded,
                  //       color: accentGreen,
                  //       size: 24.sp,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 80.sp,
                      color: accentGreen.withOpacity(0.6),
                    ),
                    24.height,
                    Text(
                      "Private Guardian Chats",
                      style: GoogleFonts.montserrat(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    12.height,
                    Text(
                      "Coming Soon",
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        color: textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    40.height,
                    // Container(
                    //   padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    //   decoration: BoxDecoration(
                    //     color: accentGreen.withOpacity(0.15),
                    //     borderRadius: BorderRadius.circular(30.r),
                    //   ),
                    //   child: Text(
                    //     "In Development • Expected Soon",
                    //     style: GoogleFonts.poppins(
                    //       fontSize: 14.sp,
                    //       color: accentGreen,
                    //       fontWeight: FontWeight.w600,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}