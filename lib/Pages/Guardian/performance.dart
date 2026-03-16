// lib/pages/guardian/guardian_metrics.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../config/colors.dart';

class GuardianMetricsScreen extends StatefulWidget {
  const GuardianMetricsScreen({super.key});

  @override
  State<GuardianMetricsScreen> createState() => _GuardianMetricsScreenState();
}

class _GuardianMetricsScreenState extends State<GuardianMetricsScreen> {
  late Future<MetricsSummary> _summaryFuture;
  late Future<List<CoachNote>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _fetchMetricsSummary();
    _notesFuture = _fetchCoachNotes();
  }

  Future<MetricsSummary> _fetchMetricsSummary() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return MetricsSummary(
      attendancePercentage: 94,
      present: 47,
      totalSessions: 50,
      totalEvents: 12,
      activitiesCount: 2,
      currentStreak: 5,
    );
  }

  Future<List<CoachNote>> _fetchCoachNotes() async {
    await Future.delayed(const Duration(milliseconds: 900));
    return [
      CoachNote(
        date: DateTime.now().subtract(const Duration(days: 3)),
        note: "Excellent ball control today. Keep building on that confidence!",
        category: "Positive",
      ),
      CoachNote(
        date: DateTime.now().subtract(const Duration(days: 7)),
        note: "Good effort in defense, but needs to be quicker in transitions.",
        category: "Constructive",
      ),
      CoachNote(
        date: DateTime.now().subtract(const Duration(days: 14)),
        note: "Strong performance in the match – great assist!",
        category: "Highlight",
      ),
      CoachNote(
        date: DateTime.now().subtract(const Duration(days: 21)),
        note: "Work on left-foot finishing in training sessions.",
        category: "Improvement Area",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _summaryFuture = _fetchMetricsSummary();
              _notesFuture = _fetchCoachNotes();
            });
          },
          color: accentGreen,
          child: Column(
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
                          "Metrics",
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

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      24.height,

                      FutureBuilder<MetricsSummary>(
                        future: _summaryFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[200]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 180.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                            );
                          }

                          final summary = snapshot.data ?? MetricsSummary.empty();

                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [accentGreen.withOpacity(0.9), accentGreen.withOpacity(0.7)],
                              ),
                              borderRadius: BorderRadius.circular(24.r),
                              boxShadow: [
                                BoxShadow(
                                  color: accentGreen.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Season Overview",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white70,
                                  ),
                                ),
                                12.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStatItem(
                                      "Attendance",
                                      "${summary.attendancePercentage}%",
                                      "${summary.present}/${summary.totalSessions} sessions",
                                      Colors.white,
                                    ),
                                    _buildStatItem(
                                      "Events",
                                      "${summary.totalEvents}",
                                      "participated",
                                      Colors.white,
                                    ),
                                  ],
                                ),
                                16.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStatItem(
                                      "Activities",
                                      "${summary.activitiesCount}",
                                      "enrolled",
                                      Colors.white,
                                    ),
                                    _buildStatItem(
                                      "Streak",
                                      "${summary.currentStreak}",
                                      "days",
                                      Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      28.height,

                      Text(
                        "Coach Notes",
                        style: GoogleFonts.montserrat(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      16.height,

                      FutureBuilder<List<CoachNote>>(
                        future: _notesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Column(
                              children: List.generate(
                                3,
                                    (_) => Padding(
                                  padding: EdgeInsets.only(bottom: 16.h),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[200]!,
                                    highlightColor: Colors.grey[300]!,
                                    child: Container(
                                      height: 50.h,
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

                          final notes = snapshot.data ?? [];

                          if (notes.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.h),
                                child: Column(
                                  children: [
                                    Icon(Icons.notes_rounded, size: 60.sp, color: Colors.grey[600]),
                                    16.height,
                                    Text(
                                      "No coach notes yet",
                                      style: GoogleFonts.poppins(fontSize: 16.sp, color: textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: notes.map((note) => _CoachNoteCard(note: note)).toList(),
                          );
                        },
                      ),

                      100.height,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String mainValue, String subValue, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.white70),
        ),
        4.height,
        Text(
          mainValue,
          style: GoogleFonts.montserrat(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          subValue,
          style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70),
        ),
      ],
    );
  }
}

// Coach Note Card
class _CoachNoteCard extends StatelessWidget {
  final CoachNote note;

  const _CoachNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final isPositive = note.category == "Positive" || note.category == "Highlight";
    final color = isPositive ? accentGreen : accentOrange;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(note.date),
                style: GoogleFonts.poppins(fontSize: 13.sp, color: textSecondary),
              ),
            ],
          ),
          8.height,
          Text(
            note.note,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
            ),
          ),
          12.height,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              note.category,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Models
class MetricsSummary {
  final int attendancePercentage;
  final int present;
  final int totalSessions;
  final int totalEvents;
  final int activitiesCount;
  final int currentStreak;

  MetricsSummary({
    required this.attendancePercentage,
    required this.present,
    required this.totalSessions,
    required this.totalEvents,
    required this.activitiesCount,
    required this.currentStreak,
  });

  factory MetricsSummary.empty() => MetricsSummary(
    attendancePercentage: 0,
    present: 0,
    totalSessions: 0,
    totalEvents: 0,
    activitiesCount: 0,
    currentStreak: 0,
  );
}

class CoachNote {
  final DateTime date;
  final String note;
  final String category;

  CoachNote({
    required this.date,
    required this.note,
    required this.category,
  });
}