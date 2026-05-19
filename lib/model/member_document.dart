// lib/model/member_document.dart

class MemberDocument {
  final int documentId;
  final int memberId;
  final String fileName;
  final String contentType;
  final int fileSize;
  final String description;
  final String createdAt;

  MemberDocument({
    required this.documentId,
    required this.memberId,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
    required this.description,
    required this.createdAt,
  });

  factory MemberDocument.fromJson(Map<String, dynamic> json) {
    return MemberDocument(
      documentId: json['documentId'] ?? 0,
      memberId: json['memberId'] ?? 0,
      fileName: json['fileName'] ?? '',
      contentType: json['contentType'] ?? 'application/pdf',
      fileSize: json['fileSize'] ?? 0,
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  String get formattedSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }
}