import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import '/providers/notification_provider.dart';
import '/settings/notification_settings.dart';
import '/theme/theme.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "All";
  String _searchQuery = "";

  final List<String> _categories = [
    "All",
    "Delivery",
    "Billing",
    "Offers",
    "Schedule",
    "System",
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSettings() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NotificationSettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _showNotificationDetail(NotificationItem item) {
    ref.read(notificationProvider.notifier).markAsRead(item.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.dialogBg(context).color ?? AppTheme.cardBg(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColor.neutral_70 : AppColor.neutral_20,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.iconBgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: AppFontFamily.poppinsBold,
                              color: item.iconColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.timestamp,
                          style: AppTheme.textSearchInfoLabeled(context)
                              .copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                item.title,
                style: AppTheme.textTitle(context).copyWith(
                  fontSize: 18,
                  fontFamily: AppFontFamily.poppinsSemiBold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.message,
                style: AppTheme.textLabel(context).copyWith(
                  fontSize: 13,
                  fontFamily: AppFontFamily.poppinsRegular,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      text: "Close",
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationProvider);
    final isEnabled = notifState.isEnabled;
    final allItems = notifState.items;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter items locally by category & search query
    final filteredItems = allItems.where((item) {
      final matchesCategory = _selectedCategory == "All" ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery) ||
          item.message.toLowerCase().contains(_searchQuery) ||
          item.category.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          "Notifications",
          style: AppTheme.textTitle(context).copyWith(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(HugeIconsStroke.arrowLeft01, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (allItems.any((n) => !n.isRead))
            IconButton(
              tooltip: "Mark all as read",
              icon: const Icon(HugeIconsStroke.checkmarkBadge01, size: 20),
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
            ),
          IconButton(
            tooltip: "Notification Settings",
            icon: const Icon(HugeIconsStroke.settings02, size: 20),
            onPressed: _openSettings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Disabled Notifications Alert Banner
            if (!isEnabled)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF57C00).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF57C00).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      HugeIconsStroke.notificationOff01,
                      color: Color(0xFFF57C00),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Notifications are turned off. Enable them in settings to receive instant delivery updates.",
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: AppFontFamily.poppinsMedium,
                          color: isDark
                              ? const Color(0xFFFFB74D)
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _openSettings,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: AppFontFamily.poppinsBold,
                          color: isDark
                              ? const Color(0xFFFFB74D)
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Search Bar Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Search Notifications",
                  hintText: "Filter by title, delivery, khata...",
                  prefixIcon: const Icon(HugeIconsSolid.search01, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(HugeIconsStroke.cancel02, size: 18),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  final count = category == "All"
                      ? allItems.length
                      : allItems
                          .where((n) =>
                              n.category.toLowerCase() ==
                              category.toLowerCase())
                          .length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        "$category ($count)",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: isSelected
                              ? AppFontFamily.poppinsSemiBold
                              : AppFontFamily.poppinsMedium,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColor.primary_50,
                      backgroundColor:
                          isDark ? AppColor.neutral_80 : AppColor.neutral_10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColor.primary_50
                              : (isDark
                                  ? AppColor.neutral_70
                                  : AppColor.neutral_20),
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = category);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 4),

            // Notifications List
            Expanded(
              child: filteredItems.isEmpty
                  ? _buildEmptyView()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _buildNotificationCard(item, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item, bool isDark) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(HugeIconsStroke.delete02, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(notificationProvider.notifier).deleteItem(item.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: item.isRead
              ? AppTheme.cardBg(context)
              : (isDark
                  ? AppColor.primary_90.withValues(alpha: 0.35)
                  : AppColor.primary_5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? (isDark ? AppColor.neutral_80 : AppColor.neutral_10)
                : (isDark ? AppColor.primary_70 : AppColor.primary_20),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showNotificationDetail(item),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Avatar
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.textTitle(context).copyWith(
                                  fontSize: 13,
                                  fontFamily: item.isRead
                                      ? AppFontFamily.poppinsMedium
                                      : AppFontFamily.poppinsBold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.timestamp,
                              style: AppTheme.textSearchInfoLabeled(context)
                                  .copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.textLabel(context).copyWith(
                            fontSize: 11.5,
                            fontFamily: AppFontFamily.poppinsRegular,
                            color: isDark
                                ? AppColor.neutral_30
                                : AppColor.neutral_60,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Unread Dot Indicator
                  if (!item.isRead) ...[
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColor.primary_50,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColor.neutral_80 : AppColor.neutral_10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchQuery.isNotEmpty
                    ? HugeIconsStroke.search01
                    : HugeIconsStroke.notification01,
                size: 40,
                color: AppTheme.iconColorThree(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? "No matching notifications"
                  : "All caught up!",
              style: AppTheme.textTitle(context).copyWith(
                fontSize: 16,
                fontFamily: AppFontFamily.poppinsSemiBold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? "No alerts match '$_searchQuery' under '$_selectedCategory'."
                  : "You have no new notifications right now.",
              textAlign: TextAlign.center,
              style: AppTheme.textSearchInfoLabeled(context)
                  .copyWith(fontSize: 12),
            ),
            const SizedBox(height: 20),
            if (_searchQuery.isNotEmpty)
              OutlineButton(
                text: "Clear Search",
                onPressed: () {
                  _searchController.clear();
                  setState(() => _selectedCategory = "All");
                },
              ),
          ],
        ),
      ),
    );
  }
}
