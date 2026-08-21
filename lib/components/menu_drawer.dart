import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:shimmer/shimmer.dart';
import '/components/dialog_logout.dart';
import '/screens/auth/login_screen.dart';
import '/screens/subscription_screen.dart';
import '/theme/theme.dart';
import '/utils/session_manager.dart';

class MenuItemData {
  final String label;
  final IconData inactiveIcon;
  final IconData activeIcon;

  const MenuItemData(this.label, this.inactiveIcon, this.activeIcon);
}

class MenuDrawer extends StatefulWidget {
  final Function(int) onItemSelected;
  final int currentIndex;
  final String role;

  const MenuDrawer({
    super.key,
    required this.onItemSelected,
    required this.currentIndex,
    this.role = 'customer',
  });

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer>
    with SingleTickerProviderStateMixin {
  final auth = FirebaseAuth.instance;
  late AnimationController _controller;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  List<MenuItemData> _getMenuItems() {
    final r = widget.role.toLowerCase();
    if (r == 'staff') {
      return const [
        MenuItemData("Home", HugeIconsStroke.home11, HugeIconsSolid.home11),
        MenuItemData("Daily Supply", HugeIconsStroke.truck, HugeIconsSolid.truck),
        MenuItemData("Ledgers & Khata", HugeIconsStroke.userMultiple02, HugeIconsSolid.userMultiple02),
        MenuItemData("Account", HugeIconsStroke.user03, HugeIconsSolid.user03),
        MenuItemData("Subscription Plan", HugeIconsStroke.crown03, HugeIconsSolid.crown03),
      ];
    } else if (r == 'admin') {
      return const [
        MenuItemData("Overview", HugeIconsStroke.home11, HugeIconsSolid.home11),
        MenuItemData("Staff Accounts", HugeIconsStroke.userGroup, HugeIconsSolid.userGroup),
        MenuItemData("Subscription Plans", HugeIconsStroke.crown03, HugeIconsSolid.crown03),
        MenuItemData("Account", HugeIconsStroke.user03, HugeIconsSolid.user03),
      ];
    } else {
      // Customer
      return const [
        MenuItemData("Home", HugeIconsStroke.home11, HugeIconsSolid.home11),
        MenuItemData("My Deliveries", HugeIconsStroke.calendar01, HugeIconsSolid.calendar01),
        MenuItemData("My Khata & Bills", HugeIconsStroke.invoice01, HugeIconsSolid.invoice01),
        MenuItemData("Account", HugeIconsStroke.user03, HugeIconsSolid.user03),
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    final items = _getMenuItems();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _slideAnimations = List.generate(
      items.length,
      (i) => Tween<Offset>(begin: const Offset(-1.0, 0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.1, 1.0, curve: Curves.easeOut),
        ),
      ),
    );

    _fadeAnimations = List.generate(
      items.length,
      (i) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.1, 1.0, curve: Curves.easeIn),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await SessionManager.clearSession();
    await auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _getMenuItems();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Frosted Glass Overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        ),

        // Menu Content
        Padding(
          padding: const EdgeInsets.only(
            bottom: 30,
            left: 20,
            right: 20,
            top: 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    AppTheme.appLogo(context),
                    height: 120,
                    width: 60,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "My",
                    style: AppTheme.textTitle(context).copyWith(
                      fontSize: 20,
                      fontFamily: AppFontFamily.poppinsBold,
                    ),
                  ),
                  Text(
                    "Dashboard",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.textTitle(context).copyWith(
                      fontSize: 20,
                      fontFamily: AppFontFamily.poppinsLight,
                    ),
                  ),
                  Text(
                    ".",
                    style: AppTheme.textTitleActive(
                      context,
                    ).copyWith(fontSize: 30),
                  ),
                ],
              ),
              ...List.generate(items.length, (index) {
                final item = items[index];
                bool isActive = index == widget.currentIndex;
                final slideAnim = index < _slideAnimations.length
                    ? _slideAnimations[index]
                    : const AlwaysStoppedAnimation(Offset.zero);
                final fadeAnim = index < _fadeAnimations.length
                    ? _fadeAnimations[index]
                    : const AlwaysStoppedAnimation(1.0);

                return SlideTransition(
                  position: slideAnim,
                  child: FadeTransition(
                    opacity: fadeAnim,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.customListBg(context)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          if (index < 4) {
                            widget.onItemSelected(index);
                          } else {
                            // Extra menu options like Subscription
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SubscriptionScreen(),
                              ),
                            );
                          }
                        },
                        child: Row(
                          spacing: 16,
                          children: [
                            Icon(
                              isActive ? item.activeIcon : item.inactiveIcon,
                              color: isActive
                                  ? AppTheme.iconColor(context)
                                  : AppTheme.iconColorThree(context),
                              size: 22,
                            ),
                            Expanded(
                              child: Text(
                                item.label,
                                style: AppTheme.textLabel(context).copyWith(
                                  fontFamily: isActive
                                      ? AppFontFamily.poppinsMedium
                                      : AppFontFamily.poppinsLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              OutlineErrorButton(
                text: 'Log Out',
                onPressed: () {
                  DialogLogout().showDialog(context, _logout);
                },
              ),
              const SizedBox(height: 20),
              Shimmer(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.sliderHighlightBg(context),
                    AppTheme.iconColorThree(context),
                    AppTheme.sliderHighlightBg(context),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                direction: ShimmerDirection.rtl,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    const Icon(HugeIconsStroke.swipeLeft01),
                    Text(
                      "Swipe left to close menu",
                      style: AppTheme.textLink(context).copyWith(
                        fontFamily: AppFontFamily.poppinsMedium,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
