// screens/clubadmin/clubadmin_payments.dart
// Progressive loading: show all members first, then load membership/payment details per card

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';

import '../../config/colors.dart';
import '../../utills/api_service.dart';

enum _MemberPayStatus { loading, pending, active, expired, noMembership, error }

class _MemberRow {
  final int memberId;
  final int userId;
  final String name;
  final String email;

  // Filled after lazy fetch
  _MemberPayStatus status;
  int? membershipId;
  int? paymentId;
  int amount;
  DateTime? membershipEndDate;
  String? membershipStatus; // raw string from API: ACTIVE / PENDING / EXPIRED

  _MemberRow({
    required this.memberId,
    required this.userId,
    required this.name,
    required this.email,
    this.status = _MemberPayStatus.loading,
    this.membershipId,
    this.paymentId,
    this.amount = 0,
    this.membershipEndDate,
    this.membershipStatus,
  });
}

class ClubAdminPaymentsScreen extends StatefulWidget {
  const ClubAdminPaymentsScreen({super.key});

  @override
  State<ClubAdminPaymentsScreen> createState() => _ClubAdminPaymentsScreenState();
}

class _ClubAdminPaymentsScreenState extends State<ClubAdminPaymentsScreen> {
  final ClubApiService _apiService = ClubApiService();

  bool _loadingMembers = true;
  String? _membersError;
  List<_MemberRow> _rows = [];

  // Filter: null = all, 'PENDING', 'ACTIVE', 'EXPIRED'
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadMembersFirst();
  }

  Future<void> _loadMembersFirst() async {
    setState(() {
      _loadingMembers = true;
      _membersError = null;
      _rows = [];
    });

    try {
      final result = await _apiService.getMembers();

      final rows = result.data
          .map((m) => _MemberRow(
        memberId: m.memberId,
        userId: m.userId,
        name: m.username,
        email: m.email,
      ))
          .toList();

      setState(() {
        _rows = rows;
        _loadingMembers = false;
      });

      // Phase 2: fetch details for each member concurrently
      for (final row in rows) {
        _fetchMemberDetails(row); // fire-and-forget, updates state individually
      }
    } catch (e) {
      setState(() {
        _loadingMembers = false;
        _membersError = 'Failed to load members. Tap to retry.';
      });
    }
  }

  // ── Phase 2: lazy fetch per member ────────────────────────────────────────
  Future<void> _fetchMemberDetails(_MemberRow row) async {
    try {
      final memberships = await _apiService.getUserMemberships(row.userId);

      if (memberships.isEmpty) {
        _updateRow(row, status: _MemberPayStatus.noMembership);
        return;
      }

      final membership = memberships.last;
      final endDateStr = membership['membershipEndDate'];
      final membershipId = membership['membershipId'];
      final membershipStatus = (membership['status'] ?? '').toString().toUpperCase();

      DateTime? endDate;
      if (endDateStr != null && endDateStr.toString().isNotEmpty) {
        endDate = DateTime.tryParse(endDateStr.toString());
      }

      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final isExpired = endDate != null && endDate.isBefore(today);

      // Determine display status
      _MemberPayStatus displayStatus;
      if (membershipStatus == 'PENDING') {
        displayStatus = _MemberPayStatus.pending;
      } else if (isExpired) {
        displayStatus = _MemberPayStatus.expired;
      } else {
        displayStatus = _MemberPayStatus.active;
      }

      int? paymentId;
      int amount = 0;
      if (membershipId != null) {
        try {
          final paymentData = await _apiService.getPaymentByMembershipId(membershipId);
          if (paymentData != null) {
            paymentId = paymentData['paymentId'];
            amount = paymentData['amount'] ?? 0;
          }
        } catch (_) {}
      }

      _updateRow(
        row,
        status: displayStatus,
        membershipId: membershipId,
        paymentId: paymentId,
        amount: amount,
        membershipEndDate: endDate,
        membershipStatus: membershipStatus,
      );
    } catch (e) {
      _updateRow(row, status: _MemberPayStatus.error);
    }
  }

  void _updateRow(
      _MemberRow row, {
        required _MemberPayStatus status,
        int? membershipId,
        int? paymentId,
        int amount = 0,
        DateTime? membershipEndDate,
        String? membershipStatus,
      }) {
    if (!mounted) return;
    setState(() {
      row.status = status;
      row.membershipId = membershipId;
      row.paymentId = paymentId;
      row.amount = amount;
      row.membershipEndDate = membershipEndDate;
      row.membershipStatus = membershipStatus;
    });
  }

  List<_MemberRow> get _filteredRows {
    if (_filterStatus == null) return _rows;
    return _rows.where((r) {
      switch (_filterStatus) {
        case 'PENDING':
          return r.status == _MemberPayStatus.pending;
        case 'ACTIVE':
          return r.status == _MemberPayStatus.active;
        case 'EXPIRED':
          return r.status == _MemberPayStatus.expired;
        default:
          return true;
      }
    }).toList();
  }

  // ── Counts ─────────────────────────────────────────────────────────────────
  int get _pendingCount => _rows.where((r) => r.status == _MemberPayStatus.pending).length;
  int get _activeCount => _rows.where((r) => r.status == _MemberPayStatus.active).length;
  int get _expiredCount => _rows.where((r) => r.status == _MemberPayStatus.expired).length;

  // ── Record payment dialog ─────────────────────────────────────────────────
  void _showRecordPaymentDialog(_MemberRow member) {
    final amountCtrl = TextEditingController(text: '${member.amount}');
    final methodCtrl = TextEditingController();
    final referenceCtrl = TextEditingController();
    DateTime? newEndDate;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text('Record Payment',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Member: ${member.name}',
                    style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary)),
                4.height,
                if (member.membershipEndDate != null)
                  Text(
                    member.status == _MemberPayStatus.expired
                        ? 'Expired: ${DateFormat('MMM dd, yyyy').format(member.membershipEndDate!)}'
                        : 'Pending since: ${DateFormat('MMM dd, yyyy').format(member.membershipEndDate!)}',
                    style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.red.shade600),
                  ),
                16.height,
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount Received *',
                    prefixText: '₹ ',
                    prefixIcon: const Icon(Icons.currency_rupee_rounded, color: Colors.red),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: accentGreen, width: 2)),
                  ),
                ),
                12.height,
                TextField(
                  controller: methodCtrl,
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    hintText: 'e.g., UPI, Cash, Bank Transfer',
                    prefixIcon: Icon(Icons.payment_rounded, color: textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: accentGreen, width: 2)),
                  ),
                ),
                12.height,
                TextField(
                  controller: referenceCtrl,
                  decoration: InputDecoration(
                    labelText: 'Payment Reference',
                    hintText: 'e.g., UTR number, receipt no.',
                    prefixIcon: Icon(Icons.receipt_rounded, color: textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: accentGreen, width: 2)),
                  ),
                ),
                16.height,
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(primary: accentGreen)),
                        child: child!,
                      ),
                    );
                    if (date != null) setDialogState(() => newEndDate = date);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.r),
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
                              Text('New Membership End Date *',
                                  style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
                              2.height,
                              Text(
                                newEndDate != null
                                    ? DateFormat('MMM dd, yyyy').format(newEndDate!)
                                    : 'Select date',
                                style: GoogleFonts.montserrat(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins(color: textSecondary)),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                if (amountCtrl.text.isEmpty || newEndDate == null) {
                  toast('Please fill all required fields');
                  return;
                }
                setDialogState(() => isSaving = true);

                bool success = false;

                if (member.paymentId != null) {
                  success = await _apiService.updatePaymentStatus(
                    member.paymentId!,
                    status: 'PAID',
                    paymentMethod: methodCtrl.text.isNotEmpty ? methodCtrl.text : null,
                    paymentReference:
                    referenceCtrl.text.isNotEmpty ? referenceCtrl.text : null,
                  );
                }


                setDialogState(() => isSaving = false);
                Navigator.pop(ctx);

                if (success) {
                  toast('✅ Payment recorded for ${member.name}', bgColor: accentGreen);
                  _loadMembersFirst(); // full refresh
                } else {
                  toast('Failed to record payment');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: isSaving
                  ? SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Save', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            // ── App bar ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w, bottom: 14.h),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white, size: 20.sp)),
                      16.width,
                      Text('Payment Management',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),

            // ── Summary chips (only after members loaded) ──
            if (!_loadingMembers && _membersError == null) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
                child: Row(
                  children: [
                    _SummaryChip(
                      label: 'All',
                      count: _rows.length,
                      color: Colors.blueGrey,
                      selected: _filterStatus == null,
                      onTap: () => setState(() => _filterStatus = null),
                    ),
                    8.width,
                    _SummaryChip(
                      label: 'Pending',
                      count: _pendingCount,
                      color: Colors.orange,
                      selected: _filterStatus == 'PENDING',
                      onTap: () => setState(
                              () => _filterStatus = _filterStatus == 'PENDING' ? null : 'PENDING'),
                    ),
                    8.width,
                    _SummaryChip(
                      label: 'Expired',
                      count: _expiredCount,
                      color: Colors.red,
                      selected: _filterStatus == 'EXPIRED',
                      onTap: () => setState(
                              () => _filterStatus = _filterStatus == 'EXPIRED' ? null : 'EXPIRED'),
                    ),
                    8.width,
                    _SummaryChip(
                      label: 'Active',
                      count: _activeCount,
                      color: accentGreen,
                      selected: _filterStatus == 'ACTIVE',
                      onTap: () => setState(
                              () => _filterStatus = _filterStatus == 'ACTIVE' ? null : 'ACTIVE'),
                    ),
                  ],
                ),
              ),
              14.height,
            ],

            // ── Body ──
            Expanded(
              child: _loadingMembers
                  ? const Center(child: CircularProgressIndicator(color: accentGreen))
                  : _membersError != null
                  ? _ErrorRetry(message: _membersError!, onRetry: _loadMembersFirst)
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
                  )
                ])
                    : ListView.builder(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  itemCount: _filteredRows.length,
                  itemBuilder: (context, index) =>
                      _MemberCard(
                        row: _filteredRows[index],
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

// ─── Summary chip widget ──────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

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
          child: Column(
            children: [
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
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Member card widget ───────────────────────────────────────────────────────
class _MemberCard extends StatelessWidget {
  final _MemberRow row;
  final void Function(_MemberRow) onRecord;

  const _MemberCard({required this.row, required this.onRecord});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _borderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            padding: EdgeInsets.all(10.w),
            decoration:
            BoxDecoration(color: _borderColor.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(Icons.person_rounded, color: _borderColor, size: 22.sp),
          ),
          14.width,
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.name,
                    style: GoogleFonts.montserrat(
                        fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                3.height,
                Text(row.email,
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: textSecondary)),
                6.height,
                // Status row — shimmer while loading, actual data once fetched
                if (row.status == _MemberPayStatus.loading)
                  _ShimmerLine(width: 140.w, height: 12.h)
                else ...[
                  Row(children: [
                    _StatusBadge(status: row.status),
                    if (row.amount > 0) ...[
                      8.width,
                      Icon(Icons.currency_rupee_rounded, size: 11.sp, color: _borderColor),
                      Text('${row.amount}',
                          style: GoogleFonts.montserrat(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: _borderColor)),
                    ]
                  ]),
                  if (row.membershipEndDate != null) ...[
                    4.height,
                    Text(
                      _endDateLabel,
                      style: GoogleFonts.poppins(fontSize: 10.sp, color: textSecondary),
                    ),
                  ],
                ],
              ],
            ),
          ),
          // Action button — only for pending/expired
          if (row.status == _MemberPayStatus.pending ||
              row.status == _MemberPayStatus.expired)
            ElevatedButton(
              onPressed: () => onRecord(row),
              style: ElevatedButton.styleFrom(
                backgroundColor: _borderColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                elevation: 0,
              ),
              child: Text('Record',
                  style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Color get _borderColor {
    switch (row.status) {
      case _MemberPayStatus.pending:
        return Colors.orange;
      case _MemberPayStatus.expired:
        return Colors.red;
      case _MemberPayStatus.active:
        return accentGreen;
      case _MemberPayStatus.error:
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  String get _endDateLabel {
    if (row.membershipEndDate == null) return '';
    final formatted = DateFormat('MMM dd, yyyy').format(row.membershipEndDate!);
    switch (row.status) {
      case _MemberPayStatus.expired:
        final days = DateTime.now().difference(row.membershipEndDate!).inDays;
        return 'Expired: $formatted ($days days ago)';
      case _MemberPayStatus.active:
        return 'Valid till: $formatted';
      case _MemberPayStatus.pending:
        return 'End date: $formatted';
      default:
        return 'End date: $formatted';
    }
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final _MemberPayStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case _MemberPayStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        icon = Icons.hourglass_top_rounded;
        break;
      case _MemberPayStatus.expired:
        color = Colors.red;
        label = 'Expired';
        icon = Icons.warning_amber_rounded;
        break;
      case _MemberPayStatus.active:
        color = accentGreen;
        label = 'Active';
        icon = Icons.check_circle_outline_rounded;
        break;
      case _MemberPayStatus.noMembership:
        color = Colors.blueGrey;
        label = 'No Membership';
        icon = Icons.remove_circle_outline_rounded;
        break;
      case _MemberPayStatus.error:
        color = Colors.grey;
        label = 'Error';
        icon = Icons.error_outline_rounded;
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: color),
          4.width,
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10.sp, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ─── Shimmer placeholder ──────────────────────────────────────────────────────
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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

// ─── Error + retry widget ─────────────────────────────────────────────────────
class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.red),
          16.height,
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary)),
          16.height,
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('Retry', style: GoogleFonts.poppins()),
            style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}