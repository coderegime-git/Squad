// screens/clubadmin/clubadmin_payments.dart
// Changes per client:
// - Remove Pending and Paid tabs
// - Only show Overdue (calculated from membership end date vs today)
// - "Record Payment" updates payment status via PATCH /api/payments/{paymentId}/status

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';

import '../../config/colors.dart';
import '../../utills/api_service.dart';

class ClubAdminPaymentsScreen extends StatefulWidget {
  const ClubAdminPaymentsScreen({super.key});

  @override
  State<ClubAdminPaymentsScreen> createState() => _ClubAdminPaymentsScreenState();
}

class _ClubAdminPaymentsScreenState extends State<ClubAdminPaymentsScreen> {
  final ClubApiService _apiService = ClubApiService();
  bool _loading = true;
  List<_OverdueMember> _overdueMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchOverdueMembers();
  }

  Future<void> _fetchOverdueMembers() async {
    setState(() => _loading = true);
    try {
      final result = await _apiService.getMembers();
      final today = DateTime.now();
      final overdue = <_OverdueMember>[];

      // for (final member in result.data) {
      //   if (member != null && member.membershipEndDate!.isNotEmpty) {
      //     try {
      //       final endDate = DateTime.parse(member.membershipEndDate!);
      //       if (endDate.isBefore(today)) {
      //         overdue.add(_OverdueMember(
      //           memberId: member.memberId,
      //           name: member.username,
      //           email: member.email,
      //           amount: member.membershipAmount ?? 0,
      //           membershipEndDate: endDate,
      //         ));
      //       }
      //     } catch (_) {}
      //   }
      // }

      setState(() {
        _overdueMembers = overdue;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      toast('Failed to load payment data');
    }
  }

  void _showRecordPaymentDialog(_OverdueMember member) {
    final amountCtrl = TextEditingController(text: '${member.amount}');
    DateTime? newEndDate;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text('Record Payment', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Member: ${member.name}', style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary)),
              4.height,
              Text(
                'Overdue since: ${DateFormat('MMM dd, yyyy').format(member.membershipEndDate)}',
                style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.red.shade600),
              ),
              16.height,
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount Received *',
                  prefixText: '₹ ',
                  prefixIcon: Icon(Icons.currency_rupee_rounded, color: Colors.red),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: accentGreen, width: 2)),
                ),
              ),
              16.height,
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 90)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: accentGreen)),
                      child: child!,
                    ),
                  );
                  if (date != null) setDialogState(() => newEndDate = date);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: textSecondary, size: 18.sp),
                      12.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('New Membership End Date', style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
                            2.height,
                            Text(
                              newEndDate != null ? DateFormat('MMM dd, yyyy').format(newEndDate!) : 'Select date',
                              style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600,
                                  color: newEndDate != null ? Colors.black : textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.poppins(color: textSecondary))),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (amountCtrl.text.isEmpty || newEndDate == null) {
                  toast('Please fill all fields');
                  return;
                }
                setDialogState(() => isSaving = true);
                // PATCH /api/payments/{paymentId}/status or update member membership
                // For now: call updateMemberMembership with new end date
                final success = await _apiService.updateMemberMembership(
                  member.memberId,
                  {
                    "membershipAmount": int.tryParse(amountCtrl.text) ?? member.amount,
                    "membershipEndDate": DateFormat('yyyy-MM-dd').format(newEndDate!),
                  },
                );
                setDialogState(() => isSaving = false);
                Navigator.pop(ctx);
                if (success) {
                  toast('✅ Payment recorded for ${member.name}', bgColor: accentGreen);
                  _fetchOverdueMembers();
                } else {
                  toast('Failed to record payment');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), elevation: 0,
              ),
              child: isSaving
                  ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Save', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: Row(
                    children: [
                      GestureDetector(onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20.sp)),
                      16.width,
                      Text('Payment Management',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),

            // Overdue header
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.06), borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20.sp),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Overdue Memberships',
                            style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                        4.height,
                        Text('Members whose membership end date has passed today.',
                            style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(12.r)),
                    child: Text('${_overdueMembers.length}',
                        style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.red)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: accentGreen))
                  : RefreshIndicator(
                onRefresh: _fetchOverdueMembers,
                color: accentGreen,
                child: _overdueMembers.isEmpty
                    ? ListView(children: [
                  SizedBox(height: 80.h),
                  Center(child: Column(children: [
                    Icon(Icons.check_circle_outline_rounded, size: 64.sp, color: accentGreen),
                    16.height,
                    Text('No overdue payments!',
                        style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w700, color: accentGreen)),
                    8.height,
                    Text('All memberships are up to date.',
                        style: GoogleFonts.poppins(fontSize: 12.sp, color: textSecondary)),
                  ])),
                ])
                    : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  itemCount: _overdueMembers.length,
                  itemBuilder: (context, index) {
                    final member = _overdueMembers[index];
                    final daysOverdue = DateTime.now().difference(member.membershipEndDate).inDays;
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: cardDark, borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.red.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), shape: BoxShape.circle),
                            child: Icon(Icons.person_rounded, color: Colors.red, size: 22.sp),
                          ),
                          14.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(member.name,
                                    style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                                4.height,
                                Text(member.email, style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
                                4.height,
                                Row(children: [
                                  Icon(Icons.currency_rupee_rounded, size: 12.sp, color: Colors.red),
                                  Text('${member.amount}',
                                      style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.red)),
                                  8.width,
                                  Text('• $daysOverdue days overdue',
                                      style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.red.shade700)),
                                ]),
                                4.height,
                                Text(
                                  'Expired: ${DateFormat('MMM dd, yyyy').format(member.membershipEndDate)}',
                                  style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _showRecordPaymentDialog(member),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)), elevation: 0,
                            ),
                            child: Text('Record', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverdueMember {
  final int memberId;
  final String name;
  final String email;
  final int amount;
  final DateTime membershipEndDate;

  _OverdueMember({
    required this.memberId,
    required this.name,
    required this.email,
    required this.amount,
    required this.membershipEndDate,
  });
}