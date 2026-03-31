import 'package:flutter/material.dart';
import 'package:sports/Pages/notification_screen.dart';
import 'package:sports/model/notification_data.dart';
import 'package:sports/utills/api_service.dart';
import 'package:sports/utills/notification_service.dart';

// import your model path:
// import 'notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;

  NotificationProvider(this._service);

  List<Data> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isMarkingAll = false;
  String? _errorMessage;

  List<Data> get notifications => _notifications;

  int get unreadCount => _unreadCount;

  bool get isLoading => _isLoading;

  bool get isMarkingAll => _isMarkingAll;

  String? get errorMessage => _errorMessage;

  /// Load notifications from API
  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getNotifications();
      final notifData = response;
      _notifications = notifData.data ?? [];
    } catch (e) {
      _errorMessage = 'Something went wrong';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch unread count
  Future<void> loadUnreadCount() async {
    try {
      final response = await _service.getUnreadCount();
      if (response != null && response['success'] == true) {
        _unreadCount = response['data'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print("Error loading unread count: $e");
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await _service.markNotificationRead(notificationId);
      if (response != null && response['success'] == true) {
        final index = _notifications.indexWhere(
          (n) => n.notificationId == notificationId,
        );
        if (index != -1) {
          // Update local state without refetching
          final updated = _notifications[index];
          if (updated.isRead == false) {
            _notifications[index] = Data(
              notificationId: updated.notificationId,
              clubId: updated.clubId,
              userId: updated.userId,
              role: updated.role,
              notificationType: updated.notificationType,
              title: updated.title,
              message: updated.message,
              eventId: updated.eventId,
              memberId: updated.memberId,
              isRead: true,
              createdAt: updated.createdAt,
            );
            if (_unreadCount > 0) _unreadCount--;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    _isMarkingAll = true;
    notifyListeners();

    try {
      final response = await _service.markAllNotificationsRead();
      if (response != null && response['success'] == true) {
        _notifications = _notifications
            .map(
              (n) => Data(
                notificationId: n.notificationId,
                clubId: n.clubId,
                userId: n.userId,
                role: n.role,
                notificationType: n.notificationType,
                title: n.title,
                message: n.message,
                eventId: n.eventId,
                memberId: n.memberId,
                isRead: true,
                createdAt: n.createdAt,
              ),
            )
            .toList();
        _unreadCount = 0;
      }
    } catch (e) {
      print("Error marking all as read: $e");
    }

    _isMarkingAll = false;
    notifyListeners();
  }
}
