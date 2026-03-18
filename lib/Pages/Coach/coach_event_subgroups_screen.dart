// lib/screens/coach/coach_event_subgroups_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/getSubGroups.dart';
import '../../utills/api_service.dart';
import 'coach_event_teams_screen.dart';

class CoachEventSubGroupsScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  final String eventName;

  const CoachEventSubGroupsScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.eventName,
  });

  @override
  State<CoachEventSubGroupsScreen> createState() =>
      _CoachEventSubGroupsScreenState();
}

class _CoachEventSubGroupsScreenState
    extends State<CoachEventSubGroupsScreen> {
  final ClubApiService _api = ClubApiService();
  late Future<GetSubGroups> _subGroupsFuture;

  @override
  void initState() {
    super.initState();
    _subGroupsFuture = _api.getSubGroups(widget.groupId);
  }

  void _refresh() {
    setState(() {
      _subGroupsFuture = _api.getSubGroups(widget.groupId);
    });
  }

  // ── Navigate to Create Sub-Group page ─────────────────────────────────────
  void _openCreatePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SubGroupFormPage(
          groupId: widget.groupId,
          groupName: widget.groupName,
          eventName: widget.eventName,
        ),
      ),
    ).then((created) {
      if (created == true) _refresh();
    });
  }

  // ── Navigate to Edit Sub-Group page ───────────────────────────────────────
  void _openEditPage(SubGroupData sg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SubGroupFormPage(
          groupId: widget.groupId,
          groupName: widget.groupName,
          eventName: widget.eventName,
          existing: sg,
        ),
      ),
    ).then((updated) {
      if (updated == true) _refresh();
    });
  }

  // ── Delete confirmation ────────────────────────────────────────────────────
  void _confirmDelete(SubGroupData sg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          "Delete Sub-Group",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${sg.name}"?\nThis action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success =
              await _api.deleteSubGroup(widget.groupId, sg.subGroupId!);
              if (success) {
                _refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Sub-Group deleted"),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Delete failed. Please try again."),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child:
            Text("Delete", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePage,
        backgroundColor: accentOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Create Sub-Group",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ),
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
                padding:
                EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sub-Groups",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.groupName,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: Colors.white60,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: FutureBuilder<GetSubGroups>(
              future: _subGroupsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red, size: 40.sp),
                        12.height,
                        Text("Failed to load sub-groups",
                            style:
                            GoogleFonts.poppins(color: Colors.grey)),
                        12.height,
                        ElevatedButton(
                            onPressed: _refresh,
                            child: const Text("Retry")),
                      ],
                    ),
                  );
                }

                final subGroups = snapshot.data?.data ?? [];
                if (subGroups.isEmpty) {
                  return Center(
                    child: Text(
                      "No sub-groups found",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  color: accentOrange,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 90.h),
                    itemCount: subGroups.length,
                    itemBuilder: (_, i) {
                      final sg = subGroups[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CoachEventTeamsScreen(
                                subGroupId: sg.subGroupId!,
                                subGroupName: sg.name ?? 'Sub-Group',
                                eventName: widget.eventName,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                                color: accentOrange.withOpacity(0.3),
                                width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: accentOrange.withOpacity(0.12),
                                  borderRadius:
                                  BorderRadius.circular(12.r),
                                ),
                                child: Icon(Icons.groups_2_rounded,
                                    color: accentOrange, size: 24.sp),
                              ),
                              14.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sg.name ?? '',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                      Text(
                                        sg.description ?? "",
                                        style: GoogleFonts.poppins(
                                            fontSize: 12.sp,
                                            color: Colors.grey.shade600),
                                      ),
                                    if (sg.ageCategory != null &&
                                        sg.ageCategory!.isNotEmpty)
                                      Container(
                                        margin: EdgeInsets.only(top: 4.h),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color:
                                          accentOrange.withOpacity(0.12),
                                          borderRadius:
                                          BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          sg.ageCategory!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 10.sp,
                                            color: accentOrange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Edit & Delete icons
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => _openEditPage(sg),
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.08),
                                        borderRadius:
                                        BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(Icons.edit_rounded,
                                          color: Colors.blue.shade400,
                                          size: 18.sp),
                                    ),
                                  ),
                                  8.width,
                                  GestureDetector(
                                    onTap: () => _confirmDelete(sg),
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.08),
                                        borderRadius:
                                        BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(Icons.delete_rounded,
                                          color: Colors.red.shade400,
                                          size: 18.sp),
                                    ),
                                  ),
                                  8.width,
                                  Icon(Icons.chevron_right_rounded,
                                      color: Colors.grey.shade400),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Sub-Group Form Page — used for both Create and Edit
// ═════════════════════════════════════════════════════════════════════════════
class _SubGroupFormPage extends StatefulWidget {
  final int groupId;
  final String groupName;
  final String eventName;
  final SubGroupData? existing;

  const _SubGroupFormPage({
    required this.groupId,
    required this.groupName,
    required this.eventName,
    this.existing,
  });

  @override
  State<_SubGroupFormPage> createState() => _SubGroupFormPageState();
}

class _SubGroupFormPageState extends State<_SubGroupFormPage> {
  final ClubApiService _api = ClubApiService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCatCtrl;
  bool _loading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _ageCatCtrl =
        TextEditingController(text: widget.existing?.ageCategory ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCatCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    bool success;
    if (_isEdit) {
      success = await _api.updateSubGroup(
        widget.groupId,
        widget.existing!.subGroupId!,
        {
          "name": _nameCtrl.text.trim(),
          "ageCategory": _ageCatCtrl.text.trim(),
          "status": "ACTIVE",
        },
      );
    } else {
      success = await _api.createSubGroup(
        widget.groupId,
        {
          "name": _nameCtrl.text.trim(),
          "ageCategory": _ageCatCtrl.text.trim(),
        },
      );
    }

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit
              ? "Sub-Group updated successfully"
              : "Sub-Group created successfully"),
          backgroundColor: accentOrange,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Operation failed. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                padding:
                EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEdit ? "Edit Sub-Group" : "Create Sub-Group",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.groupName,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: Colors.white60,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form body
          Expanded(
            child: SingleChildScrollView(
              padding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sub-Group Details",
                            style: GoogleFonts.montserrat(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          16.height,

                          // Name field
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: "Sub-Group Name *",
                              labelStyle:
                              GoogleFonts.poppins(fontSize: 13.sp),
                              hintText: "e.g. Girls, Boys",
                              hintStyle: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: accentOrange, width: 2),
                              ),
                              prefixIcon: Icon(Icons.groups_2_rounded,
                                  color: accentOrange),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            style: GoogleFonts.poppins(fontSize: 14.sp),
                            validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? "Sub-group name is required"
                                : null,
                          ),
                          16.height,

                          // Age Category field
                          TextFormField(
                            controller: _ageCatCtrl,
                            decoration: InputDecoration(
                              labelText: "Age Category *",
                              labelStyle:
                              GoogleFonts.poppins(fontSize: 13.sp),
                              hintText: "e.g. U18, U22",
                              hintStyle: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: accentOrange, width: 2),
                              ),
                              prefixIcon: Icon(Icons.category_rounded,
                                  color: accentOrange),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            style: GoogleFonts.poppins(fontSize: 14.sp),
                            validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? "Age category is required"
                                : null,
                          ),
                        ],
                      ),
                    ),

                    32.height,

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                            : Text(
                          _isEdit
                              ? "Update Sub-Group"
                              : "Create Sub-Group",
                          style: GoogleFonts.montserrat(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}