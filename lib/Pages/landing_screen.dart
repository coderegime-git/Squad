import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../routes/app_routes.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        //extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Container(
              //   padding: EdgeInsets.all(5),
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(20)
              //   ),
              //   child: ClipPath(
              //     //clipBehavior: Clip.antiAlias,
              //     child: Image.asset(
              //       'assets/images/landing_screen1.png',
              //       fit: BoxFit.cover,
              //       width: double.infinity,
              //       height: double.infinity,
              //       alignment: Alignment.center,
              //     ),
              //   ),
              // ),
              Container(
                //margin: EdgeInsets.all(12.w), 
                //← outer spacing / "border" padding
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  //borderRadius: BorderRadius.circular(24.r),
                  // border: Border.all(
                  //   color: Colors.black.withOpacity(0.3), // or any color, e.g. Colors.grey[400]
                  //   width: 2.w,
                  // ),
                  // boxShadow: [ // optional subtle shadow for depth
                  //   BoxShadow(
                  //     color: Colors.black.withOpacity(0.12),
                  //     blurRadius: 12,
                  //     offset: Offset(0, 6),
                  //   ),
                  // ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r), // same radius as outer
                  child: Image.asset(
                    'assets/images/landing_screen1.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.withOpacity(0.10),
                      Colors.green.withOpacity(0.15),
                      Colors.green.withOpacity(0.15),
                    ],
                  ),
                ),
              ),

              Column(
                children: [
                  ClipPath(
                    //clipper: BottomCurveClipper(),
                    child: Container(
                      margin: EdgeInsets.all(5),
                      height: 90.h,               // taller to accommodate the upward curve nicely
                      width: double.infinity,

                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 5.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black,
                      ),// more space for "SQUAD" text
                      child: Text(
                        "SQUAD",
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 34.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        // Optional welcome text – now black
                        // Positioned(
                        //   top: 80.h,
                        //   left: 0,
                        //   right: 0,
                        //   child: Center(
                        //     child: Text(
                        //       "WELCOME TO SQUAD",
                        //       style: GoogleFonts.montserrat(
                        //         color: Colors.black87,
                        //         fontSize: 24.sp,
                        //         fontWeight: FontWeight.w700,
                        //         letterSpacing: 1.2,
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //   ),
                        // ),

                        // Bottom buttons – centered
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 80.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 220.w,
                                  height: 45.h,
                                  child: AppButton(
                                    text: 'LOG IN',
                                    textStyle: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0,
                                    ),

                                    color: Colors.black,
                                    // shapeBorder: RoundedRectangleBorder(
                                    //   borderRadius: BorderRadius.circular(12.r),
                                    // ),
                                    padding: EdgeInsets.zero,
                                    elevation: 4,
                                    onTap: () {
                                      Navigator.pushNamed(context, AppRoutes.login);
                                    },
                                  ),
                                ),

                                20.height,


                                // SizedBox(
                                //   width: 220.w,
                                //   height: 45.h,
                                //   child: AppButton(
                                //     text: 'SIGN UP',
                                //     textStyle: GoogleFonts.montserrat(
                                //       color: Colors.black,
                                //       fontSize: 15.sp,
                                //       fontWeight: FontWeight.w700,
                                //       letterSpacing: 0,
                                //     ),
                                //
                                //     color: Colors.white,
                                //     // shapeBorder: RoundedRectangleBorder(
                                //     //   borderRadius: BorderRadius.circular(12.r),
                                //     // ),
                                //     padding: EdgeInsets.zero,
                                //     elevation: 4,
                                //     onTap: () {
                                //       Navigator.pushNamed(context, AppRoutes.signup);
                                //     },
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// class BottomCurveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//
//     path.moveTo(0, 0);
//     path.lineTo(0, size.height);  // bottom-left
//
//     // Reduced upward pull → shallower concave curve
//     path.quadraticBezierTo(
//       size.width * 0.5,          // center
//       size.height - 10.h,        // ← was -60.h, now -35.h → much gentler / smaller dip
//       size.width,
//       size.height,               // bottom-right
//     );
//
//     path.lineTo(size.width, 0);
//     path.lineTo(0, 0);
//     path.close();
//
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }

