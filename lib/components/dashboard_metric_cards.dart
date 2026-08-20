import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import '/theme/theme.dart';

/// Data class representing a single metric card item
class DashboardMetricItem {
  final String title;
  final String value;
  final String? subtitle;
  final String? badgeText;
  final bool isBadgePositive;
  final IconData icon;
  final Color iconColor;
  final Color? iconBgColor;
  final VoidCallback? onTap;

  const DashboardMetricItem({
    required this.title,
    required this.value,
    this.subtitle,
    this.badgeText,
    this.isBadgePositive = true,
    required this.icon,
    required this.iconColor,
    this.iconBgColor,
    this.onTap,
  });
}

class DashboardMetricCards extends StatefulWidget {
  final String role;
  final ValueChanged<String>? onRoleChanged;
  final bool showRoleSelector;

  const DashboardMetricCards({
    super.key,
    required this.role,
    this.onRoleChanged,
    this.showRoleSelector = false,
  });

  @override
  State<DashboardMetricCards> createState() => _DashboardMetricCardsState();
}

class _DashboardMetricCardsState extends State<DashboardMetricCards>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant DashboardMetricCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _normalizeRole(String rawRole) {
    final r = rawRole.toLowerCase().trim();
    if (r.contains('admin') || r == 'administrator') return 'admin';
    if (r.contains('staff') || r.contains('rider') || r.contains('manager')) {
      return 'staff';
    }
    if (r.contains('customer') || r.contains('client')) return 'customer';
    return 'user';
  }

  List<DashboardMetricItem> _getMetricsForRole(
    BuildContext context,
    String normalizedRole,
  ) {
    switch (normalizedRole) {
      case 'admin':
        return [
          DashboardMetricItem(
            title: "Total Customers",
            value: "128",
            subtitle: "Registered accounts",
            badgeText: "+12% mo",
            isBadgePositive: true,
            icon: HugeIconsStroke.userGroup,
            iconColor: const Color(0xFF4838D1),
            iconBgColor: const Color(0xFF4838D1).withValues(alpha: 0.12),
          ),
          DashboardMetricItem(
            title: "Daily Milk Output",
            value: "350 L",
            subtitle: "Buffalo 220L • Cow 130L",
            badgeText: "Live Target",
            isBadgePositive: true,
            icon: HugeIconsStroke.milkCarton,
            iconColor: const Color(0xFF00897B),
            iconBgColor: const Color(0xFF00897B).withValues(alpha: 0.12),
          ),
          DashboardMetricItem(
            title: "Active Subscriptions",
            value: "94",
            subtitle: "Daily regular routes",
            badgeText: "98% Active",
            isBadgePositive: true,
            icon: HugeIconsStroke.calendar01,
            iconColor: const Color(0xFFE91E63),
            iconBgColor: const Color(0xFFE91E63).withValues(alpha: 0.12),
          ),
          DashboardMetricItem(
            title: "Pending Ledger Dues",
            value: "Rs. 48.5K",
            subtitle: "14 overdue balances",
            badgeText: "Collect Now",
            isBadgePositive: false,
            icon: HugeIconsStroke.wallet01,
            iconColor: const Color(0xFFF57C00),
            iconBgColor: const Color(0xFFF57C00).withValues(alpha: 0.12),
          ),
          DashboardMetricItem(
            title: "Today's Deliveries",
            value: "112 / 120",
            subtitle: "In-progress rounds",
            badgeText: "93% Done",
            isBadgePositive: true,
            icon: HugeIconsStroke.truck,
            iconColor: const Color(0xFF1976D2),
            iconBgColor: const Color(0xFF1976D2).withValues(alpha: 0.12),
          ),
          DashboardMetricItem(
            title: "Quality & Purity",
            value: "99.4%",
            subtitle: "Lab lactometer score",
            badgeText: "Grade A+",
            isBadgePositive: true,
            icon: HugeIconsSolid.checkmarkBadge02,
            iconColor: const Color(0xFF2E7D32),
            iconBgColor: const Color(0xFF2E7D32).withValues(alpha: 0.12),
          ),
        ];

      case 'staff':
      case 'user':
        return [
          DashboardMetricItem(
            title: "Assigned Customers",
            value: "35",
            subtitle: "Route delivery list",
            badgeText: "Morning & Eve",
            isBadgePositive: true,
            icon: HugeIconsStroke.userMultiple02,
            iconColor: const Color(0xFF4838D1),
            iconBgColor: const Color(0xFF4838D1).withValues(alpha: 0.12),
          ),
          DashboardMetricItem(
            title: "Route Milk Quota",
            value: "95 L",
            subtitle: "60L AM • 35L PM",
            badgeText: "Today's Load",
            isBadgePositive: true,
            icon: HugeIconsStroke.milkCarton,
            iconColor: const Color(0xFF00897B),
            iconBgColor: const Color(0xFF00897B).withValues(alpha: 0.12),
          ),
          DashboardMetricItem(
            title: "Delivered Today",
            value: "28 / 35",
            subtitle: "7 stops remaining",
            badgeText: "80% Done",
            isBadgePositive: true,
            icon: HugeIconsStroke.truck,
            iconColor: const Color(0xFF1976D2),
            iconBgColor: const Color(0xFF1976D2).withValues(alpha: 0.12),
          ),
          DashboardMetricItem(
            title: "Cash Collected",
            value: "Rs. 12,400",
            subtitle: "Today's route cash",
            badgeText: "Khata Sync",
            isBadgePositive: true,
            icon: HugeIconsStroke.moneyReceiveFlow01,
            iconColor: const Color(0xFF2E7D32),
            iconBgColor: const Color(0xFF2E7D32).withValues(alpha: 0.12),
          ),
        ];

      case 'customer':
      default:
        return [
          DashboardMetricItem(
            title: "Daily Milk Quota",
            value: "2.0 L",
            subtitle: "1.5L Buffalo • 0.5L Cow",
            badgeText: "Live Plan",
            isBadgePositive: true,
            icon: HugeIconsStroke.milkCarton,
            iconColor: const Color(0xFF4838D1),
            iconBgColor: const Color(0xFF4838D1).withValues(alpha: 0.12),
          ),
          DashboardMetricItem(
            title: "Monthly Khata",
            value: "Rs. 4,200",
            subtitle: "Billing cycle: Aug 2026",
            badgeText: "Pay by 25th",
            isBadgePositive: false,
            icon: HugeIconsStroke.invoice01,
            iconColor: const Color(0xFFF57C00),
            iconBgColor: const Color(0xFFF57C00).withValues(alpha: 0.12),
          ),
          DashboardMetricItem(
            title: "Deliveries This Month",
            value: "18 Days",
            subtitle: "0 missed drops",
            badgeText: "100% Regular",
            isBadgePositive: true,
            icon: HugeIconsStroke.calendar01,
            iconColor: const Color(0xFF00897B),
            iconBgColor: const Color(0xFF00897B).withValues(alpha: 0.12),
          ),
          DashboardMetricItem(
            title: "Delivery Status",
            value: "Active",
            subtitle: "Next: Tomorrow 6:30 AM",
            badgeText: "On Schedule",
            isBadgePositive: true,
            icon: HugeIconsSolid.checkmarkBadge02,
            iconColor: const Color(0xFF2E7D32),
            iconBgColor: const Color(0xFF2E7D32).withValues(alpha: 0.12),
          ),
        ];
    }
  }

  String _getSectionTitle(String normalizedRole) {
    switch (normalizedRole) {
      case 'admin':
        return "Farm Performance";
      case 'staff':
      case 'user':
        return "Daily Route & Operations";
      case 'customer':
      default:
        return "My Dairy Khata & Quota";
    }
  }

  String _getRoleLabel(String normalizedRole) {
    switch (normalizedRole) {
      case 'admin':
        return "Admin";
      case 'staff':
        return "Staff";
      case 'user':
        return "Agent";
      case 'customer':
      default:
        return "Customer";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalizedRole = _normalizeRole(widget.role);
    final items = _getMetricsForRole(context, normalizedRole);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with Section Title and Role Badge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _getSectionTitle(normalizedRole),
                    style: AppTheme.textLabel(context).copyWith(
                      fontSize: 14,
                      fontFamily: AppFontFamily.poppinsSemiBold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColor.neutral_80 : AppColor.primary_5,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColor.neutral_70 : AppColor.primary_20,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getRoleLabel(normalizedRole),
                      style: AppTheme.textLabel(context).copyWith(
                        fontSize: 11,
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        color: isDark ? Colors.white : AppColor.primary_50,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // GridView of Metric Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 400 ? 2 : 2;
              final childAspectRatio = constraints.maxWidth > 350 ? 1.48 : 1.15;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final count = items.length;
                  final step = count > 1 ? 0.5 / (count - 1) : 0.0;
                  final start = (index * step).clamp(0.0, 0.6);
                  final end = (start + 0.4).clamp(0.0, 1.0);

                  final curvedAnim = CurvedAnimation(
                    parent: _animController,
                    curve: Interval(start, end, curve: Curves.easeOutCubic),
                  );

                  final fadeAnim = Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(curvedAnim);

                  final slideAnim = Tween<Offset>(
                    begin: const Offset(0.0, 0.25),
                    end: Offset.zero,
                  ).animate(curvedAnim);

                  return FadeTransition(
                    opacity: fadeAnim,
                    child: SlideTransition(
                      position: slideAnim,
                      child: _buildCard(context, item, isDark),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    DashboardMetricItem item,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBg(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Icon Container + Badge Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          item.iconBgColor ??
                          item.iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, size: 40, color: item.iconColor),
                  ),
                  if (item.badgeText != null)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: item.isBadgePositive
                              ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                              : const Color(0xFFF57C00).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.badgeText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: AppFontFamily.poppinsSemiBold,
                            color: item.isBadgePositive
                                ? (isDark
                                      ? const Color(0xFF81C784)
                                      : const Color(0xFF2E7D32))
                                : (isDark
                                      ? const Color(0xFFFFB74D)
                                      : const Color(0xFFE65100)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Value & Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.textTitle(context).copyWith(
                      fontSize: 19,
                      fontFamily: AppFontFamily.poppinsBold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.textLabel(context).copyWith(
                      fontSize: 12,
                      fontFamily: AppFontFamily.poppinsMedium,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.textSearchInfoLabeled(context).copyWith(
                        fontSize: 10,
                        color: isDark
                            ? AppColor.neutral_40
                            : AppColor.neutral_50,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
