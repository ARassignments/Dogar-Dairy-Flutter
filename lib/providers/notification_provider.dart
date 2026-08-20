import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import '/services/notification_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String category;
  final String timestamp;
  final bool isRead;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.timestamp,
    this.isRead = false,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? category,
    String? timestamp,
    bool? isRead,
    IconData? icon,
    Color? iconColor,
    Color? iconBgColor,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBgColor: iconBgColor ?? this.iconBgColor,
    );
  }
}

class NotificationState {
  final List<NotificationItem> items;
  final bool isEnabled;

  const NotificationState({
    required this.items,
    required this.isEnabled,
  });

  int get unreadCount => items.where((item) => !item.isRead).length;

  NotificationState copyWith({
    List<NotificationItem>? items,
    bool? isEnabled,
  }) {
    return NotificationState(
      items: items ?? this.items,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier()
      : super(
          NotificationState(
            isEnabled: NotificationService.masterEnabled,
            items: _defaultNotifications,
          ),
        ) {
    _init();
  }

  Future<void> _init() async {
    await NotificationService.loadSettings();
    state = state.copyWith(isEnabled: NotificationService.masterEnabled);
  }

  static final List<NotificationItem> _defaultNotifications = [
    NotificationItem(
      id: "notif-1",
      title: "Fresh Milk Delivered",
      message:
          "Your morning delivery of 2.0L Buffalo Milk has been dropped at your doorstep.",
      category: "Delivery",
      timestamp: "15m ago",
      isRead: false,
      icon: HugeIconsStroke.truck,
      iconColor: const Color(0xFF1976D2),
      iconBgColor: const Color(0xFF1976D2).withValues(alpha: 0.12),
    ),
    NotificationItem(
      id: "notif-2",
      title: "Khata Invoice Generated",
      message:
          "Your monthly billing invoice of Rs. 4,200 is generated. Due date: Aug 25.",
      category: "Billing",
      timestamp: "2h ago",
      isRead: false,
      icon: HugeIconsStroke.invoice01,
      iconColor: const Color(0xFFF57C00),
      iconBgColor: const Color(0xFFF57C00).withValues(alpha: 0.12),
    ),
    NotificationItem(
      id: "notif-3",
      title: "Weekend Farm Special - 20% Off",
      message:
          "Enjoy a 20% flat discount on 100% Pure Desi Ghee & Fresh Farm Butter this weekend!",
      category: "Offers",
      timestamp: "Today, 9:00 AM",
      isRead: false,
      icon: HugeIconsStroke.discount01,
      iconColor: const Color(0xFFE91E63),
      iconBgColor: const Color(0xFFE91E63).withValues(alpha: 0.12),
    ),
    NotificationItem(
      id: "notif-4",
      title: "Daily Quota Updated",
      message:
          "Your daily morning quota has been adjusted to 2.5L starting tomorrow morning.",
      category: "Schedule",
      timestamp: "Yesterday",
      isRead: true,
      icon: HugeIconsStroke.milkCarton,
      iconColor: const Color(0xFF00897B),
      iconBgColor: const Color(0xFF00897B).withValues(alpha: 0.12),
    ),
    NotificationItem(
      id: "notif-5",
      title: "Payment Received & Synced",
      message:
          "Received Rs. 3,800 via EasyPaisa. Your Khata ledger balance has been updated.",
      category: "Billing",
      timestamp: "Aug 18",
      isRead: true,
      icon: HugeIconsStroke.checkmarkBadge01,
      iconColor: const Color(0xFF2E7D32),
      iconBgColor: const Color(0xFF2E7D32).withValues(alpha: 0.12),
    ),
    NotificationItem(
      id: "notif-6",
      title: "Morning Route Dispatched",
      message:
          "Rider Muhammad Ali has started today's morning delivery route in your area.",
      category: "Delivery",
      timestamp: "Aug 17",
      isRead: true,
      icon: HugeIconsStroke.deliveryBox01,
      iconColor: const Color(0xFF4838D1),
      iconBgColor: const Color(0xFF4838D1).withValues(alpha: 0.12),
    ),
    NotificationItem(
      id: "notif-7",
      title: "Dairy Quality Report",
      message:
          "Lab test complete: 99.4% lactometer purity score recorded on today's organic batch.",
      category: "System",
      timestamp: "Aug 15",
      isRead: true,
      icon: HugeIconsSolid.checkmarkBadge02,
      iconColor: const Color(0xFF00897B),
      iconBgColor: const Color(0xFF00897B).withValues(alpha: 0.12),
    ),
  ];

  void setEnabled(bool enabled) {
    NotificationService.setMasterEnabled(enabled);
    state = state.copyWith(isEnabled: enabled);
  }

  void markAsRead(String id) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(isRead: true);
        }
        return item;
      }).toList(),
    );
  }

  void markAllAsRead() {
    state = state.copyWith(
      items: state.items.map((item) => item.copyWith(isRead: true)).toList(),
    );
  }

  void deleteItem(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
  }

  void clearAll() {
    state = state.copyWith(items: []);
  }

  void addNotification(NotificationItem item) {
    state = state.copyWith(
      items: [item, ...state.items],
    );
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
      (ref) => NotificationNotifier(),
    );
