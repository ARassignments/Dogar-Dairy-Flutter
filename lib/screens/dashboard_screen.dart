import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import '/providers/search_provider.dart';
import '/providers/user_provider.dart';
import '/components/animated_notification_bell.dart';
import '/components/dialog_logout.dart';
import '/components/menu_drawer.dart';
import '/components/loading_screen.dart';
import '/notifiers/avatar_notifier.dart';
import '/screens/fragments/account_screen.dart';
import '/screens/fragments/deliveries_screen.dart';
import '/screens/fragments/home_screen.dart';
import '/screens/fragments/khata_screen.dart';
import '/screens/auth/login_screen.dart';
import '/theme/theme.dart';
import '/utils/session_manager.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic>? user;
  bool _isLoadingUser = true;

  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchBar = false;
  final auth = FirebaseAuth.instance;
  final ZoomDrawerController _drawerController = ZoomDrawerController();
  late final List<Widget> pages;
  final DeliveriesScreen deliveriesScreen = const DeliveriesScreen();
  final KhataScreen khataScreen = const KhataScreen();
  final AccountScreen accountScreen = const AccountScreen();

  List<String> _getRoleMenus(String role) {
    final r = role.toLowerCase();
    if (r == 'staff') {
      return const ["Home", "Supply", "Ledgers", "Accounts"];
    } else if (r == 'admin') {
      return const ["Overview", "Vendors", "Plans", "Accounts"];
    } else {
      return const ["Home", "Deliveries", "Khata", "Accounts"];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSession();
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (ref.read(searchQueryProvider) != query) {
        ref.read(searchQueryProvider.notifier).state = query;
      }
    });
    pages = [
      HomeScreen(
        onMenuSelect: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      deliveriesScreen,
      khataScreen,
      accountScreen,
    ];
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSession() async {
    final userData = await SessionManager.getUser();
    if (mounted) {
      setState(() {
        user = userData;
        _isLoadingUser = false;
      });
    }
  }

  void closeSearchBar() {
    setState(() {
      _showSearchBar = false;
      _searchController.clear();
    });
    ref.read(searchQueryProvider.notifier).state = "";
  }

  Future<void> _logout() async {
    await SessionManager.clearSession();
    await auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    }
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
    final userModel = ref.watch(userProvider);
    final role =
        (userModel?.role.isNotEmpty == true
                ? userModel!.role
                : (user?["role"] ?? 'customer'))
            .toString()
            .toLowerCase();
    final menus = _getRoleMenus(role);

    Widget child = Scaffold(
      body: ZoomDrawer(
        controller: _drawerController,
        menuScreen: MenuDrawer(
          currentIndex: _currentIndex,
          role: role,
          onItemSelected: (index) {
            closeSearchBar();
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
                        InkWell(
                          onTap: () => _drawerController.toggle!(),
                          child: Icon(
                            HugeIconsStroke.menu02,
                            color: AppTheme.iconColor(context),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                                      fontFamily: 'Poppins',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    _isLoadingUser
                                        ? ''
                                        : (userModel?.name.isNotEmpty == true
                                              ? userModel!.name
                                              : (user?["name"] ?? 'Vendor')),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.textTitle(context).copyWith(
                                      fontFamily: 'Poppins',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300,
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
                          Text(
                            "My",
                            style: AppTheme.textTitle(context).copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            menus[_currentIndex],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.textTitle(context).copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
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
                      if (_showSearchBar) ...[
                        Expanded(
                          child: TextFormField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: "Search",
                              hintText: "Search Here...",
                              prefixIcon: const Icon(HugeIconsSolid.search01),
                              counter: const SizedBox.shrink(),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        HugeIconsStroke.cancel02,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        ref
                                                .read(
                                                  searchQueryProvider.notifier,
                                                )
                                                .state =
                                            "";
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              } else if (!RegExp(
                                r'^[a-zA-Z0-9 ]+$',
                              ).hasMatch(value)) {
                                return 'Must contain only letters or digits';
                              }
                              return null;
                            },
                            maxLength: 20,
                            onChanged: (value) {
                              ref.read(searchQueryProvider.notifier).state =
                                  value;
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (_currentIndex > 0 && _currentIndex < 3)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showSearchBar = !_showSearchBar;
                              if (_showSearchBar) {
                                Future.delayed(
                                  const Duration(milliseconds: 50),
                                  () {
                                    _searchFocusNode.requestFocus();
                                  },
                                );
                              } else {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state =
                                    "";
                              }
                            });
                          },
                          child: Icon(
                            _showSearchBar
                                ? HugeIconsStroke.cancel02
                                : HugeIconsSolid.search01,
                            color: AppTheme.iconColor(context),
                            size: 24,
                          ),
                        ),
                      if (!_showSearchBar) ...[
                        const SizedBox(width: 8),
                        const AnimatedNotificationBell(),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            DialogLogout().showDialog(context, _logout);
                          },
                          child: Icon(
                            HugeIconsStroke.logout02,
                            color: AppTheme.iconColor(context),
                            size: 24,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: user == null && userModel == null
              ? const Center(child: LoadingLogo())
              : IndexedStack(index: _currentIndex, children: pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              closeSearchBar();
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
                icon: const Icon(HugeIconsStroke.home11),
                activeIcon: const Icon(HugeIconsSolid.home11),
                label: menus[0],
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  role == 'staff'
                      ? HugeIconsStroke.truck
                      : (role == 'admin'
                            ? HugeIconsStroke.userGroup
                            : HugeIconsStroke.calendar01),
                ),
                activeIcon: Icon(
                  role == 'staff'
                      ? HugeIconsSolid.truck
                      : (role == 'admin'
                            ? HugeIconsSolid.userGroup
                            : HugeIconsSolid.calendar01),
                ),
                label: menus[1],
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  role == 'staff'
                      ? HugeIconsStroke.userMultiple02
                      : (role == 'admin'
                            ? HugeIconsStroke.crown03
                            : HugeIconsStroke.invoice01),
                ),
                activeIcon: Icon(
                  role == 'staff'
                      ? HugeIconsSolid.userMultiple02
                      : (role == 'admin'
                            ? HugeIconsSolid.crown03
                            : HugeIconsSolid.invoice01),
                ),
                label: menus[2],
              ),
              BottomNavigationBarItem(
                icon: const Icon(HugeIconsStroke.user03),
                activeIcon: const Icon(HugeIconsSolid.user03),
                label: menus[3],
              ),
            ],
          ),
        ),
        borderRadius: 24.0,
        showShadow: true,
        angle: -8.0,
        mainScreenScale: 0.05,
        shadowLayer1Color: AppTheme.customListBg(
          context,
        ).withValues(alpha: 0.5),
        shadowLayer2Color: AppTheme.customListBg(
          context,
        ).withValues(alpha: 1.0),
        mainScreenTapClose: true,
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
          return child;
        }
      },
    );
  }
}
