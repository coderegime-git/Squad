import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sports/Pages/Club_admin/payments.dart';
import 'package:sports/model/clubAdmin/dashboard_data.dart';
import 'package:sports/model/clubAdmin/get_event_details.dart';
import 'package:sports/utills/api_service.dart';

import '../../config/colors.dart';
import '../../utills/shared_preference.dart';
import '../splash.dart';
import 'add_coach_screen.dart';
import 'add_guardian.dart';
import 'add_member_screen.dart';
import 'club_admin_schedule.dart';
import 'link_children.dart';

// ── Club Settings Screen (stub) ───────────────────────────────────────────────
class ClubSettingsScreen extends StatefulWidget {
  const ClubSettingsScreen({super.key});

  @override
  State<ClubSettingsScreen> createState() => _ClubSettingsScreenState();
}

class _ClubSettingsScreenState extends State<ClubSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'XYZ Sports Club');
  final _addressCtrl = TextEditingController(text: 'Madurai, Tamil Nadu');
  final _contactCtrl = TextEditingController(text: 'Admin Name');

  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
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
                  padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
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
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      24.height,
                      _field('Registered Club Name *', _nameCtrl,
                          Icons.sports_soccer_rounded),
                      16.height,
                      _field('Address *', _addressCtrl,
                          Icons.location_on_rounded,
                          maxLines: 2),
                      16.height,
                      _field('Contact Person *', _contactCtrl,
                          Icons.person_rounded),
                      32.height,
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : () async {
                            if (!_formKey.currentState!.validate())
                              return;
                            setState(() => _isSaving = true);
                            await Future.delayed(
                                const Duration(milliseconds: 800));
                            setState(() => _isSaving = false);
                            if (mounted) {
                              toast('Club settings saved!',
                                  bgColor: accentGreen);
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: _isSaving
                              ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                              : Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700),
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

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {int maxLines = 1}) {
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
          validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Required' : null,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: textSecondary, size: 18.sp),
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
}