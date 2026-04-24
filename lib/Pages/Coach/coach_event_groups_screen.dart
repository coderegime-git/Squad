// lib/screens/coach/coach_event_groups_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../config/colors.dart';
import '../../model/clubAdmin/get_groups.dart';
import '../../utills/api_service.dart';
import 'coach_event_subgroups_screen.dart';

class CoachEventGroupsScreen extends StatefulWidget {
  final int eventId;
  final String eventName;

  const CoachEventGroupsScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<CoachEventGroupsScreen> createState() => _CoachEventGroupsScreenState();
}

class _CoachEventGroupsScreenState extends State<CoachEventGroupsScreen> {
  final ClubApiService _api = ClubApiService();
  late Future<GetGroups> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _api.getGroupsByEvent(widget.eventId);
  }

  void _refresh() {
    setState(() {
      _groupsFuture = _api.getGroupsByEvent(widget.eventId);
    });
  }

  // ── Navigate to Create Group page ─────────────────────────────────────────
  void _openCreateGroupPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GroupFormPage(
          eventId: widget.eventId,
          eventName: widget.eventName,
        ),
      ),
    ).then((created) {
      if (created == true) _refresh();
    });
  }

  // ── Navigate to Edit Group page ───────────────────────────────────────────
  void _openEditGroupPage(GroupData group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GroupFormPage(
          eventId: widget.eventId,
          eventName: widget.eventName,
          existing: group,
        ),
      ),
    ).then((updated) {
      if (updated == true) _refresh();
    });
  }

  // ── Delete confirmation dialog ────────────────────────────────────────────
  void _confirmDelete(GroupData group) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Delete Group",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${group.name}"?\nThis action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await _api.deleteGroup(
                widget.eventId,
                group.groupId!,
              );
              if (success) {
                _refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Group deleted"),
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
            child: Text(
              "Delete",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
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
        onPressed: _openCreateGroupPage,
        backgroundColor: accentGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Create Group",
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
            //height: 85.h,
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
                padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Groups",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            widget.eventName,
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
            child: FutureBuilder<GetGroups>(
              future: _groupsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40.sp,
                        ),
                        12.height,
                        Text(
                          "Failed to load groups",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                        12.height,
                        ElevatedButton(
                          onPressed: _refresh,
                          child:  Text("Retry",style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),),
                        ),
                      ],
                    ),
                  );
                }

                final groups = snapshot.data?.data ?? [];
                if (groups.isEmpty) {
                  return Center(
                    child: Text(
                      "No groups found for this event",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  color: accentGreen,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 90.h),
                    itemCount: groups.length,
                    itemBuilder: (_, i) {
                      final group = groups[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CoachEventSubGroupsScreen(
                                groupId: group.groupId!,
                                groupName: group.name ?? 'Group',
                                eventName: widget.eventName,
                                eventId: widget.eventId,
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
                              color: accentGreen.withOpacity(0.3),
                              width: 1.2,
                            ),
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
                                  color: accentGreen.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.group_rounded,
                                  color: accentGreen,
                                  size: 24.sp,
                                ),
                              ),
                              14.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group.name ?? '',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (group.description.isNotEmpty)
                                      Text(
                                        group.description,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          color: Colors.grey.shade600,
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
                                    onTap: () => _openEditGroupPage(group),
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.edit_rounded,
                                        color: Colors.blue.shade400,
                                        size: 18.sp,
                                      ),
                                    ),
                                  ),
                                  8.width,
                                  GestureDetector(
                                    onTap: () => _confirmDelete(group),
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.delete_rounded,
                                        color: Colors.red.shade400,
                                        size: 18.sp,
                                      ),
                                    ),
                                  ),
                                  8.width,
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey.shade400,
                                  ),
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
// Group Form Page — used for both Create and Edit
// ═════════════════════════════════════════════════════════════════════════════
class _GroupFormPage extends StatefulWidget {
  final int eventId;
  final String eventName;
  final GroupData? existing; // null = create, non-null = edit

  const _GroupFormPage({
    required this.eventId,
    required this.eventName,
    this.existing,
  });

  @override
  State<_GroupFormPage> createState() => _GroupFormPageState();
}

class _GroupFormPageState extends State<_GroupFormPage> {
  final ClubApiService _api = ClubApiService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  bool _loading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _descCtrl = TextEditingController(text: widget.existing?.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    bool success;
    if (_isEdit) {
      success = await _api
          .updateGroup(widget.eventId, widget.existing!.groupId!, {
            "name": _nameCtrl.text.trim(),
            "description": _descCtrl.text.trim(),
            "status": "ACTIVE",
          });
    } else {
      success = await _api.createGroup(widget.eventId, {
        "name": _nameCtrl.text.trim(),
        "description": _descCtrl.text.trim(),
      });
    }

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? "Group updated successfully"
                : "Group created successfully",
          ),
          backgroundColor: accentGreen,
        ),
      );
      Navigator.pop(context, true); // true = refresh list
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
          // Header — same style as list screen
          Container(
           // height: 85.h,
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
                padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEdit ? "Edit Group" : "Create Group",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            widget.eventName,
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
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card wrapper
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
                            "Group Details",
                            style: GoogleFonts.montserrat(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          16.height,

                          // Group Name
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: "Group Name *",
                              labelStyle: GoogleFonts.poppins(fontSize: 13.sp),
                              hintText: "e.g. Under 19",
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: accentGreen,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.group_rounded,
                                color: accentGreen,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            style: GoogleFonts.poppins(fontSize: 14.sp),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? "Group name is required"
                                : null,
                          ),
                          16.height,

                          // Description
                          TextFormField(
                            controller: _descCtrl,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: "Description",
                              labelStyle: GoogleFonts.poppins(fontSize: 13.sp),
                              hintText: "e.g. Group for U19 category",
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: accentGreen,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.description_rounded,
                                color: accentGreen,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            style: GoogleFonts.poppins(fontSize: 14.sp),
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
                          backgroundColor: accentGreen,
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
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _isEdit ? "Update Group" : "Create Group",
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
