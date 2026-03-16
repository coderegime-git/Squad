// screens/clubadmin/payment_qr_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../config/colors.dart';

class ClubAdminPaymentQRSetupScreen extends StatefulWidget {
  const ClubAdminPaymentQRSetupScreen({super.key});

  @override
  State<ClubAdminPaymentQRSetupScreen> createState() => _ClubAdminPaymentQRSetupScreenState();
}

class _ClubAdminPaymentQRSetupScreenState extends State<ClubAdminPaymentQRSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _upiIdCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();

  String _generatedQRData = "";
  bool _showQR = false;

  @override
  void dispose() {
    _upiIdCtrl.dispose();
    _accountNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _ifscCtrl.dispose();
    _bankNameCtrl.dispose();
    _branchCtrl.dispose();
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
            // Header
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
                        child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20.sp),
                      ),
                      16.width,
                      Text(
                        'Payment QR Setup',
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Box
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: accentGreen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: accentGreen.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_rounded, color: accentGreen, size: 20.sp),
                            12.width,
                            Expanded(
                              child: Text(
                                'Parents will use this QR code to pay membership fees',
                                style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),

                      24.height,

                      // UPI Details Section
                      _sectionHeader('UPI Details', Icons.account_balance_wallet_rounded, accentGreen),
                      14.height,
                      _formField(_upiIdCtrl, 'UPI ID *', 'e.g., xyzclub@upi', Icons.payment_rounded),
                      12.height,
                      _formField(_accountNameCtrl, 'Account Holder Name *', 'XYZ Sports Club', Icons.person_rounded),

                      24.height,

                      // Bank Details Section
                      _sectionHeader('Bank Account Details', Icons.account_balance_rounded, Colors.blue),
                      14.height,
                      _formField(_accountNumberCtrl, 'Account Number *', 'Enter account number', Icons.credit_card_rounded, keyboardType: TextInputType.number),
                      12.height,
                      _formField(_ifscCtrl, 'IFSC Code *', 'e.g., SBIN0001234', Icons.code_rounded),
                      12.height,
                      _formField(_bankNameCtrl, 'Bank Name *', 'e.g., State Bank of India', Icons.business_rounded),
                      12.height,
                      _formField(_branchCtrl, 'Branch Name *', 'e.g., Madurai Main Branch', Icons.location_city_rounded),

                      32.height,

                      // Generate Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _generateQR,
                          icon: Icon(Icons.qr_code_2_rounded, size: 22.sp),
                          label: Text(
                            'Generate QR Code',
                            style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                        ),
                      ),

                      // QR Display
                      if (_showQR) ...[
                        32.height,
                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(color: accentGreen, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: accentGreen.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: accentGreen.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check_circle_rounded, color: accentGreen, size: 40.sp),
                              ),
                              16.height,
                              Text(
                                'QR Code Generated!',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: accentGreen,
                                ),
                              ),
                              8.height,
                              Text(
                                'Parents can scan this to pay fees',
                                style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary),
                              ),
                              24.height,
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: Colors.grey.shade300, width: 2),
                                ),
                                child: QrImageView(
                                  data: _generatedQRData,
                                  version: QrVersions.auto,
                                  size: 220.w,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              20.height,
                              Text(
                                _accountNameCtrl.text,
                                style: GoogleFonts.montserrat(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              4.height,
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: accentGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  _upiIdCtrl.text,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    color: accentGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              24.height,
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => toast('QR code downloaded'),
                                      icon: Icon(Icons.download_rounded, size: 18.sp),
                                      label: Text('Download', style: GoogleFonts.poppins(fontSize: 13.sp)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: accentGreen,
                                        side: BorderSide(color: accentGreen),
                                        padding: EdgeInsets.symmetric(vertical: 12.h),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                      ),
                                    ),
                                  ),
                                  12.width,
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        toast('✅ QR Code activated!', bgColor: accentGreen);
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(Icons.check_circle_rounded, size: 18.sp),
                                      label: Text('Activate', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentGreen,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(vertical: 12.h),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

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

  void _generateQR() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _generatedQRData = 'upi://pay?pa=${_upiIdCtrl.text}&pn=${_accountNameCtrl.text}&cu=INR';
        _showQR = true;
      });
      toast('QR Code generated successfully!', bgColor: accentGreen);
    }
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: color, size: 18.sp),
        ),
        12.width,
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _formField(
      TextEditingController ctrl,
      String label,
      String hint,
      IconData icon, {
        TextInputType? keyboardType,
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
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary.withOpacity(0.5)),
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
}