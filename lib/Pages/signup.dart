import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart' hide whiteColor;

import '../../config/colors.dart';
import '../config/common.dart';
import '../routes/app_routes.dart';

class AccountActivationScreen extends StatefulWidget {
  const AccountActivationScreen({super.key});

  @override
  State<AccountActivationScreen> createState() => _AccountActivationScreenState();
}

class _AccountActivationScreenState extends State<AccountActivationScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.black,
      body: Container(

        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [
        //       Color(0xFF0F172A),    // dark slate
        //       scaffoldDark,         // main dark background
        //     ],
        //   ),
        // ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,

                /// HEADER (Back + Title)
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 22,
                        color: textPrimary,
                      ),
                    ),
                    20.width,
                    Text(
                      'Create Your Account',
                      style: boldTextStyle(
                        size: 20,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),

                35.height,

                /// SECTION TITLE
                // Text(
                //   'Complete Your Profile',
                //   style: boldTextStyle(
                //     size: 22,
                //     color: accentGreen,
                //   ),
                // ),
                // 8.height,
                Text(
                  'Set up your account to access your club, activities, and events.',
                  style: secondaryTextStyle(
                    size: 14,
                    color: textSecondary,
                  ),
                ),

                30.height,

                /// NAME
                AppTextField(
                  controller: nameCtrl,
                  textFieldType: TextFieldType.NAME,
                  textStyle: primaryTextStyle(color: textPrimary),
                  decoration: inputDecoration(
                    context,
                    hintText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline_rounded, color: accentGreen),
                  ).copyWith(
                    hintStyle: secondaryTextStyle(color: textSecondary),
                  ),
                  validator: (v) => v.isEmptyOrNull ? 'Full name is required' : null,
                ),

                20.height,

                /// MOBILE (locked / pre-filled)
                AppTextField(
                  controller: mobileCtrl,
                  textFieldType: TextFieldType.PHONE,
                  textStyle: primaryTextStyle(color: textPrimary),
                  enabled: false, // pre-filled from club invite/link
                  decoration: inputDecoration(
                    context,
                    hintText: 'Mobile Number',
                    prefixIcon: Icon(Icons.phone_android_rounded, color: accentGreen),
                    //fillColor: const Color(0xFF1F2A44).withOpacity(0.6),
                  ).copyWith(
                    hintStyle: secondaryTextStyle(color: textSecondary),
                  ),
                ),

                20.height,

                /// EMAIL
                AppTextField(
                  controller: emailCtrl,
                  textFieldType: TextFieldType.EMAIL,
                  textStyle: primaryTextStyle(color: textPrimary),
                  decoration: inputDecoration(
                    context,
                    hintText: 'Email (optional)',
                    prefixIcon: Icon(Icons.mail_outline_rounded, color: accentGreen),
                  ).copyWith(
                    hintStyle: secondaryTextStyle(color: textSecondary),
                  ),
                ),

                20.height,

                /// PASSWORD with visibility toggle
                TextFormField(
                  controller: passwordCtrl,
                  obscureText: _obscurePassword,
                  style: primaryTextStyle(color: textPrimary),
                  keyboardType: TextInputType.visiblePassword, // optional but recommended
                  decoration: inputDecoration(
                    context,
                    hintText: 'Create Password',
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: accentGreen,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade600
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ).copyWith(
                    hintStyle: secondaryTextStyle(color: textSecondary),
                  ),
                  validator: (v) =>
                  (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                ),

                48.height,

                /// CTA BUTTON - Gradient
                Container(
                  width: context.width(),
                  height: 40.h,
                  decoration: BoxDecoration(

                    // gradient: LinearGradient(
                    //   colors: [accentGreen, primaryColour],
                    //   begin: Alignment.centerLeft,
                    //   end: Alignment.centerRight,
                    // ),
                    borderRadius: BorderRadius.circular(16),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: accentGreen.withOpacity(0.25),
                    //     blurRadius: 12,
                    //     offset: const Offset(0, 6),
                    //   ),
                    // ],
                  ),
                  child: AppButton(
                    width: context.width(),
                    height: 56.h,
                    text: 'CREATE YOUR ACCOUNT',
                    textStyle: boldTextStyle(color: Colors.white, size: 16),
                    color: accentGreen,

                    onTap: _onActivate,
                  ),
                ),

                32.height,

                /// FOOTER NOTE
                Center(
                  child: Text(
                    'Your club administrator manages your role, activities, groups, teams, and permissions.',
                    style: secondaryTextStyle(
                        size: 12,
                        color: Colors.deepOrange,
                        weight: FontWeight.w800
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                80.height,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onActivate() {
    print("Navigate to that bottombar");
    Navigator.pushNamed(context, AppRoutes.guardianBar);

  }

  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:nb_utils/nb_utils.dart' hide whiteColor;
//
// import '../../config/colors.dart';
// import '../config/common.dart';
// import '../routes/app_routes.dart';
//
// class AccountActivationScreen extends StatefulWidget {
//   const AccountActivationScreen({super.key});
//
//   @override
//   State<AccountActivationScreen> createState() => _AccountActivationScreenState();
// }
//
// class _AccountActivationScreenState extends State<AccountActivationScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final nameCtrl = TextEditingController();
//   final mobileCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();
//   final passwordCtrl = TextEditingController();
//
//   bool _obscurePassword = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF0F172A),    // dark slate
//               scaffoldDark,         // main dark background
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 24.w),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   16.height,
//
//                   /// HEADER (Back + Title)
//                   Row(
//                     children: [
//                       InkWell(
//                         borderRadius: BorderRadius.circular(20),
//                         onTap: () => Navigator.pop(context),
//                         child: Icon(
//                           Icons.arrow_back_ios_new_rounded,
//                           size: 22,
//                           color: textPrimary,
//                         ),
//                       ),
//                       20.width,
//                       Text(
//                         'Activate Account',
//                         style: boldTextStyle(
//                           size: 24,
//                           color: textPrimary,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   48.height,
//
//                   /// SECTION TITLE
//                   Text(
//                     'Complete Your Profile',
//                     style: boldTextStyle(
//                       size: 22,
//                       color: accentGreen,
//                     ),
//                   ),
//                   8.height,
//                   Text(
//                     'Set up your account to join your squad and start managing',
//                     style: secondaryTextStyle(
//                       size: 14,
//                       color: textSecondary,
//                     ),
//                   ),
//
//                   40.height,
//
//                   /// NAME
//                   AppTextField(
//                     controller: nameCtrl,
//                     textFieldType: TextFieldType.NAME,
//                     textStyle: primaryTextStyle(color: textPrimary),
//                     decoration: inputDecoration(
//                       context,
//                       hintText: 'Full Name',
//                       prefixIcon: Icon(Icons.person_outline_rounded, color: accentGreen),
//                     ).copyWith(
//                       hintStyle: secondaryTextStyle(color: textSecondary),
//                     ),
//                     validator: (v) => v.isEmptyOrNull ? 'Full name is required' : null,
//                   ),
//
//                   20.height,
//
//                   /// MOBILE (locked / pre-filled)
//                   AppTextField(
//                     controller: mobileCtrl,
//                     textFieldType: TextFieldType.PHONE,
//                     textStyle: primaryTextStyle(color: textPrimary),
//                     enabled: false, // pre-filled from club invite/link
//                     decoration: inputDecoration(
//                       context,
//                       hintText: 'Mobile Number (from club)',
//                       prefixIcon: Icon(Icons.phone_android_rounded, color: accentGreen),
//                       fillColor: const Color(0xFF1F2A44).withOpacity(0.6),
//                     ).copyWith(
//                       hintStyle: secondaryTextStyle(color: textSecondary),
//                     ),
//                   ),
//
//                   20.height,
//
//                   /// EMAIL
//                   AppTextField(
//                     controller: emailCtrl,
//                     textFieldType: TextFieldType.EMAIL,
//                     textStyle: primaryTextStyle(color: textPrimary),
//                     decoration: inputDecoration(
//                       context,
//                       hintText: 'Email (optional)',
//                       prefixIcon: Icon(Icons.mail_outline_rounded, color: accentGreen),
//                     ).copyWith(
//                       hintStyle: secondaryTextStyle(color: textSecondary),
//                     ),
//                   ),
//
//                   20.height,
//
//                   /// PASSWORD with visibility toggle
//                   AppTextField(
//                     controller: passwordCtrl,
//                     textFieldType: TextFieldType.PASSWORD,
//                     textStyle: primaryTextStyle(color: textPrimary),
//                     obscureText: _obscurePassword,
//                     decoration: inputDecoration(
//                       context,
//                       hintText: 'Create Password',
//                       prefixIcon: Icon(Icons.lock_outline_rounded, color: accentGreen),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                           color: accentGreen,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword = !_obscurePassword;
//                           });
//                         },
//                       ),
//                     ).copyWith(
//                       hintStyle: secondaryTextStyle(color: textSecondary),
//                     ),
//                     validator: (v) =>
//                     (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
//                   ),
//
//                   48.height,
//
//                   /// CTA BUTTON - Gradient
//                   Container(
//                     width: context.width(),
//                     height: 40.h,
//                     decoration: BoxDecoration(
//
//                       // gradient: LinearGradient(
//                       //   colors: [accentGreen, primaryColour],
//                       //   begin: Alignment.centerLeft,
//                       //   end: Alignment.centerRight,
//                       // ),
//                       borderRadius: BorderRadius.circular(16),
//                       // boxShadow: [
//                       //   BoxShadow(
//                       //     color: accentGreen.withOpacity(0.25),
//                       //     blurRadius: 12,
//                       //     offset: const Offset(0, 6),
//                       //   ),
//                       // ],
//                     ),
//                     child: AppButton(
//                       width: context.width(),
//                       height: 56.h,
//                       text: 'ACTIVATE ACCOUNT',
//                       textStyle: boldTextStyle(color: Colors.black, size: 16),
//                       color: accentGreen,
//                       shapeBorder: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       onTap: _onActivate,
//                     ),
//                   ),
//
//                   32.height,
//
//                   /// FOOTER NOTE
//                   Center(
//                     child: Text(
//                       'Your role, club, group and team assignments are managed by your club administrator',
//                       style: secondaryTextStyle(
//                         size: 12,
//                         color: textSecondary,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//
//                   80.height, // extra bottom padding for scroll comfort
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _onActivate() {
//     if (_formKey.currentState!.validate()) {
//       toast('Account activated – Welcome to SQUAD!', bgColor: accentGreen);
//       // TODO: In real app → save profile + navigate based on role
//       // Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
//     } else {
//       toast('Please complete all required fields', bgColor: accentOrange);
//     }
//   }
//
//   @override
//   void dispose() {
//     nameCtrl.dispose();
//     mobileCtrl.dispose();
//     emailCtrl.dispose();
//     passwordCtrl.dispose();
//     super.dispose();
//   }
// }