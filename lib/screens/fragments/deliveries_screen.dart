import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '/components/appsnackbar.dart';
import '/models/delivery_model.dart';
import '/providers/user_provider.dart';
import '/providers/search_provider.dart';
import '/theme/theme.dart';

class DeliveriesScreen extends ConsumerStatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  ConsumerState<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends ConsumerState<DeliveriesScreen>
    with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate = DateTime.now();
  String _selectedSlot = "morning"; // 'morning' or 'evening'
  String _selectedStatusFilter = "All";
  String _selectedRoute = "Route 1 - North Nazimabad";

  final List<String> _routes = [
    "Route 1 - North Nazimabad",
    "Route 2 - Gulshan & Johar",
    "Route 3 - PECHS & Clifton",
    "Route 4 - DHA & Cantt",
  ];

  final List<String> _statusFilters = [
    "All",
    "Delivered",
    "Pending",
    "Extra",
    "Paused",
  ];

  // In-memory persistent demo delivery items
  late List<DeliveryItem> _deliveries;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initMockDeliveries();
  }

  void _initMockDeliveries() {
    final now = DateTime.now();
    _deliveries = [
      DeliveryItem(
        id: "DEL-101",
        customerId: "CUST-001",
        customerName: "Muhammad Usman",
        customerPhone: "03001234567",
        address: "House 42, Block B, North Nazimabad",
        route: "Route 1 - North Nazimabad",
        date: now,
        slot: "morning",
        buffaloLiters: 2.0,
        cowLiters: 1.0,
        totalAmount: 640.0,
        status: "delivered",
        deliveredAt: now.subtract(const Duration(hours: 2)),
        riderName: "Tariq Mahmood",
        riderPhone: "+923410292698",
        lactometerScore: "29.5 LR (Grade A+)",
        fatPercentage: "7.2% Natural Fat",
        notes: "Leave bottle inside the gate basket",
      ),
      DeliveryItem(
        id: "DEL-102",
        customerId: "CUST-002",
        customerName: "Dr. Ayesha Siddiqui",
        customerPhone: "03219876543",
        address: "Flat 4-B, Al-Razi Heights, Block C",
        route: "Route 1 - North Nazimabad",
        date: now,
        slot: "morning",
        buffaloLiters: 1.5,
        cowLiters: 0.0,
        totalAmount: 330.0,
        status: "delivered",
        deliveredAt: now.subtract(const Duration(hours: 1, minutes: 40)),
        riderName: "Tariq Mahmood",
        riderPhone: "+923410292698",
        lactometerScore: "29.8 LR (Grade A+)",
        fatPercentage: "7.4% Natural Fat",
      ),
      DeliveryItem(
        id: "DEL-103",
        customerId: "CUST-003",
        customerName: "Haji Abdul Rasheed",
        customerPhone: "03335554433",
        address: "House 118, Street 7, Block D",
        route: "Route 1 - North Nazimabad",
        date: now,
        slot: "morning",
        buffaloLiters: 3.0,
        cowLiters: 1.0,
        extraLiters: 1.0,
        totalAmount: 1060.0,
        status: "extra",
        deliveredAt: now.subtract(const Duration(minutes: 50)),
        riderName: "Tariq Mahmood",
        riderPhone: "+923410292698",
        notes: "Requested +1L extra buffalo milk for guests",
      ),
      DeliveryItem(
        id: "DEL-104",
        customerId: "CUST-004",
        customerName: "Rashid Minhas",
        customerPhone: "03451122334",
        address: "House 9, Lane 3, Block A",
        route: "Route 1 - North Nazimabad",
        date: now,
        slot: "morning",
        buffaloLiters: 2.0,
        cowLiters: 0.0,
        totalAmount: 440.0,
        status: "pending",
        riderName: "Tariq Mahmood",
        riderPhone: "+923410292698",
      ),
      DeliveryItem(
        id: "DEL-105",
        customerId: "CUST-005",
        customerName: "Chaudhry Akram",
        customerPhone: "03112233445",
        address: "House 67, Block J, North Nazimabad",
        route: "Route 1 - North Nazimabad",
        date: now,
        slot: "morning",
        buffaloLiters: 2.0,
        cowLiters: 2.0,
        totalAmount: 840.0,
        status: "paused",
        riderName: "Tariq Mahmood",
        riderPhone: "+923410292698",
        notes: "On vacation until Aug 25",
      ),
      // Evening Items
      DeliveryItem(
        id: "DEL-201",
        customerId: "CUST-001",
        customerName: "Muhammad Usman",
        customerPhone: "03001234567",
        address: "House 42, Block B, North Nazimabad",
        route: "Route 1 - North Nazimabad",
        date: now,
        slot: "evening",
        buffaloLiters: 1.5,
        cowLiters: 0.0,
        totalAmount: 330.0,
        status: "pending",
        riderName: "Imran Khan",
        riderPhone: "+923410292698",
        lactometerScore: "29.6 LR",
        fatPercentage: "7.1% Fat",
      ),
      DeliveryItem(
        id: "DEL-202",
        customerId: "CUST-002",
        customerName: "Dr. Ayesha Siddiqui",
        customerPhone: "03219876543",
        address: "Flat 4-B, Al-Razi Heights, Block C",
        route: "Route 1 - North Nazimabad",
        date: now,
        slot: "evening",
        buffaloLiters: 1.0,
        cowLiters: 1.0,
        totalAmount: 420.0,
        status: "pending",
        riderName: "Imran Khan",
        riderPhone: "+923410292698",
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

  void _markDelivered(String id) {
    setState(() {
      final index = _deliveries.indexWhere((d) => d.id == id);
      if (index != -1) {
        _deliveries[index] = _deliveries[index].copyWith(
          status: "delivered",
          deliveredAt: DateTime.now(),
        );
      }
    });
    AppSnackBar.show(
      context,
      message: "Drop marked as Delivered successfully!",
      type: AppSnackBarType.success,
    );
  }

  void _markPaused(String id) {
    setState(() {
      final index = _deliveries.indexWhere((d) => d.id == id);
      if (index != -1) {
        _deliveries[index] = _deliveries[index].copyWith(status: "paused");
      }
    });
    AppSnackBar.show(
      context,
      message: "Delivery marked as Paused for today.",
      type: AppSnackBarType.info,
    );
  }

  Future<void> _showAddExtraLitersDialog(DeliveryItem item) async {
    final controller = TextEditingController(text: "1.0");
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: AppTheme.cardBg(context),
          title: Text(
            "Add Extra Milk Liters",
            style: AppTheme.textTitle(context).copyWith(fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Customer: ${item.customerName}",
                style: AppTheme.textLabel(context).copyWith(
                  fontFamily: AppFontFamily.poppinsSemiBold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Current Quota: ${item.totalLiters} L",
                style: AppTheme.textSearchInfoLabeled(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Extra Liters to Add",
                  suffixText: "Liters",
                  prefixIcon: Icon(HugeIconsSolid.milkBottle, size: 20),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: TextStyle(color: AppTheme.iconColorThree(context))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary_50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final extra = double.tryParse(controller.text.trim()) ?? 0.0;
                if (extra > 0) {
                  setState(() {
                    final index = _deliveries.indexWhere((d) => d.id == item.id);
                    if (index != -1) {
                      final current = _deliveries[index];
                      _deliveries[index] = current.copyWith(
                        extraLiters: current.extraLiters + extra,
                        status: "extra",
                        totalAmount: current.totalAmount + (extra * 220.0),
                      );
                    }
                  });
                  Navigator.pop(ctx);
                  AppSnackBar.show(
                    context,
                    message: "+$extra L added to today's drop!",
                    type: AppSnackBarType.success,
                  );
                }
              },
              child: const Text("Confirm Extra", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPauseVacationModal() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: DateTimeRange(
        start: DateTime.now().add(const Duration(days: 1)),
        end: DateTime.now().add(const Duration(days: 5)),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColor.primary_50,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      AppSnackBar.show(
        context,
        message:
            "Deliveries paused from ${picked.start.day}/${picked.start.month} to ${picked.end.day}/${picked.end.month}.",
        type: AppSnackBarType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userModel = ref.watch(userProvider);
    final role = (userModel?.role.isNotEmpty == true ? userModel!.role : "customer")
        .toLowerCase();
    final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();

    // Filter deliveries
    final currentDeliveries = _deliveries.where((d) {
      final matchesSlot = d.slot == _selectedSlot;
      final matchesRoute = role != 'staff' || d.route == _selectedRoute;
      final matchesStatus = _selectedStatusFilter == "All" ||
          d.status.toLowerCase() == _selectedStatusFilter.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          d.customerName.toLowerCase().contains(searchQuery) ||
          d.address.toLowerCase().contains(searchQuery) ||
          d.customerPhone.contains(searchQuery);

      return matchesSlot && matchesRoute && matchesStatus && matchesSearch;
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Date Selector Strip
            _buildDateSelectorStrip(context, isDark),
            const SizedBox(height: 16),

            // 2. Slot Selector Toggle (Morning AM / Evening PM)
            _buildSlotSelector(context, isDark),
            const SizedBox(height: 16),

            if (role == 'staff') ...[
              // STAFF / VENDOR DISPATCH VIEW
              _buildRouteSelectorCard(context, isDark, currentDeliveries),
              const SizedBox(height: 16),
              _buildFilterChips(context, isDark),
              const SizedBox(height: 16),
              _buildVendorStopsList(context, isDark, currentDeliveries),
            ] else ...[
              // CUSTOMER MILK BUYER VIEW
              _buildCustomerHeroStatus(context, isDark),
              const SizedBox(height: 16),
              _buildCustomerPurityAndRider(context, isDark),
              const SizedBox(height: 16),
              _buildCustomerQuotaManager(context, isDark),
              const SizedBox(height: 16),
              _buildCustomerRecentHistory(context, isDark, currentDeliveries),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── DATE SELECTOR STRIP ───────────────────────────────────────────────────

  Widget _buildDateSelectorStrip(BuildContext context, bool isDark) {
    final now = DateTime.now();
    final days = List.generate(14, (i) => now.add(Duration(days: i - 3)));

    final weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Schedule Calendar",
              style: AppTheme.textLabel(context).copyWith(
                fontFamily: AppFontFamily.poppinsSemiBold,
                fontSize: 13,
              ),
            ),
            Text(
              "${_selectedDate.day} ${_getMonthName(_selectedDate.month)}, ${_selectedDate.year}",
              style: TextStyle(
                fontFamily: AppFontFamily.poppinsMedium,
                fontSize: 12,
                color: AppColor.primary_50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              final isSelected = date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 54,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor.primary_50
                          : (isToday
                              ? AppColor.primary_50.withValues(alpha: 0.12)
                              : AppTheme.cardBg(context)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColor.primary_50
                            : (isToday
                                ? AppColor.primary_50.withValues(alpha: 0.4)
                                : AppTheme.dividerBg(context)),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekdays[date.weekday - 1],
                          style: TextStyle(
                            fontFamily: AppFontFamily.poppinsMedium,
                            fontSize: 11,
                            color: isSelected
                                ? Colors.white70
                                : AppTheme.iconColorThree(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${date.day}",
                          style: TextStyle(
                            fontFamily: AppFontFamily.poppinsBold,
                            fontSize: 16,
                            color: isSelected
                                ? Colors.white
                                : (isToday
                                    ? AppColor.primary_50
                                    : AppTheme.iconColor(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }

  // ─── SLOT SELECTOR TOGGLE ──────────────────────────────────────────────────

  Widget _buildSlotSelector(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.customListBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerBg(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSlotTab(
              title: "Morning Dispatch (AM)",
              subtitle: "6:00 AM – 8:30 AM",
              icon: HugeIconsStroke.sun02,
              isSelected: _selectedSlot == "morning",
              onTap: () => setState(() => _selectedSlot = "morning"),
            ),
          ),
          Expanded(
            child: _buildSlotTab(
              title: "Evening Dispatch (PM)",
              subtitle: "5:00 PM – 7:30 PM",
              icon: HugeIconsStroke.moon02,
              isSelected: _selectedSlot == "evening",
              onTap: () => setState(() => _selectedSlot = "evening"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotTab({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary_50 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : AppColor.primary_50,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppFontFamily.poppinsSemiBold,
                    fontSize: 11,
                    color: isSelected ? Colors.white : AppTheme.iconColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: AppFontFamily.poppinsRegular,
                fontSize: 9.5,
                color: isSelected ? Colors.white70 : AppTheme.iconColorThree(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STAFF / VENDOR DISPATCH COMPONENTS ────────────────────────────────────

  Widget _buildRouteSelectorCard(
    BuildContext context,
    bool isDark,
    List<DeliveryItem> items,
  ) {
    final deliveredCount = items.where((d) => d.status == 'delivered').length;
    final totalCount = items.length;
    final progress = totalCount > 0 ? deliveredCount / totalCount : 0.0;

    double totalBuffalo = 0;
    double totalCow = 0;
    for (var d in items) {
      totalBuffalo += d.buffaloLiters + d.extraLiters;
      totalCow += d.cowLiters;
    }

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
              const Icon(HugeIconsSolid.truck, color: AppColor.primary_50, size: 20),
              const SizedBox(width: 8),
              Text(
                "Vendor Route Controller",
                style: AppTheme.textTitle(context).copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$deliveredCount / $totalCount Done",
                  style: const TextStyle(
                    fontFamily: AppFontFamily.poppinsSemiBold,
                    fontSize: 11,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Route dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedRoute,
            decoration: const InputDecoration(
              labelText: "Select Delivery Route",
              prefixIcon: Icon(HugeIconsStroke.route01, size: 20),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: _routes.map((r) {
              return DropdownMenuItem(
                value: r,
                child: Text(r, style: AppTheme.textLabel(context).copyWith(fontSize: 12.5)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedRoute = val);
            },
          ),
          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppTheme.customListBg(context),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          ),
          const SizedBox(height: 12),

          // Total Volume Summary Row
          Row(
            children: [
              _buildVolumePill("🥛 Buffalo: ${totalBuffalo.toStringAsFixed(1)} L", context),
              const SizedBox(width: 8),
              _buildVolumePill("🐄 Cow: ${totalCow.toStringAsFixed(1)} L", context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumePill(String label, BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.customListBg(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFontFamily.poppinsMedium,
              fontSize: 11,
              color: AppTheme.iconColor(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _statusFilters.map((filter) {
          final isSelected = _selectedStatusFilter == filter;
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
              onSelected: (_) => setState(() => _selectedStatusFilter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVendorStopsList(
    BuildContext context,
    bool isDark,
    List<DeliveryItem> items,
  ) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Column(
            children: [
              Icon(HugeIconsStroke.milkBottle, size: 40, color: AppTheme.iconColorThree(context)),
              const SizedBox(height: 10),
              Text("No delivery stops found", style: AppTheme.textLabel(context)),
              const SizedBox(height: 4),
              Text("Try another route or status filter", style: AppTheme.textSearchInfoLabeled(context)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Customer Delivery Drops (${items.length})",
          style: AppTheme.textLabel(context).copyWith(
            fontFamily: AppFontFamily.poppinsSemiBold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => _buildVendorStopCard(context, isDark, item)),
      ],
    );
  }

  Widget _buildVendorStopCard(
    BuildContext context,
    bool isDark,
    DeliveryItem item,
  ) {
    final isDelivered = item.status == 'delivered';
    final isPaused = item.status == 'paused';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDelivered
              ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
              : (isPaused
                  ? Colors.grey.withValues(alpha: 0.3)
                  : AppTheme.dividerBg(context)),
        ),
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
                      item.customerName,
                      style: AppTheme.textLabel(context).copyWith(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.address,
                      style: AppTheme.textSearchInfoLabeled(context).copyWith(
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(item.status),
            ],
          ),
          const SizedBox(height: 12),

          // Quantities Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.customListBg(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(HugeIconsSolid.milkBottle, size: 14, color: AppColor.primary_50),
                    const SizedBox(width: 6),
                    Text(
                      "Buffalo: ${item.buffaloLiters} L  •  Cow: ${item.cowLiters} L",
                      style: TextStyle(
                        fontFamily: AppFontFamily.poppinsMedium,
                        fontSize: 11.5,
                        color: AppTheme.iconColor(context),
                      ),
                    ),
                    if (item.extraLiters > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        "(+${item.extraLiters} L Extra)",
                        style: const TextStyle(
                          fontFamily: AppFontFamily.poppinsSemiBold,
                          fontSize: 11,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  "Rs. ${item.totalAmount.toInt()}",
                  style: TextStyle(
                    fontFamily: AppFontFamily.poppinsBold,
                    fontSize: 13,
                    color: AppColor.primary_50,
                  ),
                ),
              ],
            ),
          ),
          if (item.notes != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(HugeIconsStroke.note, size: 12, color: AppTheme.iconColorThree(context)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.notes!,
                    style: TextStyle(
                      fontFamily: AppFontFamily.poppinsRegular,
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.iconColorThree(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Divider(height: 1, color: AppTheme.dividerBg(context)),
          const SizedBox(height: 10),

          // Action buttons row
          Row(
            children: [
              if (!isDelivered && !isPaused) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(HugeIconsSolid.checkmarkCircle02, size: 14, color: Colors.white),
                  label: const Text(
                    "Mark Delivered",
                    style: TextStyle(
                      fontFamily: AppFontFamily.poppinsMedium,
                      fontSize: 11.5,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => _markDelivered(item.id),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(HugeIconsStroke.addCircle, size: 14),
                  label: const Text(
                    "+ Extra",
                    style: TextStyle(fontFamily: AppFontFamily.poppinsMedium, fontSize: 11),
                  ),
                  onPressed: () => _showAddExtraLitersDialog(item),
                ),
              ] else if (isDelivered) ...[
                Row(
                  children: [
                    const Icon(HugeIconsSolid.checkmarkBadge02, size: 14, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 4),
                    Text(
                      "Delivered at ${item.deliveredAt?.hour ?? 7}:${(item.deliveredAt?.minute ?? 15).toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontFamily: AppFontFamily.poppinsMedium,
                        fontSize: 11,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              if (!isDelivered && !isPaused) ...[
                IconButton(
                  icon: const Icon(HugeIconsStroke.pauseCircle, size: 18),
                  color: Colors.orange.shade700,
                  onPressed: () => _markPaused(item.id),
                  tooltip: "Pause Today's Drop",
                ),
              ],
              IconButton(
                icon: const Icon(HugeIconsStroke.call02, size: 18),
                color: AppTheme.iconColorThree(context),
                onPressed: () => _launchCall(item.customerPhone),
                tooltip: "Call Customer",
              ),
              IconButton(
                icon: const Icon(HugeIconsSolid.message02, size: 18),
                color: const Color(0xFF25D366),
                onPressed: () => _launchWhatsApp(
                  item.customerPhone,
                  "Hello ${item.customerName}! Your Dogar Dairy milk delivery for today (${item.totalLiters} L) is updated.",
                ),
                tooltip: "WhatsApp Customer",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── CUSTOMER MILK BUYER COMPONENTS ───────────────────────────────────────

  Widget _buildCustomerHeroStatus(BuildContext context, bool isDark) {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(HugeIconsSolid.sun02, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      _selectedSlot == "morning" ? "Morning Route" : "Evening Route",
                      style: const TextStyle(
                        fontFamily: AppFontFamily.poppinsMedium,
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(HugeIconsSolid.checkmarkBadge02, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      "Delivered (7:15 AM)",
                      style: TextStyle(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            "Today's Milk Drop",
            style: TextStyle(
              fontFamily: AppFontFamily.poppinsMedium,
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "3.0 Liters Pure Milk",
            style: TextStyle(
              fontFamily: AppFontFamily.poppinsBold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildWhitePill("🥛 2.0 L Buffalo Milk"),
              _buildWhitePill("🐄 1.0 L Cow Milk"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhitePill(String text) {
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

  Widget _buildCustomerPurityAndRider(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Purity card
        Expanded(
          child: Container(
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(HugeIconsSolid.checkmarkBadge02, size: 16, color: Color(0xFF2E7D32)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Purity Tested",
                      style: AppTheme.textLabel(context).copyWith(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "29.5 LR",
                  style: TextStyle(
                    fontFamily: AppFontFamily.poppinsBold,
                    fontSize: 18,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  "7.2% Fat • Grade A+",
                  style: AppTheme.textSearchInfoLabeled(context).copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Rider card
        Expanded(
          child: Container(
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColor.primary_50.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(HugeIconsSolid.deliveryTruck02, size: 16, color: AppColor.primary_50),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Route Rider",
                      style: AppTheme.textLabel(context).copyWith(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Tariq Mahmood",
                  style: AppTheme.textLabel(context).copyWith(
                    fontFamily: AppFontFamily.poppinsSemiBold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _launchCall("+923410292698"),
                      child: const Icon(HugeIconsStroke.call02, size: 16, color: AppColor.primary_50),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => _launchWhatsApp(
                        "+923410292698",
                        "Hello Rider Tariq! Regarding my Dogar Dairy milk delivery...",
                      ),
                      child: const Icon(HugeIconsSolid.message02, size: 16, color: Color(0xFF25D366)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerQuotaManager(BuildContext context, bool isDark) {
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
              const Icon(HugeIconsStroke.calendar01, size: 18, color: AppColor.primary_50),
              const SizedBox(width: 8),
              Text(
                "Quick Delivery Actions",
                style: AppTheme.textTitle(context).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(HugeIconsStroke.pauseCircle, size: 16),
                  label: const Text(
                    "Pause Vacation",
                    style: TextStyle(fontFamily: AppFontFamily.poppinsMedium, fontSize: 11.5),
                  ),
                  onPressed: _showPauseVacationModal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary_50,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(HugeIconsSolid.addCircle, size: 16, color: Colors.white),
                  label: const Text(
                    "Request Extra",
                    style: TextStyle(
                      fontFamily: AppFontFamily.poppinsMedium,
                      fontSize: 11.5,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    if (_deliveries.isNotEmpty) {
                      _showAddExtraLitersDialog(_deliveries.first);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerRecentHistory(
    BuildContext context,
    bool isDark,
    List<DeliveryItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Delivery Logs & Drop History",
          style: AppTheme.textLabel(context).copyWith(
            fontFamily: AppFontFamily.poppinsSemiBold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        ..._deliveries.take(4).map((d) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.dividerBg(context)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColor.primary_50.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(HugeIconsSolid.milkBottle, color: AppColor.primary_50, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${d.slot.toUpperCase()} Drop • ${d.totalLiters} Liters",
                        style: AppTheme.textLabel(context).copyWith(
                          fontFamily: AppFontFamily.poppinsSemiBold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${d.date.day} ${_getMonthName(d.date.month)} • ${d.lactometerScore}",
                        style: AppTheme.textSearchInfoLabeled(context).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(d.status),
                    const SizedBox(height: 4),
                    Text(
                      "Rs. ${d.totalAmount.toInt()}",
                      style: TextStyle(
                        fontFamily: AppFontFamily.poppinsBold,
                        fontSize: 12,
                        color: AppColor.primary_50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;

    switch (status.toLowerCase()) {
      case 'delivered':
        bg = const Color(0xFF2E7D32).withValues(alpha: 0.12);
        text = const Color(0xFF2E7D32);
        label = "Delivered";
        break;
      case 'extra':
        bg = const Color(0xFF1976D2).withValues(alpha: 0.12);
        text = const Color(0xFF1976D2);
        label = "Extra Milk";
        break;
      case 'paused':
        bg = Colors.grey.withValues(alpha: 0.15);
        text = Colors.grey.shade700;
        label = "Paused";
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
