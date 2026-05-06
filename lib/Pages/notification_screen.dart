import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sports/model/notification_data.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'notification_provider.dart';

// import your model:
// import 'notification_model.dart';

// ─────────────────────────────────────────────
// Bell Icon with Badge (use in AppBar)
// ─────────────────────────────────────────────
class NotificationBellIcon extends StatelessWidget {
  final VoidCallback onTap;

  const NotificationBellIcon({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, size: 26),
              if (provider.unreadCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      provider.unreadCount > 99
                          ? '99+'
                          : '${provider.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Full Notification Screen
// ─────────────────────────────────────────────
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          // ── Black band header ──────────────────────────────────
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
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 5, left: 20, right: 20, bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                     Expanded(
                      child: Text(
                        'Notifications',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),

                      ),
                    ),
                    // Mark all read button
                    Consumer<NotificationProvider>(
                      builder: (context, provider, _) {
                        final hasUnread = provider.notifications
                            .any((n) => n.isRead == false);
                        if (!hasUnread) return const SizedBox.shrink();
                        return TextButton(
                          onPressed: provider.isMarkingAll
                              ? null
                              : provider.markAllAsRead,
                          child: provider.isMarkingAll
                              ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                              : const Text(
                            'Mark all read',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────
          Expanded(
            child: Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage != null) {
                  return _buildErrorState(provider);
                }
                if (provider.notifications.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: provider.loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: provider.notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 1),
                    itemBuilder: (context, index) {
                      final notification = provider.notifications[index];
                      return _NotificationTile(
                        notification: notification,
                        onTap: () {
                          if (notification.isRead == false) {
                            provider.markAsRead(notification.notificationId!);
                          }
                        },
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
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: false,
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Color(0xFF1A1A2E),
          size: 18,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            final hasUnread = provider.notifications.any(
              (n) => n.isRead == false,
            );
            if (!hasUnread) return const SizedBox.shrink();
            return TextButton(
              onPressed: provider.isMarkingAll ? null : provider.markAllAsRead,
              child: provider.isMarkingAll
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Mark all read',
                      style: TextStyle(
                        color: Color(0xFF4361EE),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 40,
              color: Color(0xFF4361EE),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "You're all caught up!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "No notifications yet",
            style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(NotificationProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFE53935)),
          const SizedBox(height: 12),
          Text(
            provider.errorMessage ?? 'Something went wrong',
            style: const TextStyle(color: Color(0xFF616161)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.loadNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Notification Tile
// ─────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final Data notification;
  final VoidCallback onTap;

  const _NotificationTile({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isRead == false;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: isUnread ? const Color(0xFFEEF2FF) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon avatar
            _buildIconAvatar(notification.notificationType),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title ?? 'Notification',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: const Color(0xFF1A1A2E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4361EE),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notification.message != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      notification.message!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF616161),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (notification.notificationType != null)
                        _TypeChip(type: notification.notificationType!),
                      const Spacer(),
                      Text(
                        _formatTime(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconAvatar(String? type) {
    IconData icon;
    Color bg;
    Color fg;

    switch (type?.toLowerCase()) {
      case 'event':
        icon = Icons.event_outlined;
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFF57C00);
        break;
      case 'member':
        icon = Icons.person_add_outlined;
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF388E3C);
        break;
      case 'announcement':
        icon = Icons.campaign_outlined;
        bg = const Color(0xFFFCE4EC);
        fg = const Color(0xFFD81B60);
        break;
      default:
        icon = Icons.notifications_outlined;
        bg = const Color(0xFFEEF2FF);
        fg = const Color(0xFF4361EE);
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: fg),
    );
  }

  String _formatTime(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return timeago.format(dt);
    } catch (_) {
      return createdAt;
    }
  }
}

// ─────────────────────────────────────────────
// Type Chip
// ─────────────────────────────────────────────
class _TypeChip extends StatelessWidget {
  final String type;

  const _TypeChip({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9E9E9E),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
