import '/components/dashboard_metric_cards.dart';
import '/components/dashboard_slider.dart';
import '/theme/theme.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onMenuSelect;
  const HomeScreen({super.key, required this.onMenuSelect});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  bool _hover = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final role = 'customer';
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DashboardSlider(),
            const SizedBox(height: 8),
            DashboardMetricCards(role: role),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Need Help?",
                style: AppTheme.textLabel(context).copyWith(
                  fontSize: 14,
                  fontFamily: AppFontFamily.poppinsSemiBold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: Opacity(
                      opacity: 0.5,
                      child: InkWell(
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
                                  "FAQs",
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
                  Expanded(
                    child: Opacity(
                      opacity: 0.5,
                      child: InkWell(
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
                                  "Chat Now",
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
            // Column(
            //   children: [
            //     Text("Welcome, ${user?["FullName"] ?? "Guest"}"),
            //     Text("Email: ${user?["Email"] ?? "N/A"}"),
            //     Text("Organization Id: ${user?["OrganizationId"] ?? "Unknown"}"),
            //     Text("Token: ${token ?? "Not available"}"),
            //   ],
            // ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
