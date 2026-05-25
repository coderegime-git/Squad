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
  GuardianData? _selectedGuardian2;
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _medicalNotesCtrl = TextEditingController();
  String? _selectedGender;
  bool _isPasswordVisible = false;

  // Step 2 – Club Details
  String? _selectedActivity;
  String? _selectedGroup;
  String? _selectedSubGroup;
  final _jerseyCtrl = TextEditingController();
  final TextEditingController _membershipAmountCtrl = TextEditingController();
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
    'Under-10', 'Under-12', 'Under-14', 'Under-16',
    'Beginner', 'Intermediate', 'Advanced',
  ];
  final _subGroups = [
    'Team A', 'Team B', 'Squad Alpha', 'Squad Beta', 'Main Squad',
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
    _membershipAmountCtrl.dispose();
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

  // ── Searchable Guardian Picker ─────────────────────────────────────────────
  /// Opens a bottom-sheet with a live search field and a scrollable list of guardians.
  /// Returns the chosen [GuardianData] or null if dismissed.
  Future<GuardianData?> _showGuardianPicker({
    String title = 'Choose Guardian',
    GuardianData? current,
    GuardianData? exclude, // prevent selecting the same guardian twice
  }) async {
    final searchCtrl = TextEditingController();
    List<GuardianData> filtered = List.from(_guardians);
    if (exclude != null) {
      filtered = filtered.where((g) => g.guardianId != exclude.guardianId).toList();
    }

    GuardianData? picked = await showModalBottomSheet<GuardianData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            void onSearch(String q) {
              final query = q.toLowerCase().trim();
              setSheetState(() {
                final base = exclude != null
                    ? _guardians.where((g) => g.guardianId != exclude.guardianId).toList()
                    : List<GuardianData>.from(_guardians);
                filtered = query.isEmpty
                    ? base
                    : base.where((g) =>
                g.username.toLowerCase().contains(query) ||
                    g.emergencyContact.toLowerCase().contains(query) ||
                    g.relation.toLowerCase().contains(query) ||
                    g.guardianId.toString().contains(query)).toList();
              });
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              // Takes up to 75% of screen height
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // ── Handle ──────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // ── Header row ───────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: accentGreen.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.group_rounded, color: accentGreen, size: 18.sp),
                        ),
                        12.width,
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded,
                                size: 16.sp, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Search field ─────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: TextFormField(
                      controller: searchCtrl,
                      autofocus: true,
                      onChanged: onSearch,
                      style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Search by name, relation, contact…',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade400,
                        ),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: accentGreen, size: 18.sp),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? GestureDetector(
                          onTap: () {
                            searchCtrl.clear();
                            onSearch('');
                          },
                          child: Icon(Icons.cancel_rounded,
                              color: Colors.grey.shade400, size: 18.sp),
                        )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: accentGreen, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  10.height,

                  // ── Result count chip ────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: accentGreen.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '${filtered.length} guardian${filtered.length == 1 ? '' : 's'}',
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: accentGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  8.height,

                  // ── Guardian list ────────────────────────────────────
                  Flexible(
                    child: filtered.isEmpty
                        ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 40.sp, color: Colors.grey.shade300),
                          10.height,
                          Text(
                            'No guardians match\n"${searchCtrl.text}"',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 4.h),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => 8.height,
                      itemBuilder: (_, i) {
                        final g = filtered[i];
                        final isSelected =
                            current?.guardianId == g.guardianId;
                        return GestureDetector(
                          onTap: () => Navigator.pop(ctx, g),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accentGreen.withOpacity(0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: isSelected
                                    ? accentGreen
                                    : Colors.grey.shade200,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 42.r,
                                  height: 42.r,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? accentGreen.withOpacity(0.15)
                                        : Colors.blue.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      g.username.isNotEmpty
                                          ? g.username[0].toUpperCase()
                                          : '?',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? accentGreen
                                            : Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                                12.width,

                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        g.username,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        ),
                                      ),
                                      4.height,
                                      Row(
                                        children: [
                                          _guardianChip(
                                            Icons.family_restroom_rounded,
                                            g.relation,
                                            Colors.blue,
                                          ),
                                          8.width,
                                          _guardianChip(
                                            Icons.phone_rounded,
                                            g.emergencyContact,
                                            Colors.green,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Check / ID badge
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.end,
                                  children: [
                                    if (isSelected)
                                      Icon(Icons.check_circle_rounded,
                                          color: accentGreen, size: 20.sp)
                                    else
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 3.h),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                          BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          '#${g.guardianId}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10.sp,
                                            color: textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(ctx).viewInsets.bottom + 16.h),
                ],
              ),
            );
          },
        );
      },
    );
    return picked;
  }

  /// Small inline chip used inside guardian list tiles
  Widget _guardianChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10.sp, color: color.withOpacity(0.7)),
        3.width,
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9.5.sp,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  // ── Guardian selector tile (what is rendered in the form) ─────────────────
  Widget _guardianSelectorTile({
    required String label,
    required GuardianData? selected,
    required VoidCallback onTap,
    VoidCallback? onClear,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (optional)
              Padding(
                padding: EdgeInsets.only(left: 6.w),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'optional',
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      color: textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        6.height,
        GestureDetector(
          onTap: _loadingGuardians ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: selected != null
                    ? accentGreen.withOpacity(0.6)
                    : Colors.grey.shade300,
                width: selected != null ? 1.5 : 1.0,
              ),
            ),
            child: _loadingGuardians
                ? Row(
              children: [
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accentGreen,
                  ),
                ),
                10.width,
                Text(
                  'Loading guardians…',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: textSecondary,
                  ),
                ),
              ],
            )
                : selected == null
                ? Row(
              children: [
                Icon(Icons.group_add_rounded,
                    color: textSecondary, size: 18.sp),
                10.width,
                Expanded(
                  child: Text(
                    _guardians.isEmpty
                        ? 'No guardians available'
                        : 'Tap to search & select',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: textSecondary.withOpacity(0.5),
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: textSecondary, size: 20.sp),
              ],
            )
                : Row(
              children: [
                // Mini avatar
                Container(
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      selected.username.isNotEmpty
                          ? selected.username[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: accentGreen,
                      ),
                    ),
                  ),
                ),
                10.width,
                // Name + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected.username,
                        style: GoogleFonts.montserrat(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      3.height,
                      Row(
                        children: [
                          _guardianChip(Icons.family_restroom_rounded,
                              selected.relation, Colors.blue),
                          10.width,
                          _guardianChip(Icons.phone_rounded,
                              selected.emergencyContact, Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
                // Clear + change buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onClear != null)
                      GestureDetector(
                        onTap: onClear,
                        child: Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded,
                              color: Colors.red.shade400, size: 14.sp),
                        ),
                      ),
                    6.width,
                    Container(
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit_rounded,
                          color: accentGreen, size: 14.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
      AppUI.success(context, 'Please select a guardian');
      return;
    }
    if (_selectedGender == null) {
      AppUI.success(context, 'Please select gender');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final List<int> guardianIds = [_selectedGuardian!.guardianId];
      if (_selectedGuardian2 != null) {
        guardianIds.add(_selectedGuardian2!.guardianId);
      }

      final double membershipAmount =
          double.tryParse(_membershipAmountCtrl.text.trim()) ?? 0;
      Map<String, dynamic> data = {
        "username": _nameCtrl.text.trim(),
        "mobile": _phoneCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
        "password": _passwordCtrl.text.trim(),
        "emergencyContact": _guardianPhoneCtrl.text.trim(),
        "dob": _dobCtrl.text.trim().isNotEmpty
            ? DateFormat('yyyy-MM-dd')
            .format(DateFormat('dd/MM/yyyy').parse(_dobCtrl.text.trim()))
            : "",
        "gender": _selectedGender ?? "",
        "medicalNotes": _medicalNotesCtrl.text.trim(),
        "guardianIds": guardianIds,
        "membershipAmount": membershipAmount,
      };

      final String? errorMsg = await ClubApiService().AddMember(data);
      if (errorMsg == null) {
        if (mounted) Navigator.pop(context);
        AppUI.success(context, 'Member added successfully!');
      } else {
        AppUI.error(context, errorMsg);
      }
    } catch (e) {
      AppUI.error(context, "$e, Please try again.");
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

  // ── Step 1: Personal Info ──────────────────────────────────────────────────
  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Personal Information'),
        12.height,
        _formField('Full Name *', _nameCtrl, Icons.person_rounded,
            hint: 'e.g., Abinesh Kumar'),
        12.height,
        _dateField('Date of Birth *', _dobCtrl, Icons.calendar_today_rounded),
        12.height,
        _dropdownField('Gender *', 'Select Gender', _genders, _selectedGender,
                (v) => setState(() => _selectedGender = v)),
        12.height,
        _formField('Phone / WhatsApp *', _phoneCtrl, Icons.phone_rounded,
            hint: '987453210', keyboardType: TextInputType.phone),
        12.height,
        _formField('Email *', _emailCtrl, Icons.email_rounded,
            hint: 'member@email.com', required: true),
        12.height,
        _formField('Password *', _passwordCtrl, Icons.lock_outline_rounded,
            hint: 'Create a password',
            obscureText: !_isPasswordVisible,
            customValidator: (v) => AppValidator.validatePassword(v)),
        12.height,
        _formField('Medical Notes', _medicalNotesCtrl,
            Icons.medical_information_rounded,
            hint: 'e.g., No known allergies', required: true),
        12.height,
        _formField('Emergency Contact', _guardianPhoneCtrl, Icons.phone,
            keyboardType: TextInputType.number,
            hint: '98745623210', required: true),
        12.height,

        // ── Primary Guardian picker ──────────────────────────────────
        _guardianSelectorTile(
          label: 'Choose Guardian *',
          selected: _selectedGuardian,
          onTap: () async {
            final g = await _showGuardianPicker(
              title: 'Choose Primary Guardian',
              current: _selectedGuardian,
              exclude: _selectedGuardian2,
            );
            if (g != null) setState(() => _selectedGuardian = g);
          },
          onClear: _selectedGuardian != null
              ? () => setState(() => _selectedGuardian = null)
              : null,
        ),
        12.height,

        // ── Secondary Guardian picker ────────────────────────────────
        _guardianSelectorTile(
          label: 'Second Guardian',
          optional: true,
          selected: _selectedGuardian2,
          onTap: () async {
            final g = await _showGuardianPicker(
              title: 'Choose Second Guardian',
              current: _selectedGuardian2,
              exclude: _selectedGuardian, // can't pick same as primary
            );
            if (g != null) setState(() => _selectedGuardian2 = g);
          },
          onClear: _selectedGuardian2 != null
              ? () => setState(() => _selectedGuardian2 = null)
              : null,
        ),
        12.height,

        _formField(
          'Membership Amount *',
          _membershipAmountCtrl,
          Icons.currency_rupee_rounded,
          hint: '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
        12.height,
        _formField('Jersey / ID Number (optional)', _jerseyCtrl, Icons.tag_rounded,
            hint: '#10', required: false),
        20.height,
        _heading('Membership & Payment'),
        12.height,
        _dateField('Membership Start Date *', _membershipStartCtrl,
            Icons.calendar_month_rounded),
        12.height,
        _dateField('Membership End Date *', _membershipEndCtrl,
            Icons.event_rounded),
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
        _formField('Guardian Email (optional)', _guardianEmailCtrl,
            Icons.email_rounded,
            hint: 'guardian@email.com', required: false),
        12.height,
        20.height,
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
              Text('Review Summary',
                  style: GoogleFonts.montserrat(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)),
              12.height,
              _summaryRow('Name',
                  _nameCtrl.text.isNotEmpty ? _nameCtrl.text : '—'),
              _summaryRow('Activity', _selectedActivity ?? '—'),
              _summaryRow('Group', _selectedGroup ?? '—'),
              _summaryRow('Sub-group', _selectedSubGroup ?? '—'),
              _summaryRow(
                  'Guardian',
                  _selectedGuardian?.username ??
                      (_guardianNameCtrl.text.isNotEmpty
                          ? _guardianNameCtrl.text
                          : '—')),
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
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11.sp, color: textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
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
          child: Text(msg,
              style: GoogleFonts.poppins(
                  fontSize: 11.sp, color: color.withOpacity(0.85))),
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
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: textSecondary,
                fontWeight: FontWeight.w500)),
        6.height,
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          obscureText: obscureText,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: customValidator ??
                  (v) {
                if (!required) return null;
                if (label.contains("Email"))
                  return AppValidator.validateEmail(v);
                if (label.contains("Phone") ||
                    label.contains("WhatsApp") ||
                    label.contains("Emergency"))
                  return AppValidator.validatePhone(v);
                if (label.contains("Password"))
                  return AppValidator.validatePassword(v);
                if (label.contains("Name") || label.contains("Full Name"))
                  return AppValidator.validateName(v, fieldName: "Full Name");
                return AppValidator.validateRequired(v, fieldName);
              },
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                fontSize: 12.sp, color: textSecondary.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: textSecondary, size: 18.sp),
            suffixIcon: label.contains("Password")
                ? IconButton(
              icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: textSecondary),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
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

  Widget _dateField(
      String label, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: textSecondary,
                fontWeight: FontWeight.w500)),
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
                  colorScheme:
                  const ColorScheme.light(primary: accentGreen),
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
                fontSize: 12.sp, color: textSecondary.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: textSecondary, size: 18.sp),
            suffixIcon: Icon(Icons.calendar_today_rounded,
                color: accentGreen, size: 18.sp),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
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
      String text,
      List<String> items,
      String? value,
      void Function(String?) onChange,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: textSecondary,
                fontWeight: FontWeight.w500)),
        6.height,
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChange,
          hint: Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: textSecondary.withOpacity(0.5))),
          validator: (v) => v == null ? 'Required' : null,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
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
              .map((i) => DropdownMenuItem(
            value: i,
            child: Text(i,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp, color: Colors.black)),
          ))
              .toList(),
        ),
      ],
    );
  }
}