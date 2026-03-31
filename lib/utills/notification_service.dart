import 'dart:convert';

import 'package:sports/utills/api_service.dart';

import '../model/notification_data.dart';

class NotificationService {
  final ApiBaseHelper _helper; // Your existing ApiHelper

  NotificationService(this._helper);

  /// Mark a single notification as read
  /// PUT/PATCH api/notification/{notificationId}/read

  Future<dynamic> markNotificationRead(int notificationId) async {
    try {
      final fullResponse = await _helper.put(
        "api/notifications/$notificationId/read",
        {},
      );
      print("Mark read response: $fullResponse");
      return fullResponse;
    } catch (e) {
      print("Mark notification read failed: $e");
      return false;
    }
  }

  /// Mark all notifications as read
  /// PUT/PATCH api/notification/read-all
  Future<dynamic> markAllNotificationsRead() async {
    try {
      final fullResponse = await _helper.put("api/notifications/read-all", {});
      print("Mark all read response: $fullResponse");
      return fullResponse;
    } catch (e) {
      print("Mark all notifications read failed: $e");
      return false;
    }
  }

  /// Get unread notification count
  /// GET api/notification/unread-count
  Future<dynamic> getUnreadCount() async {
    try {
      final fullResponse = await _helper.get("api/notifications/unread-count");
      print("Unread count response: $fullResponse");
      return fullResponse;
    } catch (e) {
      print("Get unread count failed: $e");
      return false;
    }
  }

  /// Fetch all notifications (optional, if you have a list endpoint)
  Future<NotificationData> getNotifications() async {
    try {
      final fullResponse = await _helper.get("api/notifications");
      print("Notifications response: $fullResponse");
      return NotificationData.fromJson(fullResponse);
    } catch (e) {
      print("Get notifications failed: $e");
      return NotificationData.fromJson({});
    }
  }
}
