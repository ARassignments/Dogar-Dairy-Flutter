import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '/components/appsnackbar.dart';
import '/models/monthly_supply_model.dart';
import '/providers/user_provider.dart';
import '/theme/theme.dart';
import '/utils/session_manager.dart';

class DailySupplyLog {
  final int day;
  final DateTime date;
  final String status; // 'delivered', 'paused', 'extra', 'missed'
  final double buffaloLiters;
  final double cowLiters;
  final double goatLiters;
  final double extraLiters;
  final double dayCost;
  final String dropTime;
  final String lactometerScore;
  final String? note;

  DailySupplyLog({
    required this.day,
    required this.date,
    required this.status,
    required this.buffaloLiters,
    required this.cowLiters,
    this.goatLiters = 0.0,
    this.extraLiters = 0.0,
    required this.dayCost,
    this.dropTime = "6:35 AM",
    this.lactometerScore = "29.5 LR • 7.2% Fat",
    this.note,
  });

  double get totalLiters =>
      buffaloLiters + cowLiters + goatLiters + extraLiters;

  DailySupplyLog copyWith({
    int? day,
    DateTime? date,
    String? status,
    double? buffaloLiters,
    double? cowLiters,
    double? goatLiters,
    double? extraLiters,
    double? dayCost,
    String? dropTime,
    String? lactometerScore,
    String? note,
  }) {
    return DailySupplyLog(
      day: day ?? this.day,
      date: date ?? this.date,
      status: status ?? this.status,
      buffaloLiters: buffaloLiters ?? this.buffaloLiters,
      cowLiters: cowLiters ?? this.cowLiters,
      goatLiters: goatLiters ?? this.goatLiters,
      extraLiters: extraLiters ?? this.extraLiters,
      dayCost: dayCost ?? this.dayCost,
      dropTime: dropTime ?? this.dropTime,
      lactometerScore: lactometerScore ?? this.lactometerScore,
      note: note ?? this.note,
    );
  }
}

class MonthlySupplyDetailScreen extends ConsumerStatefulWidget {
  final MonthlySupplyModel subscription;

  const MonthlySupplyDetailScreen({super.key, required this.subscription});

  @override
  ConsumerState<MonthlySupplyDetailScreen> createState() =>
      _MonthlySupplyDetailScreenState();
}

class _MonthlySupplyDetailScreenState
    extends ConsumerState<MonthlySupplyDetailScreen> {
  late MonthlySupplyModel _sub;
  final String _selectedMonth = "August 2026";
  String _statusFilter = "All";
  String _cachedRole = "customer";
  late List<DailySupplyLog> _dailyLogs;

  double _amountPaid = 10000.0;

  @override
  void initState() {
    super.initState();
    _sub = widget.subscription;
    _loadRole();
    _initDailyLogs();
  }

  Future<void> _loadRole() async {
    final user = await SessionManager.getUser();
    if (user != null && user['role'] != null && mounted) {
      setState(() {
        _cachedRole = user['role'].toString().toLowerCase();
      });
    }
  }

  void _initDailyLogs() {
    const int totalDays = 31;
    final now = DateTime(2026, 8, 22);

    _dailyLogs = List.generate(totalDays, (index) {
      final day = index + 1;
      final logDate = DateTime(2026, 8, day);

      String status = "delivered";
      double extra = 0.0;

      // Simulated realistic patterns
      if (_sub.status == "paused" && day >= 15 && day <= 22) {
        status = "paused";
      } else if (day == 7 || day == 14) {
        status = "extra";
        extra = 1.0;
      } else if (day > now.day) {
        status = "pending";
      }

      final dayBuff = status == "paused" ? 0.0 : _sub.dailyBuffaloLiters;
      final dayCow = status == "paused" ? 0.0 : _sub.dailyCowLiters;
      final dayGoat = status == "paused" ? 0.0 : _sub.dailyGoatLiters;
      final dayCost = (dayBuff * _sub.ratePerLiterBuffalo) +
          (dayCow * _sub.ratePerLiterCow) +
          (dayGoat * _sub.ratePerLiterGoat) +
          (extra * _sub.ratePerLiterBuffalo);

      return DailySupplyLog(
        day: day,
        date: logDate,
        status: status,
        buffaloLiters: dayBuff,
        cowLiters: dayCow,
        goatLiters: dayGoat,
        extraLiters: extra,
        dayCost: dayCost,
        dropTime: status == "delivered" || status == "extra"
            ? "6:3${(day % 6)} AM"
            : (status == "paused" ? "Paused" : "Scheduled 6:30 AM"),
        note: status == "extra"
            ? "Customer requested +1.0L extra for guests"
            : (status == "paused" ? "Vacation Pause" : null),
      );
    });
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
    String clean =
        phone.replaceAll("+", "").replaceAll(" ", "").replaceAll("-", "");
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

  void _sendDetailedWhatsAppStatement() {
    final deliveredDays =
        _dailyLogs.where((l) => l.status == "delivered" || l.status == "extra").length;
    final pausedDays = _dailyLogs.where((l) => l.status == "paused").length;
    final totalLiters = _dailyLogs
        .where((l) => l.status == "delivered" || l.status == "extra")
        .fold(0.0, (sum, l) => sum + l.totalLiters);
    final totalBilled = _dailyLogs
        .where((l) => l.status == "delivered" || l.status == "extra")
        .fold(0.0, (sum, l) => sum + l.dayCost);
    final balance = (totalBilled - _amountPaid).clamp(0.0, double.infinity);

    final message =
        "🥛 *DOGAR DAIRY — MONTHLY SUPPLY DETAILED BILL*\n"
        "====================================\n"
        "👤 *Customer:* ${_sub.customerName}\n"
        "📱 *Phone:* ${_sub.customerPhone}\n"
        "📍 *Address:* ${_sub.address}\n"
        "📍 *Route:* ${_sub.route}\n"
        "📅 *Billing Month:* $_selectedMonth\n"
        "====================================\n"
        "📊 *MONTHLY SUPPLY SUMMARY:*\n"
        "• Days Delivered: $deliveredDays Days\n"
        "• Days Paused: $pausedDays Days\n"
        "• Total Milk Delivered: ${totalLiters.toStringAsFixed(1)} Liters\n"
        "• Daily Quota: 🥛 Buffalo ${_sub.dailyBuffaloLiters}L • 🐄 Cow ${_sub.dailyCowLiters}L\n"
        "------------------------------------\n"
        "💰 *FINANCIAL BREAKDOWN:*\n"
        "• Total Month Bill: Rs. ${totalBilled.toStringAsFixed(0)}\n"
        "• Amount Paid: Rs. ${_amountPaid.toStringAsFixed(0)}\n"
        "• ⚠️ *Remaining Balance Due:* Rs. ${balance.toStringAsFixed(0)}\n"
        "====================================\n"
        "💳 *PAYMENT OPTIONS:*\n"
        "• JazzCash / EasyPaisa: *0341 0292698* (Abdur Rehman)\n"
        "• Meezan Bank: *0102 0304 0506 07* (Dogar Dairy)\n"
        "------------------------------------\n"
        "🚴 *Assigned Rider:* ${_sub.assignedRider} (${_sub.riderPhone})\n"
        "Support & Billing Helpline: +92 341 0292698";

    _launchWhatsApp(_sub.customerPhone, message);
  }

  void _showRecordPaymentDialog() {
    final amountCtrl = TextEditingController(text: "4080");
    String paymentMethod = "JazzCash";
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: AppTheme.cardBg(context),
              title: Row(
                children: [
                  const Icon(
                    HugeIconsSolid.invoice01,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Record Monthly Payment",
                    style: AppTheme.textTitle(context).copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Customer: ${_sub.customerName}",
                      style: AppTheme.textLabel(context).copyWith(
                        fontFamily: AppFontFamily.poppinsSemiBold,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: "Payment Amount (PKR)",
                        prefixText: "Rs. ",
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: paymentMethod,
                      decoration: const InputDecoration(
                        labelText: "Payment Channel",
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "JazzCash",
                          child: Text("📱 JazzCash (0341 0292698)"),
                        ),
                        DropdownMenuItem(
                          value: "EasyPaisa",
                          child: Text("📱 EasyPaisa (0341 0292698)"),
                        ),
                        DropdownMenuItem(
                          value: "Cash",
                          child: Text("💵 Cash to Delivery Rider"),
                        ),
                        DropdownMenuItem(
                          value: "Bank Transfer",
                          child: Text("🏦 Meezan Bank Transfer"),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => paymentMethod = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: "Reference / Note (Optional)",
                        hintText: "e.g. TID #12345678",
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: AppTheme.iconColorThree(context)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final entered =
                        double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                    if (entered <= 0) {
                      AppSnackBar.show(
                        ctx,
                        message: "Please enter a valid amount",
                        type: AppSnackBarType.error,
                      );
                      return;
                    }
                    setState(() {
                      _amountPaid += entered;
                    });
                    Navigator.pop(ctx);
                    AppSnackBar.show(
                      context,
                      message:
                          "Recorded Rs. ${entered.toStringAsFixed(0)} via $paymentMethod for ${_sub.customerName}!",
                      type: AppSnackBarType.success,
                    );
                  },
                  child: const Text(
                    "Confirm Payment",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: AppFontFamily.poppinsSemiBold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDayModal(DailySupplyLog log) {
    final extraCtrl = TextEditingController(text: log.extraLiters.toString());
    String status = log.status;
    final noteCtrl = TextEditingController(text: log.note ?? "");

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
                    "Edit Day ${log.day} Supply Log (${log.date.day} ${_getMonthName(log.date.month)})",
                    style: AppTheme.textTitle(ctx).copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: "Day Status"),
                    items: const [
                      DropdownMenuItem(
                        value: "delivered",
                        child: Text("🟢 Standard Delivered"),
                      ),
                      DropdownMenuItem(
                        value: "extra",
                        child: Text("🟡 Delivered with Extra Milk"),
                      ),
                      DropdownMenuItem(
                        value: "paused",
                        child: Text("🟠 Paused (Vacation)"),
                      ),
                      DropdownMenuItem(
                        value: "missed",
                        child: Text("🔴 Missed Drop"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => status = val);
                    },
                  ),
                  const SizedBox(height: 10),

                  if (status == "extra") ...[
                    TextFormField(
                      controller: extraCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: "Extra Liters Added",
                        suffixText: "Liters",
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  TextFormField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: "Log Note (Optional)",
                      hintText: "e.g. Delivered to neighbor",
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary_50,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      final extra = double.tryParse(extraCtrl.text.trim()) ?? 0.0;
                      final dayBuff =
                          status == "paused" || status == "missed"
                              ? 0.0
                              : _sub.dailyBuffaloLiters;
                      final dayCow =
                          status == "paused" || status == "missed"
                              ? 0.0
                              : _sub.dailyCowLiters;
                      final dayGoat =
                          status == "paused" || status == "missed"
                              ? 0.0
                              : _sub.dailyGoatLiters;
                      final newCost = (dayBuff * _sub.ratePerLiterBuffalo) +
                          (dayCow * _sub.ratePerLiterCow) +
                          (dayGoat * _sub.ratePerLiterGoat) +
                          (extra * _sub.ratePerLiterBuffalo);

                      setState(() {
                        final index =
                            _dailyLogs.indexWhere((l) => l.day == log.day);
                        if (index != -1) {
                          _dailyLogs[index] = log.copyWith(
                            status: status,
                            extraLiters: extra,
                            buffaloLiters: dayBuff,
                            cowLiters: dayCow,
                            goatLiters: dayGoat,
                            dayCost: newCost,
                            note: noteCtrl.text.trim().isNotEmpty
                                ? noteCtrl.text.trim()
                                : null,
                          );
                        }
                      });
                      Navigator.pop(ctx);
                      AppSnackBar.show(
                        context,
                        message: "Day ${log.day} delivery log updated!",
                        type: AppSnackBarType.success,
                      );
                    },
                    child: const Text(
                      "Update Day Log",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userModel = ref.watch(userProvider);
    final role =
        (userModel?.role.isNotEmpty == true ? userModel!.role : _cachedRole)
            .toLowerCase();

    // Summary calculations
    final deliveredLogs =
        _dailyLogs.where((l) => l.status == "delivered" || l.status == "extra");
    final deliveredDays = deliveredLogs.length;
    final pausedDays = _dailyLogs.where((l) => l.status == "paused").length;
    final totalDeliveredLiters =
        deliveredLogs.fold(0.0, (sum, l) => sum + l.totalLiters);
    final totalBilled =
        deliveredLogs.fold(0.0, (sum, l) => sum + l.dayCost);
    final remainingBalance =
        (totalBilled - _amountPaid).clamp(0.0, double.infinity);

    // Filter daily logs
    final filteredLogs = _dailyLogs.where((l) {
      if (_statusFilter == "All") return true;
      return l.status.toLowerCase() == _statusFilter.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Monthly Supply Details",
          style: AppTheme.textTitle(context).copyWith(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(HugeIconsSolid.message02, color: Color(0xFF25D366)),
            tooltip: "Send WhatsApp Statement",
            onPressed: _sendDetailedWhatsAppStatement,
          ),
          IconButton(
            icon: const Icon(HugeIconsStroke.call02, color: AppColor.primary_50),
            tooltip: "Call Customer",
            onPressed: () => _launchCall(_sub.customerPhone),
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
              // Customer Profile & Quota Hero Card
              _buildCustomerHeroCard(context, isDark),
              const SizedBox(height: 14),

              // Monthly Financial & Volume Summary Card
              _buildMonthlyMetricsCard(
                context,
                isDark,
                deliveredDays: deliveredDays,
                pausedDays: pausedDays,
                deliveredLiters: totalDeliveredLiters,
                totalBilled: totalBilled,
                amountPaid: _amountPaid,
                remainingBalance: remainingBalance,
              ),
              const SizedBox(height: 14),

              // Quality & Assigned Rider Strip
              _buildQualityAndRiderStrip(context, isDark),
              const SizedBox(height: 16),

              // Day-by-Day Supply Matrix Header & Filter Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Day-by-Day Milk Log ($_selectedMonth)",
                    style: AppTheme.textLabel(context).copyWith(
                      fontFamily: AppFontFamily.poppinsSemiBold,
                      fontSize: 13.5,
                    ),
                  ),
                  Text(
                    "${filteredLogs.length} Days",
                    style: TextStyle(
                      fontFamily: AppFontFamily.poppinsMedium,
                      fontSize: 12,
                      color: AppTheme.iconColorThree(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Status Filter Chips
              _buildStatusFilterRow(context),
              const SizedBox(height: 12),

              // Daily Supply Table / List
              ...filteredLogs.map((log) => _buildDailyLogCard(context, isDark, log, role)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: role == 'staff'
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: AppTheme.dividerBg(context))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        HugeIconsSolid.message02,
                        color: Color(0xFF25D366),
                        size: 16,
                      ),
                      label: const Text(
                        "WhatsApp Bill",
                        style: TextStyle(
                          fontFamily: AppFontFamily.poppinsMedium,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: _sendDetailedWhatsAppStatement,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        HugeIconsSolid.invoice01,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        "Record Payment",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: AppFontFamily.poppinsSemiBold,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: _showRecordPaymentDialog,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildCustomerHeroCard(BuildContext context, bool isDark) {
    final isPaused = _sub.status == "paused";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.dividerBg(context)),
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
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColor.primary_50.withValues(alpha: 0.15),
                child: Text(
                  _sub.customerName.isNotEmpty
                      ? _sub.customerName[0].toUpperCase()
                      : "C",
                  style: const TextStyle(
                    fontFamily: AppFontFamily.poppinsSemiBold,
                    color: AppColor.primary_50,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _sub.customerName,
                      style: AppTheme.textTitle(context).copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _sub.address,
                      style: AppTheme.textSearchInfoLabeled(context).copyWith(
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaused
                      ? Colors.amber.withValues(alpha: 0.15)
                      : const Color(0xFF2E7D32).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPaused ? "Paused" : "Active Plan",
                  style: TextStyle(
                    fontFamily: AppFontFamily.poppinsSemiBold,
                    fontSize: 10.5,
                    color: isPaused
                        ? Colors.amber.shade800
                        : const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Quota & Drop Timing Badges
          Row(
            children: [
              if (_sub.dailyBuffaloLiters > 0)
                _buildBadge("🥛 Buffalo: ${_sub.dailyBuffaloLiters} L", context),
              if (_sub.dailyCowLiters > 0) ...[
                const SizedBox(width: 6),
                _buildBadge("🐄 Cow: ${_sub.dailyCowLiters} L", context),
              ],
              if (_sub.dailyGoatLiters > 0) ...[
                const SizedBox(width: 6),
                _buildBadge("🐐 Goat: ${_sub.dailyGoatLiters} L", context),
              ],
              const Spacer(),
              Text(
                "⏰ ${_sub.preferredTime}",
                style: TextStyle(
                  fontFamily: AppFontFamily.poppinsMedium,
                  fontSize: 11,
                  color: AppTheme.iconColorThree(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyMetricsCard(
    BuildContext context,
    bool isDark, {
    required int deliveredDays,
    required int pausedDays,
    required double deliveredLiters,
    required double totalBilled,
    required double amountPaid,
    required double remainingBalance,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricCol(
                "Total Volume",
                "${deliveredLiters.toStringAsFixed(1)} Liters",
                "Delivered ($deliveredDays Days)",
              ),
              Container(height: 38, width: 1, color: Colors.white24),
              _buildMetricCol(
                "Total Billed",
                "Rs. ${totalBilled.toStringAsFixed(0)}",
                "Paid: Rs. ${amountPaid.toStringAsFixed(0)}",
              ),
              Container(height: 38, width: 1, color: Colors.white24),
              _buildMetricCol(
                "Balance Due",
                "Rs. ${remainingBalance.toStringAsFixed(0)}",
                remainingBalance > 0 ? "⚠️ Pending" : "✅ Clear",
                valueColor: remainingBalance > 0
                    ? const Color(0xFFFFD54F)
                    : Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(
    String label,
    String value,
    String sub, {
    Color valueColor = Colors.white,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFontFamily.poppinsRegular,
            fontSize: 10.5,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFontFamily.poppinsSemiBold,
            fontSize: 14,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          sub,
          style: const TextStyle(
            fontFamily: AppFontFamily.poppinsRegular,
            fontSize: 9.5,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildQualityAndRiderStrip(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.customListBg2(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.dividerBg(context)),
            ),
            child: Row(
              children: [
                const Icon(
                  HugeIconsSolid.checkmarkBadge02,
                  color: Color(0xFF2E7D32),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Purity Verified",
                        style: TextStyle(
                          fontFamily: AppFontFamily.poppinsSemiBold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        "29.5 LR • 7.2% Fat",
                        style: AppTheme.textSearchInfoLabeled(context).copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.customListBg2(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.dividerBg(context)),
            ),
            child: Row(
              children: [
                const Icon(
                  HugeIconsSolid.deliveryTruck02,
                  color: AppColor.primary_50,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sub.assignedRider,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFontFamily.poppinsSemiBold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _sub.riderPhone,
                        style: AppTheme.textSearchInfoLabeled(context).copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilterRow(BuildContext context) {
    const filters = ["All", "Delivered", "Extra", "Paused", "Pending"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _statusFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: ChoiceChip(
              label: Text(
                f,
                style: TextStyle(
                  fontFamily: AppFontFamily.poppinsMedium,
                  fontSize: 11,
                  color: isSelected ? Colors.white : AppTheme.iconColor(context),
                ),
              ),
              selected: isSelected,
              selectedColor: AppColor.primary_50,
              backgroundColor: AppTheme.customListBg2(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected
                      ? AppColor.primary_50
                      : AppTheme.dividerBg(context),
                ),
              ),
              onSelected: (_) => setState(() => _statusFilter = f),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDailyLogCard(
    BuildContext context,
    bool isDark,
    DailySupplyLog log,
    String role,
  ) {
    final isExtra = log.status == "extra";
    final isPaused = log.status == "paused";

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: role == 'staff' ? () => _showEditDayModal(log) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExtra
                ? Colors.amber.withValues(alpha: 0.5)
                : (isPaused
                    ? Colors.grey.withValues(alpha: 0.4)
                    : AppTheme.dividerBg(context)),
          ),
        ),
        child: Row(
          children: [
            // Day Badge
            Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.customListBg2(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    "${log.day}",
                    style: const TextStyle(
                      fontFamily: AppFontFamily.poppinsSemiBold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _getWeekdayName(log.date.weekday),
                    style: TextStyle(
                      fontFamily: AppFontFamily.poppinsRegular,
                      fontSize: 9.5,
                      color: AppTheme.iconColorThree(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Drop Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isPaused
                            ? "Vacation Paused"
                            : "${log.totalLiters.toStringAsFixed(1)} Liters (${log.buffaloLiters}L Buff + ${log.cowLiters}L Cow)",
                        style: AppTheme.textLabel(context).copyWith(
                          fontFamily: AppFontFamily.poppinsSemiBold,
                          fontSize: 12,
                        ),
                      ),
                      if (isExtra) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "+Extra",
                            style: TextStyle(
                              fontFamily: AppFontFamily.poppinsSemiBold,
                              fontSize: 9,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    log.note ?? log.dropTime,
                    style: AppTheme.textSearchInfoLabeled(context).copyWith(
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),

            // Cost & Edit Icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Rs. ${log.dayCost.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontFamily: AppFontFamily.poppinsSemiBold,
                    fontSize: 12.5,
                    color: isPaused
                        ? Colors.grey
                        : const Color(0xFF2E7D32),
                  ),
                ),
                if (role == 'staff')
                  Text(
                    "Tap to edit",
                    style: TextStyle(
                      fontFamily: AppFontFamily.poppinsRegular,
                      fontSize: 9,
                      color: AppTheme.iconColorThree(context),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.customListBg2(context),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFontFamily.poppinsMedium,
          fontSize: 10.5,
          color: AppTheme.iconColor(context),
        ),
      ),
    );
  }
}
