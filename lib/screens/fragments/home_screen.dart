import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/components/dashboard_metric_cards.dart';
import '/components/dashboard_slider.dart';
import '/components/recommended_actions_grid.dart';
import '/providers/user_provider.dart';
import '/screens/help_center_screen.dart';
import '/theme/theme.dart';
import '/utils/session_manager.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Function(int) onMenuSelect;
  const HomeScreen({super.key, required this.onMenuSelect});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  String _cachedRole = 'customer';

  @override
  void initState() {
    super.initState();
    _loadCachedRole();
  }

  Future<void> _loadCachedRole() async {
    final user = await SessionManager.getUser();
    if (user != null && user['role'] != null && mounted) {
      setState(() {
        _cachedRole = user['role'].toString().toLowerCase();
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = ref.watch(userProvider);
    final role =
        (user?.role.isNotEmpty == true ? user!.role : _cachedRole).toLowerCase();

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DashboardSlider(),
            const SizedBox(height: 8),
            DashboardMetricCards(role: role),
            const SizedBox(height: 14),

            // ✨ Recommended For You 3D Interactive Action Grid with Fade In & Hover
            RecommendedActionsGrid(
              onMenuSelect: widget.onMenuSelect,
              role: role,
            ),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                role == 'staff'
                    ? "Vendor Quick Links"
                    : (role == 'admin' ? "Platform Quick Links" : "Need Help?"),
                style: AppTheme.textLabel(context).copyWith(
                  fontSize: 14,
                  fontFamily: AppFontFamily.poppinsSemiBold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Opacity(
                      opacity: 0.95,
                      child: InkWell(
                        onTap: () {
                          if (role == 'staff') {
                            widget.onMenuSelect(1); // Go to Supply / Deliveries
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const HelpCenterScreen(initialTabIndex: 0),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.customListBg(context),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  role == 'staff'
                                      ? "Manage\nCustomers"
                                      : "FAQs",
                                  style: AppTheme.textLink(context).copyWith(
                                    fontSize: 13,
                                    fontFamily: AppFontFamily.poppinsSemiBold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -40,
                              bottom: -35,
                              child: Image.asset(
                                "assets/images/dashboard/faqs_image.png",
                                height: 180,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Opacity(
                      opacity: 0.95,
                      child: InkWell(
                        onTap: () {
                          if (role == 'staff') {
                            widget.onMenuSelect(2); // Go to Ledgers / Khata
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const HelpCenterScreen(initialTabIndex: 1),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.customListBg(context),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  role == 'staff'
                                      ? "Khata\nLedgers"
                                      : "Support",
                                  style: AppTheme.textLink(context).copyWith(
                                    fontSize: 13,
                                    fontFamily: AppFontFamily.poppinsSemiBold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -40,
                              bottom: -28,
                              child: Image.asset(
                                "assets/images/dashboard/chat_image.png",
                                height: 180,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
