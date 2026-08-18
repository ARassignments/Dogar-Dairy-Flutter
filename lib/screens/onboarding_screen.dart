import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '/screens/auth/login_screen.dart';
import '/theme/theme.dart';
import '/utils/session_manager.dart';

/// Data model for each Onboarding step
class OnboardingItem {
  final String title;
  final String highlightWord;
  final String description;
  final String badgeText;
  final IconData badgeIcon;
  final int index;

  const OnboardingItem({
    required this.title,
    required this.highlightWord,
    required this.description,
    required this.badgeText,
    required this.badgeIcon,
    required this.index,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.90);
  int _currentPage = 0;

  // Continuous animation controller for ambient motion graphics
  late AnimationController _ambientController;
  late AnimationController _waveController;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      title: '100% Pure & Fresh',
      highlightWord: 'Farm Milk',
      description:
          'Experience the organic goodness of fresh buffalo and cow milk delivered straight from our certified farms to your doorstep every morning.',
      badgeText: 'Farm Direct Purity',
      badgeIcon: HugeIconsStroke.milkCarton,
      index: 0,
    ),
    OnboardingItem(
      title: 'Smart Quota & Flexible',
      highlightWord: 'Subscriptions',
      description:
          'Customize your daily morning and evening milk quantities with ease. Pause, resume, or modify your delivery plan with a single tap.',
      badgeText: 'Automated Delivery',
      badgeIcon: HugeIconsStroke.calendar01,
      index: 1,
    ),
    OnboardingItem(
      title: 'Real-Time Ledger &',
      highlightWord: 'Digital Khata',
      description:
          'Track your daily milk consumption, view transparent monthly invoices, manage payments, and download official receipts anytime.',
      badgeText: 'Transparent Accounts',
      badgeIcon: HugeIconsStroke.payment01,
      index: 2,
    ),
    OnboardingItem(
      title: 'Certified Quality &',
      highlightWord: 'Complete Control',
      description:
          'Enjoy laboratory-tested milk with live lactometer metrics, dedicated customer support, and a seamless dairy management ecosystem.',
      badgeText: 'Quality Assured',
      badgeIcon: HugeIconsSolid.checkmarkBadge02,
      index: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ambientController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  /// Complete onboarding and navigate to login screen
  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    // Persist onboarding completion status to SharedPreferences
    await SessionManager.setOnboardingCompleted(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColor.primaryColor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Stack(
                children: [
                  // Main Content Column
                  Column(
                    children: [
                      // Top Header (Logo + Skip Button)
                      _buildTopHeader(isDark),

                      // Animated PageView with native smooth swiping & Overscroll Completion
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification notification) {
                            if (notification is OverscrollNotification &&
                                notification.overscroll > 25 &&
                                _currentPage == _pages.length - 1) {
                              _completeOnboarding();
                              return true;
                            }
                            return false;
                          },
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                                PointerDeviceKind.trackpad,
                                PointerDeviceKind.stylus,
                              },
                            ),
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _pages.length,
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              onPageChanged: (index) {
                                setState(() => _currentPage = index);
                              },
                              itemBuilder: (context, index) {
                                return _buildPageItem(
                                  item: _pages[index],
                                  isDark: isDark,
                                  primaryColor: primaryColor,
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // Bottom Navigation & Controls
                      _buildBottomControls(isDark, primaryColor),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Top Header with Dogar Dairy branding and Skip button
  Widget _buildTopHeader(bool isDark) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dogar Dairy Brand Pill
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  AppTheme.appLogoLauncher(context),
                  fit: BoxFit.fitWidth,
                ),
              ),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'DOGAR DAIRY',
                    style: AppTheme.textLabel(context).copyWith(
                      fontFamily: 'PoppinsBold',
                      fontSize: 14,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Pure Farm Platform',
                    style: AppTheme.textSearchInfoLabeled(context).copyWith(
                      fontFamily: 'PoppinsRegular',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Skip Button (fades out on the last page)
          AnimatedOpacity(
            opacity: isLastPage ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: isLastPage,
              child: TextButton(
                onPressed: _completeOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: isDark
                      ? Colors.white70
                      : const Color(0xFF6B7280),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Skip',
                      style: AppTheme.textLabel(context).copyWith(
                        fontFamily: 'PoppinsMedium',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      HugeIconsStroke.arrowRight01,
                      size: 14,
                      color: AppTheme.iconColor(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single onboarding swiper card with smooth scaling, 3D depth, and parallax
  Widget _buildPageItem({
    required OnboardingItem item,
    required bool isDark,
    required Color primaryColor,
  }) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double pageOffset = 0.0;
        if (_pageController.hasClients &&
            _pageController.position.haveDimensions) {
          pageOffset =
              (_pageController.page ?? _currentPage.toDouble()) - item.index;
        }

        // Swiper card scale and opacity interpolation
        final double cardScale = (1.0 - (pageOffset.abs() * 0.08)).clamp(
          0.90,
          1.0,
        );
        final double cardOpacity = (1.0 - (pageOffset.abs() * 0.40)).clamp(
          0.50,
          1.0,
        );
        final double motionGraphicScale = (1.0 - (pageOffset.abs() * 0.15))
            .clamp(0.85, 1.0);
        final double motionGraphicTranslate = -pageOffset * 30;
        final double textTranslate = -pageOffset * 15;

        return Opacity(
          opacity: cardOpacity,
          child: Transform.scale(
            scale: cardScale,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: IgnorePointer(
                ignoring: true,
                child: Column(
                  children: [
                    const SizedBox(height: 6),

                    // Motion Graphic Graphic Area with Parallax
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(motionGraphicTranslate, 0),
                          child: Transform.scale(
                            scale: motionGraphicScale,
                            child: _buildMotionGraphic(
                              item.index,
                              isDark,
                              primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Text section with subtle Parallax
                    Transform.translate(
                      offset: Offset(textTranslate, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Badge tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(
                                alpha: isDark ? 0.18 : 0.10,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: primaryColor.withValues(
                                  alpha: isDark ? 0.35 : 0.25,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.badgeIcon,
                                  size: 15,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.badgeText,
                                  style: TextStyle(
                                    fontFamily: 'PoppinsMedium',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Title & Highlight Word
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'PoppinsBold',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                height: 1.22,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF181F2C),
                              ),
                              children: [
                                TextSpan(text: '${item.title}\n'),
                                TextSpan(
                                  text: item.highlightWord,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontFamily: 'PoppinsBold',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              item.description,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'PoppinsRegular',
                                fontSize: 13,
                                height: 1.45,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF5E6B7E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Motion Graphic Builder for each specific slide index
  Widget _buildMotionGraphic(int index, bool isDark, Color primaryColor) {
    switch (index) {
      case 0:
        return _buildPureMilkMotionGraphic(isDark, primaryColor);
      case 1:
        return _buildSubscriptionScheduleMotionGraphic(isDark, primaryColor);
      case 2:
        return _buildLedgerAccountMotionGraphic(isDark, primaryColor);
      case 3:
      default:
        return _buildEcosystemQualityMotionGraphic(isDark, primaryColor);
    }
  }

  // ===========================================================================
  // MOTION GRAPHIC 1: PURE FARM MILK & ANIMATED POURING STREAM PHYSICS
  // ===========================================================================
  Widget _buildPureMilkMotionGraphic(bool isDark, Color primaryColor) {
    return AnimatedBuilder(
      animation: Listenable.merge([_ambientController, _waveController]),
      builder: (context, child) {
        final waveVal = _waveController.value;
        final floatVal = _ambientController.value;

        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glowing Aura Rings
              Container(
                width: 235 + (floatVal * 12),
                height: 235 + (floatVal * 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withValues(alpha: isDark ? 0.20 : 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Animated Circular Milk Reservoir with Live Pouring Stream
              Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF181F2C) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(
                        alpha: isDark ? 0.35 : 0.18,
                      ),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Stack(
                    children: [
                      // Animated Liquid Wave in reservoir
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _LiquidWavePainter(
                            wavePhase: waveVal * 2 * math.pi,
                            isDark: isDark,
                            primaryColor: primaryColor,
                          ),
                        ),
                      ),

                      // Center Floating Purity Drop Icon
                      Center(
                        child: Transform.translate(
                          offset: Offset(0, -10 + (floatVal * 8)),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.water_drop_rounded,
                              size: 42,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Orbiting Purity Badge (Cow & Buffalo)
              Positioned(
                top: 20 + (math.sin(floatVal * math.pi) * 8),
                left: 6,
                child: _buildFloatingMiniCard(
                  icon: Icons.grass_rounded,
                  label: '100% Organic',
                  sub: 'Grass-Fed',
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ),

              // Orbiting Freshness Badge
              Positioned(
                bottom: 16 + (math.cos(floatVal * math.pi) * 8),
                right: 4,
                child: _buildFloatingMiniCard(
                  icon: Icons.verified_rounded,
                  label: 'Morning Pure',
                  sub: 'Buffalo & Cow',
                  color: const Color(0xFF3B82F6),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MOTION GRAPHIC 2: SMART MILK SUPPLY & DISPATCH FLEET IN MOTION
  // ===========================================================================
  Widget _buildSubscriptionScheduleMotionGraphic(
    bool isDark,
    Color primaryColor,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge([_ambientController, _waveController]),
      builder: (context, child) {
        final floatVal = _ambientController.value;
        final animVal = _waveController.value;

        return SizedBox(
          width: 290,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glowing Delivery Aura Ring
              Container(
                width: 240 + (floatVal * 10),
                height: 240 + (floatVal * 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withValues(alpha: isDark ? 0.18 : 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Central Milk Supply Van & Moving Road Card
              Container(
                width: 220,
                height: 185,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2433) : Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(
                        alpha: isDark ? 0.35 : 0.14,
                      ),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Moving Milk Supply Van with dynamic suspension and sloshing milk
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Delivery Van Body with suspension bounce
                          Transform.translate(
                            offset: Offset(
                              0,
                              math.sin(animVal * 4 * math.pi) * 2.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Rear Milk Tanker (with sloshing milk wave inside)
                                Container(
                                  width: 72,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: primaryColor.withValues(
                                        alpha: 0.4,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      children: [
                                        // Sloshing milk wave inside the tank
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          height: 30,
                                          child: CustomPaint(
                                            painter: _LiquidWavePainter(
                                              wavePhase: animVal * 2 * math.pi,
                                              isDark: isDark,
                                              primaryColor: primaryColor,
                                            ),
                                          ),
                                        ),
                                        // Milk Icon Watermark on Tank
                                        Center(
                                          child: Icon(
                                            HugeIconsSolid.milkCarton,
                                            size: 25,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 4),

                                // Front Driver Cabin
                                Container(
                                  width: 48,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(16),
                                      bottomRight: Radius.circular(10),
                                      topLeft: Radius.circular(6),
                                      bottomLeft: Radius.circular(6),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Windshield
                                      Container(
                                        width: 28,
                                        height: 18,
                                        margin: const EdgeInsets.only(left: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(8),
                                            bottomRight: Radius.circular(4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Headlight
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          margin: const EdgeInsets.only(
                                            right: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColor.accent_50,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFFD54F),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Animated Spinning Wheels
                          Positioned(
                            bottom: 12,
                            left: 54,
                            child: _buildSpinningWheel(animVal, primaryColor),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 56,
                            child: _buildSpinningWheel(animVal, primaryColor),
                          ),
                        ],
                      ),
                    ),

                    // Animated Moving Road with scrolling center dashes
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF111827)
                            : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CustomPaint(
                          painter: _MovingRoadDashesPainter(progress: animVal),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Dispatch Status Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Daily Milk Supply • Active',
                          style: TextStyle(
                            fontFamily: 'PoppinsBold',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E2530),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Floating Pill 1: Morning Milk Slot
              Positioned(
                top: 12 + (floatVal * 6),
                left: 8,
                child: _buildFloatingMiniCard(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Morning Milk',
                  sub: 'Buffalo 2.5L',
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ),

              // Floating Pill 2: Evening Milk Slot
              Positioned(
                bottom: 10 - (floatVal * 6),
                right: 8,
                child: _buildFloatingMiniCard(
                  icon: Icons.nightlight_round,
                  label: 'Evening Milk',
                  sub: 'Cow 1.0L',
                  color: const Color(0xFF8B5CF6),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper to build a spinning delivery wheel
  Widget _buildSpinningWheel(double animVal, Color primaryColor) {
    return Transform.rotate(
      angle: animVal * 2 * math.pi,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.primary_60,
          border: Border.all(color: Colors.white70, width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // MOTION GRAPHIC 3: DIGITAL KHATA & ACCOUNT LEDGER
  // ===========================================================================
  Widget _buildLedgerAccountMotionGraphic(bool isDark, Color primaryColor) {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final floatVal = _ambientController.value;

        return SizedBox(
          width: 290,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main Khata Digital Ledger Card
              Container(
                width: 215,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2433) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(
                        alpha: isDark ? 0.35 : 0.14,
                      ),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 18,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Khata Balance',
                              style: TextStyle(
                                fontFamily: 'PoppinsSemiBold',
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Paid',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Rs. 4,850',
                      style: TextStyle(
                        fontFamily: 'PoppinsBold',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Mini Graph Bars Animation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildGraphBar(0.4 + (floatVal * 0.15), primaryColor),
                        _buildGraphBar(0.7 - (floatVal * 0.1), primaryColor),
                        _buildGraphBar(0.9, const Color(0xFF10B981)),
                        _buildGraphBar(0.6 + (floatVal * 0.12), primaryColor),
                        _buildGraphBar(0.85 - (floatVal * 0.15), primaryColor),
                        _buildGraphBar(0.5 + (floatVal * 0.2), primaryColor),
                      ],
                    ),
                  ],
                ),
              ),

              // Floating Receipt Badge (Top Left)
              Positioned(
                top: 15 + (floatVal * 8),
                left: 8,
                child: _buildFloatingMiniCard(
                  icon: Icons.receipt_long_rounded,
                  label: 'Instant Invoice',
                  sub: 'Auto Billed',
                  color: const Color(0xFF0EA5E9),
                  isDark: isDark,
                ),
              ),

              // Floating Payment Badge (Bottom Right)
              Positioned(
                bottom: 12 - (floatVal * 8),
                right: 8,
                child: _buildFloatingMiniCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Reconciliation',
                  sub: '100% Accurate',
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGraphBar(double heightFactor, Color color) {
    return Container(
      width: 14,
      height: 38 * heightFactor.clamp(0.2, 1.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ===========================================================================
  // MOTION GRAPHIC 4: QUALITY ASSURANCE & COMPLETE ECOSYSTEM
  // ===========================================================================
  Widget _buildEcosystemQualityMotionGraphic(bool isDark, Color primaryColor) {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final floatVal = _ambientController.value;

        return SizedBox(
          width: 290,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing Outer Shield Glow
              Container(
                width: 220 + (floatVal * 16),
                height: 220 + (floatVal * 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(
                        0xFF10B981,
                      ).withValues(alpha: isDark ? 0.22 : 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Central Quality Shield Card
              Container(
                width: 195,
                height: 195,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1A2230) : Colors.white,
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF10B981,
                      ).withValues(alpha: isDark ? 0.3 : 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: 1.0 + (floatVal * 0.08),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.15),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          size: 42,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Lactometer Grade A',
                      style: TextStyle(
                        fontFamily: 'PoppinsBold',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E2530),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Purity Guaranteed',
                      style: TextStyle(
                        fontFamily: 'PoppinsRegular',
                        fontSize: 10.5,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Badge Top Right: Support
              Positioned(
                top: 15 + (floatVal * 6),
                right: 8,
                child: _buildFloatingMiniCard(
                  icon: Icons.support_agent_rounded,
                  label: '24/7 Care',
                  sub: 'Instant Help',
                  color: const Color(0xFF3B82F6),
                  isDark: isDark,
                ),
              ),

              // Floating Badge Bottom Left: Rating
              Positioned(
                bottom: 15 - (floatVal * 6),
                left: 8,
                child: _buildFloatingMiniCard(
                  icon: Icons.star_rounded,
                  label: '5-Star Trust',
                  sub: '10k+ Families',
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Reusable floating glassmorphic mini card for motion graphics
  Widget _buildFloatingMiniCard({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF222B3C).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PoppinsBold',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E2530),
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  fontFamily: 'PoppinsRegular',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bottom Controls: Smooth Indicator + Swipe Hint + Morphing Action Button
  Widget _buildBottomControls(bool isDark, Color primaryColor) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Smooth Indicator + Swipe Hint
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: primaryColor,
                  dotColor: AppTheme.onBoardingDot(context),
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3.5,
                  spacing: 6,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedOpacity(
                opacity: _currentPage < _pages.length - 1 ? 0.75 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      HugeIconsSolid.swipeLeft01,
                      size: 13,
                      color: AppTheme.onBoardingDot(
                        context,
                      ).withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Swipe or tap next',
                      style: TextStyle(
                        fontFamily: 'PoppinsRegular',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onBoardingDot(
                          context,
                        ).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Morphing Action Button
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 350),
            crossFadeState: isLastPage
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _buildCircularNextButton(primaryColor, isDark),
            secondChild: _buildExpandedGetStartedButton(primaryColor),
          ),
        ],
      ),
    );
  }

  /// Circular Progress Next Button for Pages 0..2 with smoothly animated progress value
  Widget _buildCircularNextButton(Color primaryColor, bool isDark) {
    return GestureDetector(
      onTap: _nextPage,
      child: SizedBox(
        width: 62,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Smoothly Animated Circular Progress Indicator Ring
            SizedBox(
              width: 58,
              height: 58,
              child: AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double livePage = _currentPage.toDouble();
                  if (_pageController.hasClients &&
                      _pageController.position.haveDimensions) {
                    livePage = _pageController.page ?? _currentPage.toDouble();
                  }
                  final double targetProgress = ((livePage + 1) / _pages.length)
                      .clamp(0.0, 1.0);

                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: targetProgress,
                      end: targetProgress,
                    ),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, _) {
                      return CircularProgressIndicator(
                        value: animatedValue,
                        strokeWidth: 3.5,
                        strokeCap: StrokeCap.round,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : primaryColor.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      );
                    },
                  );
                },
              ),
            ),

            // Inner Button
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                HugeIconsStroke.arrowRight02,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Expanded "Get Started" Gradient Button for the Final Page
  Widget _buildExpandedGetStartedButton(Color primaryColor) {
    return ElevatedButton(
      onPressed: _completeOnboarding,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        backgroundColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Get Started',
            style: TextStyle(
              fontFamily: 'PoppinsBold',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}

/// Custom Liquid Wave Painter for Farm Fresh Milk motion graphic
class _LiquidWavePainter extends CustomPainter {
  final double wavePhase;
  final bool isDark;
  final Color primaryColor;

  _LiquidWavePainter({
    required this.wavePhase,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: isDark ? 0.35 : 0.22),
          primaryColor.withValues(alpha: isDark ? 0.65 : 0.45),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final baseHeight = size.height * 0.52;
    const waveAmplitude = 12.0;

    path.moveTo(0, baseHeight);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          baseHeight +
          math.sin((x / size.width * 2 * math.pi) + wavePhase) * waveAmplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second overlapping wave for rich depth
    final secondaryPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.15 : 0.35),
          primaryColor.withValues(alpha: isDark ? 0.4 : 0.25),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final secondaryPath = Path();
    final secondBaseHeight = size.height * 0.58;

    secondaryPath.moveTo(0, secondBaseHeight);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          secondBaseHeight +
          math.cos((x / size.width * 2 * math.pi) - wavePhase) *
              (waveAmplitude * 0.8);
      secondaryPath.lineTo(x, y);
    }

    secondaryPath.lineTo(size.width, size.height);
    secondaryPath.lineTo(0, size.height);
    secondaryPath.close();

    canvas.drawPath(secondaryPath, secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidWavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase;
  }
}

/// Custom Painter for Milk Pouring Stream from tilted can with animated splash droplets
class _MilkPourStreamPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final Color primaryColor;

  _MilkPourStreamPainter({
    required this.progress,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final streamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.80),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Arched pouring stream from top-left (can nozzle) to center base
    final startX = size.width * 0.28;
    final startY = size.height * 0.26;
    final endX = size.width * 0.50;
    final endY = size.height * 0.62;

    final streamPath = Path()
      ..moveTo(startX - 3, startY)
      ..quadraticBezierTo(
        size.width * 0.36 + math.sin(progress * 2 * math.pi) * 3,
        size.height * 0.42,
        endX - 5,
        endY,
      )
      ..lineTo(endX + 5, endY)
      ..quadraticBezierTo(
        size.width * 0.40 + math.sin(progress * 2 * math.pi) * 3,
        size.height * 0.42,
        startX + 5,
        startY,
      )
      ..close();

    canvas.drawPath(streamPath, streamPaint);

    // Dynamic Splashing Droplets flying up around the impact point
    final dropPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 3) + (math.pi / 6);
      final dist = 12 + math.sin((progress * 2 * math.pi) + i) * 10;
      final dx = endX + math.cos(angle) * dist;
      final dy =
          endY - 6 - math.sin(progress * 2 * math.pi + (i * 0.8)).abs() * 16;
      final radius = 2.5 + (i % 2) * 1.5;

      canvas.drawCircle(Offset(dx, dy), radius, dropPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MilkPourStreamPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Custom Painter for Moving Road dashes in Milk Supply fleet animation
class _MovingRoadDashesPainter extends CustomPainter {
  final double progress;

  _MovingRoadDashesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const dashWidth = 14.0;
    const dashSpace = 12.0;
    final totalDashLength = dashWidth + dashSpace;
    final offsetX = (progress * totalDashLength) % totalDashLength;

    final centerY = size.height / 2;

    for (
      double x = -totalDashLength + offsetX;
      x < size.width + totalDashLength;
      x += totalDashLength
    ) {
      canvas.drawLine(
        Offset(x, centerY),
        Offset(x + dashWidth, centerY),
        dashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MovingRoadDashesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
