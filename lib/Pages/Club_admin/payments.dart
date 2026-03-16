// screens/clubadmin/clubadmin_payments.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';

import '../../config/colors.dart';

class ClubAdminPaymentsScreen extends StatefulWidget {
  const ClubAdminPaymentsScreen({super.key});

  @override
  State<ClubAdminPaymentsScreen> createState() => _ClubAdminPaymentsScreenState();
}

class _ClubAdminPaymentsScreenState extends State<ClubAdminPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                        child: Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 20.sp),
                      ),
                      16.width,
                      Text(
                        'Payment Management',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
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

            // Tab Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: accentGreen,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                labelPadding: EdgeInsets.zero,
                indicatorPadding: EdgeInsets.zero,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade500,
                labelStyle: GoogleFonts.poppins(
                    fontSize: 13.sp, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'Overdue'),
                  Tab(text: 'Paid'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPaymentList(PaymentStatus.pending),
                  _buildPaymentList(PaymentStatus.overdue),
                  _buildPaymentList(PaymentStatus.paid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList(PaymentStatus status) {
    final members = _getDummyMembers(status);
    final color = _getStatusColor(status);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 800));
      },
      color: accentGreen,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_rounded, color: color, size: 22.sp),
                ),
                14.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member['name'],
                        style: GoogleFonts.montserrat(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      4.height,
                      Text(
                        member['group'],
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: textSecondary,
                        ),
                      ),
                      4.height,
                      Row(
                        children: [
                          Icon(Icons.currency_rupee_rounded,
                              size: 12.sp, color: color),
                          Text(
                            '${member['amount']}',
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          8.width,
                          Text(
                            '• ${member['dueDate']}',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (status != PaymentStatus.paid)
                  ElevatedButton(
                    onPressed: () => _showRecordPaymentDialog(member['name'], color),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Record',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRecordPaymentDialog(String memberName, Color color) {
    final amountCtrl = TextEditingController();
    DateTime? validUntil;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Record Payment',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Member: $memberName',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: textSecondary,
                ),
              ),
              16.height,
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount Received *',
                  prefixText: '₹ ',
                  prefixIcon: Icon(Icons.currency_rupee_rounded, color: color),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                ),
              ),
              16.height,
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 60)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(primary: color),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setDialogState(() => validUntil = date);
                  }
                },
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          color: textSecondary, size: 18.sp),
                      12.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Valid Until',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: textSecondary,
                              ),
                            ),
                            2.height,
                            Text(
                              validUntil != null
                                  ? DateFormat('MMM dd, yyyy')
                                  .format(validUntil!)
                                  : 'Select date',
                              style: GoogleFonts.montserrat(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: validUntil != null
                                    ? Colors.black
                                    : textSecondary,
                              ),
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
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (amountCtrl.text.isEmpty || validUntil == null) {
                  toast('Please fill all fields');
                  return;
                }
                Navigator.pop(ctx);
                toast('✅ Payment recorded for $memberName', bgColor: color);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getDummyMembers(PaymentStatus status) {
    if (status == PaymentStatus.pending) {
      return [
        {
          'name': 'Abinesh Kumar',
          'group': 'Under-14 A • Football',
          'amount': 2500,
          'dueDate': 'Due: Feb 15'
        },
        {
          'name': 'Gopal Singh',
          'group': 'Under-10 B • Swimming',
          'amount': 3000,
          'dueDate': 'Due: Feb 20'
        },
        {
          'name': 'Priya Sharma',
          'group': 'Under-12 A • Cricket',
          'amount': 2500,
          'dueDate': 'Due: Feb 18'
        },
      ];
    } else if (status == PaymentStatus.overdue) {
      return [
        {
          'name': 'Ravi Kumar',
          'group': 'Under-16 • Football',
          'amount': 2500,
          'dueDate': 'Overdue: Jan 10'
        },
        {
          'name': 'Aarav Patel',
          'group': 'Intermediate • Swimming',
          'amount': 3000,
          'dueDate': 'Overdue: Jan 5'
        },
      ];
    } else {
      return [
        {
          'name': 'Saanvi Reddy',
          'group': 'Under-8 • Cricket',
          'amount': 2500,
          'dueDate': 'Paid: Feb 1'
        },
        {
          'name': 'Karthik Raja',
          'group': 'Advanced • Football',
          'amount': 3500,
          'dueDate': 'Paid: Jan 28'
        },
      ];
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return accentOrange;
      case PaymentStatus.overdue:
        return Colors.red;
      case PaymentStatus.paid:
        return accentGreen;
    }
  }
}

enum PaymentStatus { pending, overdue, paid }