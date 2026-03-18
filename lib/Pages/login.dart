import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../config/common.dart';
import '../routes/app_routes.dart';
import '../utills/api_service.dart';
import '../utills/helper.dart';
import '../utills/shared_preference.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final mobileCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool _hasAttemptedLogin = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  Future<void> _validateAndLogin() async {
    setState(() => _hasAttemptedLogin = true);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> data = {
        "username": mobileCtrl.text,
        "password": passwordCtrl.text,
      };

      bool success = await ClubApiService().login(data);

      if (success) {
        String token = SharedPreferenceHelper.getToken() ?? '';
        if (token.startsWith('Bearer ')) token = token.substring(7);
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final Map<String, dynamic> jwtData = jsonDecode(decoded);
          print("JWT payload: $jwtData");
          final int userId = jwtData['userId'] ?? 0;

          SharedPreferenceHelper.setId(userId);
          SharedPreferenceHelper.setClubId(jwtData['clubId'].toString());
          print("userId from JWT: $userId");
        }
        // ──────────────────────────────────────────────────────────────

        final taskData = await ClubApiService().getTasks();
        print("getTasks RAW response: $taskData");

        if (taskData != null) {
          final String role = taskData['role'] ?? '';
          final String username = taskData['username'] ?? mobileCtrl.text;

          SharedPreferenceHelper.setRole(role);
          SharedPreferenceHelper.setUsername(username);

          print(
            "Saved → role: $role | userId: ${SharedPreferenceHelper.getId()} | username: $username",
          );

          AppUI.success(context, "Login successful!");

          switch (role) {
            case 'GUARDIAN':
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.guardianBar,
                (route) => false,
              );
              break;
            case 'MEMBER':
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.memberBar,
                (route) => false,
              );
              break;
            case 'CLUB_ADMIN':
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.clubAdmin,
                (route) => false,
              );
              break;
            case 'COACH':
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.coachBar,
                (route) => false,
              );
              break;
            default:
              AppUI.error(context, "Unknown role: $role");
          }
        } else {
          AppUI.error(context, "Failed to fetch user role. Please try again.");
        }
      } else {
        AppUI.error(context, "Login failed. Please check your credentials.");
      }
    } catch (e) {
      print("Login error: $e");
      AppUI.error(context, "Login failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              margin: EdgeInsets.all(5.w),
              height: 90.h,
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.black,
              ),
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
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        40.height,
                        48.height,
                        Text(
                          "Login",
                          style: boldTextStyle(size: 28, color: textPrimary),
                        ),
                        4.height,
                        Text(
                          "Access your club dashboard",
                          style: secondaryTextStyle(
                            size: 14,
                            color: textSecondary,
                          ),
                        ),
                        40.height,
                        AppTextField(
                          controller: mobileCtrl,
                          textFieldType: TextFieldType.USERNAME,
                          textStyle: primaryTextStyle(color: textPrimary),
                          keyboardType: TextInputType.name,
                          decoration:
                              inputDecoration(
                                context,
                                hintText: 'User name',
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: accentGreen,
                                ),
                              ).copyWith(
                                hintStyle: secondaryTextStyle(
                                  color: textSecondary,
                                ),
                              ),
                          validator: (v) =>
                              (v == null) ? 'Enter your username' : null,
                        ),
                        20.height,
                        TextField(
                          controller: passwordCtrl,
                          obscureText: _obscurePassword,
                          style: primaryTextStyle(color: textPrimary),
                          decoration:
                              inputDecoration(
                                context,
                                hintText: 'Password',
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: accentGreen,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ).copyWith(
                                hintStyle: secondaryTextStyle(
                                  color: textSecondary,
                                ),
                              ),
                        ),
                        12.height,
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                toast('Forgot Password – feature coming soon'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: primaryTextStyle(
                                color: Colors.black,
                                size: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        40.height,
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 3,
                            ),
                            onPressed: _validateAndLogin,
                            child: _isLoading
                                ? AppUI.buttonSpinner()
                                : Text(
                                    'SIGN IN',
                                    style: boldTextStyle(
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                          ),
                        ),
                        40.height,
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.roleSelection,
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: secondaryTextStyle(
                                  color: textSecondary,
                                  size: 14,
                                ),
                                children: [
                                  const TextSpan(text: "New to SQUAD? "),
                                  TextSpan(
                                    text: "Create account",
                                    style: boldTextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        60.height,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mobileCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }
}
