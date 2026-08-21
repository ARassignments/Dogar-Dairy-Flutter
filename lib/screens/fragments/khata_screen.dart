import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '/components/appsnackbar.dart';
import '/models/khata_model.dart';
import '/providers/user_provider.dart';
import '/providers/search_provider.dart';
import '/theme/theme.dart';

class KhataScreen extends ConsumerStatefulWidget {
  const KhataScreen({super.key});

  @override
  ConsumerState<KhataScreen> createState() => _KhataScreenState();
}

class _KhataScreenState extends ConsumerState<KhataScreen>
    with AutomaticKeepAliveClientMixin {
  String _selectedFilter = "All";
  String _selectedMonth = "August 2026";

  final List<String> _filterOptions = [
    "All",
    "Pending",
    "Overdue",
    "Paid",
  ];

  final List<String> _monthOptions = [
    "August 2026",
    "July 2026",
    "June 2026",
  ];

  // In-memory persistent mock customer khata list
  late List<KhataCustomer> _customers;

  // Mock customer personal entries for the customer view
  late List<KhataEntry> _myLedgerEntries;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initMockData();
  }

  void _initMockData() {
    final now = DateTime.now();
    _customers = [
      KhataCustomer(
        customerId: "CUST-001",
        customerName: "Muhammad Usman",
        customerPhone: "03001234567",
        address: "House 42, Block B, North Nazimabad",
        route: "Route 1 - North Nazimabad",
        currentBalance: 4280.0,
        totalLitersThisMonth: 62.0,
        totalBilledThisMonth: 13640.0,
        totalPaidThisMonth: 9360.0,
        lastPaymentDate: now.subtract(const Duration(days: 4)),
        lastPaymentAmount: 5000.0,
        paymentStatus: "pending",
      ),
      KhataCustomer(
        customerId: "CUST-002",
        customerName: "Dr. Ayesha Siddiqui",
        customerPhone: "03219876543",
        address: "Flat 4-B, Al-Razi Heights, Block C",
        route: "Route 1 - North Nazimabad",
        currentBalance: 0.0,
        totalLitersThisMonth: 45.0,
        totalBilledThisMonth: 9900.0,
        totalPaidThisMonth: 9900.0,
        lastPaymentDate: now.subtract(const Duration(days: 1)),
        lastPaymentAmount: 9900.0,
        paymentStatus: "paid",
      ),
      KhataCustomer(
        customerId: "CUST-003",
        customerName: "Haji Abdul Rasheed",
        customerPhone: "03335554433",
        address: "House 118, Street 7, Block D",
        route: "Route 1 - North Nazimabad",
        currentBalance: 12400.0,
        totalLitersThisMonth: 90.0,
        totalBilledThisMonth: 19800.0,
        totalPaidThisMonth: 7400.0,
        lastPaymentDate: now.subtract(const Duration(days: 18)),
        lastPaymentAmount: 5000.0,
        paymentStatus: "overdue",
      ),
      KhataCustomer(
        customerId: "CUST-004",
        customerName: "Rashid Minhas",
        customerPhone: "03451122334",
        address: "House 9, Lane 3, Block A",
        route: "Route 1 - North Nazimabad",
        currentBalance: 6600.0,
        totalLitersThisMonth: 60.0,
        totalBilledThisMonth: 13200.0,
        totalPaidThisMonth: 6600.0,
        lastPaymentDate: now.subtract(const Duration(days: 8)),
        lastPaymentAmount: 6600.0,
        paymentStatus: "pending",
      ),
      KhataCustomer(
        customerId: "CUST-005",
        customerName: "Chaudhry Akram",
        customerPhone: "03112233445",
        address: "House 67, Block J, North Nazimabad",
        route: "Route 1 - North Nazimabad",
        currentBalance: 8800.0,
        totalLitersThisMonth: 75.0,
        totalBilledThisMonth: 16500.0,
        totalPaidThisMonth: 7700.0,
        lastPaymentDate: now.subtract(const Duration(days: 22)),
        lastPaymentAmount: 4000.0,
        paymentStatus: "overdue",
      ),
    ];

    _myLedgerEntries = [
      KhataEntry(
        id: "ENT-01",
        customerId: "CUST-001",
        date: now.subtract(const Duration(days: 1)),
        type: "delivery_debit",
        liters: 3.0,
        amount: 660.0,
        description: "2L Buffalo + 1L Cow Milk",
      ),
      KhataEntry(
        id: "ENT-02",
        customerId: "CUST-001",
        date: now.subtract(const Duration(days: 2)),
        type: "delivery_debit",
        liters: 3.0,
        amount: 660.0,
        description: "2L Buffalo + 1L Cow Milk",
      ),
      KhataEntry(
        id: "ENT-03",
        customerId: "CUST-001",
        date: now.subtract(const Duration(days: 3)),
        type: "delivery_debit",
        liters: 4.0,
        amount: 880.0,
        description: "2L Buffalo + 1L Cow + 1L Extra",
      ),
      KhataEntry(
        id: "ENT-04",
        customerId: "CUST-001",
        date: now.subtract(const Duration(days: 4)),
        type: "payment_credit",
        amount: 5000.0,
        description: "Payment Received via JazzCash",
        paymentMethod: "JazzCash",
      ),
      KhataEntry(
        id: "ENT-05",
        customerId: "CUST-001",
        date: now.subtract(const Duration(days: 5)),
        type: "delivery_debit",
        liters: 3.0,
        amount: 660.0,
        description: "2L Buffalo + 1L Cow Milk",
      ),
    ];
  }

  Future<void> _launchCall(String phone) async {
    final cleanPhone = phone.replaceAll(" ", "").replaceAll("-", "");
    final Uri url = Uri.parse("tel:$cleanPhone");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (_) {}
  }

  Future<void> _launchWhatsApp(String phone, String message) async {
    String clean = phone.replaceAll("+", "").replaceAll(" ", "").replaceAll("-", "");
    if (clean.startsWith("0")) {
      clean = "92${clean.substring(1)}";
    }
    final Uri url = Uri.parse("https://wa.me/$clean?text=${Uri.encodeComponent(message)}");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.show(
      context,
      message: "$label copied to clipboard",
      type: AppSnackBarType.success,
    );
  }

  Future<void> _showRecordPaymentDialog(KhataCustomer customer) async {
    final amountController = TextEditingController(
      text: customer.currentBalance > 0 ? customer.currentBalance.toInt().toString() : "1000",
    );
    final noteController = TextEditingController();
    String selectedMethod = "Cash";
    final methods = ["Cash", "JazzCash", "EasyPaisa", "Bank Transfer"];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: AppTheme.cardBg(context),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(HugeIconsSolid.invoice01, color: Color(0xFF2E7D32), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Record Khata Payment",
                    style: AppTheme.textTitle(context).copyWith(fontSize: 16),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer: ${customer.customerName}",
                      style: AppTheme.textLabel(context).copyWith(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Current Outstanding: Rs. ${customer.currentBalance.toInt()}",
                      style: const TextStyle(
                        fontFamily: AppFontFamily.poppinsMedium,
                        fontSize: 12,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount Field
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Payment Amount (PKR)",
                        prefixText: "Rs. ",
                        prefixIcon: Icon(HugeIconsSolid.money03, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Payment Method Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedMethod,
                      decoration: const InputDecoration(
                        labelText: "Payment Method",
                        prefixIcon: Icon(HugeIconsSolid.creditCard, size: 20),
                      ),
                      items: methods.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(m, style: AppTheme.textLabel(context).copyWith(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMethod = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Note Field
                    TextFormField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: "Receipt Note / Reference",
                        hintText: "e.g. Received by Rider Tariq",
                        prefixIcon: Icon(HugeIconsStroke.note, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.iconColorThree(context))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final paid = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (paid > 0) {
                      setState(() {
                        final index = _customers.indexWhere((c) => c.customerId == customer.customerId);
                        if (index != -1) {
                          final current = _customers[index];
                          final newBalance = (current.currentBalance - paid).clamp(0.0, double.infinity);
                          _customers[index] = current.copyWith(
                            currentBalance: newBalance,
                            totalPaidThisMonth: current.totalPaidThisMonth + paid,
                            lastPaymentDate: DateTime.now(),
                            lastPaymentAmount: paid,
                            paymentStatus: newBalance == 0 ? "paid" : "pending",
                          );
                        }
                      });
                      Navigator.pop(ctx);
                      AppSnackBar.show(
                        context,
                        message: "Payment of Rs. ${paid.toInt()} recorded successfully!",
                        type: AppSnackBarType.success,
                      );
                    }
                  },
                  child: const Text("Save Payment", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCustomerStatementModal(KhataCustomer customer) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 4,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Khata Statement",
                      style: AppTheme.textTitle(ctx).copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColor.primary_50.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedMonth,
                        style: const TextStyle(
                          fontFamily: AppFontFamily.poppinsMedium,
                          fontSize: 11,
                          color: AppColor.primary_50,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "${customer.customerName} • ${customer.address}",
                  style: AppTheme.textSearchInfoLabeled(ctx).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: AppTheme.dividerBg(ctx)),
                const SizedBox(height: 16),

                // Financial Summary
                Row(
                  children: [
                    _buildStatementPill(ctx, "Total Billed", "Rs. ${customer.totalBilledThisMonth.toInt()}", AppColor.primary_50),
                    const SizedBox(width: 8),
                    _buildStatementPill(ctx, "Paid", "Rs. ${customer.totalPaidThisMonth.toInt()}", const Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    _buildStatementPill(ctx, "Balance Due", "Rs. ${customer.currentBalance.toInt()}", const Color(0xFFE91E63)),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  "Recent Transactions",
                  style: AppTheme.textLabel(ctx).copyWith(
                    fontFamily: AppFontFamily.poppinsSemiBold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),

                ..._myLedgerEntries.map((e) => _buildTransactionRow(ctx, e)),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary_50,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(HugeIconsSolid.download01, size: 16, color: Colors.white),
                  label: const Text(
                    "Download PDF Statement",
                    style: TextStyle(fontFamily: AppFontFamily.poppinsMedium, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    AppSnackBar.show(
                      context,
                      message: "PDF Statement for ${customer.customerName} downloaded!",
                      type: AppSnackBarType.success,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatementPill(BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontFamily: AppFontFamily.poppinsRegular, fontSize: 10.5, color: color)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontFamily: AppFontFamily.poppinsBold, fontSize: 12.5, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow(BuildContext context, KhataEntry entry) {
    final isCredit = entry.type == 'payment_credit';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.customListBg(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isCredit
                  ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                  : AppColor.primary_50.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCredit ? HugeIconsSolid.checkmarkCircle02 : HugeIconsSolid.milkBottle,
              size: 14,
              color: isCredit ? const Color(0xFF2E7D32) : AppColor.primary_50,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  style: AppTheme.textLabel(context).copyWith(
                    fontFamily: AppFontFamily.poppinsMedium,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "${entry.date.day}/${entry.date.month}/${entry.date.year}",
                  style: AppTheme.textSearchInfoLabeled(context).copyWith(fontSize: 10.5),
                ),
              ],
            ),
          ),
          Text(
            "${isCredit ? '-' : '+'} Rs. ${entry.amount.toInt()}",
            style: TextStyle(
              fontFamily: AppFontFamily.poppinsBold,
              fontSize: 12.5,
              color: isCredit ? const Color(0xFF2E7D32) : const Color(0xFFE91E63),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userModel = ref.watch(userProvider);
    final role = (userModel?.role.isNotEmpty == true ? userModel!.role : "customer")
        .toLowerCase();
    final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();

    // Filter vendor customers
    final filteredCustomers = _customers.where((c) {
      final matchesStatus = _selectedFilter == "All" ||
          c.paymentStatus.toLowerCase() == _selectedFilter.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          c.customerName.toLowerCase().contains(searchQuery) ||
          c.customerPhone.contains(searchQuery) ||
          c.address.toLowerCase().contains(searchQuery);

      return matchesStatus && matchesSearch;
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Month Header Selector
            _buildMonthHeader(context, isDark),
            const SizedBox(height: 16),

            if (role == 'staff') ...[
              // VENDOR / STAFF KHATA DASHBOARD
              _buildVendorHeroMetrics(context, isDark),
              const SizedBox(height: 16),
              _buildFilterChips(context, isDark),
              const SizedBox(height: 16),
              _buildVendorCustomerKhataList(context, isDark, filteredCustomers),
            ] else ...[
              // CUSTOMER BILLING & LEDGER
              _buildCustomerHeroBill(context, isDark),
              const SizedBox(height: 16),
              _buildCustomerPaymentOptions(context, isDark),
              const SizedBox(height: 16),
              _buildCustomerDailyLedger(context, isDark),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── MONTH HEADER ──────────────────────────────────────────────────────────

  Widget _buildMonthHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(HugeIconsSolid.calendar01, size: 18, color: AppColor.primary_50),
            const SizedBox(width: 8),
            Text(
              "Billing Period",
              style: AppTheme.textLabel(context).copyWith(
                fontFamily: AppFontFamily.poppinsSemiBold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.cardBg(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.dividerBg(context)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedMonth,
              isDense: true,
              style: AppTheme.textLabel(context).copyWith(
                fontFamily: AppFontFamily.poppinsSemiBold,
                fontSize: 12,
              ),
              items: _monthOptions.map((m) {
                return DropdownMenuItem(value: m, child: Text(m));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedMonth = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ─── VENDOR / STAFF KHATA OVERVIEW ─────────────────────────────────────────

  Widget _buildVendorHeroMetrics(BuildContext context, bool isDark) {
    double totalKhataDue = 0;
    double totalCollected = 0;
    double totalBilled = 0;
    for (var c in _customers) {
      totalKhataDue += c.currentBalance;
      totalCollected += c.totalPaidThisMonth;
      totalBilled += c.totalBilledThisMonth;
    }

    final collectionPercentage = totalBilled > 0
        ? ((totalCollected / totalBilled) * 100).toInt()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1552), const Color(0xFF130E38)]
              : [const Color(0xFF4838D1), const Color(0xFF6756F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary_50.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Outstanding Khata",
                style: TextStyle(
                  fontFamily: AppFontFamily.poppinsMedium,
                  fontSize: 12.5,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$collectionPercentage% Collected",
                  style: const TextStyle(
                    fontFamily: AppFontFamily.poppinsSemiBold,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Rs. ${totalKhataDue.toInt()}",
            style: const TextStyle(
              fontFamily: AppFontFamily.poppinsBold,
              fontSize: 26,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 14),

          // Mini statistics
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Collected", style: TextStyle(fontFamily: AppFontFamily.poppinsRegular, fontSize: 11, color: Colors.white70)),
                    const SizedBox(height: 2),
                    Text("Rs. ${totalCollected.toInt()}", style: const TextStyle(fontFamily: AppFontFamily.poppinsBold, fontSize: 14, color: Color(0xFF69F0AE))),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Active Accounts", style: TextStyle(fontFamily: AppFontFamily.poppinsRegular, fontSize: 11, color: Colors.white70)),
                    const SizedBox(height: 2),
                    Text("${_customers.length} Households", style: const TextStyle(fontFamily: AppFontFamily.poppinsBold, fontSize: 14, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filterOptions.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(filter),
              labelStyle: TextStyle(
                fontFamily: AppFontFamily.poppinsMedium,
                fontSize: 11.5,
                color: isSelected ? Colors.white : AppTheme.iconColor(context),
              ),
              selectedColor: AppColor.primary_50,
              backgroundColor: AppTheme.customListBg(context),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? AppColor.primary_50 : AppTheme.dividerBg(context),
                ),
              ),
              onSelected: (_) => setState(() => _selectedFilter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVendorCustomerKhataList(
    BuildContext context,
    bool isDark,
    List<KhataCustomer> customers,
  ) {
    if (customers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Column(
            children: [
              Icon(HugeIconsStroke.userMultiple02, size: 40, color: AppTheme.iconColorThree(context)),
              const SizedBox(height: 10),
              Text("No customer accounts found", style: AppTheme.textLabel(context)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Customer Khata Accounts (${customers.length})",
          style: AppTheme.textLabel(context).copyWith(
            fontFamily: AppFontFamily.poppinsSemiBold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        ...customers.map((c) => _buildVendorCustomerKhataCard(context, isDark, c)),
      ],
    );
  }

  Widget _buildVendorCustomerKhataCard(
    BuildContext context,
    bool isDark,
    KhataCustomer customer,
  ) {
    final hasDue = customer.currentBalance > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerBg(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.customerName,
                      style: AppTheme.textLabel(context).copyWith(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.address,
                      style: AppTheme.textSearchInfoLabeled(context).copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              _buildKhataBadge(customer.paymentStatus),
            ],
          ),
          const SizedBox(height: 12),

          // Balance & Liter summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.customListBg(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Volume Consumed",
                      style: AppTheme.textSearchInfoLabeled(context).copyWith(fontSize: 10.5),
                    ),
                    Text(
                      "${customer.totalLitersThisMonth} Liters",
                      style: AppTheme.textLabel(context).copyWith(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      hasDue ? "Balance Due" : "Khata Cleared",
                      style: AppTheme.textSearchInfoLabeled(context).copyWith(fontSize: 10.5),
                    ),
                    Text(
                      "Rs. ${customer.currentBalance.toInt()}",
                      style: TextStyle(
                        fontFamily: AppFontFamily.poppinsBold,
                        fontSize: 14,
                        color: hasDue ? const Color(0xFFE91E63) : const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppTheme.dividerBg(context)),
          const SizedBox(height: 10),

          // Action Buttons
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(HugeIconsSolid.money03, size: 14, color: Colors.white),
                label: const Text(
                  "Record Payment",
                  style: TextStyle(
                    fontFamily: AppFontFamily.poppinsMedium,
                    fontSize: 11.5,
                    color: Colors.white,
                  ),
                ),
                onPressed: () => _showRecordPaymentDialog(customer),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(HugeIconsStroke.invoice01, size: 14),
                label: const Text(
                  "Ledger",
                  style: TextStyle(fontFamily: AppFontFamily.poppinsMedium, fontSize: 11),
                ),
                onPressed: () => _showCustomerStatementModal(customer),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(HugeIconsStroke.call02, size: 18),
                color: AppTheme.iconColorThree(context),
                onPressed: () => _launchCall(customer.customerPhone),
                tooltip: "Call Customer",
              ),
              IconButton(
                icon: const Icon(HugeIconsSolid.message02, size: 18),
                color: const Color(0xFF25D366),
                onPressed: () => _launchWhatsApp(
                  customer.customerPhone,
                  "Assalam-o-Alaikum ${customer.customerName}! Your Dogar Dairy bill for $_selectedMonth is Rs. ${customer.currentBalance.toInt()} (${customer.totalLitersThisMonth} L delivered). Please clear your balance via JazzCash/EasyPaisa (03410292698). Thank you!",
                ),
                tooltip: "Send WhatsApp Bill",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── CUSTOMER MILK BUYER KHATA VIEW ───────────────────────────────────────

  Widget _buildCustomerHeroBill(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1552), const Color(0xFF130E38)]
              : [const Color(0xFF4838D1), const Color(0xFF6756F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary_50.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Current Month Due",
                style: TextStyle(
                  fontFamily: AppFontFamily.poppinsMedium,
                  fontSize: 12.5,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Due by 5th Sep",
                  style: TextStyle(
                    fontFamily: AppFontFamily.poppinsSemiBold,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Rs. 4,280",
            style: TextStyle(
              fontFamily: AppFontFamily.poppinsBold,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 14),

          // Sub totals
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Liters", style: TextStyle(fontFamily: AppFontFamily.poppinsRegular, fontSize: 11, color: Colors.white70)),
                    SizedBox(height: 2),
                    Text("62.0 Liters", style: TextStyle(fontFamily: AppFontFamily.poppinsBold, fontSize: 14, color: Colors.white)),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Paid So Far", style: TextStyle(fontFamily: AppFontFamily.poppinsRegular, fontSize: 11, color: Colors.white70)),
                    SizedBox(height: 2),
                    Text("Rs. 9,360", style: TextStyle(fontFamily: AppFontFamily.poppinsBold, fontSize: 14, color: Color(0xFF69F0AE))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerPaymentOptions(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              const Icon(HugeIconsSolid.creditCard, color: AppColor.primary_50, size: 18),
              const SizedBox(width: 8),
              Text(
                "Vendor Payment Channels",
                style: AppTheme.textTitle(context).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // JazzCash & EasyPaisa Pill
          _buildPaymentAccountTile(
            context,
            title: "JazzCash / EasyPaisa",
            accountNumber: "03410292698",
            accountTitle: "Dogar Dairy Farm",
            iconColor: const Color(0xFFE91E63),
          ),
          const SizedBox(height: 10),

          // Bank Account Pill
          _buildPaymentAccountTile(
            context,
            title: "Meezan Bank Ltd",
            accountNumber: "01020304050607",
            accountTitle: "Dogar Dairy Karachi",
            iconColor: const Color(0xFF00897B),
          ),
          const SizedBox(height: 14),

          // Share receipt on WhatsApp
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(HugeIconsSolid.message02, size: 16, color: Colors.white),
            label: const Text(
              "Share Payment Proof on WhatsApp",
              style: TextStyle(
                fontFamily: AppFontFamily.poppinsMedium,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            onPressed: () => _launchWhatsApp(
              "+923410292698",
              "Assalam-o-Alaikum Dogar Dairy! I have transferred the milk bill payment of Rs. 4,280 for $_selectedMonth. Please find attached proof.",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentAccountTile(
    BuildContext context, {
    required String title,
    required String accountNumber,
    required String accountTitle,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.customListBg(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(HugeIconsSolid.creditCard, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.textLabel(context).copyWith(fontFamily: AppFontFamily.poppinsSemiBold, fontSize: 12)),
                Text("$accountNumber • $accountTitle", style: AppTheme.textSearchInfoLabeled(context).copyWith(fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(HugeIconsStroke.copy01, size: 16),
            color: AppTheme.iconColorThree(context),
            onPressed: () => _copyToClipboard(accountNumber, title),
            tooltip: "Copy $title Number",
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDailyLedger(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Daily Ledger & Milk Log",
              style: AppTheme.textLabel(context).copyWith(
                fontFamily: AppFontFamily.poppinsSemiBold,
                fontSize: 13,
              ),
            ),
            InkWell(
              onTap: () {
                AppSnackBar.show(
                  context,
                  message: "Downloading Monthly PDF Statement...",
                  type: AppSnackBarType.info,
                );
              },
              child: Row(
                children: [
                  const Icon(HugeIconsStroke.download01, size: 14, color: AppColor.primary_50),
                  const SizedBox(width: 4),
                  Text(
                    "Download PDF",
                    style: TextStyle(
                      fontFamily: AppFontFamily.poppinsMedium,
                      fontSize: 11.5,
                      color: AppColor.primary_50,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._myLedgerEntries.map((e) => _buildTransactionRow(context, e)),
      ],
    );
  }

  Widget _buildKhataBadge(String status) {
    Color bg;
    Color text;
    String label;

    switch (status.toLowerCase()) {
      case 'paid':
        bg = const Color(0xFF2E7D32).withValues(alpha: 0.12);
        text = const Color(0xFF2E7D32);
        label = "Paid";
        break;
      case 'overdue':
        bg = const Color(0xFFE91E63).withValues(alpha: 0.12);
        text = const Color(0xFFE91E63);
        label = "Overdue";
        break;
      case 'pending':
      default:
        bg = const Color(0xFFF57C00).withValues(alpha: 0.12);
        text = const Color(0xFFF57C00);
        label = "Pending";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFontFamily.poppinsSemiBold,
          fontSize: 10.5,
          color: text,
        ),
      ),
    );
  }
}
