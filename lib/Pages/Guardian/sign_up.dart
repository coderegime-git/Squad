// lib/Pages/Guardian/sign_up.dart  (or parent_onboarding_screen.dart)
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../routes/app_routes.dart';

class ParentOnboardingScreen extends StatefulWidget {
  const ParentOnboardingScreen({super.key});

  @override
  State<ParentOnboardingScreen> createState() => _ParentOnboardingScreenState();
}

class _ParentOnboardingScreenState extends State<ParentOnboardingScreen> {
  final _childNameController = TextEditingController();
  final _childMobileController = TextEditingController();
  String? _selectedClub;
  String? _selectedActivity;
  String? _selectedGroup;

  final List<String> _clubs = ['XYZ FC Madurai', 'ABC Sports Club', 'United FC', 'Royal Tigers'];
  final List<String> _activities = ['Football', 'Cricket', 'Swimming', 'Basketball', 'Kabaddi'];
  final List<String> _groups = ['Under-8 A', 'Under-10 B', 'Under-12 A', 'Under-14 Elite', 'Beginner'];

  bool _isSubmitting = false;

  void _submitRequest() {
    if (_childNameController.text.trim().isEmpty) {
      toast("Please enter child's name", bgColor: accentOrange);
      return;
    }
    if (_selectedClub == null || _selectedActivity == null || _selectedGroup == null) {
      toast("Please select club, activity & group", bgColor: accentOrange);
      return;
    }

    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isSubmitting = false);
      toast("Request sent! Club admin will verify shortly.", bgColor: accentGreen);
      Future.delayed(const Duration(seconds: 1), () {
        //Navigator.pushReplacementNamed(context, AppRoutes.guardian);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 26.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Parent Setup",
          style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w600, color: accentGreen),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            12.height,

            Text(
              "Let's connect your child",
              style: GoogleFonts.montserrat(fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.black),
            ),
            6.height,
            Text(
              "Enter details. Club admin will review & activate.",
              style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary, height: 1.4),
            ),

            28.height,

            // Child Name
            _buildLabel("Child's Full Name *"),
            6.height,
            AppTextField(
              controller: _childNameController,
              textFieldType: TextFieldType.NAME,
              textStyle: GoogleFonts.poppins(color: Colors.black, fontSize: 14.sp),
              decoration: _inputDecoration("Enter child's name"),
            ),

            20.height,

            // Child Mobile
            _buildLabel("Child's Mobile (optional)"),
            6.height,
            AppTextField(
              controller: _childMobileController,
              textFieldType: TextFieldType.PHONE,
              keyboardType: TextInputType.phone,
              textStyle: GoogleFonts.poppins(color: Colors.black, fontSize: 14.sp),
              decoration: _inputDecoration("Enter mobile number"),
            ),

            20.height,

            // Club
            _buildLabel("Club *"),
            6.height,
            DropdownButtonFormField<String>(
              value: _selectedClub,
              isExpanded: true, // ← IMPORTANT: prevents right overflow
              hint: Text("Select club", style: GoogleFonts.poppins(color: textSecondary, fontSize: 14.sp)),
              items: _clubs.map((club) {
                return DropdownMenuItem(
                  value: club,
                  child: Text(club, style: GoogleFonts.poppins(color: Colors.black, fontSize: 14.sp)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedClub = value),
              decoration: _dropdownDecoration(),
              dropdownColor: cardDark,

            ),

            20.height,

            // Activity + Group – aligned perfectly
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Activity *"),
                      6.height,
                      DropdownButtonFormField<String>(
                        value: _selectedActivity,
                        isExpanded: true,
                        hint: Text("Select", style: GoogleFonts.poppins(color: textSecondary, fontSize: 14.sp)),
                        items: _activities.map((act) {
                          return DropdownMenuItem(
                            value: act,
                            child: Text(act, style: GoogleFonts.poppins(color: Colors.black, fontSize: 14.sp)),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedActivity = v),
                        decoration: _dropdownDecoration(),
                        dropdownColor: cardDark,
                      ),
                    ],
                  ),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Group / Sub-group *"),
                      6.height,
                      DropdownButtonFormField<String>(
                        value: _selectedGroup,
                        isExpanded: true,
                        hint: Text("Select", style: GoogleFonts.poppins(color: textSecondary, fontSize: 14.sp)),
                        items: _groups.map((g) {
                          return DropdownMenuItem(
                            value: g,
                            child: Text(g, style: GoogleFonts.poppins(color: Colors.black, fontSize: 14.sp)),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedGroup = v),
                        decoration: _dropdownDecoration(),
                        dropdownColor: cardDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            48.height,

            // Submit
            AppButton(
              width: double.infinity,
              height: 50.h,
              text: _isSubmitting ? "Sending..." : "Submit Request",
              textStyle: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white),
              color: _isSubmitting ? Colors.grey : accentGreen,
              shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              onTap: _isSubmitting ? null : _submitRequest,
            ),

            24.height,

            Center(
              child: Text(
                "Club admin will verify and activate the profile soon",
                style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),

            60.height,
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black, fontWeight: FontWeight.w500),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: textSecondary, fontSize: 14.sp),
      filled: true,
      fillColor: cardDark.withOpacity(0.85),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: accentGreen, width: 1.5),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: cardDark.withOpacity(0.85),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: accentGreen, width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _childNameController.dispose();
    _childMobileController.dispose();
    super.dispose();
  }
}