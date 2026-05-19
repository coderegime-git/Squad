import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../config/colors.dart';
import '../../model/clubAdmin/club_settings.dart';
import '../../utills/api_service.dart';

class ClubSettingsScreen extends StatefulWidget {
  const ClubSettingsScreen({super.key});

  @override
  State<ClubSettingsScreen> createState() => _ClubSettingsScreenState();
}

class _ClubSettingsScreenState extends State<ClubSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic info
  final _clubNameCtrl = TextEditingController();
  final _registeredNameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // Address
  final _addressLine1Ctrl = TextEditingController();
  final _addressLine2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  // Contact
  final _contactPersonCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  final ClubApiService _api = ClubApiService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    for (final c in [
      _clubNameCtrl,
      _registeredNameCtrl,
      _descriptionCtrl,
      _addressLine1Ctrl,
      _addressLine2Ctrl,
      _cityCtrl,
      _stateCtrl,
      _postalCodeCtrl,
      _countryCtrl,
      _contactPersonCtrl,
      _contactEmailCtrl,
      _contactPhoneCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── API calls ───────────────────────────────────────────────────────────────
  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final ClubSettingsData? data = await _api.getClubSettings();
      if (data != null && mounted) {
        _clubNameCtrl.text = data.clubName ?? '';
        _registeredNameCtrl.text = data.registeredName ?? '';
        _descriptionCtrl.text = data.description ?? '';

        _addressLine1Ctrl.text = data.address?.addressLine1 ?? '';
        _addressLine2Ctrl.text = data.address?.addressLine2 ?? '';
        _cityCtrl.text = data.address?.city ?? '';
        _stateCtrl.text = data.address?.state ?? '';
        _postalCodeCtrl.text = data.address?.postalCode ?? '';
        _countryCtrl.text = data.address?.country ?? '';

        _contactPersonCtrl.text = data.contactPersonName ?? '';
        _contactEmailCtrl.text = data.contactEmail ?? '';

        // Phone handling with +91
        String phone = data.contactPhone ?? '';
        if (phone.startsWith('+91')) {
          phone = phone.substring(3).trim();
        }
        _contactPhoneCtrl.text = phone;
      }
    } catch (_) {
      if (mounted) toast('Failed to load settings', bgColor: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = ClubSettingsData(
      clubName: _clubNameCtrl.text.trim(),
      registeredName: _registeredNameCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      address: ClubAddress(
        addressLine1: _addressLine1Ctrl.text.trim(),
        addressLine2: _addressLine2Ctrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        postalCode: _postalCodeCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
      ),
      contactPersonName: _contactPersonCtrl.text.trim(),
      contactEmail: _contactEmailCtrl.text.trim(),
      // Add +91 when saving
      contactPhone: _contactPhoneCtrl.text.trim().isEmpty
          ? ''
          : '+91${_contactPhoneCtrl.text.trim()}',
    );

    final success = await _api.updateClubSettings(payload);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        toast('Club settings saved!', bgColor: accentGreen);
        Navigator.pop(context);
      } else {
        toast('Failed to save settings', bgColor: Colors.red);
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: accentGreen),
              )
                  : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Club Information
                      _sectionHeader(Icons.sports_soccer_rounded,
                          'Club Information'),
                      16.height,
                      _field(
                        label: 'Club Name *',
                        ctrl: _clubNameCtrl,
                        icon: Icons.sports_soccer_rounded,
                      ),
                      14.height,
                      _field(
                        label: 'Registered Name *',
                        ctrl: _registeredNameCtrl,
                        icon: Icons.business_rounded,
                      ),
                      14.height,
                      _field(
                        label: 'Description',
                        ctrl: _descriptionCtrl,
                        icon: Icons.description_rounded,
                        maxLines: 3,
                        required: false,
                      ),
                      28.height,

                      // Address
                      _sectionHeader(
                          Icons.location_on_rounded, 'Address'),
                      16.height,
                      _field(
                        label: 'Address Line 1 *',
                        ctrl: _addressLine1Ctrl,
                        icon: Icons.location_on_rounded,
                      ),
                      14.height,
                      _field(
                        label: 'Address Line 2',
                        ctrl: _addressLine2Ctrl,
                        icon: Icons.location_on_outlined,
                        required: false,
                      ),
                      14.height,
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              label: 'City *',
                              ctrl: _cityCtrl,
                              icon: Icons.location_city_rounded,
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: _field(
                              label: 'State *',
                              ctrl: _stateCtrl,
                              icon: Icons.map_rounded,
                            ),
                          ),
                        ],
                      ),
                      14.height,
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              label: 'Postal Code *',
                              ctrl: _postalCodeCtrl,
                              icon: Icons.pin_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: _field(
                              label: 'Country *',
                              ctrl: _countryCtrl,
                              icon: Icons.public_rounded,
                            ),
                          ),
                        ],
                      ),
                      28.height,

                      // Contact Details
                      _sectionHeader(Icons.contact_phone_rounded,
                          'Contact Details'),
                      16.height,
                      _field(
                        label: 'Contact Person *',
                        ctrl: _contactPersonCtrl,
                        icon: Icons.person_rounded,
                      ),
                      14.height,
                      _field(
                        label: 'Contact Email *',
                        ctrl: _contactEmailCtrl,
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          if (!v.trim().contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      14.height,

                      // Phone Field with +91 prefix
                      _phoneField(),

                      36.height,

                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            disabledBackgroundColor:
                            accentGreen.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: _isSaving
                              ? SizedBox(
                            height: 22.h,
                            width: 22.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
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

  // ── Reusable widgets ────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              top: 5.h, bottom: 7.h, left: 20.w, right: 20.w),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 20.sp),
              ),
              16.width,
              Text(
                'Club Settings',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.r),
          decoration: BoxDecoration(
            color: accentGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: accentGreen, size: 16.sp),
        ),
        10.width,
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required IconData icon,
    int maxLines = 1,
    bool required = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        5.height,
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator ??
                  (v) => (required && (v == null || v.trim().isEmpty))
                  ? 'Required'
                  : null,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 18.sp),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w, vertical: 13.h),
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
              borderSide: const BorderSide(color: Colors.red, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // Special Phone Field with +91 prefix
  Widget _phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Phone *',
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        5.height,
        TextFormField(
          controller: _contactPhoneCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10), // Limit to 10 digits
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (v.trim().length != 10) return 'Enter valid 10-digit number';
            return null;
          },
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 12),
                Text(
                  '+91',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(height: 20, width: 1, color: Colors.grey.shade400),
              ],
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 70),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w, vertical: 13.h),
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
              borderSide: const BorderSide(color: Colors.red, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}