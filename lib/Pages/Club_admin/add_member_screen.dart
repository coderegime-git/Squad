// screens/clubadmin/clubadmin_add_member.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_guardians.dart';
import '../../utills/api_service.dart';
import '../../utills/helper.dart';

class ClubAdminAddMemberScreen extends StatefulWidget {
  const ClubAdminAddMemberScreen({super.key});

  @override
  State<ClubAdminAddMemberScreen> createState() =>
      _ClubAdminAddMemberScreenState();
}

class _ClubAdminAddMemberScreenState extends State<ClubAdminAddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;
  List<GuardianData> _guardians = [];
  GuardianData? _selectedGuardian;

  // Step 1 – Personal Info
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _medicalNotesCtrl = TextEditingController();
  String? _selectedGender;

  // Step 2 – Club Details
  String? _selectedActivity;
  String? _selectedGroup;
  String? _selectedSubGroup;
  final _jerseyCtrl = TextEditingController();
  final _membershipStartCtrl = TextEditingController();
  final _membershipEndCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  String? _selectedPaymentStatus;

  // Step 3 – Guardian Info
  final _guardianNameCtrl = TextEditingController();
  final _guardianPhoneCtrl = TextEditingController();
  final _guardianEmailCtrl = TextEditingController();
  String? _selectedRelation;
  final apiService = ClubApiService();
  final List<String> _stepTitles = [
    'Personal Info',
    'Club Details',
    'Guardian Info',
  ];
  bool _loadingGuardians = true;
  final _genders = ['Male', 'Female', 'Other'];
  final _activities = ['Football', 'Swimming', 'Cricket', 'Basketball'];
  final _groups = [
    'Under-10',
    'Under-12',
    'Under-14',
    'Under-16',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];
  final _subGroups = [
    'Team A',
    'Team B',
    'Squad Alpha',
    'Squad Beta',
    'Main Squad',
  ];
  final _paymentStatuses = ['Paid', 'Pending', 'Partial'];
  final _relations = ['Father', 'Mother', 'Guardian', 'Other'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    _medicalNotesCtrl.dispose();
    _jerseyCtrl.dispose();
    _membershipStartCtrl.dispose();
    _membershipEndCtrl.dispose();
    _feeCtrl.dispose();
    _guardianNameCtrl.dispose();
    _guardianPhoneCtrl.dispose();
    _guardianEmailCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getGuardianData();
    super.initState();
  }

  void getGuardianData() async {
    final guardianResult = await apiService.getGuardians();
    setState(() {
      _guardians = guardianResult.data;
      _loadingGuardians = false;
    });
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
                        'Add New Member',
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
                                      /* _currentStep == _stepTitles.length - 1
                                          ?*/
                                      'Add Member',
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
    if (!_formKey.currentState!.validate() || _isLoading) return;
    if (_selectedGuardian == null) {
      AppUI.success(context, 'Please select guardian');
      return;
    }
    if (_selectedGender == null) {
      AppUI.success(context, 'Please select gender');
      return;
    }
    /* if (_currentStep < _stepTitles.length - 1) {
      setState(() => _currentStep++);
    } else {*/
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> data = {
        "username": _nameCtrl.text.trim(),
        "mobile": _phoneCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
        "password": _passwordCtrl.text.trim(),
        "emergencyContact": int.tryParse(_guardianPhoneCtrl.text.trim()) ?? 0,
        "dob": _dobCtrl.text.trim().isNotEmpty
            ? DateFormat(
                'yyyy-MM-dd',
              ).format(DateFormat('dd/MM/yyyy').parse(_dobCtrl.text.trim()))
            : "",
        "gender": _selectedGender ?? "",
        "medicalNotes": _medicalNotesCtrl.text.trim(),
        "guardianUserId": _selectedGuardian!.guardianId,
        "membershipAmount": 10,
      };

      bool success = await ClubApiService().AddMember(data);
      if (success) {
        Navigator.pop(context);
        //toast('Member added successfully!', bgColor: accentGreen);
        AppUI.success(context, 'Member added successfully!');
      } else {
        //toast('Failed to add member. Please try again.');
        AppUI.error(context, "Failed to add member, Please try again.");
      }
    } catch (e) {
      //toast('Error: ${e.toString()}');
      AppUI.error(context, "Failed to add member, Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
    //  }
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

  // ── Step 1: Personal Info ───────────────────────────────────────────
  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Personal Information'),
        12.height,

        /*   Center(
          child: GestureDetector(
            onTap: () => toast('Pick profile photo'),
            child: Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: accentGreen.withOpacity(0.1),
                shape: BoxShape.circle,
                border:
                Border.all(color: accentGreen.withOpacity(0.4), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded, color: accentGreen, size: 26.sp),
                  4.height,
                  Text('Photo',
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp, color: accentGreen)),
                ],
              ),
            ),
          ),
        ),
        20.height,
*/
        _formField(
          'Full Name *',
          _nameCtrl,
          Icons.person_rounded,
          hint: 'e.g., Abinesh Kumar',
        ),
        12.height,
        _dateField('Date of Birth *', _dobCtrl, Icons.calendar_today_rounded),
        12.height,
        _dropdownField(
          'Gender *',
          _genders,
          _selectedGender,
          (v) => setState(() => _selectedGender = v),
        ),
        12.height,
        _formField(
          'Phone / WhatsApp *',
          _phoneCtrl,
          Icons.phone_rounded,
          hint: '987453210',
          keyboardType: TextInputType.phone,
        ),
        12.height,
        _formField(
          'Email *',
          _emailCtrl,
          Icons.email_rounded,
          hint: 'member@email.com',
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
          'Medical Notes',
          _medicalNotesCtrl,
          Icons.medical_information_rounded,
          hint: 'e.g., No known allergies',
          required: true,
        ),
        12.height,
        _formField(
          'Emergency Contact',
          _guardianPhoneCtrl,
          keyboardType: TextInputType.number,
          Icons.phone,
          hint: '98745623210',
          required: true,
        ),
        12.height,
        8.height,
        (_loadingGuardians)
            ? const Center(child: CircularProgressIndicator())
            : _guardians.isEmpty
            ? Text('No guardians available')
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
                    .map(
                      (g) => DropdownMenuItem(
                        value: g,
                        child: Text(
                          g.username,
                          style: GoogleFonts.poppins(fontSize: 13.sp),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedGuardian = v),
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
                    borderSide: BorderSide(color: accentGreen, width: 1.5),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Club & Sport Details'),
        12.height,
        _infoBox(
          'The member will be uniquely identified as:\nClub + Activity + Group + Sub-group + Member',
          Icons.info_outline_rounded,
          Colors.blue,
        ),
        16.height,
        _dropdownField(
          'Activity / Sport *',
          _activities,
          _selectedActivity,
          (v) => setState(() => _selectedActivity = v),
        ),
        12.height,
        _dropdownField(
          'Group *',
          _groups,
          _selectedGroup,
          (v) => setState(() => _selectedGroup = v),
        ),
        12.height,
        _dropdownField(
          'Sub-group *',
          _subGroups,
          _selectedSubGroup,
          (v) => setState(() => _selectedSubGroup = v),
        ),
        12.height,
        _formField(
          'Jersey / ID Number (optional)',
          _jerseyCtrl,
          Icons.tag_rounded,
          hint: '#10',
          required: false,
        ),
        20.height,
        _heading('Membership & Payment'),
        12.height,
        _dateField(
          'Membership Start Date *',
          _membershipStartCtrl,
          Icons.calendar_month_rounded,
        ),
        12.height,
        _dateField(
          'Membership End Date *',
          _membershipEndCtrl,
          Icons.event_rounded,
        ),
      ],
    );
  }

  Widget _step3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Guardian Information'),
        12.height,
        _infoBox(
          'Guardian will receive an OTP login to view this member\'s schedule, events, and performance.',
          Icons.security_rounded,
          accentGreen,
        ),
        16.height,

        _formField(
          'Guardian Email (optional)',
          _guardianEmailCtrl,
          Icons.email_rounded,
          hint: 'guardian@email.com',
          required: false,
        ),
        12.height,
        // _dropdownField('Relation to Member *', _relations, _selectedRelation,
        //         (v) => setState(() => _selectedRelation = v)),
        20.height,

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
                'Name',
                _nameCtrl.text.isNotEmpty ? _nameCtrl.text : '—',
              ),
              _summaryRow('Activity', _selectedActivity ?? '—'),
              _summaryRow('Group', _selectedGroup ?? '—'),
              _summaryRow('Sub-group', _selectedSubGroup ?? '—'),
              _summaryRow(
                'Guardian',
                _guardianNameCtrl.text.isNotEmpty
                    ? _guardianNameCtrl.text
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
    bool obscureText = false,
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
          maxLines: maxLines,
          keyboardType: keyboardType,
          obscureText: obscureText,
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

  Widget _dateField(String label, TextEditingController ctrl, IconData icon) {
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
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1980),
              lastDate: DateTime(2040),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(primary: accentGreen),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              ctrl.text = DateFormat('dd/MM/yyyy').format(picked);
            }
          },
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
            hintText: 'DD/MM/YYYY',
            hintStyle: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: textSecondary.withOpacity(0.5),
            ),
            prefixIcon: Icon(icon, color: textSecondary, size: 18.sp),
            suffixIcon: Icon(
              Icons.calendar_today_rounded,
              color: accentGreen,
              size: 18.sp,
            ),
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
        ),
      ],
    );
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
