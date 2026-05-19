// lib/screens/coach/coach_member_profile_screen.dart
//
// Full member profile (read-only admin details) +
// Performance tab: comments + PDF upload/view (connected to real API)

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_filex/open_filex.dart';

import '../../config/colors.dart';
import '../../model/member_document.dart';
import '../../utills/api_service.dart';

class CoachMemberProfileScreen extends StatefulWidget {
  final int memberId;
  final String memberName;
  final String memberEmail;
  final Map<String, dynamic> memberData;

  const CoachMemberProfileScreen({
    super.key,
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    required this.memberData,
  });

  @override
  State<CoachMemberProfileScreen> createState() =>
      _CoachMemberProfileScreenState();
}

class _CoachMemberProfileScreenState extends State<CoachMemberProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // API services
  final CoachApiService _coachApi = CoachApiService();
  final DocumentApiService _docApi = DocumentApiService();

  // Profile data
  Map<String, dynamic>? _memberDetail;
  bool _isLoadingProfile = true;

  // Performance / comments
  final TextEditingController _commentCtrl = TextEditingController();
  File? _selectedFile;               // ← NEW
  bool _isSubmittingReport = false;  // ← NEW

  // Documents
  List<MemberDocument> _documents = [];
  bool _isLoadingDocs = false;
  final Map<int, bool> _downloadingDocs = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDocuments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);
    try {
      final member =
      await _coachApi.getMemberDetails(0, widget.memberId);
      setState(() {
        _memberDetail = member != null
            ? {
          'username': member.username,
          'email': member.email,
          'gender': member.gender,
          'dob': member.dob,
          'medicalNotes': member.medicalNotes,
          'memberId': member.memberId,
        }
            : null;
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoadingDocs = true);
    try {
      final docs = await _docApi.getDocuments(memberId: widget.memberId);
      setState(() {
        _documents = docs;
        _isLoadingDocs = false;
      });
    } catch (e) {
      setState(() => _isLoadingDocs = false);
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      final sizeInMb = file.lengthSync() / (1024 * 1024);
      if (sizeInMb > 5) {
        toast('File too large. Max 5MB allowed.');
        return;
      }

      setState(() {
        _selectedFile = file;
      });
    } catch (e) {
      toast('Error picking file');
    }
  }

  void _removeSelectedFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _submitReport() async {
    final description = _commentCtrl.text.trim();

    if (description.isEmpty) {
      toast('Please enter a description / report comment');
      return;
    }

    if (_selectedFile == null) {
      toast('Please select a PDF file');
      return;
    }

    setState(() => _isSubmittingReport = true);

    try {
      final success = await _docApi.uploadDocument(
        memberId: widget.memberId,
        file: _selectedFile!,
        description: description,
      );

      if (success) {
        toast('Report submitted successfully!', bgColor: accentGreen);
        _commentCtrl.clear();
        _selectedFile = null;
        _loadDocuments();
      } else {
        toast('Failed to submit report. Try again.');
      }
    } catch (e) {
      toast('Error: ${e.toString()}');
    } finally {
      setState(() => _isSubmittingReport = false);
    }
  }

  Future<void> _downloadAndOpenDoc(MemberDocument doc) async {
    setState(() => _downloadingDocs[doc.documentId] = true);
    try {
      final path = await _docApi.downloadDocument(
        documentId: doc.documentId,
        memberId: widget.memberId,
        fileName: doc.fileName,
      );
      setState(() => _downloadingDocs[doc.documentId] = false);

      if (path == null) {
        toast('Download failed');
        return;
      }

      if (!mounted) return;
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        toast('Cannot open file. No PDF viewer installed.');
      }
    } catch (e) {
      setState(() => _downloadingDocs[doc.documentId] = false);
      toast('Error downloading document');
    }
  }
  void _showDocumentOptions(String filePath, String fileName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r))),
              ),
              16.height,
              Text(fileName,
                  style: GoogleFonts.montserrat(
                      fontSize: 15.sp, fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              20.height,

              _docOptionTile(
                icon: Icons.visibility_rounded,
                color: Colors.deepPurple,
                title: 'Open in PDF Viewer',
                subtitle: 'View the document in-app',
                onTap: () async {
                  Navigator.pop(context);
                  final result = await OpenFilex.open(filePath);
                  if (result.type != ResultType.done) {
                    toast('Cannot open file. No PDF viewer installed.');
                  }
                },
              ),
              12.height,

              _docOptionTile(
                icon: Icons.download_rounded,
                color: accentGreen,
                title: 'Save to Downloads',
                subtitle: 'Save a copy to your device',
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final downloadsDir =
                    Directory('/storage/emulated/0/Download');
                    if (!downloadsDir.existsSync()) {
                      downloadsDir.createSync(recursive: true);
                    }
                    final dest = File('${downloadsDir.path}/$fileName');
                    await File(filePath).copy(dest.path);
                    toast('Saved to Downloads/$fileName',
                        bgColor: accentGreen);
                  } catch (e) {
                    print("Document download failed ${e}");
                    toast('Could not save to Downloads');
                  }
                },
              ),
              16.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _docOptionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            14.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14.sp, color: Colors.grey),
          ],
        ),
      ),
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
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: 5.h, left: 20.w, right: 20.w, bottom: 4.h),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white),
                        ),
                        16.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.memberName,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              Text(widget.memberEmail,
                                  style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      color: Colors.white60)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: accentGreen,
                    labelColor: accentGreen,
                    unselectedLabelColor: Colors.grey.shade400,
                    labelStyle: GoogleFonts.poppins(
                        fontSize: 13.sp, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Profile'),
                      Tab(text: 'Performance'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildPerformanceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Profile Tab (Unchanged)
  Widget _buildProfileTab() {
    final m = widget.memberData;
    final name = m['name'] ?? m['username'] ?? widget.memberName;
    final email = m['email'] ?? widget.memberEmail;
    final memberId = m['memberId'] ?? m['id'] ?? widget.memberId;
    final mobile = m['mobile'] ?? m['phone'] ?? '-';
    final gender = m['gender'] ?? '-';
    final dob = m['dob'] ?? m['dateOfBirth'] ?? '-';
    final medicalNotes = m['medicalNotes'] ?? m['medical_notes'] ?? '';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36.r,
                  backgroundColor: accentGreen.withOpacity(0.15),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: GoogleFonts.montserrat(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: accentGreen),
                  ),
                ),
                12.height,
                Text(name,
                    style: GoogleFonts.montserrat(
                        fontSize: 18.sp, fontWeight: FontWeight.w700)),
                4.height,
                Text(email,
                    style: GoogleFonts.poppins(
                        fontSize: 13.sp, color: Colors.grey.shade500)),
              ],
            ),
          ),
          16.height,
          _infoCard('Personal Information', [
            _row('Member ID', '#$memberId'),
            _row('Mobile', mobile),
            _row('Gender', gender),
            _row('Date of Birth', dob),
          ]),
          16.height,
          _infoCard('Medical Notes', [],
              customChild: Text(
                medicalNotes.isNotEmpty
                    ? medicalNotes
                    : 'No medical notes on record',
                style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: medicalNotes.isNotEmpty
                        ? Colors.black87
                        : Colors.grey),
              )),
        ],
      ),
    );
  }

  // Updated Performance Tab
  Widget _buildPerformanceTab() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit Performance Report',
                style: GoogleFonts.montserrat(
                    fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
              12.height,

              // Description
              TextField(
                controller: _commentCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write performance comment / report description...',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 13.sp, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide:
                      const BorderSide(color: accentGreen, width: 1.5)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                style: GoogleFonts.poppins(fontSize: 13.sp),
              ),
              16.height,

              // File Picker
              GestureDetector(
                onTap: _pickPdf,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border:
                    Border.all(color: Colors.deepPurple.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.upload_file_rounded,
                          color: Colors.deepPurple, size: 28.sp),
                      12.width,
                      Expanded(
                        child: Text(
                          _selectedFile == null
                              ? 'Tap to select PDF (Max 5MB)'
                              : 'Selected: ${_selectedFile!.path.split('/').last}',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: _selectedFile == null
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (_selectedFile != null)
                        GestureDetector(
                          onTap: _removeSelectedFile,
                          child: const Icon(Icons.close_rounded,
                              color: Colors.red, size: 22),
                        ),
                    ],
                  ),
                ),
              ),
              20.height,

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmittingReport ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  icon: _isSubmittingReport
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded, size: 20),
                  label: Text(
                    'Submit Report',
                    style: GoogleFonts.poppins(
                        fontSize: 15.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: _isLoadingDocs
              ? Center(
              child: CircularProgressIndicator(color: accentGreen))
              : _documents.isEmpty
              ? _emptyDocs()
              : RefreshIndicator(
            onRefresh: _loadDocuments,
            color: accentGreen,
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: _documents.length,
              itemBuilder: (_, i) => _documentCard(_documents[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _documentCard(MemberDocument doc) {
    final isDownloading = _downloadingDocs[doc.documentId] == true;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.picture_as_pdf,
                color: Colors.deepPurple, size: 22.sp),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.description.isNotEmpty
                      ? doc.description
                      : doc.fileName,
                  style: GoogleFonts.poppins(
                      fontSize: 13.sp, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height,
                Text(
                  doc.fileName,
                  style: GoogleFonts.poppins(
                      fontSize: 11.sp, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height,
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 10.sp, color: Colors.grey),
                    4.width,
                    Text(doc.formattedDate,
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: Colors.grey.shade500)),
                    12.width,
                    Icon(Icons.data_usage_rounded,
                        size: 10.sp, color: Colors.grey),
                    4.width,
                    Text(doc.formattedSize,
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
          ),
          12.width,
          GestureDetector(
            onTap: isDownloading
                ? null
                : () => _downloadAndOpenDoc(doc),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isDownloading
                    ? Colors.grey.shade200
                    : accentGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: isDownloading
                  ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: accentGreen))
                  : Icon(Icons.remove_red_eye,
                  color: accentGreen, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyDocs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded,
              size: 48.sp, color: Colors.grey.shade300),
          12.height,
          Text('No documents uploaded yet',
              style: GoogleFonts.poppins(
                  fontSize: 14.sp, color: Colors.grey.shade500)),
          6.height,
          Text('Submit a report using the form above',
              style: GoogleFonts.poppins(
                  fontSize: 12.sp, color: Colors.grey.shade400),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> rows, {Widget? customChild}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.montserrat(
                  fontSize: 14.sp, fontWeight: FontWeight.w700)),
          12.height,
          if (customChild != null) customChild,
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          SizedBox(
            width: 110.w,
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12.sp, color: Colors.grey.shade500)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}