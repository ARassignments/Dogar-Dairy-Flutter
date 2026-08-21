import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import '/providers/notification_provider.dart';
import '/screens/notifications_screen.dart';
import '/theme/theme.dart';

class AnimatedNotificationBell extends ConsumerStatefulWidget {
  const AnimatedNotificationBell({super.key});

  @override
  ConsumerState<AnimatedNotificationBell> createState() =>
      _AnimatedNotificationBellState();
}

class _AnimatedNotificationBellState
    extends ConsumerState<AnimatedNotificationBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _rotationAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 0.18,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.18,
          end: -0.18,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.18,
          end: 0.12,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.12,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 45, // pause before next ring cycle
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openNotifications() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NotificationsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationProvider);
    final isEnabled = notifState.isEnabled;
    final unreadCount = notifState.unreadCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isEnabled || unreadCount == 0) {
      if (_controller.isAnimating) {
        _controller.stop();
        _controller.reset();
      }
    } else {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }

    return InkWell(
      onTap: _openNotifications,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _rotationAnim,
              builder: (context, child) {
                final angle = (isEnabled && unreadCount > 0)
                    ? _rotationAnim.value * math.pi
                    : 0.0;
                return Transform.rotate(
                  angle: angle,
                  alignment: Alignment.topCenter,
                  child: child,
                );
              },
              child: Icon(
                isEnabled
                    ? (unreadCount > 0
                          ? HugeIconsSolid.notification01
                          : HugeIconsStroke.notification01)
                    : HugeIconsStroke.notificationOff01,
                color: isEnabled
                    ? (unreadCount > 0
                          ? (isDark
                                ? AppTheme.iconColor(context)
                                : AppColor.primaryColor)
                          : AppTheme.iconColor(context))
                    : AppTheme.iconColorThree(context).withValues(alpha: 0.4),
                size: 24,
              ),
            ),
            if (isEnabled && unreadCount > 0)
              Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.customListBg(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? "9+" : "$unreadCount",
                      style: AppTheme.textLabel(context).copyWith(
                        fontSize: 9,
                        fontFamily: AppFontFamily.poppinsBold,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
