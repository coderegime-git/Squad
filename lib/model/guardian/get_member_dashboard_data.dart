// model/guardian/guardian_dashboard_data.dart
import 'dart:convert';

GuardianDashboardData guardianDashboardDataFromJson(Map<String, dynamic> json) =>
    GuardianDashboardData.fromJson(json);

class GuardianDashboardData {
  GuardianDashboardData({
    required this.success,
    required this.message,
    required this.data,
    this.errorCode,
    required this.timestamp,
  });

  late final bool success;
  late final String message;
  late final GuardianDashboardBody data;
  late final String? errorCode;
  late final String timestamp;

  factory GuardianDashboardData.fromJson(Map<String, dynamic> json) {
    return GuardianDashboardData(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: GuardianDashboardBody.fromJson(json['data'] ?? {}),
      errorCode: json['errorCode'],
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class GuardianDashboardBody {
  GuardianDashboardBody({
    required this.children,
    required this.selectedChild,
    required this.notifications,
  });

  late final List<GuardianChild> children;
  late final SelectedChildData selectedChild;
  late final List<String> notifications;

  factory GuardianDashboardBody.fromJson(Map<String, dynamic> json) {
    return GuardianDashboardBody(
      children: (json['children'] as List<dynamic>? ?? [])
          .map((e) => GuardianChild.fromJson(e))
          .toList(),
      selectedChild: SelectedChildData.fromJson(json['selectedChild'] ?? {}),
      notifications: List<String>.from(json['notifications'] ?? []),
    );
  }
}

class GuardianChild {
  GuardianChild({
    required this.memberId,
    required this.name,
    required this.gender,
    this.photo,
  });

  late final int memberId;
  late final String name;
  late final String gender;
  late final String? photo;

  factory GuardianChild.fromJson(Map<String, dynamic> json) {
    return GuardianChild(
      memberId: json['memberId'] ?? 0,
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      photo: json['photo'],
    );
  }
}

class SelectedChildData {
  SelectedChildData({
    required this.attendancePercentage,
    this.performanceRating,
    required this.events,
    required this.payments,
  });

  late final num attendancePercentage;
  late final num? performanceRating;
  late final List<GuardianChildEvent> events;
  late final GuardianPayment payments;

  factory SelectedChildData.fromJson(Map<String, dynamic> json) {
    return SelectedChildData(
      attendancePercentage: json['attendancePercentage'] ?? 0,
      performanceRating: json['performanceRating'],
      events: (json['events'] as List<dynamic>? ?? [])
          .map((e) => GuardianChildEvent.fromJson(e))
          .toList(),
      payments: GuardianPayment.fromJson(json['payments'] ?? {}),
    );
  }

  factory SelectedChildData.empty() => SelectedChildData(
    attendancePercentage: 0,
    performanceRating: null,
    events: [],
    payments: GuardianPayment.empty(),
  );
}

class GuardianChildEvent {
  GuardianChildEvent({
    required this.eventId,
    required this.title,
    required this.rsvpStatus,
    required this.eventDate,
  });

  late final int eventId;
  late final String title;
  late final String rsvpStatus;
  late final String eventDate;

  factory GuardianChildEvent.fromJson(Map<String, dynamic> json) {
    return GuardianChildEvent(
      eventId: json['eventId'] ?? 0,
      title: json['title'] ?? '',
      rsvpStatus: json['rsvpStatus'] ?? '',
      eventDate: json['eventDate'] ?? '',
    );
  }
}

class GuardianPayment {
  GuardianPayment({
    required this.due,
    required this.status,
  });

  late final int due;
  late final String status;

  factory GuardianPayment.fromJson(Map<String, dynamic> json) {
    return GuardianPayment(
      due: json['due'] ?? 0,
      status: json['status'] ?? '',
    );
  }

  factory GuardianPayment.empty() =>
      GuardianPayment(due: 0, status: '');
}