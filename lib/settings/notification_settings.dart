import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import '/components/appsnackbar.dart';
import '/services/notification_service.dart';
import '/theme/theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    await NotificationService.loadSettings();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleMaster(bool value) async {
    setState(() {
      NotificationService.masterEnabled = value;
    });
    await NotificationService.setMasterEnabled(value);
    if (value) {
      final granted = await NotificationService.requestPermission();
      if (!granted && mounted) {
        AppSnackBar.show(
          context,
          message: "Please allow notifications in device settings",
          type: AppSnackBarType.warning,
        );
      }
    }
  }

  Future<void> _toggleChannel(String key, bool value) async {
    setState(() {
      NotificationService.updatePreference(key, value);
    });
  }

  Future<void> _triggerTest({String? title, String? message}) async {
    if (!NotificationService.masterEnabled) {
      AppSnackBar.show(
        context,
        message: "Please enable master notifications first",
        type: AppSnackBarType.warning,
      );
      return;
    }

    setState(() => _isTesting = true);

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      await NotificationService.sendTestNotification(
        context,
        customTitle: title,
        customMessage: message,
      );
      setState(() => _isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final platformName = NotificationService.getPlatformName();

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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Platform & Sync Status Header Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: NotificationService.masterEnabled
                            ? (isDark
                                  ? AppColor.primary_90.withValues(alpha: 0.5)
                                  : AppColor.primary_5)
                            : (isDark
                                  ? AppColor.neutral_80
                                  : AppColor.neutral_10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: NotificationService.masterEnabled
                              ? (isDark
                                    ? AppColor.primary_70
                                    : AppColor.primary_20)
                              : (isDark
                                    ? AppColor.neutral_70
                                    : AppColor.neutral_20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: NotificationService.masterEnabled
                                  ? AppTheme.togglerColor(
                                      context,
                                    ).withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              NotificationService.masterEnabled
                                  ? HugeIconsSolid.notification01
                                  : HugeIconsStroke.notificationOff01,
                              color: NotificationService.masterEnabled
                                  ? AppTheme.togglerColor(context)
                                  : Colors.grey,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Active Platform: ",
                                      style: AppTheme.textLabel(context)
                                          .copyWith(
                                            fontSize: 12,
                                            fontFamily:
                                                AppFontFamily.poppinsMedium,
                                          ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.togglerColor(context),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        platformName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontFamily:
                                              AppFontFamily.poppinsSemiBold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  NotificationService.masterEnabled
                                      ? "Synced for Android, iOS, Web & Windows"
                                      : "Notifications are currently paused",
                                  style: AppTheme.textSearchInfoLabeled(
                                    context,
                                  ).copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Master Push Notification Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        secondary: Icon(
                          HugeIconsStroke.notification02,
                          color: AppTheme.iconColor(context),
                          size: 24,
                        ),
                        title: Text(
                          "Enable Notifications",
                          style: AppTheme.textTitle(context).copyWith(
                            fontSize: 15,
                            fontFamily: AppFontFamily.poppinsSemiBold,
                          ),
                        ),
                        subtitle: Text(
                          "Receive real-time alerts across all your connected devices",
                          style: AppTheme.textSearchInfoLabeled(
                            context,
                          ).copyWith(fontSize: 12),
                        ),
                        activeThumbColor: AppTheme.togglerColor(context),
                        value: NotificationService.masterEnabled,
                        onChanged: _toggleMaster,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Notification Channel Preferences
                    Text(
                      "Alert Preferences",
                      style: AppTheme.textLabel(context).copyWith(
                        fontSize: 14,
                        fontFamily: AppFontFamily.poppinsSemiBold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    AnimatedOpacity(
                      opacity: NotificationService.masterEnabled ? 1.0 : 0.4,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: !NotificationService.masterEnabled,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg(context),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildPreferenceTile(
                                icon: HugeIconsStroke.truck,
                                title: "Daily Delivery Alerts",
                                subtitle:
                                    "Morning & evening route departure and arrival notices",
                                value: NotificationService.deliveryAlerts,
                                onChanged: (v) => _toggleChannel(
                                  NotificationService.keyDelivery,
                                  v,
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: AppTheme.dividerBg(context),
                              ),
                              _buildPreferenceTile(
                                icon: HugeIconsStroke.invoice01,
                                title: "Khata & Billing Reminders",
                                subtitle:
                                    "Monthly ledger invoices, bill generation, and payment receipts",
                                value: NotificationService.khataAlerts,
                                onChanged: (v) => _toggleChannel(
                                  NotificationService.keyKhata,
                                  v,
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: AppTheme.dividerBg(context),
                              ),
                              _buildPreferenceTile(
                                icon: HugeIconsStroke.milkCarton,
                                title: "Milk Quota & Subscription Updates",
                                subtitle:
                                    "Route updates, pause schedule confirmations & extra milk alerts",
                                value: NotificationService.orderAlerts,
                                onChanged: (v) => _toggleChannel(
                                  NotificationService.keyOrder,
                                  v,
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: AppTheme.dividerBg(context),
                              ),
                              _buildPreferenceTile(
                                icon: HugeIconsStroke.discount01,
                                title: "Farm Deals & Promotions",
                                subtitle:
                                    "Special seasonal discounts on Desi Ghee, Butter & Dairy items",
                                value: NotificationService.offersAlerts,
                                onChanged: (v) => _toggleChannel(
                                  NotificationService.keyOffers,
                                  v,
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: AppTheme.dividerBg(context),
                              ),
                              _buildPreferenceTile(
                                icon: HugeIconsStroke.volumeHigh,
                                title: "Sound & Vibration",
                                subtitle:
                                    "Play notification tone and vibrate on incoming alerts",
                                value: NotificationService.soundEnabled,
                                onChanged: (v) => _toggleChannel(
                                  NotificationService.keySound,
                                  v,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Test Notification Center
                    Text(
                      "Test Notification Module",
                      style: AppTheme.textLabel(context).copyWith(
                        fontSize: 14,
                        fontFamily: AppFontFamily.poppinsSemiBold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                HugeIconsSolid.checkmarkBadge02,
                                size: 20,
                                color: const Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Verify Device Receiving",
                                style: AppTheme.textTitle(context).copyWith(
                                  fontSize: 14,
                                  fontFamily: AppFontFamily.poppinsSemiBold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Press the button below to simulate an immediate push notification on this device ($platformName).",
                            style: AppTheme.textSearchInfoLabeled(
                              context,
                            ).copyWith(fontSize: 12),
                          ),
                          const SizedBox(height: 16),

                          // Main Test Button
                          FlatButton(
                            text: _isTesting
                                ? "Dispatching Test..."
                                : "Send Test Notification",
                            icon: HugeIconsStroke.sent,
                            iconLeft: true,
                            onPressed: _isTesting
                                ? null
                                : () => _triggerTest(
                                    title: "Dogar Dairy Pure Farm",
                                    message:
                                        "Your morning milk delivery of 2.0L Buffalo Milk is on its way!",
                                  ),
                            loading: _isTesting,
                            disabled: _isTesting,
                          ),

                          const SizedBox(height: 14),

                          // Quick Scenario Test Buttons
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildQuickTestChip(
                                label: "🚚 Delivery Arrival",
                                title: "Rider Arriving Soon",
                                message:
                                    "Your dairy rider Muhammad Ali is 5 mins away.",
                              ),
                              _buildQuickTestChip(
                                label: "🧾 Payment Received",
                                title: "Khata Sync Confirmed",
                                message:
                                    "Received Rs. 4,200 for August Billing. Thank you!",
                              ),
                              _buildQuickTestChip(
                                label: "🧈 20% Off Desi Ghee",
                                title: "Weekend Farm Offer",
                                message:
                                    "Special discount on pure Desi Ghee & Fresh Butter.",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Icon(icon, color: AppTheme.iconColor(context), size: 22),
      title: Text(
        title,
        style: AppTheme.textLabel(
          context,
        ).copyWith(fontSize: 13, fontFamily: AppFontFamily.poppinsMedium),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.textSearchInfoLabeled(context).copyWith(fontSize: 11),
      ),
      activeThumbColor: AppTheme.togglerColor(context),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildQuickTestChip({
    required String label,
    required String title,
    required String message,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => _triggerTest(title: title, message: message),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColor.neutral_80 : AppColor.neutral_10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColor.neutral_70 : AppColor.neutral_20,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.textLabel(
            context,
          ).copyWith(fontSize: 11, fontFamily: AppFontFamily.poppinsMedium),
        ),
      ),
    );
  }
}
