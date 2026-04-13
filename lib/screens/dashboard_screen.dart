import 'package:dogardairy/components/appsnackbar.dart';
import 'package:dogardairy/components/dashboard_slider.dart';
import 'package:dogardairy/components/dialog_logout.dart';
import 'package:dogardairy/components/menu_drawer.dart';
import 'package:dogardairy/notifiers/avatar_notifier.dart';
import 'package:dogardairy/screens/auth/login_screen.dart';
import 'package:dogardairy/screens/subscription_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '/components/loading_screen.dart';
import '/theme/theme.dart';
import '/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:hugeicons_pro/hugeicons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? user;
  bool _isLoadingUser = true;

  int _currentIndex = 0;
  bool _showSearchBar = false;
  final ZoomDrawerController _drawerController = ZoomDrawerController();
  List<String> menus = ["Home", "Orders", "Ledgers", "Accounts"];

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final userData = await SessionManager.getUser();
    setState(() {
      user = userData;
      _isLoadingUser = false;
    });
  }

  Future<void> _logout() async {
    await SessionManager.clearSession();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => LoginScreen(),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    }
  }

  List<Widget> _pages() {
    return [_homePage(), _homePage(), _homePage(), _accountsPage()];
  }

  Widget _homePage() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DashboardSlider(),
            SizedBox(height: 16),
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

  Widget _accountsPage() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder<String?>(
              valueListenable: avatarNotifier,
              builder: (context, avatar, _) {
                return Column(
                  children: [
                    Hero(
                      tag: 'profile-avatar',
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: AppTheme.customListBg(context),
                          foregroundImage: avatar != null
                              ? AssetImage(avatar)
                              : const AssetImage(
                                  "assets/images/avatars/boy_14.png",
                                ),
                          child: avatar != null
                              ? Icon(
                                  HugeIconsSolid.user03,
                                  size: 60,
                                  color: AppTheme.iconColorThree(context),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Profile Details",
                      style: AppTheme.textTitle(context).copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg(context),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            _buildInfoTile(
                              HugeIconsStroke.user03,
                              "Name",
                              user!["name"],
                            ),
                            Divider(
                              height: 1,
                              color: AppTheme.dividerBg(context),
                            ),
                            _buildInfoTile(
                              HugeIconsStroke.mail01,
                              "Email",
                              user!["email"],
                            ),
                            Divider(
                              height: 1,
                              color: AppTheme.dividerBg(context),
                            ),
                            _buildInfoTile(
                              HugeIconsStroke.call02,
                              "Contact",
                              formatInternationalPhone(
                                "${user!["PhoneNumber"]}",
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: AppTheme.dividerBg(context),
                            ),
                            _buildInfoTile(
                              HugeIconsStroke.mapsLocation01,
                              "Address",
                              user!["Address"],
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: FlatButton(
                                onPressed: () {
                                  // Navigator.push(
                                  //   context,
                                  //   PageRouteBuilder(
                                  //     opaque: false,
                                  //     pageBuilder:
                                  //         (
                                  //           context,
                                  //           animation,
                                  //           secondaryAnimation,
                                  //         ) => ProfileScreen(),
                                  //     transitionsBuilder:
                                  //         (
                                  //           context,
                                  //           animation,
                                  //           secondaryAnimation,
                                  //           child,
                                  //         ) {
                                  //           const begin = Offset(0.0, 1.0);
                                  //           const end = Offset.zero;
                                  //           const curve = Curves.easeInOut;
                                  //           final tween = Tween(
                                  //             begin: begin,
                                  //             end: end,
                                  //           ).chain(CurveTween(curve: curve));
                                  //           return SlideTransition(
                                  //             position: animation.drive(tween),
                                  //             child: child,
                                  //           );
                                  //         },
                                  //   ),
                                  // );
                                },
                                icon: HugeIconsSolid.edit01,
                                radiusCustom: true,
                                radius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                text: "Edit Profile",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Icon(HugeIconsStroke.userGroup03, size: 24),
                      title: Text(
                        "Manage Users",
                        style: AppTheme.textLabel(context),
                      ),
                      onTap: () {},
                    ),
                    Divider(height: 1, color: AppTheme.dividerBg(context)),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Icon(
                        HugeIconsStroke.messageMultiple02,
                        size: 24,
                      ),
                      title: Text(
                        "Messages",
                        style: AppTheme.textLabel(context),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? HugeIconsStroke.moon02
                            : HugeIconsStroke.sun02,
                        size: 24,
                      ),
                      title: Text(
                        Theme.of(context).brightness == Brightness.dark
                            ? "Dark Mode"
                            : "Light Mode",
                        style: AppTheme.textLabel(context),
                      ),
                      trailing: Switch(
                        value: Theme.of(context).brightness == Brightness.dark,
                        activeColor: AppTheme.iconColor(context),
                        onChanged: (value) {
                          ThemeController.setTheme(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                      onTap: () {
                        final isDark =
                            ThemeController.themeNotifier.value ==
                            ThemeMode.dark;
                        ThemeController.setTheme(
                          isDark ? ThemeMode.light : ThemeMode.dark,
                        );
                      },
                    ),
                    Divider(height: 1, color: AppTheme.dividerBg(context)),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Icon(HugeIconsStroke.crown03, size: 24),
                      title: Text(
                        "Subscription",
                        style: AppTheme.textLabel(context),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    SubscriptionScreen(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  const begin = Offset(0.0, 1.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  final tween = Tween(
                                    begin: begin,
                                    end: end,
                                  ).chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: AppTheme.dividerBg(context)),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Icon(HugeIconsStroke.note, size: 24),
                      title: Text(
                        "Privacy Policy",
                        style: AppTheme.textLabel(context),
                      ),
                      onTap: () {},
                    ),
                    Divider(height: 1, color: AppTheme.dividerBg(context)),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Icon(HugeIconsStroke.headset, size: 24),
                      title: Text(
                        "Help Center",
                        style: AppTheme.textLabel(context),
                      ),
                      onTap: () {},
                    ),
                    Divider(height: 1, color: AppTheme.dividerBg(context)),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Icon(
                        HugeIconsStroke.chartBreakoutCircle,
                        size: 24,
                      ),
                      title: Text(
                        "About Dogar Dairy",
                        style: AppTheme.textLabel(context),
                      ),
                      onTap: () async {
                        final Uri url = Uri.parse('https://y2ksolutions.com');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode
                                .externalApplication, // opens in browser
                          );
                        } else {
                          AppSnackBar.show(
                            context,
                            message: "Could not open the website.",
                            type: AppSnackBarType.error,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlineErrorButton(
                  text: 'Log Out',
                  onPressed: () {
                    DialogLogout().showDialog(context, _logout);
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Icon(icon, size: 24),
      title: Text(label, style: AppTheme.textLabel(context)),
      subtitle: Text(
        value.isNotEmpty ? value : "Not provided",
        style: AppTheme.textSearchInfoLabeled(context).copyWith(fontSize: 12),
      ),
    );
  }

  String formatInternationalPhone(String number) {
    if (number.startsWith("0")) {
      return "+92 ${number.substring(1, 4)} ${number.substring(4, 7)} ${number.substring(7)}";
    }
    return number;
  }

  Widget _defaultAvatar() {
    return Image.asset(
      "assets/images/avatars/boy_14.png",
      width: 40,
      height: 40,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages();
    Widget child = Scaffold(
      body: ZoomDrawer(
        controller: _drawerController,
        menuScreen: MenuDrawer(
          currentIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() => _currentIndex = index);
            _drawerController.toggle!();
          },
        ),
        mainScreen: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 0,
            toolbarHeight: 70,
            title: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      if (!_showSearchBar) ...[
                        IconButton(
                          icon: const Icon(HugeIconsStroke.menu02, size: 22),
                          onPressed: () => _drawerController.toggle!(),
                        ),
                        SizedBox(width: 5),
                        if (_currentIndex < 1) ...[
                          Row(
                            children: [
                              ClipOval(
                                child: ValueListenableBuilder(
                                  valueListenable: avatarNotifier,
                                  builder: (context, avatar, _) {
                                    return avatar != null
                                        ? Image.network(
                                            avatar,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _defaultAvatar(),
                                          )
                                        : _defaultAvatar();
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  Text(
                                    "Hi, ",
                                    style: AppTheme.textTitle(context).copyWith(
                                      fontSize: 20,
                                      fontFamily: AppFontFamily.poppinsBold,
                                    ),
                                  ),
                                  Text(
                                    _currentIndex > 0
                                        ? menus[_currentIndex]
                                        : _isLoadingUser
                                        ? ''
                                        : user?["name"] ?? 'Unknown User',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.textTitle(context).copyWith(
                                      fontSize: 20,
                                      fontFamily: AppFontFamily.poppinsLight,
                                    ),
                                  ),
                                  Text(
                                    ".",
                                    style: AppTheme.textTitleActive(context)
                                        .copyWith(
                                          fontFamily: 'Poppins',
                                          fontSize: 18,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                        if (_currentIndex > 0) ...[
                          Image.asset(
                            AppTheme.appLogo(context),
                            height: 120,
                            width: 60,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "My",
                            style: AppTheme.textTitle(context).copyWith(
                              fontSize: 20,
                              fontFamily: AppFontFamily.poppinsBold,
                            ),
                          ),
                          Text(
                            menus[_currentIndex],
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
                            ).copyWith(fontFamily: 'Poppins', fontSize: 18),
                          ),
                        ],

                        const Spacer(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              InkWell(
                onTap: () {
                  DialogLogout().showDialog(context, _logout);
                },
                child: const Icon(HugeIconsStroke.logout02, size: 20),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: user == null
              ? const Center(child: LoadingLogo())
              : IndexedStack(index: _currentIndex, children: _pages()),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            elevation: 0,
            iconSize: 24,
            landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
            selectedLabelStyle: AppTheme.textLabel(
              context,
            ).copyWith(fontSize: 12),
            unselectedLabelStyle: AppTheme.textLabel(
              context,
            ).copyWith(fontSize: 11),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            selectedItemColor: AppTheme.onBoardingDotActive(context),
            unselectedItemColor: AppTheme.onBoardingDot(context),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(HugeIconsStroke.home11),
                activeIcon: Icon(HugeIconsSolid.home11),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(HugeIconsStroke.home11),
                activeIcon: Icon(HugeIconsSolid.home11),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(HugeIconsStroke.userMultiple02),
                activeIcon: Icon(HugeIconsSolid.userMultiple02),
                label: "Ledgers",
              ),
              BottomNavigationBarItem(
                icon: Icon(HugeIconsStroke.user03),
                activeIcon: Icon(HugeIconsSolid.user03),
                label: "Accounts",
              ),
            ],
          ),
        ),
        borderRadius: 24.0,
        showShadow: true,
        angle: -8.0,
        mainScreenScale: 0.05, // slightly more zoom-in effect
        shadowLayer1Color: AppTheme.customListBg(context).withOpacity(0.5),
        shadowLayer2Color: AppTheme.customListBg(context).withOpacity(1.0),
        mainScreenTapClose: true,
        // overlayBlur: 0.8,
        slideWidth: MediaQuery.of(context).size.width * 0.85,
        menuBackgroundColor: Colors.transparent,
        openCurve: Curves.fastOutSlowIn,
        closeCurve: Curves.easeInBack,
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: child,
            ),
          );
        } else {
          return child!;
        }
      },
    );
  }
}
