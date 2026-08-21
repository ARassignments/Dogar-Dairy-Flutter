import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '/components/appsnackbar.dart';
import '/theme/theme.dart';

class PrivacyPolicySection {
  final String id;
  final String title;
  final String category;
  final IconData icon;
  final Color iconColor;
  final String summary;
  final List<String> bulletPoints;
  final String? calloutBadge;

  const PrivacyPolicySection({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.summary,
    required this.bulletPoints,
    this.calloutBadge,
  });
}

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "All";
  String _searchQuery = "";
  final Set<String> _expandedSectionIds = {};

  final List<String> _categories = [
    "All",
    "Data Collected",
    "How We Use Data",
    "Multi-Tenancy",
    "Khata & Billing",
    "Data Rights",
    "Security",
  ];

  static const List<PrivacyPolicySection> _sections = [
    PrivacyPolicySection(
      id: "scope",
      title: "1. Scope & Application",
      category: "Multi-Tenancy",
      icon: HugeIconsStroke.shield01,
      iconColor: Color(0xFF4838D1),
      summary:
          "This Privacy Policy applies to the Dogar Dairy platform across all supported platforms (Android, iOS, Web, Desktop). Our platform serves three distinct roles with strict data boundaries:",
      bulletPoints: [
        "Platform Admin: Operates the cloud platform, manages system plans, and oversees verified vendor accounts.",
        "Staff (Dairy Vendors / Shopkeepers): The primary business owners using the app to manage their daily milk supplies, route deliveries, inventory, and customer ledgers.",
        "Customers (Milk Buyers): Everyday consumers viewing their personal delivery logs, monthly consumption quotas, and digital khata statements 100% free.",
      ],
      calloutBadge: "Multi-Tenant Scope",
    ),
    PrivacyPolicySection(
      id: "collected_data",
      title: "2. Information We Collect",
      category: "Data Collected",
      icon: HugeIconsStroke.file01,
      iconColor: Color(0xFF00897B),
      summary:
          "We collect only the essential information necessary to facilitate seamless dairy deliveries, supply route coordination, and accurate ledger accounting:",
      bulletPoints: [
        "Profile & Identity: Full name, verified mobile number, email address, profile avatar, and assigned user role.",
        "Delivery Coordinates & Address: House/shop delivery address, landmark details, city, state, and geographic delivery zone.",
        "Dairy Supply Preferences: Milk type preferences (Fresh Buffalo Milk, Cow Milk, Organic Goat Milk), morning/evening quota allocations, and delivery frequency.",
        "Vendor Business Data: Customer contact records entered by vendors, daily route lists, rider allocations, procurement costs, stock levels, and operational expense logs.",
        "Technical Diagnostics: Device OS, unique install identifiers, network status, and FCM notification push tokens.",
      ],
      calloutBadge: "Minimal Collection",
    ),
    PrivacyPolicySection(
      id: "how_used",
      title: "3. How We Use Your Data",
      category: "How We Use Data",
      icon: HugeIconsStroke.truck,
      iconColor: Color(0xFF1976D2),
      summary:
          "Your data is used strictly for core dairy logistics, order fulfillment, and transparent ledger synchronization:",
      bulletPoints: [
        "Supply Route Optimization: Calculating daily milk volume requirements for morning (AM) and evening (PM) delivery routes.",
        "Live Delivery Confirmations: Dispatching push notifications and in-app alerts when your milk bottle/container is dropped at your doorstep.",
        "Automated Khata Ledger: Maintaining tamper-evident, double-entry digital bookkeeping for every transaction, payment, and adjustment.",
        "Quality Verification: Associating lab lactometer purity scores and quality certificates with daily batches.",
        "Platform Security & Auditing: Detecting unauthorized access attempts and preserving multi-tenant isolation.",
      ],
    ),
    PrivacyPolicySection(
      id: "multi_tenancy",
      title: "4. Multi-Tenant Isolation & Vendor Privacy",
      category: "Multi-Tenancy",
      icon: HugeIconsStroke.database,
      iconColor: Color(0xFFE91E63),
      summary:
          "Dogar Dairy is architected with strict cryptographic and database-level isolation between independent dairy businesses:",
      bulletPoints: [
        "Zero Cross-Tenant Leakage: A dairy vendor (Staff) can only view and manage their own customers, prices, profit margins, and ledgers.",
        "Customer Data Sovereignty: Milk buyers have read-only access strictly to the transactions performed with their specific milk vendor.",
        "Firestore Security Rules: Database operations are locked down via authenticated user ID and vendor ID checks at the cloud layer.",
      ],
      calloutBadge: "Strict Isolation",
    ),
    PrivacyPolicySection(
      id: "khata_payments",
      title: "5. Digital Khata, Invoicing & Payments",
      category: "Khata & Billing",
      icon: HugeIconsStroke.invoice01,
      iconColor: Color(0xFFF57C00),
      summary:
          "Our digital khata system ensures transparent billing while protecting sensitive financial transactions:",
      bulletPoints: [
        "Payment Methods Supported: EasyPaisa, JazzCash, Bank Transfer, and Cash on Delivery (COD).",
        "No Card Storage: Dogar Dairy does not store raw credit/debit card numbers or bank passwords on its servers.",
        "Exportable PDF Receipts: Invoices and receipts can be exported or shared to WhatsApp solely upon direct user initiation.",
        "Invoice Transparency: Both the dairy vendor and the customer see synchronized records of daily liters delivered and payments received.",
      ],
    ),
    PrivacyPolicySection(
      id: "data_sharing",
      title: "6. Data Sharing & Third-Party Disclosure",
      category: "Security",
      icon: HugeIconsStroke.share01,
      iconColor: Color(0xFF7E57C2),
      summary:
          "We treat your personal and business data as strictly confidential. We enforce the following guarantees:",
      bulletPoints: [
        "No Selling or Renting: We NEVER sell, lease, rent, or trade your personal records, contact books, or business numbers to data brokers or advertising networks.",
        "Cloud Infrastructure: Hosted on secure Google Cloud Firebase data centers with TLS 1.3 encryption in transit and AES-256 at rest.",
        "Legal Disclosures: Disclosures will only be made if strictly mandated by valid legal court orders or applicable national regulatory authorities.",
      ],
      calloutBadge: "Zero Ads / Zero Selling",
    ),
    PrivacyPolicySection(
      id: "retention_deletion",
      title: "7. Data Retention & Account Deletion",
      category: "Data Rights",
      icon: HugeIconsStroke.delete02,
      iconColor: Color(0xFFD32F2F),
      summary:
          "You retain complete control over your data lifecycle, retention periods, and the right to permanent deletion:",
      bulletPoints: [
        "Active Session Retention: Account data is retained for the duration of your active subscription or customer relationship.",
        "Right to be Forgotten: You can request complete deletion of your account and all associated ledgers at any time via in-app settings or support.",
        "Immediate Session Purge: Logging out clears all local cached session credentials, remembered tokens, and avatar data.",
      ],
      calloutBadge: "Right to be Forgotten",
    ),
    PrivacyPolicySection(
      id: "user_rights",
      title: "8. Your Privacy Rights & Controls",
      category: "Data Rights",
      icon: HugeIconsStroke.checkmarkBadge01,
      iconColor: Color(0xFF2E7D32),
      summary:
          "You are entitled to the following privacy protections and interactive controls inside Dogar Dairy:",
      bulletPoints: [
        "Access & Portability: Download and inspect complete historical delivery and billing ledgers in PDF format.",
        "Rectification: Correct misspelled names, phone numbers, delivery addresses, and milk quotas in real time.",
        "Notification Preferences: Granularly toggle delivery alerts, khata reminders, promotional offers, and system sounds in Notification Settings.",
        "Revoke Permissions: Disable camera, gallery, or notification permissions anytime through your device operating system settings.",
      ],
    ),
    PrivacyPolicySection(
      id: "contact_dpo",
      title: "9. Contacting Our Data Protection Team",
      category: "Security",
      icon: HugeIconsStroke.headset,
      iconColor: Color(0xFF00ACC1),
      summary:
          "If you have inquiries, privacy compliance requests, or wish to exercise your data rights, reach out to our team:",
      bulletPoints: [
        "Official Email: abdurrehman905623@gmail.com",
        "Helpline / WhatsApp: +92 341 0292698 (Mon-Sat, 8:00 AM - 8:00 PM PKT)",
        "Registered Office: Dogar Dairy Farm & Tech Solutions, Karachi, Pakistan.",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _expandedSectionIds.addAll(["scope", "collected_data"]);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedSectionIds.contains(id)) {
        _expandedSectionIds.remove(id);
      } else {
        _expandedSectionIds.add(id);
      }
    });
  }

  void _expandAll() {
    setState(() {
      _expandedSectionIds.addAll(_sections.map((s) => s.id));
    });
  }

  void _collapseAll() {
    setState(() {
      _expandedSectionIds.clear();
    });
  }

  List<PrivacyPolicySection> get _filteredSections {
    return _sections.where((section) {
      final matchesCategory =
          _selectedCategory == "All" ||
          section.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesQuery =
          _searchQuery.isEmpty ||
          section.title.toLowerCase().contains(_searchQuery) ||
          section.summary.toLowerCase().contains(_searchQuery) ||
          section.bulletPoints.any(
            (b) => b.toLowerCase().contains(_searchQuery),
          );

      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> _contactSupportEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'abdurrehman905623@gmail.com',
      queryParameters: {
        'subject': 'Dogar Dairy - Privacy Policy & Data Inquiry',
      },
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else if (mounted) {
        AppSnackBar.show(
          context,
          message: "Contact email: abdurrehman905623@gmail.com",
          type: AppSnackBarType.info,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: "Contact email: abdurrehman905623@gmail.com",
          type: AppSnackBarType.info,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSections;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          "Privacy Policy",
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
        actions: [
          IconButton(
            tooltip: _expandedSectionIds.length == _sections.length
                ? "Collapse All"
                : "Expand All",
            icon: Icon(
              _expandedSectionIds.length == _sections.length
                  ? HugeIconsStroke.arrowUp01
                  : HugeIconsStroke.arrowDown01,
              size: 20,
            ),
            onPressed: () {
              if (_expandedSectionIds.length == _sections.length) {
                _collapseAll();
              } else {
                _expandAll();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Summary Card
              _buildHeroHeader(context, isDark),
              const SizedBox(height: 20),

              // Search Bar
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Search Policy",
                  hintText: "Search keywords (e.g. khata, vendor, delete)...",
                  prefixIcon: const Icon(HugeIconsSolid.search01, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(HugeIconsStroke.cancel02, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(category),
                        labelStyle: TextStyle(
                          fontFamily: AppFontFamily.poppinsMedium,
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.iconColor(context),
                        ),
                        backgroundColor: AppTheme.customListBg(context),
                        selectedColor: AppColor.primary_50,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColor.primary_50
                                : AppTheme.dividerBg(context),
                          ),
                        ),
                        onSelected: (val) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Policy Section List
              if (filtered.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          HugeIconsStroke.file01,
                          size: 48,
                          color: AppTheme.iconColorThree(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No matching policy clauses found",
                          style: AppTheme.textLabel(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Try searching another keyword or select 'All'",
                          style: AppTheme.textSearchInfoLabeled(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ...filtered.map(
                  (section) => _buildSectionCard(context, section, isDark),
                ),
              ],

              const SizedBox(height: 24),

              // Privacy Officer Contact Banner
              _buildContactCard(context, isDark),
              const SizedBox(height: 20),

              // Acceptance Acknowledgment Button
              FlatButton(
                text: "I Understand & Accept",
                onPressed: () {
                  AppSnackBar.show(
                    context,
                    message: "Privacy policy acknowledged and accepted.",
                    type: AppSnackBarType.success,
                  );
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, bool isDark) {
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.primary_50.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  HugeIconsSolid.shield01,
                  color: AppColor.primary_50,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dogar Dairy Privacy Guarantee",
                      style: AppTheme.textTitle(
                        context,
                      ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          HugeIconsStroke.calendar01,
                          size: 12,
                          color: AppTheme.iconColorThree(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Last Updated: August 2026",
                          style: AppTheme.textSearchInfoLabeled(
                            context,
                          ).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Your privacy is our core priority. Dogar Dairy is designed to safeguard your dairy supply routes, customer records, and digital khata ledgers with encrypted multi-tenant cloud storage.",
            style: AppTheme.textSearchInfoLabeled(
              context,
            ).copyWith(fontSize: 12.5, height: 1.5),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildTrustPill("🔒 100% Tenant Isolation", context),
              _buildTrustPill("🚫 Zero Third-Party Ads", context),
              _buildTrustPill("🛡️ Encrypted Cloud Khata", context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustPill(String text, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.customListBg(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFontFamily.poppinsMedium,
          fontSize: 11,
          color: AppTheme.iconColor(context),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    PrivacyPolicySection section,
    bool isDark,
  ) {
    final isExpanded = _expandedSectionIds.contains(section.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded
              ? section.iconColor.withValues(alpha: 0.35)
              : AppTheme.dividerBg(context),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: section.iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(section.icon, color: section.iconColor, size: 20),
          ),
          title: Text(
            section.title,
            style: AppTheme.textLabel(
              context,
            ).copyWith(fontFamily: AppFontFamily.poppinsSemiBold, fontSize: 14),
          ),
          subtitle: section.calloutBadge != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: section.iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        section.calloutBadge!,
                        style: TextStyle(
                          fontFamily: AppFontFamily.poppinsMedium,
                          fontSize: 10,
                          color: section.iconColor,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          trailing: Icon(
            isExpanded
                ? HugeIconsStroke.arrowUp01
                : HugeIconsStroke.arrowDown01,
            size: 18,
            color: AppTheme.iconColorThree(context),
          ),
          onExpansionChanged: (_) => _toggleExpand(section.id),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                section.summary,
                style: AppTheme.textSearchInfoLabeled(
                  context,
                ).copyWith(fontSize: 12.5, height: 1.45),
              ),
            ),
            const SizedBox(height: 10),
            ...section.bulletPoints.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 10),
                      child: Icon(
                        HugeIconsSolid.checkmarkCircle02,
                        size: 14,
                        color: section.iconColor,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: AppTheme.textLabel(context).copyWith(
                          fontSize: 12,
                          height: 1.4,
                          color: isDark
                              ? AppColor.neutral_30
                              : AppColor.neutral_80,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                HugeIconsStroke.helpCircle,
                size: 20,
                color: AppColor.primary_50,
              ),
              const SizedBox(width: 8),
              Text(
                "Questions regarding your data?",
                style: AppTheme.textLabel(context).copyWith(
                  fontFamily: AppFontFamily.poppinsSemiBold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Contact our Data Protection Officer for data export, deletion requests, or compliance inquiries.",
            style: AppTheme.textSearchInfoLabeled(
              context,
            ).copyWith(fontSize: 11.5),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _contactSupportEmail,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  HugeIconsStroke.mail01,
                  size: 16,
                  color: AppColor.primary_50,
                ),
                SizedBox(width: 6),
                Text(
                  "abdurrehman905623@gmail.com",
                  style: TextStyle(
                    fontFamily: AppFontFamily.poppinsSemiBold,
                    fontSize: 12.5,
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
}
