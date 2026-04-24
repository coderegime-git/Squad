// lib/pages/onboarding/coach_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../routes/app_routes.dart';

class CoachOnboardingScreen extends StatefulWidget {
  const CoachOnboardingScreen({super.key});

  @override
  State<CoachOnboardingScreen> createState() => _CoachOnboardingScreenState();
}

class _CoachOnboardingScreenState extends State<CoachOnboardingScreen> {
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  List<String> _selectedGroups = [];

  final List<String> _availableGroups = [
    'Under-8 A - Football',
    'Under-10 B - Cricket',
    'Under-12 Elite - Swimming',
    'Under-14 A - Football',
    'Beginner Swimming',
  ];

  bool _isSubmitting = false;

  void _submitCoachSetup() {
    if (_nameController.text.trim().isEmpty) {
      toast("Please enter your name", bgColor: accentOrange);
      return;
    }
    if (_selectedGroups.isEmpty) {
      toast("Please select at least one group", bgColor: accentOrange);
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API request to club admin for approval
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isSubmitting = false);
      toast("Setup request sent! Club admin will assign groups soon.", bgColor: accentGreen);

      // Go to coach dashboard (limited until approved)
      Future.delayed(const Duration(seconds: 1), () {
        //Navigator.pushReplacementNamed(context, AppRoutes.coachDashboard); // create this route later
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldDark,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 26.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Coach Setup",
          style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w600, color: accentGreen),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,

            Text(
              "Let's get you set up as a Coach",
              style: GoogleFonts.montserrat(fontSize: 22.sp, fontWeight: FontWeight.w700, color: Colors.black),
            ),
            8.height,
            Text(
              "Fill in your details and select groups. Club admin will review and assign you.",
              style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary, height: 1.4),
            ),

            32.height,

            // Coach Name
            _buildLabel("Your Full Name *"),
            8.height,
            AppTextField(
              controller: _nameController,
              textFieldType: TextFieldType.NAME,
              textStyle: GoogleFonts.poppins(color: Colors.black, fontSize: 14.sp),
              decoration: _inputDecoration("Enter your name"),
            ),

            24.height,

            // Specialization
            _buildLabel("Specialization / Expertise"),
            8.height,
            AppTextField(
              controller: _specializationController,
              textFieldType: TextFieldType.OTHER,
              textStyle: GoogleFonts.poppins(color: Colors.black, fontSize: 14.sp),
              decoration: _inputDecoration("e.g., Football Tactics, Swimming Coach"),
            ),

            24.height,

            // Group Selection (multi-select chips)
            _buildLabel("Select Groups You Want to Coach *"),
            8.height,
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _availableGroups.map((group) {
                final isSelected = _selectedGroups.contains(group);
                return FilterChip(
                  label: Text(
                    group,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: isSelected ? Colors.black : Colors.black,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: accentGreen,
                  backgroundColor: cardDark,
                  checkmarkColor: Colors.black,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedGroups.add(group);
                      } else {
                        _selectedGroups.remove(group);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            40.height,

            // Submit
            AppButton(
              width: double.infinity,
              height: 50.h,
              text: _isSubmitting ? "Submitting..." : "Submit for Approval",
              textStyle: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white),
              color: _isSubmitting ? Colors.grey : accentGreen,
              shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              onTap: _isSubmitting ? null : _submitCoachSetup,
            ),

            24.height,

            Center(
              child: Text(
                "Club admin will review and assign your groups shortly",
                style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary, fontStyle: FontStyle.italic),
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
      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.w500),
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
        borderSide: BorderSide(color: Colors.grey.shade600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: accentGreen, width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    super.dispose();
  }
}