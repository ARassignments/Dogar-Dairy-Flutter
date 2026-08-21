import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '/components/appsnackbar.dart';
import '/screens/help_center_screen.dart';
import '/screens/privacy_policy_screen.dart';
import '/theme/theme.dart';

class AboutDogarDairyScreen extends StatelessWidget {
  const AboutDogarDairyScreen({super.key});

  static const String appVersion = "1.0.4";
  static const String buildNumber = "2026";
  static const String websiteUrl = "https://dogardairy.netlify.app";
  static const String helplinePhone = "+923410292698";
  static const String supportEmail = "abdurrehman905623@gmail.com";

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        AppSnackBar.show(
          context,
          message: "Could not open: $urlString",
          type: AppSnackBarType.error,
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: "Could not open: $urlString",
          type: AppSnackBarType.error,
        );
      }
    }
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    const message =
        "Hello Dogar Dairy! I would like to inquire about your services.";
    final Uri url = Uri.parse(
      "https://wa.me/923410292698?text=${Uri.encodeComponent(message)}",
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        AppSnackBar.show(
          context,
          message: "WhatsApp Helpline: +92 341 0292698",
          type: AppSnackBarType.info,
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: "WhatsApp Helpline: +92 341 0292698",
          type: AppSnackBarType.info,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          "About Dogar Dairy",
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero Brand Card
              _buildBrandHero(context, isDark),
              const SizedBox(height: 20),

              // 2. Mission & Vision Card
              _buildMissionCard(context, isDark),
              const SizedBox(height: 20),

              // 3. Live Stats & Milestones
              _buildImpactStats(context, isDark),
              const SizedBox(height: 20),

              // 4. Core Pillars & Quality Assurance
              _buildPillarsSection(context, isDark),
              const SizedBox(height: 20),

              // 5. Milk Varieties Offered
              _buildMilkVarieties(context, isDark),
              const SizedBox(height: 20),

              // 6. Technology & Developer Information
              _buildCompanyInfo(context, isDark),
              const SizedBox(height: 20),

              // 7. Quick Resource Links
              _buildResourceLinks(context, isDark),
              const SizedBox(height: 24),

              // 8. Action Buttons
              FlatButton(
                text: "Visit Official Website",
                icon: HugeIconsStroke.globe02,
                onPressed: () => _launchUrl(context, websiteUrl),
              ),
              const SizedBox(height: 12),
              OutlineButton(
                text: "Chat with Us on WhatsApp",
                icon: HugeIconsSolid.message02,
                onPressed: () => _launchWhatsApp(context),
              ),
              const SizedBox(height: 28),

              // 9. Copyright & Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      "Dogar Dairy Farm & Tech Solutions",
                      style: AppTheme.textLabel(context).copyWith(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "© 2026 Dogar Dairy. All rights reserved.",
                      style: AppTheme.textSearchInfoLabeled(
                        context,
                      ).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHero(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerBg(context)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.primary_50.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.primary_50.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: Image.asset(
              AppTheme.appLogo(context),
              height: 70,
              width: 70,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                HugeIconsSolid.milkBottle,
                size: 54,
                color: AppColor.primary_50,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Dogar Dairy",
            style: AppTheme.textTitle(context).copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Pure Farm Milk & Digital Dairy SaaS",
            textAlign: TextAlign.center,
            style: AppTheme.textSearchInfoLabeled(
              context,
            ).copyWith(fontSize: 13, fontFamily: AppFontFamily.poppinsMedium),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColor.primary_50.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  HugeIconsSolid.checkmarkCircle02,
                  size: 14,
                  color: AppColor.primary_50,
                ),
                const SizedBox(width: 6),
                Text(
                  "Version $appVersion (Build $buildNumber) • Stable",
                  style: const TextStyle(
                    fontFamily: AppFontFamily.poppinsMedium,
                    fontSize: 11,
                    color: AppColor.primary_50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerBg(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  HugeIconsSolid.award02,
                  color: Color(0xFF2E7D32),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Our Story & Mission",
                style: AppTheme.textTitle(
                  context,
                ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Dogar Dairy was founded with a singular purpose: to bring 100% pure, unadulterated farm-fresh milk directly to Pakistani households while empowering dairy vendors and shopkeepers with modern cloud management software.",
            style: AppTheme.textLabel(context).copyWith(
              fontSize: 12.5,
              height: 1.55,
              color: isDark ? AppColor.neutral_30 : AppColor.neutral_80,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "By pairing ethical organic cattle farming with automated route dispatch and double-entry digital khata ledgers, we eliminate adulteration and bring complete transparency to daily milk consumption.",
            style: AppTheme.textSearchInfoLabeled(
              context,
            ).copyWith(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStats(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            count: "5,000+",
            label: "Households",
            icon: HugeIconsStroke.home03,
            color: const Color(0xFF1976D2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            context,
            count: "15,000 L",
            label: "Daily Milk",
            icon: HugeIconsSolid.milkBottle,
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            context,
            count: "120+",
            label: "Vendors",
            icon: HugeIconsStroke.store01,
            color: const Color(0xFFF57C00),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String count,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerBg(context)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            count,
            style: AppTheme.textTitle(
              context,
            ).copyWith(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.textSearchInfoLabeled(
              context,
            ).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarsSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerBg(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Why Choose Dogar Dairy?",
            style: AppTheme.textTitle(
              context,
            ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _buildPillarItem(
            context,
            icon: HugeIconsSolid.checkmarkBadge02,
            iconColor: const Color(0xFF2E7D32),
            title: "100% Pure & Unadulterated",
            desc:
                "Zero chemical preservatives, zero synthetic fats, chilled to 4°C right after milking.",
          ),
          const SizedBox(height: 14),
          _buildPillarItem(
            context,
            icon: HugeIconsSolid.truck,
            iconColor: const Color(0xFF1976D2),
            title: "Twice-Daily Doorstep Delivery",
            desc:
                "Reliable morning (6:00-8:30 AM) and evening (5:00-7:30 PM) routes with live drop alerts.",
          ),
          const SizedBox(height: 14),
          _buildPillarItem(
            context,
            icon: HugeIconsSolid.invoice01,
            iconColor: const Color(0xFFF57C00),
            title: "Transparent Digital Khata",
            desc:
                "Double-entry bookkeeping, daily consumption logs, and synchronized monthly invoices.",
          ),
          const SizedBox(height: 14),
          _buildPillarItem(
            context,
            icon: HugeIconsSolid.shield01,
            iconColor: const Color(0xFF4838D1),
            title: "Multi-Tenant Vendor SaaS",
            desc:
                "Complete enterprise tools for dairy shopkeepers to scale their business with total privacy.",
          ),
        ],
      ),
    );
  }

  Widget _buildPillarItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.textLabel(context).copyWith(
                  fontFamily: AppFontFamily.poppinsSemiBold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppTheme.textSearchInfoLabeled(
                  context,
                ).copyWith(fontSize: 11.5, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMilkVarieties(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerBg(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Our Pure Milk Varieties",
            style: AppTheme.textTitle(
              context,
            ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _buildVarietyTile(
            context,
            title: "Fresh Buffalo Milk",
            subtitle: "Rich, creamy, high natural fat (6.5% - 7.5% Fat)",
            iconPath: AppTheme.buffaloMilkIcon(context),
            fallbackIcon: HugeIconsSolid.milkBottle,
            color: const Color(0xFF4838D1),
          ),
          Divider(height: 16, color: AppTheme.dividerBg(context)),
          _buildVarietyTile(
            context,
            title: "Pure Cow Milk",
            subtitle:
                "Light, highly digestible, wholesome nutrition (3.8% - 4.5% Fat)",
            iconPath: AppTheme.cowMilkIcon(context),
            fallbackIcon: HugeIconsSolid.milkBottle,
            color: const Color(0xFF00897B),
          ),
          Divider(height: 16, color: AppTheme.dividerBg(context)),
          _buildVarietyTile(
            context,
            title: "Organic Goat Milk",
            subtitle: "Gentle, allergen-friendly, rich in natural vitamins",
            iconPath: AppTheme.goatMilkIcon(context),
            fallbackIcon: HugeIconsSolid.milkBottle,
            color: const Color(0xFFE91E63),
          ),
        ],
      ),
    );
  }

  Widget _buildVarietyTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String iconPath,
    required IconData fallbackIcon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(
            iconPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Icon(fallbackIcon, color: color, size: 22),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.textLabel(context).copyWith(
                  fontFamily: AppFontFamily.poppinsSemiBold,
                  fontSize: 13,
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
        ),
      ],
    );
  }

  Widget _buildCompanyInfo(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.customListBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerBg(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                HugeIconsStroke.building02,
                size: 18,
                color: AppColor.primary_50,
              ),
              const SizedBox(width: 8),
              Text(
                "Corporate & Farm Details",
                style: AppTheme.textLabel(context).copyWith(
                  fontFamily: AppFontFamily.poppinsSemiBold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow("Technology Partner:", "AR Assignments", context),
          const SizedBox(height: 6),
          _buildDetailRow(
            "Head Office:",
            "Dogar Dairy Farm, Karachi, Pakistan",
            context,
          ),
          const SizedBox(height: 6),
          _buildDetailRow("Helpline / WhatsApp:", "+92 341 0292698", context),
          const SizedBox(height: 6),
          _buildDetailRow(
            "Support Email:",
            "abdurrehman905623@gmail.com",
            context,
          ),
          const SizedBox(height: 6),
          _buildDetailRow(
            "Official Website:",
            "dogardairy.netlify.app",
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.textSearchInfoLabeled(
            context,
          ).copyWith(fontSize: 11.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: AppTheme.textLabel(context).copyWith(fontSize: 11.5),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceLinks(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerBg(context)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(HugeIconsStroke.note, size: 20),
            title: Text(
              "Privacy Policy & Terms",
              style: AppTheme.textLabel(context),
            ),
            trailing: const Icon(HugeIconsStroke.arrowRight01, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
          Divider(height: 1, color: AppTheme.dividerBg(context)),
          ListTile(
            leading: const Icon(HugeIconsStroke.headset, size: 20),
            title: Text(
              "Help Center & FAQs",
              style: AppTheme.textLabel(context),
            ),
            trailing: const Icon(HugeIconsStroke.arrowRight01, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
