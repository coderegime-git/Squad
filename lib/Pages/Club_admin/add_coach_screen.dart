// screens/clubadmin/add_coach_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';

class ClubAdminAddCoachScreen extends StatefulWidget {
  const ClubAdminAddCoachScreen({super.key});

  @override
  State<ClubAdminAddCoachScreen> createState() =>
      _ClubAdminAddCoachScreenState();
}

class _ClubAdminAddCoachScreenState extends State<ClubAdminAddCoachScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final roleController = TextEditingController();
  final _certificationCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  String? _selectedSpecialization;
  List<String> _selectedGroups = [];

  final List<String> _stepTitles = [
    'Personal Info',
    'Specialization',
    'Assign Groups',
  ];

  final List<String> _specializations = [
    'Football',
    'Swimming',
    'Cricket',
    'Basketball',
    'Athletics',
  ];

  final List<String> _availableGroups = [
    'Under-10 A',
    'Under-10 B',
    'Under-12 A',
    'Under-14 A',
    'Under-14 B',
    'Under-16',
    'Intermediate',
    'Advanced',
  ];

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _experienceCtrl.dispose();
    _certificationCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
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
            // ── Header ──────────────────────────────────────────────────
            Container(
              height: 85.h,
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
                        'Add New Coach',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
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

            // ── Step Indicator ──────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                children: List.generate(_stepTitles.length, (i) {
                  final isDone = i < _currentStep;
                  final isActive = i == _currentStep;
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // connecting line
                              if (i < _stepTitles.length - 1)
                                Positioned(
                                  left: 20.r,
                                  right: -30.r,
                                  top: 13.r,
                                  child: Container(
                                    height: 2.h,
                                    color: i < _currentStep
                                        ? accentGreen
                                        : Colors.grey.shade300,
                                  ),
                                ),

                              Column(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: 28.r,
                                    height: 28.r,
                                    decoration: BoxDecoration(
                                      color: (isDone || isActive)
                                          ? accentGreen
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: (isDone || isActive)
                                            ? accentGreen
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: isDone
                                          ? const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : Text(
                                              '${i + 1}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13.sp,
                                                color: isActive
                                                    ? Colors.white
                                                    : textSecondary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                  8.height,
                                  Text(
                                    _stepTitles[i],
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.sp,
                                      color: isActive
                                          ? accentGreen
                                          : textSecondary,
                                      fontWeight: isActive
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // ── Form Content ────────────────────────────────────────────
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _stepContent(),
                      28.height,
                      Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() => _currentStep--),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                child: Text(
                                  'Back',
                                  style: GoogleFonts.poppins(
                                    color: textSecondary,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          if (_currentStep > 0) 12.width,
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              child: _isLoading
                                  ? AppUI.buttonSpinner()
                                  : Text(
                                      'Add Coach',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      40.height,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentStep < _stepTitles.length - 1) {
      setState(() => _currentStep++);
      return;
    }

    // Final step → call API
    if (_selectedSpecialization == null) {
      toast('Please select a specialization');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        "username": _usernameCtrl.text.trim(),
        "password": _passwordCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
        "mobile": _phoneCtrl.text.trim(),
        "specialization": _selectedSpecialization ?? "",
        "experienceYears": int.tryParse(_experienceCtrl.text.trim()) ?? 0,
        //"groups": _selectedGroups,
        "certification": _certificationCtrl.text.trim(),
        "bio": _bioCtrl.text.trim(),
        "role": roleController.text,
      };

      // Optional: remove empty optional fields if backend doesn't like empty strings
      // if (data["certification"] == "") data.remove("certification");
      // if (data["bio"] == "") data.remove("bio");

      bool success = await ClubApiService().AddCoach(data);

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          AppUI.success(context, 'Coach added successfully!');
        }
      } else {
        if (mounted) {
          AppUI.error(context, 'Failed to add coach. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        AppUI.error(context, 'Failed to add coach. Please try again.');
        print("${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _stepContent() {
    switch (_currentStep) {
      case 0:
        return _step1();
      case 1:
        return _step2();
      case 2:
        return _step3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Personal Information'),
        12.height,

        /*     Center(
          child: GestureDetector(
            onTap: () => toast('Pick coach profile photo'),
            child: Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: accentGreen.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentGreen.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_rounded,
                    color: accentGreen,
                    size: 26.sp,
                  ),
                  4.height,
                  Text(
                    'Photo',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: accentGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        20.height,*/
        _formField(
          'Username *',
          _usernameCtrl,
          Icons.account_circle_rounded,
          hint: 'e.g., coach_sunny',
        ),
        12.height,

        _formField(
          'Password *',
          _passwordCtrl,
          Icons.lock_rounded,
          hint: '••••••••••',
          obscureText: true,
        ),
        12.height,

        _formField(
          'Phone / WhatsApp *',
          _phoneCtrl,
          Icons.phone_rounded,
          hint: '+91 XXXXX XXXXX',
          keyboardType: TextInputType.phone,
        ),
        12.height,

        _formField(
          'Email *',
          _emailCtrl,
          Icons.email_rounded,
          hint: 'coach@example.com',
        ),
        12.height,

        _formField(
          'Years of Experience',
          _experienceCtrl,
          Icons.timeline_rounded,
          hint: 'e.g., 8',
          keyboardType: TextInputType.number,
          required: false,
        ),
        12.height,

        _formField(
          'Certification',
          _certificationCtrl,
          Icons.workspace_premium_rounded,
          hint: 'e.g., AIFF Level B',
          required: false,
        ),
        12.height,
        _formField(
          'Role ',
          roleController,
          Icons.workspace_premium_rounded,
          hint: 'e.g., Team lead',
          required: false,
        ),
        12.height,

        _formField(
          'Bio',
          _bioCtrl,
          Icons.description_rounded,
          hint: 'Short description about coach',
          required: false,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Specialization'),
        12.height,
        _infoBox(
          'Select the main sport/activity this coach specializes in.',
          Icons.sports_rounded,
          accentGreen,
        ),
        16.height,
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: _specializations.map((spec) {
            final selected = _selectedSpecialization == spec;
            return ChoiceChip(
              label: Text(spec),
              selected: selected,
              onSelected: (_) => setState(() => _selectedSpecialization = spec),
              selectedColor: accentGreen,
              backgroundColor: Colors.white,
              labelStyle: GoogleFonts.poppins(
                color: selected ? Colors.white : textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(
                  color: selected ? accentGreen : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Step 3: Assign Groups & Summary ────────────────────────────────
  Widget _step3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Assign Groups'),
        12.height,
        _infoBox(
          'Select all groups/sub-groups this coach will be responsible for.',
          Icons.group_work_rounded,
          Colors.blue,
        ),
        16.height,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _availableGroups.map((group) {
            final selected = _selectedGroups.contains(group);
            return FilterChip(
              label: Text(
                group,
                style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
              ),
              selected: selected,
              onSelected: (sel) {
                setState(() {
                  if (sel) {
                    _selectedGroups.add(group);
                  } else {
                    _selectedGroups.remove(group);
                  }
                });
              },
              selectedColor: accentGreen.withOpacity(0.15),
              checkmarkColor: accentGreen,
              backgroundColor: Colors.white,
              shape: StadiumBorder(
                side: BorderSide(color: Colors.grey.shade500),
              ),
            );
          }).toList(),
        ),
        32.height,

        // Summary card
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Summary',
                style: GoogleFonts.montserrat(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              12.height,
              _summaryRow(
                'Username',
                _usernameCtrl.text.isNotEmpty ? _usernameCtrl.text : '—',
              ),
              _summaryRow('Specialization', _selectedSpecialization ?? '—'),
              _summaryRow(
                'Groups',
                _selectedGroups.isNotEmpty ? _selectedGroups.join(', ') : '—',
              ),
              _summaryRow(
                'Experience',
                _experienceCtrl.text.isNotEmpty
                    ? '${_experienceCtrl.text} years'
                    : '—',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String text) => Text(
    text,
    style: GoogleFonts.montserrat(
      fontSize: 16.sp,
      fontWeight: FontWeight.w800,
      color: Colors.black,
    ),
  );

  Widget _infoBox(String msg, IconData icon, Color color) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16.sp),
        8.width,
        Expanded(
          child: Text(
            msg,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: color.withOpacity(0.85),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _formField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    String? hint,
    bool required = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool obscureText = false, // added support for password
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        6.height,
        TextFormField(
          controller: ctrl,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: required
              ? (v) => (v == null || v.trim().isEmpty)
                    ? label == "Email *"
                          ? validateEmail(v!)
                          : 'Required'
                    : null
              : null,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: textSecondary.withOpacity(0.5),
            ),
            prefixIcon: Icon(icon, color: textSecondary, size: 18.sp),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 13.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: accentGreen, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  static String emailPattern =
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$";
  static RegExp emailRegEx = RegExp(emailPattern);

  // Validates an email address.
  static bool isEmail(String value) {
    if (emailRegEx.hasMatch(value.trim())) {
      return true;
    }
    return false;
  }

  static String? validateEmail(String value) {
    String email = value.trim();
    if (email.isEmpty) {
      return 'Email field is required';
    }
    if (!isEmail(email)) {
      return 'Email error valid';
    }
    return null;
  }
}
