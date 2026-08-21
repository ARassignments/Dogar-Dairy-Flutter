import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '/components/appsnackbar.dart';
import '/theme/theme.dart';

class HelpFaqItem {
  final String id;
  final String category;
  final String question;
  final String answer;
  final List<String>? steps;
  final IconData icon;
  final Color iconColor;
  final String? badge;

  const HelpFaqItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    this.steps,
    required this.icon,
    required this.iconColor,
    this.badge,
  });
}

class HelpCenterScreen extends StatefulWidget {
  final int initialTabIndex;
  const HelpCenterScreen({super.key, this.initialTabIndex = 0});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All";
  final Set<String> _expandedFaqIds = {};
  final Map<String, bool?> _feedbackMap = {};

  // Support ticket form
  final GlobalKey<FormState> _ticketFormKey = GlobalKey<FormState>();
  final TextEditingController _ticketNameController = TextEditingController();
  final TextEditingController _ticketPhoneController = TextEditingController();
  final TextEditingController _ticketMessageController =
      TextEditingController();
  String _selectedIssueCategory = "Milk Delivery Issue";
  bool _isSubmittingTicket = false;

  final List<String> _issueCategories = [
    "Milk Delivery Issue",
    "Khata & Invoice Dispute",
    "Milk Quality / Purity Concern",
    "Vendor Subscription Inquiry",
    "App Technical Problem",
    "Other Feedback",
  ];

  final List<String> _categories = [
    "All",
    "Delivery & Supply",
    "Khata & Billing",
    "Milk Quality",
    "Vendor Operations",
    "Account & App",
  ];

  static const List<HelpFaqItem> _faqs = [
    HelpFaqItem(
      id: "faq_1",
      category: "Delivery & Supply",
      question: "What are the standard milk delivery timings?",
      answer:
          "Dogar Dairy routes operate twice daily to ensure pure fresh farm milk reaches you at optimal freshness:",
      steps: [
        "Morning (AM) Route: 6:00 AM – 8:30 AM",
        "Evening (PM) Route: 5:00 PM – 7:30 PM",
        "You can adjust your preferred slot in Profile Settings or directly with your assigned vendor.",
      ],
      icon: HugeIconsStroke.truck,
      iconColor: Color(0xFF1976D2),
      badge: "Delivery Hours",
    ),
    HelpFaqItem(
      id: "faq_2",
      category: "Delivery & Supply",
      question: "How do I pause or change my daily milk quantity for holidays?",
      answer:
          "You can update or temporarily pause your daily milk quota with zero penalty before route dispatch:",
      steps: [
        "Go to the Subscription / Quota screen from your dashboard.",
        "Select your active milk plan (Buffalo, Cow, or Goat).",
        "Tap 'Pause Delivery' and select your start and resume dates.",
        "Make sure to submit changes at least 3 hours before the morning route (by 3:00 AM) or evening route (by 2:00 PM).",
      ],
      icon: HugeIconsStroke.calendar01,
      iconColor: Color(0xFF00897B),
      badge: "Flexible Quota",
    ),
    HelpFaqItem(
      id: "faq_3",
      category: "Milk Quality",
      question: "How is Dogar Dairy milk tested for 100% purity?",
      answer:
          "Every batch of buffalo and cow milk undergoes rigorous multi-step organic quality checks before being dispatched to households:",
      steps: [
        "Lactometer Density Test: Ensures pure, unadulterated natural milk density (Standard 28-32 LR).",
        "Fat & Solid Non-Fat (SNF) Analysis: Buffalo milk averages 6.5% - 7.5% natural fat; Cow milk averages 3.8% - 4.5% natural fat.",
        "Zero Chemical Preservatives: 100% unpasteurized raw organic farm milk chilled to 4°C immediately after milking.",
        "Quality test reports are updated daily on your Dashboard under 'Quality & Purity'.",
      ],
      icon: HugeIconsSolid.checkmarkBadge02,
      iconColor: Color(0xFF2E7D32),
      badge: "Grade A+ Purity",
    ),
    HelpFaqItem(
      id: "faq_4",
      category: "Khata & Billing",
      question:
          "How does the Digital Khata ledger work and when is billing due?",
      answer:
          "Dogar Dairy utilizes a transparent, double-entry digital ledger that automatically synchronizes between vendors and buyers:",
      steps: [
        "Daily Synchronization: Each confirmed morning and evening drop automatically logs liters and price to your monthly khata.",
        "Billing Cycle: Monthly invoices are generated automatically on the 1st of every month.",
        "Due Date: Khata invoices are due by the 10th of each calendar month.",
        "You can inspect daily drop logs, downloaded PDF invoices, and payment receipts anytime in 'My Khata'.",
      ],
      icon: HugeIconsStroke.invoice01,
      iconColor: Color(0xFFF57C00),
      badge: "Automated Khata",
    ),
    HelpFaqItem(
      id: "faq_5",
      category: "Khata & Billing",
      question: "What payment methods can I use to clear my khata dues?",
      answer:
          "Vendors support multiple convenient payment options integrated directly with digital receipts:",
      steps: [
        "EasyPaisa & JazzCash: Transfer directly to your vendor's verified mobile account.",
        "Bank Transfer (IBFT): Instant bank payment with account title verification.",
        "Cash on Delivery: Hand cash directly to your assigned route delivery rider.",
        "Once payment is marked, an official digital receipt is recorded on your ledger.",
      ],
      icon: HugeIconsStroke.moneyReceiveFlow01,
      iconColor: Color(0xFF4838D1),
      badge: "Multiple Channels",
    ),
    HelpFaqItem(
      id: "faq_6",
      category: "Vendor Operations",
      question:
          "How do Dairy Vendors (Staff) add new customers and manage routes?",
      answer:
          "Vendors have full control over their own business operations, customer profiles, and custom rate cards:",
      steps: [
        "Navigate to the 'Customers' tab from the main drawer or bottom navigation.",
        "Tap the '+' icon to enter customer name, phone number, address, and delivery slot.",
        "Set custom per-liter rates for Buffalo, Cow, or Goat milk for that specific customer.",
        "Assign the customer to a morning or evening delivery route for automatic daily dispatch.",
      ],
      icon: HugeIconsStroke.userMultiple02,
      iconColor: Color(0xFF7E57C2),
      badge: "Vendor SaaS",
    ),
    HelpFaqItem(
      id: "faq_7",
      category: "Vendor Operations",
      question: "How do SaaS subscription plans work for Dairy Vendors?",
      answer:
          "Vendors enjoy a free trial period to test customer routes, stock, and khata management. Afterwards:",
      steps: [
        "Starter Vendor: Ideal for single-route vendors managing up to 50 active households.",
        "Growth Vendor: Covers up to 250 customers with multiple delivery riders and SMS/WhatsApp due alerts.",
        "Enterprise Vendor: Unlimited customer capacity, multi-branch dairy shop stock, and custom PDF branding.",
        "Customer accounts for milk buyers are always 100% free forever.",
      ],
      icon: HugeIconsStroke.crown03,
      iconColor: Color(0xFFE91E63),
      badge: "SaaS Plans",
    ),
    HelpFaqItem(
      id: "faq_8",
      category: "Account & App",
      question: "How do I update my phone number or delivery location?",
      answer:
          "To update personal information, go to 'Account' -> 'Profile Details'. You can modify your phone number, select a new animated avatar, and update your delivery location.",
      icon: HugeIconsStroke.user03,
      iconColor: Color(0xFF00ACC1),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    // Expand the first two FAQs by default
    _expandedFaqIds.addAll(["faq_1", "faq_4"]);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _ticketNameController.dispose();
    _ticketPhoneController.dispose();
    _ticketMessageController.dispose();
    super.dispose();
  }

  void _toggleFaq(String id) {
    setState(() {
      if (_expandedFaqIds.contains(id)) {
        _expandedFaqIds.remove(id);
      } else {
        _expandedFaqIds.add(id);
      }
    });
  }

  List<HelpFaqItem> get _filteredFaqs {
    return _faqs.where((faq) {
      final matchesCategory =
          _selectedCategory == "All" ||
          faq.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesQuery =
          _searchQuery.isEmpty ||
          faq.question.toLowerCase().contains(_searchQuery) ||
          faq.answer.toLowerCase().contains(_searchQuery) ||
          (faq.steps?.any((s) => s.toLowerCase().contains(_searchQuery)) ??
              false);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> _launchWhatsApp({String? customMessage}) async {
    final message =
        customMessage ??
        "Hello Dogar Dairy Support! I need assistance with my milk account / delivery.";
    final Uri url = Uri.parse(
      "https://wa.me/923410292698?text=${Uri.encodeComponent(message)}",
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        AppSnackBar.show(
          context,
          message: "WhatsApp Helpline: +92 341 0292698",
          type: AppSnackBarType.info,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: "WhatsApp Helpline: +92 341 0292698",
          type: AppSnackBarType.info,
        );
      }
    }
  }

  Future<void> _launchPhoneCall() async {
    final Uri url = Uri.parse("tel:+923410292698");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else if (mounted) {
        AppSnackBar.show(
          context,
          message: "Helpline: +92 341 0292698",
          type: AppSnackBarType.info,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: "Helpline: +92 341 0292698",
          type: AppSnackBarType.info,
        );
      }
    }
  }

  Future<void> _launchEmail({String? subject, String? body}) async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: 'abdurrehman905623@gmail.com',
      queryParameters: {
        'subject': subject ?? 'Dogar Dairy - Customer Support Request',
        'body': body ?? 'Hello Support Team,\n\n',
      },
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else if (mounted) {
        AppSnackBar.show(
          context,
          message: "Email: abdurrehman905623@gmail.com",
          type: AppSnackBarType.info,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: "Email: abdurrehman905623@gmail.com",
          type: AppSnackBarType.info,
        );
      }
    }
  }

  Future<void> _submitTicket() async {
    if (!_ticketFormKey.currentState!.validate()) return;

    setState(() => _isSubmittingTicket = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSubmittingTicket = false);

    final name = _ticketNameController.text.trim();
    final phone = _ticketPhoneController.text.trim();
    final msg = _ticketMessageController.text.trim();

    final fullMessage =
        "🚨 *Dogar Dairy Support Ticket*\n"
        "• *Category*: $_selectedIssueCategory\n"
        "• *Name*: $name\n"
        "• *Contact*: $phone\n"
        "• *Details*: $msg";

    _ticketMessageController.clear();

    AppSnackBar.show(
      context,
      message: "Ticket created successfully! Opening WhatsApp support...",
      type: AppSnackBarType.success,
    );

    await _launchWhatsApp(customMessage: fullMessage);
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
          "Help Center",
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColor.white : AppColor.primary_50,
          unselectedLabelColor: AppTheme.iconColorThree(context),
          indicatorColor: AppColor.primary_50,
          indicatorWeight: 3,
          labelStyle: TextStyle(
            fontFamily: AppFontFamily.poppinsSemiBold,
            fontSize: 13,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: AppFontFamily.poppinsMedium,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: "FAQs"),
            Tab(text: "Contact Us"),
            Tab(text: "Submit Ticket"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: FAQs & Knowledge Base
          _buildFaqTab(context, isDark),

          // TAB 2: Contact Channels
          _buildContactTab(context, isDark),

          // TAB 3: Submit Support Ticket
          _buildTicketTab(context, isDark),
        ],
      ),
    );
  }

  // ─── TAB 1: FAQs ─────────────────────────────────────────────────────────────

  Widget _buildFaqTab(BuildContext context, bool isDark) {
    final filtered = _filteredFaqs;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Box
          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: "Search FAQs",
              hintText:
                  "Search topics (e.g. delivery time, khata, pure milk)...",
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

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
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
                        _selectedCategory = cat;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // FAQ Items
          if (filtered.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      HugeIconsStroke.helpCircle,
                      size: 48,
                      color: AppTheme.iconColorThree(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No FAQs found matching your search",
                      style: AppTheme.textLabel(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Try a different keyword or contact support directly",
                      style: AppTheme.textSearchInfoLabeled(context),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ...filtered.map((faq) => _buildFaqCard(context, faq, isDark)),
          ],

          const SizedBox(height: 20),

          // Still need help card
          _buildQuickHelpBanner(context, isDark),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFaqCard(BuildContext context, HelpFaqItem faq, bool isDark) {
    final isExpanded = _expandedFaqIds.contains(faq.id);
    final feedback = _feedbackMap[faq.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded
              ? faq.iconColor.withValues(alpha: 0.35)
              : AppTheme.dividerBg(context),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: faq.iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(faq.icon, color: faq.iconColor, size: 20),
          ),
          title: Text(
            faq.question,
            style: AppTheme.textLabel(context).copyWith(
              fontFamily: AppFontFamily.poppinsSemiBold,
              fontSize: 13.5,
            ),
          ),
          subtitle: faq.badge != null
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
                        color: faq.iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        faq.badge!,
                        style: TextStyle(
                          fontFamily: AppFontFamily.poppinsMedium,
                          fontSize: 10,
                          color: faq.iconColor,
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
          onExpansionChanged: (_) => _toggleFaq(faq.id),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                faq.answer,
                style: AppTheme.textSearchInfoLabeled(
                  context,
                ).copyWith(fontSize: 12.5, height: 1.45),
              ),
            ),
            if (faq.steps != null && faq.steps!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...faq.steps!.map(
                (step) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 8),
                        child: Icon(
                          HugeIconsSolid.checkmarkCircle02,
                          size: 13,
                          color: faq.iconColor,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          step,
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
            const SizedBox(height: 12),
            Divider(height: 1, color: AppTheme.dividerBg(context)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Was this helpful?",
                  style: AppTheme.textSearchInfoLabeled(
                    context,
                  ).copyWith(fontSize: 11),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    setState(() {
                      _feedbackMap[faq.id] = true;
                    });
                    AppSnackBar.show(
                      context,
                      message: "Thank you for your feedback!",
                      type: AppSnackBarType.success,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: feedback == true
                          ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                          : AppTheme.customListBg(context),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          HugeIconsStroke.thumbsUp,
                          size: 13,
                          color: feedback == true
                              ? const Color(0xFF2E7D32)
                              : AppTheme.iconColorThree(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Yes",
                          style: TextStyle(
                            fontFamily: AppFontFamily.poppinsMedium,
                            fontSize: 11,
                            color: feedback == true
                                ? const Color(0xFF2E7D32)
                                : AppTheme.iconColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _feedbackMap[faq.id] = false;
                    });
                    AppSnackBar.show(
                      context,
                      message: "We'll work to improve this answer.",
                      type: AppSnackBarType.info,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: feedback == false
                          ? const Color(0xFFD32F2F).withValues(alpha: 0.15)
                          : AppTheme.customListBg(context),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          HugeIconsStroke.thumbsDown,
                          size: 13,
                          color: feedback == false
                              ? const Color(0xFFD32F2F)
                              : AppTheme.iconColorThree(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "No",
                          style: TextStyle(
                            fontFamily: AppFontFamily.poppinsMedium,
                            fontSize: 11,
                            color: feedback == false
                                ? const Color(0xFFD32F2F)
                                : AppTheme.iconColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHelpBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primary_50.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.primary_50.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.primary_50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              HugeIconsSolid.headset,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Need Direct Assistance?",
                  style: AppTheme.textTitle(
                    context,
                  ).copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  "Our dairy support desk is online to assist with routes & khata.",
                  style: AppTheme.textSearchInfoLabeled(
                    context,
                  ).copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary_50,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              _tabController.animateTo(1);
            },
            child: const Text(
              "Contact",
              style: TextStyle(
                fontFamily: AppFontFamily.poppinsMedium,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 2: Contact Channels ──────────────────────────────────────────────────

  Widget _buildContactTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
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
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        HugeIconsSolid.call,
                        color: Color(0xFF2E7D32),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Official Support Channels",
                            style: AppTheme.textTitle(context).copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Fastest response via WhatsApp & Helpline",
                            style: AppTheme.textSearchInfoLabeled(
                              context,
                            ).copyWith(fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  "Have urgent milk delivery changes, payment verification questions, or software queries? Contact our dedicated support team directly.",
                  style: AppTheme.textSearchInfoLabeled(
                    context,
                  ).copyWith(fontSize: 12.5, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Channel Cards
          _buildChannelCard(
            context,
            icon: HugeIconsSolid.message02,
            iconColor: const Color(0xFF25D366),
            title: "WhatsApp Live Chat",
            subtitle: "Instant chat with our delivery & khata agent",
            detail: "+92 341 0292698",
            badgeText: "Recommended",
            badgeColor: const Color(0xFF25D366),
            onTap: () => _launchWhatsApp(),
          ),
          const SizedBox(height: 12),

          _buildChannelCard(
            context,
            icon: HugeIconsSolid.call02,
            iconColor: const Color(0xFF1976D2),
            title: "Helpline Call",
            subtitle: "Speak directly with support (6 AM – 9 PM PKT)",
            detail: "+92 341 0292698",
            onTap: _launchPhoneCall,
          ),
          const SizedBox(height: 12),

          _buildChannelCard(
            context,
            icon: HugeIconsSolid.mail01,
            iconColor: const Color(0xFFE91E63),
            title: "Email Support",
            subtitle: "Inquiries, billing disputes & vendor onboarding",
            detail: "abdurrehman905623@gmail.com",
            onTap: () => _launchEmail(),
          ),
          const SizedBox(height: 20),

          // Operating Hours & Farm Location
          Container(
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
                      HugeIconsStroke.clock01,
                      size: 18,
                      color: AppColor.primary_50,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Operating Hours & Availability",
                      style: AppTheme.textLabel(context).copyWith(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  "Milk Dispatch Rounds:",
                  "6:00 AM – 8:30 AM & 5:00 PM – 7:30 PM",
                  context,
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  "Support Desk:",
                  "Monday – Saturday (8:00 AM – 8:00 PM PKT)",
                  context,
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  "Head Office:",
                  "Dogar Dairy Farm, Karachi, Pakistan",
                  context,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChannelCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String detail,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerBg(context)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: AppTheme.textLabel(context).copyWith(
                fontFamily: AppFontFamily.poppinsSemiBold,
                fontSize: 14,
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppColor.primary_50).withValues(
                    alpha: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontFamily: AppFontFamily.poppinsMedium,
                    fontSize: 10,
                    color: badgeColor ?? AppColor.primary_50,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTheme.textSearchInfoLabeled(
                context,
              ).copyWith(fontSize: 11.5),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              style: TextStyle(
                fontFamily: AppFontFamily.poppinsSemiBold,
                fontSize: 12.5,
                color: iconColor,
              ),
            ),
          ],
        ),
        trailing: const Icon(HugeIconsStroke.arrowRight01, size: 18),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.textSearchInfoLabeled(
            context,
          ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: AppTheme.textLabel(context).copyWith(fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ─── TAB 3: Submit Ticket ───────────────────────────────────────────────────

  Widget _buildTicketTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Form(
        key: _ticketFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Report an Issue / Inquiry",
              style: AppTheme.textTitle(
                context,
              ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              "Fill out details below to submit a priority support ticket via WhatsApp & Email.",
              style: AppTheme.textSearchInfoLabeled(
                context,
              ).copyWith(fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Issue Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedIssueCategory,
              decoration: const InputDecoration(
                labelText: "Issue Category",
                prefixIcon: Icon(HugeIconsSolid.folder01, size: 20),
              ),
              items: _issueCategories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(
                    cat,
                    style: AppTheme.textLabel(context).copyWith(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedIssueCategory = val);
                }
              },
            ),
            const SizedBox(height: 16),

            // Name Field
            TextFormField(
              controller: _ticketNameController,
              decoration: const InputDecoration(
                labelText: "Your Full Name",
                hintText: "Enter your name",
                prefixIcon: Icon(HugeIconsSolid.user03, size: 20),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? "Please enter your name"
                  : null,
            ),
            const SizedBox(height: 16),

            // Phone Field
            TextFormField(
              controller: _ticketPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Contact Phone Number",
                hintText: "+92 300 1234567",
                prefixIcon: Icon(HugeIconsSolid.call, size: 20),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? "Please enter contact number"
                  : null,
            ),
            const SizedBox(height: 16),

            // Message Description
            TextFormField(
              controller: _ticketMessageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description / Details",
                hintText:
                    "Describe your issue (e.g. morning delivery missed on Aug 21, billing disagreement on ledger #48)...",
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Icon(HugeIconsSolid.note, size: 20),
                ),
              ),
              validator: (v) => (v == null || v.trim().length < 5)
                  ? "Please provide at least a brief description"
                  : null,
            ),
            const SizedBox(height: 24),

            // Submit Button
            FlatButton(
              text: _isSubmittingTicket
                  ? "Submitting..."
                  : "Send Request via WhatsApp",
              loading: _isSubmittingTicket,
              icon: HugeIconsSolid.message02,
              onPressed: _submitTicket,
            ),
            const SizedBox(height: 14),

            // Secondary Email button
            OutlineButton(
              text: "Send via Official Email",
              icon: HugeIconsStroke.mail01,
              onPressed: () {
                if (_ticketFormKey.currentState!.validate()) {
                  final name = _ticketNameController.text.trim();
                  final phone = _ticketPhoneController.text.trim();
                  final msg = _ticketMessageController.text.trim();
                  _launchEmail(
                    subject:
                        "[$_selectedIssueCategory] Support Request from $name",
                    body:
                        "Name: $name\nContact: $phone\nCategory: $_selectedIssueCategory\n\nDetails:\n$msg",
                  );
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
