// screens/clubadmin/add_guardian_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';

class ClubAdminAddGuardianScreen extends StatefulWidget {
  const ClubAdminAddGuardianScreen({super.key});

  @override
  State<ClubAdminAddGuardianScreen> createState() =>
      _ClubAdminAddGuardianScreenState();
}

class _ClubAdminAddGuardianScreenState
    extends State<ClubAdminAddGuardianScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1 – Personal Info
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emergencyContactCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  String? _selectedRelation;

  // Step 2 – Link Children
  List<String> _selectedChildren = [];

  final List<String> _stepTitles = [
    'Guardian Info',
    'Link Children',
    'Confirm',
  ];

  final List<String> _relations = [
    'Father',
    'Mother',
    'Grandparent',
    'Legal Guardian',
    'Other',
  ];

  final List<String> _availableChildren = [
    'Abinesh Kumar (Under-14 A - Football)',
    'Gopal Singh (Under-10 B - Swimming)',
    'Priya Sharma (Under-12 A - Football)',
    'Ravi Kumar (Under-16 - Cricket)',
    'Aarav Patel (Intermediate - Swimming)',
    'Saanvi Reddy (Under-8 - Basketball)',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emergencyContactCtrl.dispose();
    _occupationCtrl.dispose();
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
                        'Add New Guardian',
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
            /*
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
*/

            // ── Form Content ────────────────────────────────────────────
            Expanded(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                      'Add Guardian',
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

  void _handleNext() async {
    // Validate current step before proceeding
    if (!_formKey.currentState!.validate() || _isLoading) return;
    if (_selectedRelation == null) {
      AppUI.success(context, 'Please select relationship');
      return;
    }
    // Final submit – call API
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> data = {
        "username": _nameCtrl.text.trim(),
        "mobile": _phoneCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
        "password": _passwordCtrl.text.trim(),
        "relation": _selectedRelation ?? "",
        "emergencyContact":
            int.tryParse(_emergencyContactCtrl.text.trim()) ?? 0,
      };

      bool success = await ClubApiService().AddGuardian(data);

      if (success) {
        Navigator.pop(context);
        AppUI.success(context, 'Guardian added successfully!');
      } else {
        AppUI.error(context, 'Failed to add guardian. Please try again.');
      }
    } catch (e) {
      toast('Failed to add guardian');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  // ── Step 1: Guardian Personal Info ──────────────────────────────────
  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Guardian Information'),
        12.height,

        // Center(
        //   child: GestureDetector(
        //     onTap: () => toast('Pick guardian profile photo (optional)'),
        //     child: Container(
        //       width: 80.r,
        //       height: 80.r,
        //       decoration: BoxDecoration(
        //         color: accentGreen.withOpacity(0.1),
        //         shape: BoxShape.circle,
        //         border: Border.all(
        //           color: accentGreen.withOpacity(0.4),
        //           width: 2,
        //         ),
        //       ),
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Icon(
        //             Icons.camera_alt_rounded,
        //             color: accentGreen,
        //             size: 26.sp,
        //           ),
        //           4.height,
        //           Text(
        //             'Photo (opt)',
        //             style: GoogleFonts.poppins(
        //               fontSize: 10.sp,
        //               color: accentGreen,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        // Center(
        //   child: GestureDetector(
        //     onTap: () => toast('Pick guardian profile photo (optional)'),
        //     child: Container(
        //       width: 80.r,
        //       height: 80.r,
        //       decoration: BoxDecoration(
        //         color: accentGreen.withOpacity(0.1),
        //         shape: BoxShape.circle,
        //         border: Border.all(
        //           color: accentGreen.withOpacity(0.4),
        //           width: 2,
        //         ),
        //       ),
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Icon(
        //             Icons.camera_alt_rounded,
        //             color: accentGreen,
        //             size: 26.sp,
        //           ),
        //           4.height,
        //           Text(
        //             'Photo (opt)',
        //             style: GoogleFonts.poppins(
        //               fontSize: 10.sp,
        //               color: accentGreen,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        20.height,

        _formField(
          'Full Name *',
          _nameCtrl,
          Icons.person_rounded,
          hint: 'e.g., Nandha Kumar',
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
          hint: 'guardian@example.com',
          required: true,
        ),
        12.height,
        _formField(
          'Password *',
          _passwordCtrl,
          Icons.lock_outline_rounded,
          hint: 'Create a password',
          obscureText: true,
        ),
        12.height,
        _formField(
          'Emergency Contact *',
          _emergencyContactCtrl,
          Icons.contact_phone_rounded,
          hint: '+91 XXXXX XXXXX',
          keyboardType: TextInputType.phone,
        ),
        // 12.height,
        // _formField('Occupation (optional)', _occupationCtrl,
        //     Icons.work_rounded,
        //     hint: 'e.g., Software Engineer', required: false),
        12.height,
        _dropdownField(
          'Relation to Children*',
          _relations,
          _selectedRelation,
          (v) => setState(() => _selectedRelation = v),
        ),
      ],
    );
  }

  Widget _step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Link Children'),
        12.height,
        _infoBox(
          'Select one or more children this guardian will have access to.\nThey will receive OTP login credentials.',
          Icons.family_restroom_rounded,
          accentGreen,
        ),
        16.height,

        if (_availableChildren.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Text(
                'No children available to link.\nAdd members first.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: textSecondary,
                  fontSize: 13.sp,
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _availableChildren.map((child) {
              final selected = _selectedChildren.contains(child);
              return FilterChip(
                label: Text(
                  child,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                selected: selected,
                onSelected: (sel) {
                  setState(() {
                    if (sel) {
                      _selectedChildren.add(child);
                    } else {
                      _selectedChildren.remove(child);
                    }
                  });
                },
                selectedColor: accentGreen.withOpacity(0.15),
                checkmarkColor: accentGreen,
                backgroundColor: Colors.white,
                shape: StadiumBorder(
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ── Step 3: Summary & Confirm ──────────────────────────────────────
  Widget _step3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Review & Confirm'),
        12.height,
        _infoBox(
          'Guardian will be able to view schedules, attendance, performance, and communicate with coaches for the linked children.',
          Icons.security_rounded,
          accentGreen,
        ),
        24.height,

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
                'Summary',
                style: GoogleFonts.montserrat(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              12.height,
              _summaryRow(
                'Name',
                _nameCtrl.text.isNotEmpty ? _nameCtrl.text : '—',
              ),
              _summaryRow(
                'Phone',
                _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : '—',
              ),
              _summaryRow(
                'Email',
                _emailCtrl.text.isNotEmpty ? _emailCtrl.text : '—',
              ),
              _summaryRow('Relation', _selectedRelation ?? '—'),
              _summaryRow(
                'Emergency',
                _emergencyContactCtrl.text.isNotEmpty
                    ? _emergencyContactCtrl.text
                    : '—',
              ),
              _summaryRow(
                'Linked Children',
                _selectedChildren.isNotEmpty
                    ? '${_selectedChildren.length} selected'
                    : 'None',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
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
        bool obscureText = false,
        String? Function(String?)? customValidator,
      }) {
    String fieldName = label.replaceAll(RegExp(r'[\*\s]'), '');

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
          maxLines: maxLines,
          keyboardType: keyboardType,
          obscureText: obscureText,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: customValidator ?? (v) {
            if (!required) return null;

            if (label.contains("Email")) {
              return AppValidator.validateEmail(v);
            }
            if (label.contains("Phone") || label.contains("WhatsApp") || label.contains("Emergency")) {
              return AppValidator.validatePhone(v);
            }
            if (label.contains("Password")) {
              return AppValidator.validatePassword(v);
            }
            if (label.contains("Name") || label.contains("Full Name")) {
              return AppValidator.validateName(v, fieldName: "Full Name");
            }
            return AppValidator.validateRequired(v, fieldName);
          },
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
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
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

  Widget _dropdownField(
    String label,
    List<String> items,
    String? value,
    void Function(String?) onChange,
  ) {
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
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChange,
          validator: (v) => v == null ? 'Required' : null,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
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
          ),
          items: items
              .map(
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(
                    i,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
