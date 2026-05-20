// lib/pages/guardian/guardian_payments.dart
// ── All 6 Membership/Payment APIs integrated ──────────────────────────────
//
// API usage map:
// ① GET /api/payments/guardians/{guardianId}/pending-payments
//      → Top summary banner: shows all pending payments across children
// ② GET /api/users/{userId}/memberships
//      → Per-child membership list (club name, role, dates, status)
// ③ GET /api/memberships/{membershipId}/payment        [replaces API 2]
//      → Per-membership payment detail: paymentDate, dueDate, paymentMethod,
//        paymentReference, paymentStatus, guardianUserId
// ④ GET /api/payments/memberships/{membershipId}       [kept as fallback]
//      → Same payload but different route; used if ③ throws
// ⑤ GET /api/clubs/{clubId}/members/{userId}/membership-status
//      → Cross-check actual membership status per club (used for active cards)
// ──────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';

import '../../config/colors.dart';
import '../../utills/api_service.dart';
import '../../utills/shared_preference.dart';

// ─────────────────────────────────────────────────────────────────────────────
// View models
// ─────────────────────────────────────────────────────────────────────────────

enum _PayStatus { loading, active, pending, expired, noMembership, error }

class _ChildRow {
  final int memberId;
  final int userId;
  final String name;
  _ChildRow({required this.memberId, required this.userId, required this.name});
}

class _MembershipRow {
  final int membershipId;
  final int clubId;          // needed for API ⑤
  final String clubName;
  final String role;
  final DateTime? startDate;
  final DateTime? endDate;
  final String rawStatus;    // from API ②: PENDING / ACTIVE / EXPIRED

  // Filled after lazy API ③ fetch
  _PayStatus payStatus;
  num? paymentId;           // Changed
  num amount;
  String? paymentMethod;
  String? paymentReference;
  String? paymentStatusRaw;  // PENDING / PAID / OVERDUE
  DateTime? paymentDate;
  DateTime? dueDate;

  _MembershipRow({
    required this.membershipId,
    required this.clubId,
    required this.clubName,
    required this.role,
    this.startDate,
    this.endDate,
    required this.rawStatus,
    this.payStatus = _PayStatus.loading,
    this.paymentId,
    this.amount = 0,           // default as num
    this.paymentMethod,
    this.paymentReference,
    this.paymentStatusRaw,
    this.paymentDate,
    this.dueDate,
  });
}

class _PendingPayRow {
  final String memberName;
  final int membershipId;
  final num amount;                    // ← Changed
  final String status;
  final String memberEmail;
  final String memberMobile;

  _PendingPayRow({
    required this.memberName,
    required this.membershipId,
    required this.amount,
    required this.status,
    required this.memberEmail,
    required this.memberMobile,
  });

  factory _PendingPayRow.fromMap(Map<String, dynamic> m) => _PendingPayRow(
    memberName:   m['memberName']   ?? '',
    membershipId: m['membershipId'] is int ? m['membershipId'] : (m['membershipId'] as num?)?.toInt() ?? 0,  // keep int if you prefer
    amount:       _toNum(m['amount'] ?? 0),
    status:       m['status']       ?? '',
    memberEmail:  m['memberEmail']  ?? '',
    memberMobile: m['memberMobile'] ?? '',
  );
}

num _toNum(dynamic value, {num defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? defaultValue;
  return defaultValue;
}
class GuardianPaymentsScreen extends StatefulWidget {
  const GuardianPaymentsScreen({super.key});

  @override
  State<GuardianPaymentsScreen> createState() => _GuardianPaymentsScreenState();
}

class _GuardianPaymentsScreenState extends State<GuardianPaymentsScreen> {
  final _parentApi = ParentApiService();
  final _clubApi   = ClubApiService();

  // Phase 1 – children
  bool _loadingChildren = true;
  String? _childrenError;
  List<_ChildRow> _children = [];
  _ChildRow? _selectedChild;

  // API ① – pending payments banner (guardian-level)
  bool _loadingPending = false;
  List<_PendingPayRow> _pendingPayments = [];

  // Phase 2 – memberships per child  (API ②)
  bool _loadingMemberships = false;
  List<_MembershipRow> _memberships = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  // ─── Bootstrap: children + pending payments banner ────────────────────────
  Future<void> _bootstrap() async {
    setState(() {
      _loadingChildren = true;
      _childrenError   = null;
    });

    try {
      // Load children
      final result = await _parentApi.getYourMembers();
      final rows   = (result.data ?? [])
          .map((m) => _ChildRow(
        memberId: m.memberId,
        userId:   m.userId,
        name:     m.username,
      ))
          .toList();

      setState(() {
        _children        = rows;
        _loadingChildren = false;
        if (rows.isNotEmpty) {
          _selectedChild = rows.first;
        }
      });

      // API ① — pending payments for this guardian
      _loadPendingPayments();

      // API ② — memberships for first child
      if (rows.isNotEmpty) _loadMemberships(rows.first);
    } catch (e) {
      setState(() {
        _loadingChildren = false;
        _childrenError   = 'Failed to load data. Tap to retry.';
      });
    }
  }

  // ─── API ①: pending payments for guardian ─────────────────────────────────
  Future<void> _loadPendingPayments() async {
    final guardianId = SharedPreferenceHelper.getId();
    if (guardianId == null) return;

    setState(() => _loadingPending = true);
    try {
      final raw = await _clubApi.getGuardianPendingPayments(guardianId);
      setState(() {
        _pendingPayments = raw.map(_PendingPayRow.fromMap).toList();
        _loadingPending  = false;
      });
    } catch (_) {
      setState(() => _loadingPending = false);
    }
  }

  // ─── API ②: memberships per child ─────────────────────────────────────────
  Future<void> _loadMemberships(_ChildRow child) async {
    setState(() {
      _loadingMemberships = true;
      _memberships        = [];
    });
    try {
      final raw = await _clubApi.getUserMemberships(child.userId);

      final today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);

      final rows = raw.map((m) {
        final start  = _parseDate(m['membershipStartDate']?.toString());
        final end    = _parseDate(m['membershipEndDate']?.toString());
        final status = (m['status'] ?? '').toString().toUpperCase();

        _PayStatus display;
        if (status == 'PENDING') {
          display = _PayStatus.pending;
        } else if (end != null && end.isBefore(today)) {
          display = _PayStatus.expired;
        } else {
          display = _PayStatus.active;
        }

        return _MembershipRow(
          membershipId: m['membershipId'] ?? 0,
          clubId:       m['clubId']       ?? 0,
          clubName:     m['clubName']     ?? 'Unknown Club',
          role:         m['role']         ?? '',
          startDate:    start,
          endDate:      end,
          rawStatus:    status,
          payStatus:    display,
        );
      }).toList();

      setState(() {
        _memberships        = rows;
        _loadingMemberships = false;
      });

      // Lazy-load payment details (API ③ with API ④ fallback) per membership
      for (final row in rows) {
        _fetchPaymentDetails(row);
      }
    } catch (e) {
      setState(() => _loadingMemberships = false);
      toast('Failed to load memberships');
    }
  }

  Future<void> _fetchPaymentDetails(_MembershipRow row) async {
    try {
      Map<String, dynamic>? payData;

      // API ③: GET /api/memberships/{membershipId}/payment
      try {
        payData = await _clubApi.getMembershipPayment(row.membershipId);
      } catch (_) {
        // fallback to API ④
        payData = await _clubApi.getPaymentByMembershipId(row.membershipId);
      }

      // API ⑤: GET /api/clubs/{clubId}/members/{userId}/membership-status
      // Use this to cross-check/override the membership status
      Map<String, dynamic>? statusData;
      if (row.clubId > 0 && _selectedChild != null) {
        try {
          statusData = await _clubApi.getMembershipStatus(
            row.clubId,
            _selectedChild!.userId,
          );
        } catch (_) {}
      }

      if (!mounted) return;

      setState(() {
        if (payData != null) {
          row.paymentId        = _toNum(payData['paymentId']);
          row.amount           = _toNum(payData['amount']);
          row.paymentMethod    = payData['paymentMethod'];
          row.paymentReference = payData['paymentReference'];
          row.paymentStatusRaw = (payData['paymentStatus'] ?? '').toString().toUpperCase();
          row.paymentDate      = _parseDateTime(payData['paymentDate']?.toString());
          row.dueDate          = _parseDate(payData['dueDate']?.toString());
        }

        if (statusData != null) {
          final s = (statusData['membershipStatus'] ?? '').toString().toUpperCase();
          final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          final endFromStatus = _parseDate(statusData['membershipEndDate']?.toString());
          if (s == 'PENDING') {
            row.payStatus = _PayStatus.pending;
          } else if (endFromStatus != null && endFromStatus.isBefore(today)) {
            row.payStatus = _PayStatus.expired;
          } else if (s == 'ACTIVE') {
            row.payStatus = _PayStatus.active;
          }
        }
      });
    } catch (e) {
      if (mounted) setState(() => row.payStatus = _PayStatus.error);
      print("Catch the error ${e}");
      print("Catch the error ${e}");

    }
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try { return DateTime.parse(raw); } catch (_) { return null; }
  }

  DateTime? _parseDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try { return DateTime.parse(raw); } catch (_) { return null; }
  }

  String _fmt(DateTime? d) =>
      d == null ? '—' : DateFormat('MMM dd, yyyy').format(d);

  String _fmtDateTime(DateTime? d) =>
      d == null ? '—' : DateFormat('MMM dd, yyyy • hh:mm a').format(d);

  num get _totalPendingAmount =>
      _pendingPayments.fold(0, (sum, p) => sum + p.amount);

  // ─── Build ─────────────────────────────────────────────────────────────────
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
            _buildAppBar(),
            Expanded(
              child: _loadingChildren
                  ? const Center(child: CircularProgressIndicator(color: accentGreen))
                  : _childrenError != null
                  ? _ErrorRetry(message: _childrenError!, onRetry: _bootstrap)
                  : _children.isEmpty
                  ? _emptyState('No children linked to your account')
                  : RefreshIndicator(
                onRefresh: _bootstrap,
                color: accentGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      24.height,

                      // ── API ①: Pending payments banner ──────
                      if (_loadingPending)
                        _shimmerBox(height: 80.h)
                      else if (_pendingPayments.isNotEmpty)
                        _buildPendingBanner(),

                      if (_pendingPayments.isNotEmpty) 20.height,

                      // ── Child selector ───────────────────────
                      _buildChildSelector(),
                      24.height,

                      // ── API ② + ③/④ + ⑤: memberships ───────
                      _buildSectionTitle('Membership & Payment Status'),
                      16.height,
                      _buildMembershipList(),
                      80.height,
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

  // ─── App Bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              top: 5.h, left: 20.w, right: 20.w, bottom: 14.h),
          child: Text(
            'Payments',
            style: GoogleFonts.montserrat(
                color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ─── API ① Banner: pending payments across all children ───────────────────
  Widget _buildPendingBanner() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.orange.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 20.sp),
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_pendingPayments.length} Pending Payment${_pendingPayments.length > 1 ? 's' : ''}',
                      style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade800),
                    ),
                    Text(
                      'Total due: ₹${_totalPendingAmount.toInt()}',
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp, color: Colors.orange.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          12.height,
          ..._pendingPayments.map((p) => Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.person_rounded,
                      size: 13.sp, color: Colors.orange.shade700),
                  5.width,
                  Text(p.memberName,
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp, color: Colors.black87)),
                ]),
                Text(
                  '₹${p.amount}',
                  style: GoogleFonts.montserrat(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade800),
                ),
              ],
            ),
          )),
          8.height,
          Text(
            'Please contact the club admin to clear dues.',
            style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.orange.shade700,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  // ─── Child selector ────────────────────────────────────────────────────────
  Widget _buildChildSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accentGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.person_rounded, color: accentGreen, size: 24.sp),
          12.width,
          Expanded(
            child: DropdownButton<_ChildRow>(
              value: _selectedChild,
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
              style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
              items: _children.map((c) => DropdownMenuItem<_ChildRow>(
                value: c,
                child: Text(c.name),
              )).toList(),
              onChanged: (child) {
                if (child == null) return;
                setState(() => _selectedChild = child);
                _loadMemberships(child);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Membership list ───────────────────────────────────────────────────────
  Widget _buildMembershipList() {
    if (_loadingMemberships) {
      return Column(
          children: List.generate(2, (_) => _shimmerBox(height: 160.h)));
    }
    if (_memberships.isEmpty) {
      return _emptyCard('No memberships found for this child');
    }
    return Column(
      children: _memberships
          .map((m) => _MembershipCard(
        row:          m,
        formatDate:   _fmt,
        formatDt:     _fmtDateTime,
      ))
          .toList(),
    );
  }

  // ─── Utils ─────────────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String t) => Text(t,
      style: GoogleFonts.montserrat(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade700));

  Widget _shimmerBox({required double height}) {
    return Container(
      margin:      EdgeInsets.only(bottom: 14.h),
      height:      height,
      decoration:  BoxDecoration(
          color:            Colors.grey.shade200,
          borderRadius:     BorderRadius.circular(16.r)),
    );
  }

  Widget _emptyState(String msg) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.people_outline_rounded,
          size: 64.sp, color: Colors.grey.shade300),
      16.height,
      Text(msg,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontSize: 14.sp, color: textSecondary)),
    ]),
  );

  Widget _emptyCard(String msg) => Container(
    padding:     EdgeInsets.all(24.w),
    decoration:  BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border:       Border.all(color: Colors.grey.shade200)),
    child: Column(children: [
      Icon(Icons.card_membership_rounded,
          size: 48.sp, color: Colors.grey.shade300),
      12.height,
      Text(msg,
          style: GoogleFonts.poppins(
              fontSize: 13.sp, color: textSecondary)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Membership card
// ─────────────────────────────────────────────────────────────────────────────

class _MembershipCard extends StatelessWidget {
  final _MembershipRow row;
  final String Function(DateTime?) formatDate;
  final String Function(DateTime?) formatDt;

  const _MembershipCard({
    required this.row,
    required this.formatDate,
    required this.formatDt,
  });

  Color get _color {
    switch (row.payStatus) {
      case _PayStatus.active:       return accentGreen;
      case _PayStatus.pending:      return Colors.orange;
      case _PayStatus.expired:      return Colors.red;
      case _PayStatus.noMembership: return Colors.blueGrey;
      default:                      return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (row.payStatus) {
      case _PayStatus.active:       return 'Active';
      case _PayStatus.pending:      return 'Pending';
      case _PayStatus.expired:      return 'Expired';
      case _PayStatus.noMembership: return 'No Membership';
      case _PayStatus.loading:      return '...';
      default:                      return 'Error';
    }
  }

  String _payLabel(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'PAID':    return 'Paid';
      case 'PENDING': return 'Unpaid';
      case 'OVERDUE': return 'Overdue';
      default:        return raw ?? '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header: club name + status badge ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.sports_soccer_rounded,
                    color: _color, size: 22.sp),
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.clubName,
                        style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                    if (row.role.isNotEmpty) ...[
                      3.height,
                      Text(row.role,
                          style: GoogleFonts.poppins(
                              fontSize: 11.sp, color: textSecondary)),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(_statusLabel,
                    style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: _color)),
              ),
            ],
          ),

          16.height,
          Divider(color: Colors.grey.shade200, height: 1),
          14.height,

          // ── Membership dates (from API ②) ─────────────────────────────────
          Row(
            children: [
              Expanded(child: _tile('Member Since', formatDate(row.startDate))),
              Expanded(child: _tile('Valid Until',  formatDate(row.endDate))),
            ],
          ),

          14.height,

          // ── Payment details (from API ③/④) ───────────────────────────────
          if (row.payStatus == _PayStatus.loading)
            _ShimmerLine(width: double.infinity, height: 14.h)
          else ...[
            Row(
              children: [
                Expanded(
                  child: _tile(
                    'Amount',
                    row.amount > 0 ? '₹${row.amount}' : '—',
                  ),
                ),
                if (row.paymentStatusRaw != null)
                  Expanded(
                    child: _tile(
                      'Payment',
                      _payLabel(row.paymentStatusRaw),
                      valueColor: row.paymentStatusRaw == 'PAID'
                          ? accentGreen
                          : Colors.red,
                    ),
                  ),
              ],
            ),

            // Due date (from API ③)
            if (row.dueDate != null) ...[
              10.height,
              _tile('Due Date', formatDate(row.dueDate)),
            ],

            // Payment date (from API ③) — only if paid
            if (row.paymentDate != null &&
                row.paymentStatusRaw == 'PAID') ...[
              10.height,
              Row(children: [
                Icon(Icons.check_circle_rounded,
                    size: 13.sp, color: accentGreen),
                6.width,
                Text(
                  'Paid on ${formatDt(row.paymentDate)}',
                  style: GoogleFonts.poppins(
                      fontSize: 11.sp, color: accentGreen),
                ),
              ]),
            ],

            // Payment method
            if ((row.paymentMethod ?? '').isNotEmpty) ...[
              8.height,
              Row(children: [
                Icon(Icons.payment_rounded, size: 13.sp, color: textSecondary),
                5.width,
                Text(row.paymentMethod!,
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp, color: textSecondary)),
              ]),
            ],

            // Reference with copy
            if ((row.paymentReference ?? '').isNotEmpty) ...[
              4.height,
              Row(children: [
                Icon(Icons.receipt_long_rounded,
                    size: 13.sp, color: textSecondary),
                5.width,
                Expanded(
                  child: Text(
                    'Ref: ${row.paymentReference}',
                    style: GoogleFonts.poppins(
                        fontSize: 10.sp, color: textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: row.paymentReference!));
                    toast('Copied to clipboard', bgColor: accentGreen);
                  },
                  child: Icon(Icons.copy_rounded,
                      size: 14.sp, color: Colors.blue),
                ),
              ]),
            ],

            // Notice for pending/expired
            if (row.payStatus == _PayStatus.expired ||
                row.payStatus == _PayStatus.pending) ...[
              14.height,
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: _color.withOpacity(0.25)),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16.sp, color: _color),
                  10.width,
                  Expanded(
                    child: Text(
                      row.payStatus == _PayStatus.expired
                          ? 'Membership expired. Please contact the club admin to renew.'
                          : 'Payment is pending. Please contact the club admin.',
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp, color: _color),
                    ),
                  ),
                ]),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _tile(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 10.sp, color: textSecondary)),
        3.height,
        Text(value,
            style: GoogleFonts.montserrat(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer line
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerLine extends StatefulWidget {
  final double width;
  final double height;
  const _ShimmerLine({required this.width, required this.height});

  @override
  State<_ShimmerLine> createState() => _ShimmerLineState();
}

class _ShimmerLineState extends State<_ShimmerLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error + Retry
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.red),
        16.height,
        Text(message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 13.sp, color: textSecondary)),
        16.height,
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text('Retry', style: GoogleFonts.poppins()),
          style: ElevatedButton.styleFrom(
              backgroundColor: accentGreen, foregroundColor: Colors.white),
        ),
      ]),
    );
  }
}