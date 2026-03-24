import 'package:flutter/material.dart';

class AppUI {
  static void showMessage(
      BuildContext context, {
        required String message,
        Color? backgroundColor,
        Color textColor = Colors.white,
        Duration duration = const Duration(seconds: 3),
        bool isSuccess = false,
        bool isError = false,
        bool isWarning = false,
        bool isInfo = false,
      }) {
    Color bgColor = backgroundColor ??
        (isError
            ? Colors.red.shade700
            : isSuccess
            ? Colors.green.shade700
            : isWarning
            ? Colors.orange.shade800
            : isInfo
            ? Colors.blue.shade700
            : Colors.grey.shade800);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor, fontSize: 15)),
        backgroundColor: bgColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 6,
      ),
    );
  }

  static void success(BuildContext context, String msg) => showMessage(context, message: msg, isSuccess: true);
  static void error(BuildContext context, String msg) => showMessage(context, message: msg, isError: true);
  static void warning(BuildContext context, String msg) => showMessage(context, message: msg, isWarning: true);
  static void info(BuildContext context, String msg) => showMessage(context, message: msg, isInfo: true);

  // ────────────────────────────────────────────────
  // Easy Circular Progress Indicator
  // ────────────────────────────────────────────────

  /// Show full-screen loading overlay (easy to call)
  static void showLoading(
      BuildContext context, {
        String? message = "Loading...",
        Color? color,
        bool barrierDismissible = false,
      }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => _LoadingOverlay(
        message: message,
        color: color ?? Theme.of(context).primaryColor,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Hide the loading overlay
  static void hideLoading(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
  static Widget buttonSpinner({
    double size = 24.0,
    double strokeWidth = 2.5,
    Color color = Colors.white,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
  /// Small circular loader (perfect for buttons)
  static Widget buttonLoader({
    Color? color,
    double size = 24.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Theme.of(WidgetsBinding.instance.rootElement!).primaryColor),
        strokeWidth: 2.8,
      ),
    );
  }

  /// Customizable progress widget (if you need it directly)
  static Widget progress({
    required BuildContext context,
    Color? color,
    double size = 48.0,
    String? message,
    bool isSmall = false,
  }) {
    final effectiveColor = color ?? Theme.of(context).primaryColor;

    final indicator = SizedBox(
      width: isSmall ? 24 : size,
      height: isSmall ? 24 : size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
        strokeWidth: isSmall ? 2.8 : 4.0,
      ),
    );

    return message != null
        ? Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(height: 12),
        Text(
          message,
          style: TextStyle(color: effectiveColor, fontWeight: FontWeight.w500),
        ),
      ],
    )
        : indicator;
  }
}

// Internal overlay widget (used by showLoading)
class _LoadingOverlay extends StatelessWidget {
  final String? message;
  final Color color;
  final bool barrierDismissible;

  const _LoadingOverlay({
    this.message,
    required this.color,
    required this.barrierDismissible,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => barrierDismissible,
      child: Material(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeWidth: 4.0,
                ),
                if (message != null && message!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    message!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class EventDateTimeValidator {
  static const int _minDurationMins = 5;
  static const int _maxDurationHours = 12; // events rarely run >12 h in a day
  static const int _maxAdvanceDays = 365;

  /// Combines a [date] and a [TimeOfDay] into a [DateTime].
  static DateTime combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  /// Returns an error string for the FIRST failing rule, or null when valid.
  static String? validate({
    required DateTime? date,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    DateTime? now,
  }) {
    final _now = now ?? DateTime.now();

    // ── Presence checks ───────────────────────────────────────────────────
    if (date == null) return 'Please select an event date.';
    if (startTime == null) return 'Please select a start time.';
    if (endTime == null) return 'Please select an end time.';

    final start = combine(date, startTime);
    final end = combine(date, endTime);

    // ── Date range ────────────────────────────────────────────────────────

    // 1. Date must not be in the past (allow today)
    final today = DateTime(_now.year, _now.month, _now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    if (eventDay.isBefore(today)) {
      return 'Event date cannot be in the past.';
    }

    // 2. Date must not be too far in the future
    final maxFuture = today.add(Duration(days: _maxAdvanceDays));
    if (eventDay.isAfter(maxFuture)) {
      return 'Event date cannot be more than $_maxAdvanceDays days in the future.';
    }

    // 3. If today, start time must not already be past (1-min grace)
    if (eventDay == today &&
        start.isBefore(_now.subtract(const Duration(minutes: 1)))) {
      return 'Start time cannot be in the past for today\'s event.';
    }

    // ── Time ordering ─────────────────────────────────────────────────────

    // 4. End must not equal start
    if (start == end) {
      return 'End time cannot be the same as start time.';
    }

    // 5. End must be after start
    if (end.isBefore(start)) {
      return 'End time must be after start time.';
    }

    // ── Duration rules ────────────────────────────────────────────────────
    final duration = end.difference(start);

    // 6. Minimum duration
    if (duration.inMinutes < _minDurationMins) {
      return 'Event must be at least $_minDurationMins minutes long.';
    }

    // 7. Maximum duration (soft warning — not blocking)
    if (duration.inHours >= _maxDurationHours) {
      final h = duration.inHours;
      return 'This event is $h hours long. Confirm this is correct.';
    }

    return null; // ✅ all valid
  }

  /// Soft warnings show a confirm dialog; hard errors block submission.
  static bool isBlockingError(String? message) {
    if (message == null) return false;
    if (message.startsWith('This event is')) return false; // soft warning
    return true;
  }

  /// Human-readable duration label, e.g. "2h 30m".
  static String durationLabel(DateTime date, TimeOfDay start, TimeOfDay end) {
    final s = combine(date, start);
    final e = combine(date, end);
    if (e.isBefore(s) || e == s) return '--';
    final diff = e.difference(s);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
