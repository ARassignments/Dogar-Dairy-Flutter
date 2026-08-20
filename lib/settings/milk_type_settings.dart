import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import '/providers/milk_type_provider.dart';
import '/theme/theme.dart';

class MilkTypeSettingsScreen extends ConsumerStatefulWidget {
  const MilkTypeSettingsScreen({super.key});

  @override
  ConsumerState<MilkTypeSettingsScreen> createState() =>
      _MilkTypeSettingsScreenState();
}

class _MilkTypeSettingsScreenState
    extends ConsumerState<MilkTypeSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Pass context after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(milkTypeProvider.notifier).initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentTypes = ref.watch(milkTypeProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          "Milk Types",
          style: AppTheme.textTitle(context).copyWith(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(HugeIconsStroke.arrowLeft01, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: paymentTypes.length,
        itemBuilder: (context, index) {
          final type = paymentTypes[index];
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: index == 0 ? 0 : 2,
              bottom: index == paymentTypes.length - 1 ? 0 : 2,
            ),
            child: Card(
              color: AppTheme.cardBg(context),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: CheckboxListTile(
                activeColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColor.neutral_70
                    : AppColor.neutral_20,
                checkColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColor.neutral_20
                    : AppColor.neutral_70,
                selectedTileColor:
                    Theme.of(context).brightness == Brightness.dark
                    ? AppColor.neutral_70
                    : AppColor.neutral_20,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                value: type.isVisible,
                onChanged: (_) {
                  ref.read(milkTypeProvider.notifier).toggleMilkType(type.name);
                },
                controlAffinity: ListTileControlAffinity.leading,
                secondary: (type.isIcon)
                    ? Icon(
                        type.icon,
                        size: 24,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColor.neutral_70
                            : AppColor.neutral_20,
                      )
                    : Image.asset(
                        type.imageUrl,
                        width: 22,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                title: Text(
                  type.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.textLabel(
                    context,
                  ).copyWith(fontFamily: AppFontFamily.poppinsSemiBold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
