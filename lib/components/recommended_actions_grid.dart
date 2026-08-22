import 'package:flutter/material.dart';
import '/components/appsnackbar.dart';
import '/screens/monthly_supply_screen.dart';
import '/screens/profile_screen.dart';
import '/theme/theme.dart';

class RecommendedActionItem {
  final String title;
  final String imagePath;
  final VoidCallback? onTap;

  const RecommendedActionItem({
    required this.title,
    required this.imagePath,
    this.onTap,
  });
}

class RecommendedActionsGrid extends StatefulWidget {
  final Function(int) onMenuSelect;
  final String role;

  const RecommendedActionsGrid({
    super.key,
    required this.onMenuSelect,
    required this.role,
  });

  @override
  State<RecommendedActionsGrid> createState() => _RecommendedActionsGridState();
}

class _RecommendedActionsGridState extends State<RecommendedActionsGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  List<RecommendedActionItem> _getItems() {
    return [
      RecommendedActionItem(
        title: "Shop Supply",
        imagePath: "assets/images/dashboard/shop_supply.png",
        onTap: () => widget.onMenuSelect(1), // Deliveries / Supply tab
      ),
      RecommendedActionItem(
        title: "Monthly Supply",
        imagePath: "assets/images/dashboard/monthly_supply.png",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MonthlySupplyScreen()),
          );
        },
      ),
      RecommendedActionItem(
        title: "Stocks",
        imagePath: "assets/images/dashboard/stocks.png",
        onTap: () => _showStocksModal(context),
      ),
      RecommendedActionItem(
        title: "Credit",
        imagePath: "assets/images/dashboard/credit.png",
        onTap: () => widget.onMenuSelect(2), // Khata / Ledgers tab
      ),
      RecommendedActionItem(
        title: "Expences",
        imagePath: "assets/images/dashboard/expences.png",
        onTap: () => _showExpensesModal(context),
      ),
      RecommendedActionItem(
        title: "Workers Pay",
        imagePath: "assets/images/dashboard/workers_pay.png",
        onTap: () => _showWorkersPayModal(context),
      ),
      RecommendedActionItem(
        title: "Settings",
        imagePath: "assets/images/dashboard/settings.png",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
      ),
      RecommendedActionItem(
        title: "Other Items",
        imagePath: "assets/images/dashboard/other_items.png",
        onTap: () => _showOtherItemsModal(context),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    final items = _getItems();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimations = List.generate(items.length, (index) {
      final start = (index * 0.08).clamp(0.0, 0.7);
      final end = (start + 0.3).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnimations = List.generate(items.length, (index) {
      final start = (index * 0.08).clamp(0.0, 0.7);
      final end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0.0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showStocksModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Dairy Stock & Inventory",
                style: AppTheme.textTitle(
                  ctx,
                ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _buildModalRow(
                ctx,
                "🥛 Fresh Buffalo Milk",
                "420 Liters in Stock",
                "Safe",
              ),
              _buildModalRow(
                ctx,
                "🐄 Pure Cow Milk",
                "180 Liters in Stock",
                "Safe",
              ),
              _buildModalRow(ctx, "🧈 Desi Ghee", "45 KG in Stock", "Low"),
              _buildModalRow(
                ctx,
                "🥣 Fresh Yogurt (Dahi)",
                "85 KG in Stock",
                "Safe",
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary_50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Done",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExpensesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Monthly Expenses",
                style: AppTheme.textTitle(
                  ctx,
                ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _buildModalRow(
                ctx,
                "🌾 Cattle Fodder & Feed",
                "Rs. 45,000",
                "Paid",
              ),
              _buildModalRow(
                ctx,
                "⛽ Delivery Route Fuel",
                "Rs. 18,500",
                "Paid",
              ),
              _buildModalRow(
                ctx,
                "🧊 Chillers & Electricity",
                "Rs. 24,000",
                "Due",
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary_50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWorkersPayModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Workers & Riders Payroll",
                style: AppTheme.textTitle(
                  ctx,
                ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _buildModalRow(
                ctx,
                "🚴 Tariq Mahmood (Rider)",
                "Rs. 28,000 / mo",
                "Paid",
              ),
              _buildModalRow(
                ctx,
                "🚴 Imran Khan (Rider)",
                "Rs. 28,000 / mo",
                "Paid",
              ),
              _buildModalRow(
                ctx,
                "👨‍🌾 Bilal Ahmed (Farm Staff)",
                "Rs. 32,000 / mo",
                "Paid",
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary_50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOtherItemsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Other Dairy Products",
                style: AppTheme.textTitle(
                  ctx,
                ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _buildModalRow(
                ctx,
                "🧈 Pure Organic Desi Ghee",
                "Rs. 2,600 / KG",
                "Available",
              ),
              _buildModalRow(
                ctx,
                "🥣 Fresh Dahi (Yogurt)",
                "Rs. 240 / KG",
                "Available",
              ),
              _buildModalRow(
                ctx,
                "🧀 Fresh Paneer & Butter",
                "Rs. 1,400 / KG",
                "Available",
              ),
              _buildModalRow(
                ctx,
                "🍬 Traditional Khoya / Mawa",
                "Rs. 1,200 / KG",
                "Available",
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary_50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalRow(
    BuildContext context,
    String title,
    String subtitle,
    String status,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.customListBg(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.textLabel(context).copyWith(
                  fontFamily: AppFontFamily.poppinsSemiBold,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTheme.textSearchInfoLabeled(
                  context,
                ).copyWith(fontSize: 11),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: status == 'Low' || status == 'Due'
                  ? const Color(0xFFE91E63).withValues(alpha: 0.12)
                  : const Color(0xFF2E7D32).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontFamily: AppFontFamily.poppinsMedium,
                fontSize: 10,
                color: status == 'Low' || status == 'Due'
                    ? const Color(0xFFE91E63)
                    : const Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _getItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: "Recommended For You" & "See more"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recommended For You",
                style: AppTheme.textLabel(context).copyWith(
                  fontSize: 14,
                  fontFamily: AppFontFamily.poppinsSemiBold,
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  AppSnackBar.show(
                    context,
                    message:
                        "All 8 recommended actions are active on your dashboard.",
                    type: AppSnackBarType.info,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    "See more",
                    style: AppTheme.textLink(
                      context,
                    ).copyWith(fontFamily: AppFontFamily.poppinsMedium),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2-Column Grid with hover and entrance animations
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.50,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final fadeAnimation = _fadeAnimations[index];
                  final slideAnimation = _slideAnimations[index];

                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: _HoverActionCard(item: item),
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
}

class _HoverActionCard extends StatefulWidget {
  final RecommendedActionItem item;

  const _HoverActionCard({required this.item});

  @override
  State<_HoverActionCard> createState() => _HoverActionCardState();
}

class _HoverActionCardState extends State<_HoverActionCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHighlight = _isHovered || _isPressed;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.item.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : (_isHovered ? 1.04 : 1.0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isHighlight
                  ? (isDark
                        ? AppColor.primary_50.withValues(alpha: 0.12)
                        : AppColor.primary_50.withValues(alpha: 0.05))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 3D Illustration Image with subtle floating hover
                Expanded(
                  child: Center(
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.only(bottom: _isHovered ? 4 : 0),
                      child: Image.asset(
                        widget.item.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.category_rounded,
                            size: 60,
                            color: AppColor.primary_50,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Title
                Text(
                  widget.item.title,
                  textAlign: TextAlign.center,
                  style: AppTheme.textLabel(context).copyWith(
                    fontFamily: AppFontFamily.poppinsMedium,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
