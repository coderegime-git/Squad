// screens/clubadmin/clubadmin_payments.dart
// ── All 6 Membership/Payment APIs integrated ──────────────────────────────
//
// API usage map:
// ① GET /api/users/{userId}/memberships
//      → Per-member membership list (clubName, role, dates, status)
// ② GET /api/memberships/{membershipId}/payment
//      → Payment detail: paymentDate, dueDate, paymentStatus, guardianUserId
// ③ GET /api/payments/memberships/{membershipId}
//      → Same payload, used as fallback to API ②
// ④ GET /api/clubs/{clubId}/members/{userId}/membership-status
//      → Cross-check live membership status per club
// ⑤ PATCH /api/payments/{paymentId}/status
//      → Mark payment PAID when admin records a payment
// ⑥ GET /api/payments/guardians/{guardianId}/pending-payments
//      → NOT used in club admin (guardian-only view); handled in guardian screen
//
// Extra: updateMemberMembership() extends membershipEndDate on PATCH /api/members/{id}
// ──────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';

import '../../config/colors.dart';
import '../../utills/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// View model
// ─────────────────────────────────────────────────────────────────────────────

enum _MemberPayStatus { loading, pending, active, expired, noMembership, error }

class _MemberRow {
  final int    memberId;
  final int    userId;
  final String name;
  final String email;

  // Filled after lazy API ① → ②/③ → ④ chain
  _MemberPayStatus status;
  int?     membershipId;
  int?     clubId;        // from API ① — needed for API ④
  int?     paymentId;     // from API ②/③
  num      amount;
  DateTime? membershipEndDate;
  String?  membershipStatus;   // raw: ACTIVE / PENDING / EXPIRED
  DateTime? paymentDate;       // from API ②
  DateTime? dueDate;           // from API ②
  String?  paymentStatusRaw;   // PENDING / PAID / OVERDUE (from API ②)
  String?  paymentMethod;
  String?  paymentReference;

  _MemberRow({
    required this.memberId,
    required this.userId,
    required this.name,
    required this.email,
    this.status             = _MemberPayStatus.loading,
    this.membershipId,
    this.clubId,
    this.paymentId,
    this.amount             = 0,
    this.membershipEndDate,
    this.membershipStatus,
    this.paymentDate,
    this.dueDate,
    this.paymentStatusRaw,
    this.paymentMethod,
    this.paymentReference,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ClubAdminPaymentsScreen extends StatefulWidget {
  const ClubAdminPaymentsScreen({super.key});

  @override
  State<ClubAdminPaymentsScreen> createState() =>
      _ClubAdminPaymentsScreenState();
}

class _ClubAdminPaymentsScreenState extends State<ClubAdminPaymentsScreen> {
  final ClubApiService _api = ClubApiService();

  bool    _loadingMembers = true;
  String? _membersError;
  List<_MemberRow> _rows = [];

  String? _filterStatus; // null=All, 'PENDING', 'ACTIVE', 'EXPIRED'

  @override
  void initState() {
    super.initState();
    _loadMembersFirst();
  }

  Future<void> _loadMembersFirst() async {
    setState(() {
      _loadingMembers = true;
      _membersError   = null;
      _rows           = [];
    });
    try {
      final result = await _api.getMembers();
      final rows = result.data.map((m) => _MemberRow(
        memberId: m.memberId,
        userId:   m.userId,
        name:     m.username,
        email:    m.email,
      )).toList();

      setState(() {
        _rows           = rows;
        _loadingMembers = false;
      });

      // Phase 2: lazy-fetch per member
      for (final row in rows) _fetchMemberDetails(row);
    } catch (e) {
      setState(() {
        _loadingMembers = false;
        _membersError   = 'Failed to load members. Tap to retry.';
      });
      print("catch6");
    }
  }

  Future<void> _fetchMemberDetails(_MemberRow row) async {
    try {
      final memberships = await _api.getUserMemberships(row.userId);

      if (memberships.isEmpty) {
        _set(row, status: _MemberPayStatus.noMembership);
        return;
      }

      final membership       = memberships.last;
      final membershipId     = membership['membershipId'];
      final clubId           = membership['clubId'];
      final endDateStr       = membership['membershipEndDate'];
      final membershipStatus =
      (membership['status'] ?? '').toString().toUpperCase();

      final endDate = _parseDate(endDateStr?.toString());
      final today   = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final isExpired = endDate != null && endDate.isBefore(today);

      _MemberPayStatus display;
      if (membershipStatus == 'PENDING') {
        display = _MemberPayStatus.pending;
      } else if (isExpired) {
        display = _MemberPayStatus.expired;
      } else {
        display = _MemberPayStatus.active;
      }

      // Optimistic update so the card appears quickly
      _set(row,
          status:            display,
          membershipId:      membershipId,
          clubId:            clubId,
          membershipEndDate: endDate,
          membershipStatus:  membershipStatus);

      // ── API ② then ③ fallback: payment details ────────────────────────────
      Map<String, dynamic>? payData;
      if (membershipId != null) {
        try {
          // API ②: GET /api/memberships/{membershipId}/payment
          payData = await _api.getMembershipPayment(membershipId);
        } catch (_) {
          print("catch1");
          try {
            payData = await _api.getPaymentByMembershipId(membershipId);
          } catch (_) {
            print("catch2");
          }
        }
      }

      // ── API ④: cross-check live membership status ─────────────────────────
      if (clubId != null && clubId > 0) {
        try {
          final statusData =
          await _api.getMembershipStatus(clubId, row.userId);
          if (statusData != null) {
            final s       = (statusData['membershipStatus'] ?? '').toString().toUpperCase();
            final endFromStatus =
            _parseDate(statusData['membershipEndDate']?.toString());
            _MemberPayStatus verified;
            if (s == 'PENDING') {
              verified = _MemberPayStatus.pending;
            } else if (endFromStatus != null && endFromStatus.isBefore(today)) {
              verified = _MemberPayStatus.expired;
            } else {
              verified = _MemberPayStatus.active;
            }
            display = verified;
          }
        } catch (_) {
          print("catch3");
        } // non-critical
      }

      _set(
        row,
        status:            display,
        membershipId:      membershipId,
        clubId:            clubId,
        paymentId:         payData?['paymentId'],
        amount: (payData?['amount'] is num)
            ? payData!['amount'] as num
            : 0,
        membershipEndDate: endDate,
        membershipStatus:  membershipStatus,
        paymentDate:       _parseDateTime(payData?['paymentDate']?.toString()),
        dueDate:           _parseDate(payData?['dueDate']?.toString()),
        paymentStatusRaw:
        (payData?['paymentStatus'] ?? '').toString().toUpperCase(),
        paymentMethod:     payData?['paymentMethod'],
        paymentReference:  payData?['paymentReference'],
      );
    } catch (e) {
      _set(row, status: _MemberPayStatus.error);
      print("catch4 ${e}");
    }
  }

  void _set(
      _MemberRow row, {
        required _MemberPayStatus status,
        int?     membershipId,
        int?     clubId,
        int?     paymentId,
        num      amount           = 0,
        DateTime? membershipEndDate,
        String?  membershipStatus,
        DateTime? paymentDate,
        DateTime? dueDate,
        String?  paymentStatusRaw,
        String?  paymentMethod,
        String?  paymentReference,
      }) {
    if (!mounted) return;
    setState(() {
      row.status            = status;
      if (membershipId   != null) row.membershipId     = membershipId;
      if (clubId         != null) row.clubId            = clubId;
      if (paymentId      != null) row.paymentId         = paymentId;
      if (amount > 0) row.amount = amount;
      if (membershipEndDate != null) row.membershipEndDate = membershipEndDate;
      if (membershipStatus  != null) row.membershipStatus  = membershipStatus;
      if (paymentDate    != null) row.paymentDate       = paymentDate;
      if (dueDate        != null) row.dueDate            = dueDate;
      if (paymentStatusRaw != null) row.paymentStatusRaw = paymentStatusRaw;
      if (paymentMethod  != null) row.paymentMethod     = paymentMethod;
      if (paymentReference != null) row.paymentReference = paymentReference;
    });
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try { return DateTime.parse(raw); } catch (_) { return null; }
  }

  DateTime? _parseDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try { return DateTime.parse(raw); } catch (_) { return null; }
  }

  // ─── Filtered rows ────────────────────────────────────────────────────────
  List<_MemberRow> get _filteredRows {
    if (_filterStatus == null) return _rows;
    return _rows.where((r) {
      switch (_filterStatus) {
        case 'PENDING': return r.status == _MemberPayStatus.pending;
        case 'ACTIVE':  return r.status == _MemberPayStatus.active;
        case 'EXPIRED': return r.status == _MemberPayStatus.expired;
        default:        return true;
      }
    }).toList();
  }

  int get _pendingCount =>
      _rows.where((r) => r.status == _MemberPayStatus.pending).length;
  int get _activeCount  =>
      _rows.where((r) => r.status == _MemberPayStatus.active).length;
  int get _expiredCount =>
      _rows.where((r) => r.status == _MemberPayStatus.expired).length;

  // ─── Record Payment dialog — calls API ⑤ + updateMemberMembership ─────────
  void _showRecordPaymentDialog(_MemberRow member) {
    final amountCtrl    = TextEditingController(
        text: member.amount > 0 ? '${member.amount}' : '');
    final methodCtrl    = TextEditingController(
        text: member.paymentMethod ?? '');
    final referenceCtrl = TextEditingController(
        text: member.paymentReference ?? '');
    DateTime? newEndDate;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r)),
          title: Text('Record Payment',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Member info
                Text('Member: ${member.name}',
                    style: GoogleFonts.poppins(
                        fontSize: 13.sp, color: textSecondary)),
                4.height,
                // Due date from API ②
                if (member.dueDate != null)
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(member.dueDate!)}',
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp, color: Colors.orange.shade700),
                  ),
                if (member.membershipEndDate != null)
                  Text(
                    member.status == _MemberPayStatus.expired
                        ? 'Expired: ${DateFormat('MMM dd, yyyy').format(member.membershipEndDate!)}'
                        : 'End date: ${DateFormat('MMM dd, yyyy').format(member.membershipEndDate!)}',
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp, color: Colors.red.shade600),
                  ),
                16.height,

                // Amount
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount Received *',
                    prefixText: '₹ ',
                    prefixIcon: const Icon(Icons.currency_rupee_rounded,
                        color: Colors.red),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                        const BorderSide(color: accentGreen, width: 2)),
                  ),
                ),
                12.height,

                // Payment method
                TextField(
                  controller: methodCtrl,
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    hintText: 'e.g., UPI, Cash, Bank Transfer',
                    prefixIcon: Icon(Icons.payment_rounded, color: textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                        const BorderSide(color: accentGreen, width: 2)),
                  ),
                ),
                12.height,

                // Reference
                TextField(
                  controller: referenceCtrl,
                  decoration: InputDecoration(
                    labelText: 'Payment Reference',
                    hintText: 'e.g., UTR number, receipt no.',
                    prefixIcon: Icon(Icons.receipt_rounded, color: textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                        const BorderSide(color: accentGreen, width: 2)),
                  ),
                ),
                16.height,

                // New end date picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                      DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate:
                      DateTime.now().add(const Duration(days: 730)),
                      builder: (ctx2, child) => Theme(
                        data: Theme.of(ctx2).copyWith(
                          colorScheme: const ColorScheme.light(
                              primary: accentGreen),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setD(() => newEndDate = picked);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(children: [
                      Icon(Icons.calendar_today_rounded,
                          color: textSecondary, size: 18.sp),
                      12.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('New Membership End Date *',
                                style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: textSecondary)),
                            2.height,
                            Text(
                              newEndDate != null
                                  ? DateFormat('MMM dd, yyyy')
                                  .format(newEndDate!)
                                  : 'Select date',
                              style: GoogleFonts.montserrat(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: newEndDate != null
                                    ? Colors.black
                                    : textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: textSecondary)),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                if (amountCtrl.text.trim().isEmpty ||
                    newEndDate == null) {
                  toast(
                      'Please fill Amount and select new end date');
                  return;
                }
                if (member.paymentId == null) {
                  toast(
                      'No payment record found for this member');
                  return;
                }

                setD(() => isSaving = true);

                // ── API ⑤: mark payment as PAID ──────────────────────
                final payOk = await _api.updatePaymentStatus(
                  member.paymentId!,
                  status: 'PAID',
                  paymentMethod: methodCtrl.text.trim().isNotEmpty
                      ? methodCtrl.text.trim()
                      : null,
                  paymentReference:
                  referenceCtrl.text.trim().isNotEmpty
                      ? referenceCtrl.text.trim()
                      : null,
                );

                bool memberOk = false;
                if (payOk) {
                  memberOk = await _api.updateMemberMembership(
                    member.memberId,
                    {
                      'membershipEndDate': DateFormat('yyyy-MM-dd')
                          .format(newEndDate!),
                    },
                  );
                }


                setD(() => isSaving = false);
                if (mounted) Navigator.pop(ctx);

                if (payOk) {
                  toast(
                    memberOk
                        ? '✅ Payment recorded & membership extended'
                        : '✅ Payment recorded. (Membership date update failed — update manually)',
                    bgColor: accentGreen,
                  );
                  _loadMembersFirst();
                } else {
                  toast('Failed to record payment. Please try again.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: isSaving
                  ? SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : Text('Save',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            // App bar
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    bottomLeft:  Radius.circular(16),
                    bottomRight: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 5.h, left: 20.w, right: 20.w, bottom: 14.h),
                  child: Row(children: [
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 20.sp)),
                    16.width,
                    Text('Payment Management',
                        style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ),

            // Filter chips
            if (!_loadingMembers && _membersError == null)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
                child: Row(children: [
                  _Chip(label: 'All',     count: _rows.length,   color: Colors.blueGrey,
                      selected: _filterStatus == null,
                      onTap: () => setState(() => _filterStatus = null)),
                  8.width,
                  _Chip(label: 'Pending', count: _pendingCount,  color: Colors.orange,
                      selected: _filterStatus == 'PENDING',
                      onTap: () => setState(() =>
                      _filterStatus = _filterStatus == 'PENDING' ? null : 'PENDING')),
                  8.width,
                  _Chip(label: 'Expired', count: _expiredCount,  color: Colors.red,
                      selected: _filterStatus == 'EXPIRED',
                      onTap: () => setState(() =>
                      _filterStatus = _filterStatus == 'EXPIRED' ? null : 'EXPIRED')),
                  8.width,
                  _Chip(label: 'Active',  count: _activeCount,   color: accentGreen,
                      selected: _filterStatus == 'ACTIVE',
                      onTap: () => setState(() =>
                      _filterStatus = _filterStatus == 'ACTIVE' ? null : 'ACTIVE')),
                ]),
              ),

            if (!_loadingMembers && _membersError == null) 14.height,

            // Body
            Expanded(
              child: _loadingMembers
                  ? const Center(
                  child: CircularProgressIndicator(color: accentGreen))
                  : _membersError != null
                  ? _ErrorRetry(
                  message: _membersError!,
                  onRetry: _loadMembersFirst)
                  : RefreshIndicator(
                onRefresh: _loadMembersFirst,
                color: accentGreen,
                child: _rows.isEmpty
                    ? ListView(children: [
                  SizedBox(height: 80.h),
                  Center(
                    child: Column(children: [
                      Icon(Icons.people_outline_rounded,
                          size: 64.sp, color: textSecondary),
                      16.height,
                      Text('No members found',
                          style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: textSecondary)),
                    ]),
                  ),
                ])
                    : ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.w, vertical: 8.h),
                  itemCount: _filteredRows.length,
                  itemBuilder: (_, i) => _MemberCard(
                    row:      _filteredRows[i],
                    onRecord: _showRecordPaymentDialog,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter chip
// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.count, required this.color,
    required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: selected ? color : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(children: [
            Text('$count',
                style: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : color)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: selected ? Colors.white : color,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Member card
// ─────────────────────────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final _MemberRow row;
  final void Function(_MemberRow) onRecord;
  const _MemberCard({required this.row, required this.onRecord});

  Color get _color {
    switch (row.status) {
      case _MemberPayStatus.pending:      return Colors.orange;
      case _MemberPayStatus.expired:      return Colors.red;
      case _MemberPayStatus.active:       return accentGreen;
      case _MemberPayStatus.error:        return Colors.grey;
      default:                            return Colors.blueGrey;
    }
  }

  String get _endDateLabel {
    if (row.membershipEndDate == null) return '';
    final f = DateFormat('MMM dd, yyyy').format(row.membershipEndDate!);
    switch (row.status) {
      case _MemberPayStatus.expired:
        final d = DateTime.now().difference(row.membershipEndDate!).inDays;
        return 'Expired: $f ($d days ago)';
      case _MemberPayStatus.active:   return 'Valid till: $f';
      case _MemberPayStatus.pending:  return 'End date: $f';
      default:                        return 'End date: $f';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(children: [
        // Avatar
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
              color: _color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(Icons.person_rounded, color: _color, size: 22.sp),
        ),
        14.width,

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(row.name,
                  style: GoogleFonts.montserrat(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)),
              3.height,
              Text(row.email,
                  style: GoogleFonts.poppins(
                      fontSize: 11.sp, color: textSecondary)),
              6.height,
              if (row.status == _MemberPayStatus.loading)
                _ShimmerLine(width: 140.w, height: 12.h)
              else ...[
                Row(children: [
                  _StatusBadge(status: row.status),
                  if (row.amount > 0) ...[
                    8.width,
                    Icon(Icons.currency_rupee_rounded,
                        size: 11.sp, color: _color),
                    Text('${row.amount}',
                        style: GoogleFonts.montserrat(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: _color)),
                  ],
                ]),
                if (_endDateLabel.isNotEmpty) ...[
                  4.height,
                  Text(_endDateLabel,
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp, color: textSecondary)),
                ],
                // Due date from API ②
                if (row.dueDate != null) ...[
                  3.height,
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(row.dueDate!)}',
                    style: GoogleFonts.poppins(
                        fontSize: 10.sp, color: Colors.orange.shade700),
                  ),
                ],
                // Payment date from API ②
                if (row.paymentDate != null &&
                    row.paymentStatusRaw == 'PAID') ...[
                  3.height,
                  Text(
                    'Paid: ${DateFormat('MMM dd, yyyy').format(row.paymentDate!)}',
                    style: GoogleFonts.poppins(
                        fontSize: 10.sp, color: accentGreen),
                  ),
                ],
              ],
            ],
          ),
        ),

        // Record button
        if (row.status == _MemberPayStatus.pending ||
            row.status == _MemberPayStatus.expired)
          ElevatedButton(
            onPressed: () => onRecord(row),
            style: ElevatedButton.styleFrom(
              backgroundColor: _color,
              foregroundColor: Colors.white,
              padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
              elevation: 0,
            ),
            child: Text('Record',
                style: GoogleFonts.poppins(
                    fontSize: 11.sp, fontWeight: FontWeight.w600)),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final _MemberPayStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color; String label; IconData icon;
    switch (status) {
      case _MemberPayStatus.pending:
        color = Colors.orange; label = 'Pending';
        icon  = Icons.hourglass_top_rounded; break;
      case _MemberPayStatus.expired:
        color = Colors.red; label = 'Expired';
        icon  = Icons.warning_amber_rounded; break;
      case _MemberPayStatus.active:
        color = accentGreen; label = 'Active';
        icon  = Icons.check_circle_outline_rounded; break;
      case _MemberPayStatus.noMembership:
        color = Colors.blueGrey; label = 'No Membership';
        icon  = Icons.remove_circle_outline_rounded; break;
      default:
        color = Colors.grey; label = 'Error';
        icon  = Icons.error_outline_rounded;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11.sp, color: color),
        4.width,
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: color)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerLine extends StatefulWidget {
  final double width; final double height;
  const _ShimmerLine({required this.width, required this.height});
  @override State<_ShimmerLine> createState() => _ShimmerLineState();
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
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      width: widget.width, height: widget.height,
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(6.r)),
    ),
  );
}


class _ErrorRetry extends StatelessWidget {
  final String message; final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.red),
      16.height,
      Text(message, textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary)),
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