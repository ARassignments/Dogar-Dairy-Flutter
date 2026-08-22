import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '/components/appsnackbar.dart';
import '/models/monthly_supply_model.dart';
import '/providers/user_provider.dart';
import '/screens/monthly_supply_detail_screen.dart';
import '/theme/theme.dart';
import '/utils/session_manager.dart';

class MonthlySupplyScreen extends ConsumerStatefulWidget {
  const MonthlySupplyScreen({super.key});

  @override
  ConsumerState<MonthlySupplyScreen> createState() => _MonthlySupplyScreenState();
}

class _MonthlySupplyScreenState extends ConsumerState<MonthlySupplyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = "All";
  String _selectedRoute = "All Routes";
  String _selectedMonth = "August 2026";
  String _cachedRole = "customer";

  final List<String> _routes = [
    "All Routes",
    "Route A - North Nazimabad",
    "Route B - Gulshan-e-Iqbal",
    "Route C - PECHS & Nursery",
    "Route D - DHA & Clifton",
    "Route E - Malir Cantt",
  ];

  final List<String> _statusFilters = ["All", "Active", "Paused", "Pending"];

  final List<String> _months = [
    "August 2026",
    "September 2026",
    "October 2026",
    "November 2026",
    "December 2026",
  ];

  late List<MonthlySupplyModel> _subscriptions;

  @override
  void initState() {
    super.initState();
    _loadCachedRole();
    _initSampleSubscriptions();
  }

  Future<void> _loadCachedRole() async {
    final user = await SessionManager.getUser();
    if (user != null && user['role'] != null && mounted) {
      setState(() {
        _cachedRole = user['role'].toString().toLowerCase();
      });
    }
  }

  void _initSampleSubscriptions() {
    _subscriptions = [
      MonthlySupplyModel(
        id: "ms-1",
        customerId: "c-101",
        customerName: "Chaudhry Muhammad Aslam",
        customerPhone: "+92 300 1234567",
        address: "House 14-B, Block C, North Nazimabad",
        route: "Route A - North Nazimabad",
        dailyBuffaloLiters: 2.0,
        dailyCowLiters: 1.0,
        dailyGoatLiters: 0.0,
        ratePerLiterBuffalo: 220.0,
        ratePerLiterCow: 200.0,
        preferredSlot: "morning",
        preferredTime: "6:30 AM",
        status: "active",
        startDate: DateTime(2026, 1, 1),
        assignedRider: "Tariq Mahmood",
        riderPhone: "+923410292698",
        notes: "Leave in blue porch cooler.",
      ),
      MonthlySupplyModel(
        id: "ms-2",
        customerId: "c-102",
        customerName: "Haji Abdul Rasheed",
        customerPhone: "+92 321 9876543",
        address: "Flat 402, Al-Razi Heights, Gulshan",
        route: "Route B - Gulshan-e-Iqbal",
        dailyBuffaloLiters: 3.5,
        dailyCowLiters: 0.0,
        dailyGoatLiters: 0.0,
        ratePerLiterBuffalo: 220.0,
        preferredSlot: "morning",
        preferredTime: "7:00 AM",
        status: "active",
        startDate: DateTime(2026, 2, 1),
        assignedRider: "Imran Khan",
        riderPhone: "+923410292698",
      ),
      MonthlySupplyModel(
        id: "ms-3",
        customerId: "c-103",
        customerName: "Dr. Farhan Siddiqui",
        customerPhone: "+92 333 4567890",
        address: "Villa 88, Street 9, PECHS Block 2",
        route: "Route C - PECHS & Nursery",
        dailyBuffaloLiters: 1.0,
        dailyCowLiters: 2.0,
        dailyGoatLiters: 0.5,
        ratePerLiterBuffalo: 220.0,
        ratePerLiterCow: 200.0,
        ratePerLiterGoat: 280.0,
        preferredSlot: "both",
        preferredTime: "Morning 6:45 AM & Eve 6:00 PM",
        status: "active",
        startDate: DateTime(2026, 3, 15),
        assignedRider: "Tariq Mahmood",
        riderPhone: "+923410292698",
      ),
      MonthlySupplyModel(
        id: "ms-4",
        customerId: "c-104",
        customerName: "Mrs. Naila Tariq",
        customerPhone: "+92 345 6789012",
        address: "Bungalow 22-A, DHA Phase 6",
        route: "Route D - DHA & Clifton",
        dailyBuffaloLiters: 4.0,
        dailyCowLiters: 2.0,
        dailyGoatLiters: 0.0,
        ratePerLiterBuffalo: 220.0,
        ratePerLiterCow: 200.0,
        preferredSlot: "morning",
        preferredTime: "6:15 AM",
        status: "paused",
        startDate: DateTime(2026, 4, 1),
        pauseStartDate: DateTime(2026, 8, 15),
        pauseEndDate: DateTime(2026, 8, 25),
        assignedRider: "Imran Khan",
        riderPhone: "+923410292698",
        notes: "Family travelling to Lahore.",
      ),
      MonthlySupplyModel(
        id: "ms-5",
        customerId: "c-105",
        customerName: "Malik Shahbaz",
        customerPhone: "+92 312 3456789",
        address: "Shop 5, Dairy Chowk, Malir Cantt",
        route: "Route E - Malir Cantt",
        dailyBuffaloLiters: 15.0,
        dailyCowLiters: 5.0,
        dailyGoatLiters: 0.0,
        ratePerLiterBuffalo: 215.0,
        ratePerLiterCow: 195.0,
        preferredSlot: "morning",
        preferredTime: "5:30 AM",
        status: "active",
        startDate: DateTime(2026, 5, 1),
        assignedRider: "Bilal Ahmed",
        riderPhone: "+923410292698",
        notes: "Commercial shopkeeper monthly bulk supply.",
      ),
    ];
  }

  Future<void> _launchCall(String phone) async {
    final clean = phone.replaceAll(" ", "");
    final Uri url = Uri.parse("tel:$clean");
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
    final Uri url = Uri.parse(
      "https://wa.me/$clean?text=${Uri.encodeComponent(message)}",
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _sendWhatsAppStatement(MonthlySupplyModel item) {
    final message =
        "🥛 *DOGAR DAIRY — MONTHLY SUPPLY STATEMENT*\n"
        "------------------------------------\n"
        "👤 *Customer:* ${item.customerName}\n"
        "📅 *Month:* $_selectedMonth\n"
        "📍 *Route:* ${item.route}\n"
        "⏰ *Drop Slot:* ${item.preferredSlot.toUpperCase()} (${item.preferredTime})\n"
        "------------------------------------\n"
        "🥛 *Daily Quota:*\n"
        "${item.dailyBuffaloLiters > 0 ? '• Buffalo Milk: ${item.dailyBuffaloLiters} L @ Rs. ${item.ratePerLiterBuffalo.toInt()}/L\n' : ''}"
        "${item.dailyCowLiters > 0 ? '• Cow Milk: ${item.dailyCowLiters} L @ Rs. ${item.ratePerLiterCow.toInt()}/L\n' : ''}"
        "${item.dailyGoatLiters > 0 ? '• Goat Milk: ${item.dailyGoatLiters} L @ Rs. ${item.ratePerLiterGoat.toInt()}/L\n' : ''}"
        "📊 *Total Daily Liters:* ${item.totalDailyLiters} Liters\n"
        "💰 *Daily Total:* Rs. ${item.dailyCost.toStringAsFixed(0)}\n"
        "💵 *Est. Monthly Total (30 Days):* Rs. ${item.estimatedMonthlyCost.toStringAsFixed(0)}\n"
        "------------------------------------\n"
        "🚴 *Assigned Rider:* ${item.assignedRider} (${item.riderPhone})\n"
        "⚡ *Status:* ${item.status.toUpperCase()}\n\n"
        "For adjustments or vacation pauses, contact Dogar Dairy Support: +92 341 0292698";

    _launchWhatsApp(item.customerPhone, message);
  }

  void _showAddSubscriptionModal() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final buffaloCtrl = TextEditingController(text: "2.0");
    final cowCtrl = TextEditingController(text: "1.0");
    final goatCtrl = TextEditingController(text: "0.0");
    final buffaloRateCtrl = TextEditingController(text: "220");
    final cowRateCtrl = TextEditingController(text: "200");
    final notesCtrl = TextEditingController();
    String slot = "morning";
    String route = _routes[1];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final buff = double.tryParse(buffaloCtrl.text) ?? 0.0;
            final cow = double.tryParse(cowCtrl.text) ?? 0.0;
            final goat = double.tryParse(goatCtrl.text) ?? 0.0;
            final buffRate = double.tryParse(buffaloRateCtrl.text) ?? 220.0;
            final cowRate = double.tryParse(cowRateCtrl.text) ?? 200.0;
            final dailyTotal = (buff * buffRate) + (cow * cowRate);
            final monthlyTotal = dailyTotal * 30;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(HugeIconsSolid.truck, color: AppColor.primary_50, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          "New Monthly Subscription",
                          style: AppTheme.textTitle(ctx).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Customer Name
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Customer Full Name",
                        prefixIcon: Icon(HugeIconsStroke.user03, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Phone & Address
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: "Phone (WhatsApp)",
                              prefixIcon: Icon(HugeIconsStroke.call02, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: slot,
                            decoration: const InputDecoration(
                              labelText: "Slot",
                              prefixIcon: Icon(HugeIconsStroke.sun01, size: 20),
                            ),
                            items: const [
                              DropdownMenuItem(value: "morning", child: Text("Morning (AM)")),
                              DropdownMenuItem(value: "evening", child: Text("Evening (PM)")),
                              DropdownMenuItem(value: "both", child: Text("Both Slots")),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => slot = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(
                        labelText: "Delivery Address & House #",
                        prefixIcon: Icon(HugeIconsStroke.location01, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Route Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: route,
                      decoration: const InputDecoration(
                        labelText: "Delivery Route",
                        prefixIcon: Icon(HugeIconsStroke.route01, size: 20),
                      ),
                      items: _routes.where((r) => r != "All Routes").map((r) {
                        return DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => route = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Liters Inputs
                    Text(
                      "Daily Milk Quotas & Rates",
                      style: AppTheme.textLabel(ctx).copyWith(fontFamily: AppFontFamily.poppinsSemiBold, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: buffaloCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: "🥛 Buffalo (L/day)",
                            ),
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: cowCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: "🐄 Cow (L/day)",
                            ),
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: goatCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: "🐐 Goat (L/day)",
                            ),
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: "Special Delivery Notes (Optional)",
                        prefixIcon: Icon(HugeIconsStroke.note, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Live Cost Summary Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColor.primary_50.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.primary_50.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Daily Commitment",
                                style: TextStyle(fontFamily: AppFontFamily.poppinsRegular, fontSize: 11),
                              ),
                              Text(
                                "${(buff + cow + goat).toStringAsFixed(1)} Liters / Day",
                                style: const TextStyle(
                                  fontFamily: AppFontFamily.poppinsSemiBold,
                                  fontSize: 13,
                                  color: AppColor.primary_50,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Estimated Monthly Bill",
                                style: TextStyle(fontFamily: AppFontFamily.poppinsRegular, fontSize: 11),
                              ),
                              Text(
                                "Rs. ${monthlyTotal.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontFamily: AppFontFamily.poppinsSemiBold,
                                  fontSize: 14,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary_50,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) {
                          AppSnackBar.show(ctx, message: "Please enter customer name", type: AppSnackBarType.error);
                          return;
                        }
                        final newSub = MonthlySupplyModel(
                          id: "ms-${DateTime.now().millisecondsSinceEpoch}",
                          customerId: "c-${DateTime.now().millisecondsSinceEpoch}",
                          customerName: nameCtrl.text.trim(),
                          customerPhone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : "+92 300 0000000",
                          address: addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : "Karachi, Pakistan",
                          route: route,
                          dailyBuffaloLiters: buff,
                          dailyCowLiters: cow,
                          dailyGoatLiters: goat,
                          ratePerLiterBuffalo: buffRate,
                          ratePerLiterCow: cowRate,
                          preferredSlot: slot,
                          preferredTime: slot == "morning" ? "6:30 AM" : "5:30 PM",
                          status: "active",
                          startDate: DateTime.now(),
                          notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                        );

                        setState(() {
                          _subscriptions.insert(0, newSub);
                        });
                        Navigator.pop(ctx);
                        AppSnackBar.show(
                          context,
                          message: "Monthly subscription created for ${newSub.customerName}!",
                          type: AppSnackBarType.success,
                        );
                      },
                      child: const Text(
                        "Activate Monthly Subscription",
                        style: TextStyle(color: Colors.white, fontFamily: AppFontFamily.poppinsSemiBold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditSubscriptionModal(MonthlySupplyModel item) {
    final buffaloCtrl = TextEditingController(text: item.dailyBuffaloLiters.toString());
    final cowCtrl = TextEditingController(text: item.dailyCowLiters.toString());
    final goatCtrl = TextEditingController(text: item.dailyGoatLiters.toString());
    String status = item.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Edit Plan: ${item.customerName}",
                    style: AppTheme.textTitle(ctx).copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.address,
                    style: AppTheme.textSearchInfoLabeled(ctx).copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 14),

                  // Quota Fields
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: buffaloCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: "Buffalo (L/day)"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: cowCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: "Cow (L/day)"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: goatCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: "Goat (L/day)"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: "Subscription Status"),
                    items: const [
                      DropdownMenuItem(value: "active", child: Text("🟢 Active Supply")),
                      DropdownMenuItem(value: "paused", child: Text("🟠 Paused (Vacation)")),
                      DropdownMenuItem(value: "pending", child: Text("🔵 Pending Confirmation")),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => status = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary_50,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final buff = double.tryParse(buffaloCtrl.text) ?? item.dailyBuffaloLiters;
                      final cow = double.tryParse(cowCtrl.text) ?? item.dailyCowLiters;
                      final goat = double.tryParse(goatCtrl.text) ?? item.dailyGoatLiters;

                      setState(() {
                        final index = _subscriptions.indexWhere((s) => s.id == item.id);
                        if (index != -1) {
                          _subscriptions[index] = item.copyWith(
                            dailyBuffaloLiters: buff,
                            dailyCowLiters: cow,
                            dailyGoatLiters: goat,
                            status: status,
                          );
                        }
                      });
                      Navigator.pop(ctx);
                      AppSnackBar.show(context, message: "Subscription updated successfully!", type: AppSnackBarType.success);
                    },
                    child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _togglePauseSubscription(MonthlySupplyModel item) {
    final isPaused = item.status == "paused";
    setState(() {
      final index = _subscriptions.indexWhere((s) => s.id == item.id);
      if (index != -1) {
        _subscriptions[index] = item.copyWith(
          status: isPaused ? "active" : "paused",
          pauseStartDate: isPaused ? null : DateTime.now(),
          pauseEndDate: isPaused ? null : DateTime.now().add(const Duration(days: 7)),
        );
      }
    });

    AppSnackBar.show(
      context,
      message: isPaused
          ? "Resumed monthly supply for ${item.customerName}"
          : "Paused monthly supply for ${item.customerName} (Vacation Mode)",
      type: AppSnackBarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userModel = ref.watch(userProvider);
    final role = (userModel?.role.isNotEmpty == true ? userModel!.role : _cachedRole).toLowerCase();
    final searchQuery = _searchController.text.trim().toLowerCase();

    // Filter Subscriptions
    final filtered = _subscriptions.where((item) {
      final matchesRoute = _selectedRoute == "All Routes" || item.route == _selectedRoute;
      final matchesStatus = _selectedStatusFilter == "All" || item.status.toLowerCase() == _selectedStatusFilter.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          item.customerName.toLowerCase().contains(searchQuery) ||
          item.address.toLowerCase().contains(searchQuery) ||
          item.customerPhone.contains(searchQuery);
      return matchesRoute && matchesStatus && matchesSearch;
    }).toList();

    // Summary calculations
    final activeCount = _subscriptions.where((s) => s.status == 'active').length;
    final pausedCount = _subscriptions.where((s) => s.status == 'paused').length;
    final totalDailyLiters = _subscriptions.where((s) => s.status == 'active').fold(0.0, (sum, s) => sum + s.totalDailyLiters);
    final totalMonthlyLiters = totalDailyLiters * 30;
    final totalMonthlyRevenue = _subscriptions.where((s) => s.status == 'active').fold(0.0, (sum, s) => sum + s.estimatedMonthlyCost);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          role == 'staff' ? "Monthly Supply Manager" : (role == 'admin' ? "Platform Monthly Supply" : "My Monthly Supply"),
          style: AppTheme.textTitle(context).copyWith(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (role == 'staff')
            IconButton(
              icon: const Icon(HugeIconsStroke.addCircle, color: AppColor.primary_50),
              onPressed: _showAddSubscriptionModal,
              tooltip: "Add New Subscriber",
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Summary Card
              _buildHeroSummaryCard(
                context,
                isDark,
                role: role,
                activeCount: activeCount,
                pausedCount: pausedCount,
                monthlyLiters: totalMonthlyLiters,
                monthlyRevenue: totalMonthlyRevenue,
              ),
              const SizedBox(height: 16),

              if (role == 'staff' || role == 'admin') ...[
                // Month Selector & Route Filter Row
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedMonth,
                        decoration: InputDecoration(
                          labelText: "Active Month",
                          prefixIcon: const Icon(HugeIconsStroke.calendar01, size: 18),
                          filled: true,
                          fillColor: AppTheme.customListBg2(context),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: _months.map((m) {
                          return DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedMonth = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedRoute,
                        decoration: InputDecoration(
                          labelText: "Route Filter",
                          prefixIcon: const Icon(HugeIconsStroke.route01, size: 18),
                          filled: true,
                          fillColor: AppTheme.customListBg2(context),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: _routes.map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text(r, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRoute = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search Bar
                TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Search Subscribers",
                    hintText: "Search by customer name, phone, address...",
                    prefixIcon: const Icon(HugeIconsSolid.search01, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(HugeIconsStroke.cancel02, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.customListBg2(context),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),

                // Status Filter Chips
                _buildStatusFilterChips(context),
                const SizedBox(height: 16),

                // Customer Subscriptions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Monthly Subscribers (${filtered.length})",
                      style: AppTheme.textLabel(context).copyWith(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      "Total: ${totalDailyLiters.toStringAsFixed(1)} L/Day",
                      style: const TextStyle(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 12,
                        color: AppColor.primary_50,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Subscriber Cards List
                if (filtered.isEmpty)
                  _buildEmptyState(context)
                else
                  ...filtered.map((item) => _buildSubscriberCard(context, isDark, item)),
              ] else ...[
                // Customer Perspective Monthly Supply
                _buildCustomerMonthlyView(context, isDark),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: role == 'staff'
          ? FloatingActionButton.extended(
              backgroundColor: AppColor.primary_50,
              icon: const Icon(HugeIconsSolid.addCircle, color: Colors.white, size: 18),
              label: const Text("New Subscriber", style: TextStyle(color: Colors.white, fontFamily: AppFontFamily.poppinsSemiBold)),
              onPressed: _showAddSubscriptionModal,
            )
          : null,
    );
  }

  Widget _buildHeroSummaryCard(
    BuildContext context,
    bool isDark, {
    required String role,
    required int activeCount,
    required int pausedCount,
    required double monthlyLiters,
    required double monthlyRevenue,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A148C).withValues(alpha: 0.3),
            blurRadius: 14,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(HugeIconsSolid.truck, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    role == 'customer' ? "My Monthly Commitment" : "Monthly Supply Forecast",
                    style: const TextStyle(
                      fontFamily: AppFontFamily.poppinsSemiBold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _selectedMonth,
                  style: const TextStyle(
                    fontFamily: AppFontFamily.poppinsMedium,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Projected Monthly Volume",
                      style: TextStyle(
                        fontFamily: AppFontFamily.poppinsRegular,
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role == 'customer' ? "90.0 Liters" : "${monthlyLiters.toStringAsFixed(0)} Liters",
                      style: const TextStyle(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 36, width: 1, color: Colors.white24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Estimated Billing",
                      style: TextStyle(
                        fontFamily: AppFontFamily.poppinsRegular,
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role == 'customer' ? "Rs. 19,800" : "Rs. ${monthlyRevenue.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 20,
                        color: Color(0xFFFFD54F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (role == 'staff' || role == 'admin') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                _buildHeroBadge("🟢 $activeCount Active Households"),
                const SizedBox(width: 8),
                _buildHeroBadge("🟠 $pausedCount Vacation Pauses"),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppFontFamily.poppinsMedium,
          fontSize: 11,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _statusFilters.map((filter) {
          final isSelected = _selectedStatusFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  fontFamily: AppFontFamily.poppinsMedium,
                  fontSize: 11.5,
                  color: isSelected ? Colors.white : AppTheme.iconColor(context),
                ),
              ),
              selected: isSelected,
              selectedColor: AppColor.primary_50,
              backgroundColor: AppTheme.customListBg2(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? AppColor.primary_50 : AppTheme.dividerBg(context),
                ),
              ),
              onSelected: (_) => setState(() => _selectedStatusFilter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubscriberCard(BuildContext context, bool isDark, MonthlySupplyModel item) {
    final isPaused = item.status == "paused";

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MonthlySupplyDetailScreen(subscription: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPaused ? Colors.amber.withValues(alpha: 0.4) : AppTheme.dividerBg(context),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColor.primary_50.withValues(alpha: 0.15),
                        child: Text(
                          item.customerName.isNotEmpty ? item.customerName[0].toUpperCase() : "C",
                          style: const TextStyle(
                            fontFamily: AppFontFamily.poppinsSemiBold,
                            color: AppColor.primary_50,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.textLabel(context).copyWith(
                                fontFamily: AppFontFamily.poppinsSemiBold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              item.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.textSearchInfoLabeled(context).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaused
                        ? Colors.amber.withValues(alpha: 0.15)
                        : const Color(0xFF2E7D32).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPaused ? "Paused" : "Active",
                    style: TextStyle(
                      fontFamily: AppFontFamily.poppinsSemiBold,
                      fontSize: 10.5,
                      color: isPaused ? Colors.amber.shade800 : const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Daily Liter Quota breakdown
            Row(
              children: [
                if (item.dailyBuffaloLiters > 0)
                  _buildQuotaPill("🥛 Buffalo: ${item.dailyBuffaloLiters} L", context),
                if (item.dailyCowLiters > 0) ...[
                  const SizedBox(width: 6),
                  _buildQuotaPill("🐄 Cow: ${item.dailyCowLiters} L", context),
                ],
                if (item.dailyGoatLiters > 0) ...[
                  const SizedBox(width: 6),
                  _buildQuotaPill("🐐 Goat: ${item.dailyGoatLiters} L", context),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Monthly Estimated Value & Delivery Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(HugeIconsStroke.route01, size: 14, color: AppTheme.iconColorThree(context)),
                    const SizedBox(width: 4),
                    Text(
                      item.route.split(" - ").first,
                      style: TextStyle(
                        fontFamily: AppFontFamily.poppinsRegular,
                        fontSize: 11,
                        color: AppTheme.iconColorThree(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(HugeIconsStroke.sun01, size: 14, color: AppTheme.iconColorThree(context)),
                    const SizedBox(width: 4),
                    Text(
                      item.preferredTime,
                      style: TextStyle(
                        fontFamily: AppFontFamily.poppinsRegular,
                        fontSize: 11,
                        color: AppTheme.iconColorThree(context),
                      ),
                    ),
                  ],
                ),
                Text(
                  "Rs. ${item.estimatedMonthlyCost.toStringAsFixed(0)} / mo",
                  style: const TextStyle(
                    fontFamily: AppFontFamily.poppinsSemiBold,
                    fontSize: 13,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons: Edit, Pause/Resume, WhatsApp, Call
            Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(HugeIconsStroke.view, size: 14),
                  label: const Text("Details", style: TextStyle(fontSize: 11, fontFamily: AppFontFamily.poppinsMedium)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MonthlySupplyDetailScreen(subscription: item),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(HugeIconsStroke.edit01, size: 14),
                  label: const Text("Edit", style: TextStyle(fontSize: 11, fontFamily: AppFontFamily.poppinsMedium)),
                  onPressed: () => _showEditSubscriptionModal(item),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(
                    isPaused ? HugeIconsSolid.play : HugeIconsStroke.pauseCircle,
                    size: 14,
                    color: isPaused ? const Color(0xFF2E7D32) : Colors.amber.shade800,
                  ),
                  label: Text(
                    isPaused ? "Resume" : "Pause",
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: AppFontFamily.poppinsMedium,
                      color: isPaused ? const Color(0xFF2E7D32) : Colors.amber.shade800,
                    ),
                  ),
                  onPressed: () => _togglePauseSubscription(item),
                ),
                const Spacer(),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.12),
                    padding: const EdgeInsets.all(6),
                  ),
                  icon: const Icon(HugeIconsSolid.message02, color: Color(0xFF25D366), size: 16),
                  tooltip: "Send WhatsApp Bill Statement",
                  onPressed: () => _sendWhatsAppStatement(item),
                ),
                const SizedBox(width: 4),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColor.primary_50.withValues(alpha: 0.12),
                    padding: const EdgeInsets.all(6),
                  ),
                  icon: const Icon(HugeIconsStroke.call02, color: AppColor.primary_50, size: 16),
                  tooltip: "Call Customer",
                  onPressed: () => _launchCall(item.customerPhone),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotaPill(String text, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.customListBg2(context),
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildCustomerMonthlyView(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.dividerBg(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(HugeIconsSolid.checkmarkBadge02, color: Color(0xFF2E7D32), size: 22),
              const SizedBox(width: 8),
              Text(
                "My Household Monthly Plan",
                style: AppTheme.textTitle(context).copyWith(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "🥛 Daily Fresh Buffalo Milk: 2.0 Liters\n🐄 Daily Pure Cow Milk: 1.0 Liters\n⏰ Morning Shift Drop: 6:30 AM – 7:00 AM\n🚴 Assigned Rider: Tariq Mahmood (+92 341 0292698)",
            style: AppTheme.textLabel(context).copyWith(
              fontFamily: AppFontFamily.poppinsRegular,
              fontSize: 12.5,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(HugeIconsStroke.calendar01, size: 16),
                  label: const Text("View Daily Log", style: TextStyle(fontSize: 11.5)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MonthlySupplyDetailScreen(subscription: _subscriptions.first),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary_50),
                  icon: const Icon(HugeIconsSolid.message02, color: Colors.white, size: 16),
                  label: const Text("WhatsApp Dairy", style: TextStyle(color: Colors.white, fontSize: 11.5)),
                  onPressed: () {
                    _launchWhatsApp("+923410292698", "Hello Dogar Dairy! Regarding my monthly milk subscription...");
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            Icon(HugeIconsStroke.truck, size: 40, color: AppTheme.iconColorThree(context)),
            const SizedBox(height: 10),
            Text("No monthly subscribers found", style: AppTheme.textLabel(context)),
            const SizedBox(height: 4),
            Text("Try another route, status, or search term", style: AppTheme.textSearchInfoLabeled(context)),
          ],
        ),
      ),
    );
  }
}
