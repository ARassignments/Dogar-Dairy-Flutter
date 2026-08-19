import 'package:dogardairy/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dogardairy/models/payment_dropdown_model.dart';
import 'package:hugeicons_pro/hugeicons.dart';

class MilkTypeNotifier extends StateNotifier<List<PaymentDropdownModel>> {
  MilkTypeNotifier() : super([]);

  void initialize(BuildContext context) {
    state = [
      PaymentDropdownModel(
        true,
        false,
        AppTheme.buffaloMilkIcon(context),
        name: "Buffalo Milk",
        icon: HugeIconsSolid.sendToMobile,
      ),
      PaymentDropdownModel(
        true,
        false,
        AppTheme.cowMilkIcon(context),
        name: "Cow Milk",
        icon: HugeIconsSolid.sendToMobile,
      ),
      PaymentDropdownModel(
        true,
        false,
        AppTheme.goatMilkIcon(context),
        name: "Goat Milk",
        icon: HugeIconsSolid.bank,
      ),
    ];
  }

  void toggleMilkType(String name) {
    state = state.map((type) {
      if (type.name == name) {
        return PaymentDropdownModel(
          !type.isVisible,
          type.isIcon,
          type.imageUrl,
          name: type.name,
          icon: type.icon,
        );
      }
      return type;
    }).toList();
  }
}

final milkTypeProvider =
    StateNotifierProvider<MilkTypeNotifier, List<PaymentDropdownModel>>(
      (ref) => MilkTypeNotifier(),
    );
