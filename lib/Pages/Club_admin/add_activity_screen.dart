import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sports/utills/shared_preference.dart';

import '../../model/clubAdmin/activities_data.dart';
import '../../utills/api_service.dart';

enum ActivityType {
  training('TRAINING', 'Training', Icons.sports_cricket, Color(0xFF1B8C4E)),
  program('PROGRAM', 'Program', Icons.groups, Color(0xFF1E88E5)),
  camp('CAMP', 'Camp', Icons.campaign, Color(0xFF8E24AA));

  const ActivityType(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;
  final Color color;
}

/// Payload sent to the API — mirrors the JSON spec exactly.
class ActivityPayload {
  final String name;
  final String description;
  final String activityType;
  final String startDateTime; // ISO-8601
  final String endDateTime; // ISO-8601

  ActivityPayload({
    required this.name,
    required this.description,
    required this.activityType,
    required this.startDateTime,
    required this.endDateTime,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'activityType': activityType,
    'startDateTime': startDateTime,
    'endDateTime': endDateTime,
  };
}

class ActivityCreationPage extends StatefulWidget {
  final ActivityListData? activityListData;
  final int? id;

  const ActivityCreationPage({super.key, this.activityListData, this.id});

  @override
  State<ActivityCreationPage> createState() => _ActivityCreationPageState();
}

class _ActivityCreationPageState extends State<ActivityCreationPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final nameFocus = FocusNode();
  final _descCtrl = TextEditingController();
  final desFocus = FocusNode();
  final apiService = ClubApiService();
  bool showDateErrors = false;
  ActivityType _selectedType = ActivityType.training;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime(2026, 3, 20, 9, 42);
  bool _isSubmitting = false;

  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _bg = Color(0xFFF5F7F6);
  static const Color _primary = Color(0xFF1B8C4E);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _red = Color(0xFFE53935);

  String? get _dateError =>
      DateTimeValidator.validate(start: _startDate, end: _endDate);

  @override
  void initState() {
    super.initState();
    if (widget.activityListData != null) {
      final data = widget.activityListData;
      _nameCtrl.text = data!.name ?? "";
      _descCtrl.text = data!.description ?? "";
      _selectedType = data!.activityType == "TRAINING"
          ? ActivityType.training
          : data.activityType == "CAMP"
          ? ActivityType.camp
          : ActivityType.program;

      if (data.startDateTime != null && data.startDateTime!.isNotEmpty) {
        _startDate = DateTime.parse('${data.startDateTime!}Z').toLocal();
      }

      if (data.endDateTime != null && data.endDateTime!.isNotEmpty) {
        _endDate = DateTime.parse('${data.endDateTime!}Z').toLocal();
      }
    }
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatDisplay(DateTime dt) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mn = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour < 12 ? 'AM' : 'PM';
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$mn $ap';
  }

  /// Serialise to ISO-8601 with milliseconds, e.g. 2026-03-19T09:42:52.862Z
  String _toIso(DateTime dt) => dt.toUtc().toIso8601String();

  Duration get _duration => _endDate.difference(_startDate);

  String get _durationLabel {
    final h = _duration.inHours;
    final m = _duration.inMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  // ── Date / Time pickers ───────────────────────────────────────────────────

  Future<void> _pickDate(bool isStart) async {
    final init = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: _startDate,
      lastDate: DateTime(2080),
      builder: (ctx, child) => _lightPickerTheme(child!),
    );
    if (picked == null) return;
    final t = isStart ? _startDate : _endDate;
    final combined = DateTime(
      picked.year,
      picked.month,
      picked.day,
      t.hour,
      t.minute,
    );
    setState(() {
      if (isStart) {
        _startDate = combined;
        if (_endDate.isBefore(_startDate))
          _endDate = _startDate.add(const Duration(hours: 2));
      } else {
        _endDate = combined;
      }
    });
  }

  Future<void> _pickTime(bool isStart) async {
    final init = isStart ? _startDate : _endDate;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(init),
      builder: (ctx, child) => _lightPickerTheme(child!),
    );
    if (picked == null) return;
    final updated = DateTime(
      init.year,
      init.month,
      init.day,
      picked.hour,
      picked.minute,
    );
    setState(() {
      if (isStart)
        _startDate = updated;
      else
        _endDate = updated;
    });
  }

  Widget _lightPickerTheme(Widget child) => Theme(
    data: ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: _primary,
        surface: Colors.white,
      ),
    ),
    child: child,
  );

  Future<bool> _showConfirmDialog(String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFF57C00),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Confirm Schedule',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            content: Text(
              message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Go Back',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes, Continue'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _submit() async {
    setState(() => showDateErrors = true);
    FocusScope.of(context).unfocus();
    nameFocus.unfocus();
    desFocus.unfocus();
    if (!_formKey.currentState!.validate()) return;

    final dateMsg = _dateError;
    if (DateTimeValidator.isBlockingError(dateMsg)) {
      _showError(dateMsg!);
      return;
    }

    // Soft warning (multi-day) — ask for confirmation
    if (dateMsg != null) {
      final confirmed = await _showConfirmDialog(dateMsg);
      if (!confirmed) return;
    }
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    final payload = ActivityPayload(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      activityType: _selectedType.value,
      startDateTime: _toIso(_startDate),
      endDateTime: _toIso(_endDate),
    );

    try {
      final clubId = SharedPreferenceHelper.getClubId();
      if (clubId == null || clubId == "") return;
      var response;

      if (widget.id == null) {
        response = await apiService.addActivities(clubId.toString(), payload);
      } else {
        response = await apiService.updateActivities(
          widget.activityListData!.activityId.toString(),
          payload,
        );
      }

      if (!mounted) return;
      if (response.success == true) {
        _showSuccess();
      } else {
        _showError(response.message ?? "Failed");
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildDateValidationBanner() {
    final error = _dateError;
    final isWarn = error != null && !DateTimeValidator.isBlockingError(error);
    final isError = error != null && DateTimeValidator.isBlockingError(error);
    final isOk = error == null;

    // Only show banner once user has attempted submit, OR always show warnings
    if (!showDateErrors && isError) return const SizedBox.shrink();

    Color bgColor, borderColor, iconColor, textColor;
    IconData icon;

    if (isOk) {
      bgColor = _primary.withOpacity(0.07);
      borderColor = _primary.withOpacity(0.25);
      iconColor = _primary;
      textColor = _primary;
      icon = Icons.check_circle_outline;
    } else if (isWarn) {
      bgColor = const Color(0xFFFFF8E1);
      borderColor = const Color(0xFFFFCC02).withOpacity(0.6);
      iconColor = const Color(0xFFF57C00);
      textColor = const Color(0xFFE65100);
      icon = Icons.info_outline;
    } else {
      bgColor = _red.withOpacity(0.07);
      borderColor = _red.withOpacity(0.3);
      iconColor = _red;
      textColor = _red;
      icon = Icons.error_outline;
    }

    final label = isOk ? 'Duration: $_durationLabel' : error!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: bgColor,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (_) => _SuccessDialog(
        activityName: _nameCtrl.text,
        type: _selectedType,
        id: widget.id,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        _buildTypeSelector(),
                        const SizedBox(height: 24),
                        _buildNameField(),
                        const SizedBox(height: 14),
                        _buildDescField(),
                        const SizedBox(height: 28),
                        _buildSectionLabel('SCHEDULE'),
                        const SizedBox(height: 12),
                        _buildDateTimeCard(isStart: true),
                        const SizedBox(height: 10),
                        _buildDateTimeCard(isStart: false),
                        const SizedBox(height: 12),
                        _buildDurationChip(),
                        const SizedBox(height: 12),

                        _buildDateValidationBanner(),

                        const SizedBox(height: 20),
                        // ── Live payload preview ──────────────────────────
                        //_buildPayloadPreview(),
                        const SizedBox(height: 28),
                        _buildSubmitButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 50,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: _OutlineButton(
          onTap: () => Navigator.maybePop(context),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 15,
            color: _textPrimary,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: _OutlineButton(
            onTap: () {},
            child: const Icon(Icons.more_horiz, size: 18, color: _textPrimary),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 55, bottom: 16),
        title: const Text(
          'New Activity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: _textPrimary,
          ),
        ),
        background: Container(
          color: Colors.white,
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -40,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primary.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'CLUB ADMIN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      color: _primary.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _border),
      ),
    );
  }

  // ── Type Selector ─────────────────────────────────────────────────────────

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('ACTIVITY TYPE'),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ActivityType.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final type = ActivityType.values[i];
              final selected = type == _selectedType;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: selected
                        ? type.color.withOpacity(0.09)
                        : Colors.white,
                    border: Border.all(
                      color: selected ? type.color.withOpacity(0.55) : _border,
                      width: selected ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selected
                            ? type.color.withOpacity(0.12)
                            : Colors.black.withOpacity(0.04),
                        blurRadius: selected ? 12 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: selected ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 220),
                        child: Icon(
                          type.icon,
                          color: selected ? type.color : _textSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? type.color : _textSecondary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Text Fields ───────────────────────────────────────────────────────────

  Widget _buildNameField() => _FieldCard(
    label: 'Activity Name',
    child: TextFormField(
      maxLines: 2,
      controller: _nameCtrl,
      focusNode: nameFocus,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: _fieldDeco('e.g. U19 Practice Session'),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Name is required' : null,
    ),
  );

  Widget _buildDescField() => _FieldCard(
    label: 'Description',
    child: TextFormField(
      focusNode: desFocus,
      controller: _descCtrl,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: _textPrimary, fontSize: 14),
      maxLines: 4,
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Description is required' : null,
      decoration: _fieldDeco('Add details about this activity...'),
    ),
  );

  InputDecoration _fieldDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: _textSecondary.withOpacity(0.4), fontSize: 14),
    border: InputBorder.none,
    contentPadding: EdgeInsets.all(8),
    isDense: true,
  );

  // ── Date-Time Cards ───────────────────────────────────────────────────────

  Widget _buildDateTimeCard({required bool isStart}) {
    final dt = isStart ? _startDate : _endDate;
    final label = isStart ? 'Starts' : 'Ends';
    final accent = isStart ? _primary : _red;
    final error = _dateError;
    final hasErr =
        showDateErrors &&
        error != null &&
        DateTimeValidator.isBlockingError(error);

    // Highlight both cards on error, only end card on "end before start" type errors
    final highlightBorder = hasErr ? _red.withOpacity(0.5) : _border;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: highlightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: accent.withOpacity(0.1),
              ),
              child: Icon(
                isStart
                    ? Icons.play_circle_outline
                    : Icons.stop_circle_outlined,
                color: accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatDisplay(dt),
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _SmallAction(
                  label: 'Date',
                  icon: Icons.calendar_today_outlined,
                  onTap: () => _pickDate(isStart),
                ),
                const SizedBox(width: 8),
                _SmallAction(
                  label: 'Time',
                  icon: Icons.access_time_outlined,
                  onTap: () => _pickTime(isStart),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChip() {
    final valid = _endDate.isAfter(_startDate);
    return Row(
      children: [
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: valid ? _primary.withOpacity(0.08) : _red.withOpacity(0.08),
            border: Border.all(
              color: valid
                  ? _primary.withOpacity(0.25)
                  : _red.withOpacity(0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                valid ? Icons.timelapse : Icons.warning_amber_rounded,
                size: 14,
                color: valid ? _primary : _red,
              ),
              const SizedBox(width: 6),
              Text(
                valid ? 'Duration: $_durationLabel' : 'Invalid time range',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valid ? _primary : _red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Payload Preview ───────────────────────────────────────────────────────

  Widget _buildPayloadPreview() {
    final payload = ActivityPayload(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      activityType: _selectedType.value,
      startDateTime: _toIso(_startDate),
      endDateTime: _toIso(_endDate),
    );

    final json = payload.toJson();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF0FBF5),
        border: Border.all(color: _primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Icon(
                  Icons.data_object_rounded,
                  size: 14,
                  color: _primary.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  'REQUEST PAYLOAD',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: _primary.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: _primary.withOpacity(0.12),
                  ),
                  child: Text(
                    'POST /activities',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFD1EAD9)),
          const SizedBox(height: 10),
          // Fields
          ...json.entries.map((e) => _payloadRow(e.key, e.value.toString())),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _payloadRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '"$key"',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primary.withOpacity(0.8),
                fontFamily: 'Courier',
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontSize: 12,
              color: _textSecondary,
              fontFamily: 'Courier',
            ),
          ),
          Expanded(
            child: Text(
              '"$value"',
              style: const TextStyle(
                fontSize: 12,
                color: _textPrimary,
                fontFamily: 'Courier',
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit Button ─────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _isSubmitting ? _primary.withOpacity(0.5) : _primary,
          boxShadow: _isSubmitting
              ? []
              : [
                  BoxShadow(
                    color: _primary.withOpacity(0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isSubmitting ? null : _submit,
            splashColor: Colors.white24,
            child: Center(
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.id != null
                              ? "Update Activity"
                              : 'Create Activity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Shared ────────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
      color: _textSecondary,
    ),
  );
}

// ─── Reusable Widgets ───────────────────────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    ),
  );
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EB)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: const Color(0xFF1B8C4E).withOpacity(0.75),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF3F4F6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF6B7280)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Success Dialog ─────────────────────────────────────────────────────────

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog({
    required this.activityName,
    required this.type,
    this.id,
  });

  final String activityName;
  final ActivityType type;
  final int? id;

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  static const Color _primary = Color(0xFF1B8C4E);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primary.withOpacity(0.1),
                  border: Border.all(
                    color: _primary.withOpacity(0.35),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: _primary,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.id != null ? "Activity updated" : 'Activity Created!',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.activityName,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: widget.type.color.withOpacity(0.1),
                border: Border.all(color: widget.type.color.withOpacity(0.3)),
              ),
              child: Text(
                widget.type.label,
                style: TextStyle(
                  color: widget.type.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class DateTimeValidator {
  static const int _maxDurationDays = 30;
  static const int _minDurationMins = 5;
  static const int _maxAdvanceMonths = 24;

  /// Returns a non-null error string for the FIRST failing rule, or null if valid.
  static String? validate({
    required DateTime start,
    required DateTime end,
    DateTime? now,
  }) {
    final _now = now ?? DateTime.now();

    // ── Start date rules ──────────────────────────────────────────────────

    // 1. Start must not be in the past (allow up to 1 minute grace)
    if (start.isBefore(_now.subtract(const Duration(minutes: 1)))) {
      return 'Start time cannot be in the past.';
    }

    // 2. Start must not be too far in the future
    final maxFuture = DateTime(
      _now.year,
      _now.month + _maxAdvanceMonths,
      _now.day,
    );
    if (start.isAfter(maxFuture)) {
      return 'Start date cannot be more than $_maxAdvanceMonths months in the future.';
    }

    // ── End date rules ────────────────────────────────────────────────────

    // 3. End must not equal start
    if (end.isAtSameMomentAs(start)) {
      return 'End time cannot be the same as start time.';
    }

    // 4. End must be after start
    if (end.isBefore(start)) {
      return 'End time must be after start time.';
    }

    // ── Duration rules ────────────────────────────────────────────────────

    final duration = end.difference(start);

    // 5. Minimum duration
    if (duration.inMinutes < _minDurationMins) {
      return 'Activity must be at least $_minDurationMins minutes long.';
    }

    // 6. Maximum duration
    if (duration.inDays >= _maxDurationDays) {
      return 'Activity cannot span more than $_maxDurationDays days.';
    }

    // ── Same-day check ────────────────────────────────────────────────────

    // 7. Warn if end date falls on a different calendar day (multi-day)
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    if (endDay.isAfter(startDay)) {
      final days = endDay.difference(startDay).inDays;
      return 'This activity spans $days day${days > 1 ? 's' : ''}. Confirm this is correct.';
    }

    return null; // ✅ all good
  }

  /// Returns only errors that should block submission (excludes soft warnings).
  static bool isBlockingError(String? message) {
    if (message == null) return false;
    // Multi-day span is a soft warning — allow submission
    if (message.startsWith('This activity spans')) return false;
    return true;
  }
}
