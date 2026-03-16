// lib/pages/guardian/guardian_payments.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../config/colors.dart';

class GuardianPaymentsScreen extends StatefulWidget {
  const GuardianPaymentsScreen({super.key});

  @override
  State<GuardianPaymentsScreen> createState() => _GuardianPaymentsScreenState();
}

class _GuardianPaymentsScreenState extends State<GuardianPaymentsScreen> {
  String? _selectedChildId;
  late Future<List<Child>> _childrenFuture;
  late Future<List<ClubMembershipStatus>> _allMembershipsFuture;
  late Future<List<PaymentTransaction>> _paymentHistoryFuture;
  late Future<ClubPaymentDetails> _clubPaymentDetailsFuture;

  @override
  void initState() {
    super.initState();
    _childrenFuture = _fetchChildren();
    _allMembershipsFuture = _fetchAllClubMemberships();
    _paymentHistoryFuture = _fetchPaymentHistory();
    _clubPaymentDetailsFuture = _fetchClubPaymentDetails();
  }

  Future<List<Child>> _fetchChildren() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      Child(
        id: '1',
        name: 'Abinesh',
        group: 'Under-14 A',
        activity: 'Football',
        club: 'XYZ FC',
      ),
      Child(
        id: '2',
        name: 'Gopal',
        group: 'Under-10 B',
        activity: 'Swimming',
        club: 'ABC Sports',
      ),
    ];
  }

  Future<List<ClubMembershipStatus>> _fetchAllClubMemberships() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // TODO: Replace with actual API call based on selected child
    // GET /api/guardian/child/{childId}/all-memberships

    return [
      ClubMembershipStatus(
        clubId: 'club1',
        clubName: 'XYZ Football Club',
        activity: 'Football',
        group: 'Under-14 A',
        isPaid: true,
        membershipValidFrom: DateTime(2025, 12, 15),
        membershipValidUntil: DateTime(2026, 2, 15),
        amountDue: 0,
        totalAmount: 2500,
        daysRemaining: 5,
        status: PaymentStatusEnum.active,
      ),
      ClubMembershipStatus(
        clubId: 'club2',
        clubName: 'ABC Swimming Academy',
        activity: 'Swimming',
        group: 'Intermediate B',
        isPaid: false,
        membershipValidFrom: DateTime(2025, 11, 1),
        membershipValidUntil: DateTime(2026, 2, 28),
        amountDue: 3000,
        totalAmount: 3000,
        daysRemaining: 18,
        status: PaymentStatusEnum.due,
      ),
      ClubMembershipStatus(
        clubId: 'club3',
        clubName: 'Elite Cricket Academy',
        activity: 'Cricket',
        group: 'Under-16',
        isPaid: true,
        membershipValidFrom: DateTime(2025, 10, 1),
        membershipValidUntil: DateTime(2026, 3, 31),
        amountDue: 0,
        totalAmount: 4000,
        daysRemaining: 49,
        status: PaymentStatusEnum.active,
      ),
    ];
  }

  Future<List<PaymentTransaction>> _fetchPaymentHistory() async {
    await Future.delayed(const Duration(milliseconds: 900));
    return [
      PaymentTransaction(
        id: 'TXN001',
        date: DateTime(2025, 12, 14),
        amount: 2500,
        receiptNumber: 'RCP-2025-1214-001',
        paymentMethod: 'UPI',
        status: 'Completed',
      ),
      PaymentTransaction(
        id: 'TXN002',
        date: DateTime(2025, 9, 10),
        amount: 2500,
        receiptNumber: 'RCP-2025-0910-002',
        paymentMethod: 'Bank Transfer',
        status: 'Completed',
      ),
      PaymentTransaction(
        id: 'TXN003',
        date: DateTime(2025, 6, 5),
        amount: 2500,
        receiptNumber: 'RCP-2025-0605-003',
        paymentMethod: 'Cash',
        status: 'Completed',
      ),
    ];
  }

  Future<ClubPaymentDetails> _fetchClubPaymentDetails() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return ClubPaymentDetails(
      clubName: 'XYZ Football Club',
      accountHolderName: 'XYZ Football Club',
      accountNumber: '1234567890',
      ifscCode: 'SBIN0001234',
      bankName: 'State Bank of India',
      branchName: 'Coimbatore Main Branch',
      upiId: 'xyzfc@oksbi',
      qrCodeData: 'upi://pay?pa=xyzfc@oksbi&pn=XYZ Football Club&cu=INR',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Header
          Container(
            height: 85.h,                      // slightly taller → better proportions
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 5.h,
                  left: 20.w,
                  right: 20.w,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Payments",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //const Spacer(),

                    // GestureDetector(
                    //   onTap: () {
                    //     //Navigator.pushNamed(context, AppRoutes.guardianNotifications);
                    //   },
                    //   child: Stack(
                    //     children: [
                    //       Icon(
                    //         Icons.notifications_none_rounded,
                    //         color: Colors.white,
                    //         size: 26.sp,
                    //       ),
                    //       Positioned(
                    //         right: 0,
                    //         top: 0,
                    //         child: Container(
                    //           width: 10.r,
                    //           height: 10.r,
                    //           decoration: BoxDecoration(
                    //             color: accentOrange,
                    //             shape: BoxShape.circle,
                    //             border: Border.all(
                    //               color: Colors.black,
                    //               width: 1.5,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _allMembershipsFuture = _fetchAllClubMemberships();
                  _paymentHistoryFuture = _fetchPaymentHistory();
                  _clubPaymentDetailsFuture = _fetchClubPaymentDetails();
                });
              },
              color: accentGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    24.height,

                    // Child Selector
                    FutureBuilder<List<Child>>(
                      future: _childrenFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 60.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                          );
                        }

                        final children = snapshot.data!;
                        _selectedChildId ??= children.first.id;

                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: cardDark,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: accentGreen.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person_rounded, color: accentGreen, size: 24.sp),
                              12.width,
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _selectedChildId,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items: children.map((child) {
                                    return DropdownMenuItem(
                                      value: child.id,
                                      child: Text('${child.name} - ${child.activity}'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedChildId = value;
                                      _allMembershipsFuture = _fetchAllClubMemberships();
                                      _paymentHistoryFuture = _fetchPaymentHistory();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    24.height,

                    // Payment Status Card - ALL CLUBS
                    Text(
                      'Membership Status',
                      style: GoogleFonts.montserrat(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    16.height,

                    FutureBuilder<List<ClubMembershipStatus>>(
                      future: _allMembershipsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Column(
                            children: List.generate(
                              2,
                                  (_) => Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 160.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24.r),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final memberships = snapshot.data ?? [];

                        if (memberships.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.h),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.card_membership_rounded,
                                    size: 60.sp,
                                    color: Colors.grey[400],
                                  ),
                                  16.height,
                                  Text(
                                    'No active memberships',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15.sp,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: memberships.map((membership) {
                            final progressValue = membership.daysRemaining / 60;
                            final statusColor = membership.status == PaymentStatusEnum.active
                                ? accentGreen
                                : membership.status == PaymentStatusEnum.due
                                ? accentOrange
                                : Colors.red;

                            return Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 16.h),
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Club Name Header
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        child: Icon(
                                          Icons.sports_soccer_rounded,
                                          color: statusColor,
                                          size: 20.sp,
                                        ),
                                      ),
                                      12.width,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              membership.clubName,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                            2.height,
                                            Text(
                                              '${membership.activity} • ${membership.group}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.sp,
                                                color: textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  16.height,
                                  Divider(color: Colors.grey.shade300, height: 1),
                                  16.height,
                                  // Status Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            membership.status == PaymentStatusEnum.active
                                                ? 'Active'
                                                : membership.status == PaymentStatusEnum.due
                                                ? 'Payment Due'
                                                : 'Overdue',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: statusColor,
                                            ),
                                          ),
                                          4.height,
                                          Text(
                                            'Valid until ${DateFormat('MMM dd, yyyy').format(membership.membershipValidUntil)}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11.sp,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20.r),
                                        ),
                                        child: Text(
                                          membership.amountDue > 0 ? '₹${membership.amountDue}' : 'No Dues',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  16.height,
                                  // Progress bar
                                  LinearProgressIndicator(
                                    value: progressValue.clamp(0.0, 1.0),
                                    backgroundColor: Colors.grey.shade300,
                                    color: statusColor,
                                    minHeight: 6.h,
                                    borderRadius: BorderRadius.circular(3.r),
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${membership.daysRemaining} days left',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.sp,
                                          color: textSecondary,
                                        ),
                                      ),
                                      Text(
                                        'Total: ₹${membership.totalAmount}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.sp,
                                          color: textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (membership.amountDue > 0) ...[
                                    16.height,
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Navigate to payment for this specific club
                                          toast('Pay ₹${membership.amountDue} for ${membership.clubName}');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: statusColor,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(vertical: 5.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          'Pay Now - ₹${membership.amountDue}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    28.height,

                    // Payment Methods Section
                    Text(
                      'Payment Methods',
                      style: GoogleFonts.montserrat(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    16.height,

                    FutureBuilder<ClubPaymentDetails>(
                      future: _clubPaymentDetailsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Column(
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  height: 280.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                ),
                              ),
                              16.height,
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  height: 200.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        final details = snapshot.data ?? ClubPaymentDetails.empty();

                        return Column(
                          children: [
                            // QR Code Card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(24.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: accentGreen.withOpacity(0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                          color: accentGreen.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Icon(
                                          Icons.qr_code_2_rounded,
                                          color: accentGreen,
                                          size: 24.sp,
                                        ),
                                      ),
                                      12.width,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Scan & Pay',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                            2.height,
                                            Text(
                                              'Use any UPI app to scan',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.sp,
                                                color: textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  20.height,
                                  // QR Code
                                  Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(color: Colors.grey.shade300, width: 2),
                                    ),
                                    child: QrImageView(
                                      data: details.qrCodeData,
                                      version: QrVersions.auto,
                                      size: 200.w,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  16.height,
                                  Text(
                                    details.clubName,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  4.height,
                                  Text(
                                    details.upiId,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      color: accentGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  20.height,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            // TODO: Save QR code
                                            toast('QR code saved to gallery');
                                          },
                                          icon: Icon(Icons.download_rounded, size: 18.sp),
                                          label: Text('Save QR', style: GoogleFonts.poppins(fontSize: 13.sp)),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: accentGreen,
                                            side: BorderSide(color: accentGreen),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.r),
                                            ),
                                            padding: EdgeInsets.symmetric(vertical: 12.h),
                                          ),
                                        ),
                                      ),
                                      12.width,
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            // TODO: Share QR code
                                            toast('Share QR code');
                                          },
                                          icon: Icon(Icons.share_rounded, size: 18.sp),
                                          label: Text('Share', style: GoogleFonts.poppins(fontSize: 13.sp)),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: accentGreen,
                                            side: BorderSide(color: accentGreen),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.r),
                                            ),
                                            padding: EdgeInsets.symmetric(vertical: 12.h),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            16.height,

                            // Bank Details Card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Icon(
                                          Icons.account_balance_rounded,
                                          color: Colors.blue,
                                          size: 18.sp,
                                        ),
                                      ),
                                      12.width,
                                      Text(
                                        'Bank Transfer Details',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  20.height,
                                  _buildBankDetailRow(
                                    'Account Holder',
                                    details.accountHolderName,
                                    showCopy: true,
                                  ),
                                  _buildBankDetailRow(
                                    'Account Number',
                                    details.accountNumber,
                                    showCopy: true,
                                  ),
                                  _buildBankDetailRow(
                                    'IFSC Code',
                                    details.ifscCode,
                                    showCopy: true,
                                  ),
                                  _buildBankDetailRow(
                                    'Bank Name',
                                    details.bankName,
                                    showCopy: false,
                                  ),
                                  _buildBankDetailRow(
                                    'Branch',
                                    details.branchName,
                                    showCopy: false,
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    28.height,

                    // Payment History
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment History',
                          style: GoogleFonts.montserrat(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            toast('View all transactions');
                          },
                          label: Text(
                            'View All',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: accentGreen,
                          ),
                        ),
                      ],
                    ),
                    12.height,

                    FutureBuilder<List<PaymentTransaction>>(
                      future: _paymentHistoryFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Column(
                            children: List.generate(
                              3,
                                  (_) => Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 80.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final transactions = snapshot.data ?? [];

                        if (transactions.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.h),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    size: 60.sp,
                                    color: Colors.grey[400],
                                  ),
                                  16.height,
                                  Text(
                                    'No payment history',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15.sp,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: transactions.map((txn) {
                            return _PaymentHistoryCard(transaction: txn);
                          }).toList(),
                        );
                      },
                    ),

                    100.height,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String value, {required bool showCopy, bool isLast = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: textSecondary,
                  ),
                ),
                4.height,
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            if (showCopy)
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  toast('Copied to clipboard', bgColor: accentGreen);
                },
                icon: Icon(Icons.copy_rounded, size: 20.sp, color: Colors.blue),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        if (!isLast) ...[
          12.height,
          Divider(color: Colors.grey.shade300, height: 1),
          12.height,
        ],
      ],
    );
  }
}

// Payment History Card Widget
class _PaymentHistoryCard extends StatelessWidget {
  final PaymentTransaction transaction;

  const _PaymentHistoryCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accentGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: accentGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: accentGreen,
                      size: 24.sp,
                    ),
                  ),
                  12.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Successful',
                        style: GoogleFonts.montserrat(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      4.height,
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.date),
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '₹${transaction.amount}',
                style: GoogleFonts.montserrat(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),
          12.height,
          Divider(color: Colors.grey.shade300, height: 1),
          12.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receipt No.',
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary),
                  ),
                  2.height,
                  Text(
                    transaction.receiptNumber,
                    style: GoogleFonts.montserrat(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Payment Method',
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary),
                  ),
                  2.height,
                  Text(
                    transaction.paymentMethod,
                    style: GoogleFonts.montserrat(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Models
class Child {
  final String id;
  final String name;
  final String group;
  final String activity;
  final String club;

  Child({
    required this.id,
    required this.name,
    required this.group,
    required this.activity,
    required this.club,
  });
}

enum PaymentStatusEnum { active, due, overdue }

class ClubMembershipStatus {
  final String clubId;
  final String clubName;
  final String activity;
  final String group;
  final bool isPaid;
  final DateTime membershipValidFrom;
  final DateTime membershipValidUntil;
  final int amountDue;
  final int totalAmount;
  final int daysRemaining;
  final PaymentStatusEnum status;

  ClubMembershipStatus({
    required this.clubId,
    required this.clubName,
    required this.activity,
    required this.group,
    required this.isPaid,
    required this.membershipValidFrom,
    required this.membershipValidUntil,
    required this.amountDue,
    required this.totalAmount,
    required this.daysRemaining,
    required this.status,
  });
}

class PaymentTransaction {
  final String id;
  final DateTime date;
  final int amount;
  final String receiptNumber;
  final String paymentMethod;
  final String status;

  PaymentTransaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.receiptNumber,
    required this.paymentMethod,
    required this.status,
  });
}

class ClubPaymentDetails {
  final String clubName;
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String branchName;
  final String upiId;
  final String qrCodeData;

  ClubPaymentDetails({
    required this.clubName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.branchName,
    required this.upiId,
    required this.qrCodeData,
  });

  factory ClubPaymentDetails.empty() => ClubPaymentDetails(
    clubName: '',
    accountHolderName: '',
    accountNumber: '',
    ifscCode: '',
    bankName: '',
    branchName: '',
    upiId: '',
    qrCodeData: '',
  );
}