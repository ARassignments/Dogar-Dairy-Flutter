import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import '/components/appsnackbar.dart';
import '/components/loading_screen.dart';
import '/notifiers/avatar_notifier.dart';
import '/providers/user_provider.dart';
import '/theme/theme.dart';
import '/utils/session_manager.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _sessionUser;
  String? _localAvatar;
  String? _localGender;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final userData = await SessionManager.getUser();
    final avatarData = await SessionManager.getAvatarAndGender();
    if (mounted) {
      setState(() {
        _sessionUser = userData;
        _localAvatar = avatarData["avatar"];
        _localGender = avatarData["gender"];
        _isLoading = false;
      });
      if (_localAvatar != null && avatarNotifier.value == null) {
        avatarNotifier.updateAvatar(_localAvatar!);
      }
    }
  }

  String _formatPhone(String number) {
    if (number.isEmpty) return "Not set";
    if (number.startsWith("0") && number.length >= 10) {
      return "+92 ${number.substring(1, 4)} ${number.substring(4, 7)} ${number.substring(7)}";
    }
    return number;
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

  Future<void> _showEditProfileBottomSheet(
    String currentName,
    String currentContact,
    String currentAddress,
  ) async {
    final nameController = TextEditingController(text: currentName);
    final contactController = TextEditingController(text: currentContact);
    final addressController = TextEditingController(text: currentAddress);
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 8,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.primary_50.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              HugeIconsSolid.edit02,
                              color: AppColor.primary_50,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Edit Profile Details",
                            style: AppTheme.textTitle(ctx).copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(height: 1, color: AppTheme.dividerBg(ctx)),
                      const SizedBox(height: 16),

                      // Name Field
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          hintText: "Enter your full name",
                          prefixIcon: Icon(HugeIconsSolid.user03, size: 20),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Please enter your name"
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Phone Field
                      TextFormField(
                        controller: contactController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Contact Phone Number",
                          hintText: "03001234567",
                          prefixIcon: Icon(HugeIconsSolid.call, size: 20),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Please enter contact number"
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Address Field
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: "Delivery / Shop Address",
                          hintText: "House #, Street, Sector / Area, City",
                          prefixIcon: Icon(
                            HugeIconsSolid.mapsLocation01,
                            size: 20,
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Please enter delivery address"
                            : null,
                      ),
                      const SizedBox(height: 22),

                      // Actions
                      FlatButton(
                        text: isSaving ? "Saving Changes..." : "Save Changes",
                        loading: isSaving,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          setModalState(() => isSaving = true);

                          final updatedName = nameController.text.trim();
                          final updatedContact = contactController.text.trim();
                          final updatedAddress = addressController.text.trim();

                          final updates = {
                            'name': updatedName,
                            'contact': updatedContact,
                            'phone': updatedContact,
                            'address': updatedAddress,
                          };

                          // 1. Update Firestore via userProvider
                          await ref
                              .read(userProvider.notifier)
                              .updateUser(updates);

                          // 2. Update local SessionManager
                          final currentLocal =
                              await SessionManager.getUser() ?? {};
                          currentLocal['name'] = updatedName;
                          currentLocal['contact'] = updatedContact;
                          currentLocal['phone'] = updatedContact;
                          currentLocal['address'] = updatedAddress;
                          await SessionManager.saveUser(currentLocal);

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                          if (!mounted) return;
                          setState(() {
                            _sessionUser = currentLocal;
                          });
                          AppSnackBar.show(
                            context,
                            message: "Profile updated successfully!",
                            type: AppSnackBarType.success,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      OutlineButton(
                        text: "Cancel",
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAvatarBottomSheet(BuildContext context) async {
    final savedData = await SessionManager.getAvatarAndGender();
    if (!context.mounted) return;
    String selectedGender = _localGender ?? savedData["gender"] ?? "male";
    String? selectedAvatar = avatarNotifier.value ?? savedData["avatar"];

    final maleAvatars = List.generate(
      18,
      (i) => "assets/images/avatars/boy_${i + 1}.png",
    );
    final femaleAvatars = List.generate(
      20,
      (i) => "assets/images/avatars/girl_${i + 1}.png",
    );

    List<String> currentList = selectedGender == "male"
        ? maleAvatars
        : femaleAvatars;

    await showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Choose Profile Avatar",
                    textAlign: TextAlign.center,
                    style: AppTheme.textTitle(
                      context,
                    ).copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("Male Avatars"),
                        labelStyle: TextStyle(
                          fontFamily: AppFontFamily.poppinsMedium,
                          fontSize: 12,
                          color: selectedGender == "male"
                              ? Colors.white
                              : AppTheme.iconColor(context),
                        ),
                        selectedColor: AppColor.primary_50,
                        backgroundColor: AppTheme.customListBg(context),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: selectedGender == "male"
                                ? AppColor.primary_50
                                : AppTheme.dividerBg(context),
                          ),
                        ),
                        selected: selectedGender == "male",
                        onSelected: (_) {
                          setModalState(() {
                            selectedGender = "male";
                            currentList = maleAvatars;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text("Female Avatars"),
                        labelStyle: TextStyle(
                          fontFamily: AppFontFamily.poppinsMedium,
                          fontSize: 12,
                          color: selectedGender == "female"
                              ? Colors.white
                              : AppTheme.iconColor(context),
                        ),
                        selectedColor: AppColor.primary_50,
                        backgroundColor: AppTheme.customListBg(context),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: selectedGender == "female"
                                ? AppColor.primary_50
                                : AppTheme.dividerBg(context),
                          ),
                        ),
                        selected: selectedGender == "female",
                        onSelected: (_) {
                          setModalState(() {
                            selectedGender = "female";
                            currentList = femaleAvatars;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: currentList.length,
                      itemBuilder: (context, index) {
                        final avatar = currentList[index];
                        final isSelected = avatar == selectedAvatar;
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            await SessionManager.saveAvatarAndGender(
                              selectedGender,
                              avatar,
                            );
                            avatarNotifier.updateAvatar(avatar);

                            // Update Firestore profile_image_url
                            await ref.read(userProvider.notifier).updateUser({
                              'profile_image_url': avatar,
                            });

                            if (mounted) {
                              setState(() {
                                _localAvatar = avatar;
                                _localGender = selectedGender;
                              });
                            }
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              AppSnackBar.show(
                                context,
                                message: "Avatar updated!",
                                type: AppSnackBarType.success,
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColor.primary_50
                                    : AppTheme.dividerBg(context),
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(avatar, fit: BoxFit.cover),
                                  if (isSelected)
                                    Container(
                                      color: AppColor.primary_50.withValues(
                                        alpha: 0.4,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          HugeIconsSolid.checkmarkBadge02,
                                          color: Colors.white,
                                          size: 50,
                                        ),
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
                  const SizedBox(height: 16),
                  OutlineButton(
                    text: "Close",
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userModel = ref.watch(userProvider);

    // Resolve unified data prioritizing Live Riverpod state over cached session
    final displayName = userModel?.name.isNotEmpty == true
        ? userModel!.name
        : (_sessionUser?["name"] ?? "Dogar Dairy User");

    final email = userModel?.email.isNotEmpty == true
        ? userModel!.email
        : (_sessionUser?["email"] ?? "Not provided");

    final phone = userModel?.phone.isNotEmpty == true
        ? userModel!.phone
        : (_sessionUser?["contact"] ?? _sessionUser?["phone"] ?? "");

    final address = userModel?.address.isNotEmpty == true
        ? userModel!.address
        : (_sessionUser?["address"] ?? "Not provided");

    final rawRole = userModel?.role.isNotEmpty == true
        ? userModel!.role
        : (_sessionUser?["role"] ?? "customer");
    final role = rawRole.toString().toLowerCase();

    final userType =
        _sessionUser?["UserType"] ?? (role == 'staff' ? 'Vendor' : 'Customer');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          "My Profile",
          style: AppTheme.textTitle(context).copyWith(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(HugeIconsStroke.arrowLeft01, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: "Edit Profile",
            icon: const Icon(HugeIconsStroke.edit02, size: 20),
            onPressed: () =>
                _showEditProfileBottomSheet(displayName, phone, address),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingLogo())
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Avatar & Identity Header
                    _buildAvatarHeader(context, displayName, role, isDark),
                    const SizedBox(height: 20),

                    // 2. Personal Information Card
                    _buildSectionHeader("Personal Information", context),
                    const SizedBox(height: 8),
                    _buildInfoCard(context, [
                      _buildInfoTile(
                        context,
                        icon: HugeIconsStroke.user03,
                        iconColor: const Color(0xFF4838D1),
                        label: "Full Name",
                        value: displayName,
                        onEdit: () => _showEditProfileBottomSheet(
                          displayName,
                          phone,
                          address,
                        ),
                      ),
                      Divider(height: 1, color: AppTheme.dividerBg(context)),
                      _buildInfoTile(
                        context,
                        icon: HugeIconsStroke.mail02,
                        iconColor: const Color(0xFFE91E63),
                        label: "Email Address",
                        value: email,
                        trailingBadge: "Verified",
                      ),
                      Divider(height: 1, color: AppTheme.dividerBg(context)),
                      _buildInfoTile(
                        context,
                        icon: HugeIconsStroke.userAccount,
                        iconColor: const Color(0xFF00897B),
                        label: "Account ID",
                        value: userModel?.uid.isNotEmpty == true
                            ? userModel!.uid
                            : (_sessionUser?["uid"] ?? "N/A"),
                        onCopy: () => _copyToClipboard(
                          userModel?.uid ?? _sessionUser?["uid"] ?? "",
                          "Account ID",
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // 3. Contact & Delivery Card
                    _buildSectionHeader(
                      "Contact & Delivery Coordinates",
                      context,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoCard(context, [
                      _buildInfoTile(
                        context,
                        icon: HugeIconsStroke.call02,
                        iconColor: const Color(0xFF2E7D32),
                        label: "Phone Number",
                        value: _formatPhone(phone),
                        onCopy: () => _copyToClipboard(phone, "Phone number"),
                        onEdit: () => _showEditProfileBottomSheet(
                          displayName,
                          phone,
                          address,
                        ),
                      ),
                      Divider(height: 1, color: AppTheme.dividerBg(context)),
                      _buildInfoTile(
                        context,
                        icon: HugeIconsStroke.mapsLocation01,
                        iconColor: const Color(0xFFF57C00),
                        label: "Delivery Address",
                        value: address,
                        isMultiline: true,
                        onEdit: () => _showEditProfileBottomSheet(
                          displayName,
                          phone,
                          address,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // 4. Role & Platform Scope Card
                    _buildSectionHeader(
                      "Account Role & Multi-Tenancy",
                      context,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoCard(context, [
                      _buildInfoTile(
                        context,
                        icon: HugeIconsStroke.shield01,
                        iconColor: const Color(0xFF4838D1),
                        label: "User Role",
                        value: role == 'staff'
                            ? "Dairy Vendor / Shopkeeper"
                            : (role == 'admin'
                                  ? "Platform Operator"
                                  : "Milk Buyer / Household"),
                        trailingBadge: role.toUpperCase(),
                      ),
                      Divider(height: 1, color: AppTheme.dividerBg(context)),
                      _buildInfoTile(
                        context,
                        icon: HugeIconsStroke.crown03,
                        iconColor: const Color(0xFFF57C00),
                        label: "Subscription Scope",
                        value: role == 'staff'
                            ? "Vendor SaaS Management Plan"
                            : (role == 'admin'
                                  ? "Full Cloud Operations"
                                  : "100% Free Forever"),
                      ),
                      Divider(height: 1, color: AppTheme.dividerBg(context)),
                      _buildInfoTile(
                        context,
                        icon: HugeIconsStroke.userStory,
                        iconColor: const Color(0xFF00ACC1),
                        label: "Account Category",
                        value: "$userType Profile",
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // 5. Action Buttons
                    FlatButton(
                      text: "Edit Profile Details",
                      icon: HugeIconsSolid.edit02,
                      onPressed: () => _showEditProfileBottomSheet(
                        displayName,
                        phone,
                        address,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlineButton(
                      text: "Change Profile Avatar",
                      icon: HugeIconsStroke.imageDone02,
                      onPressed: () => _showAvatarBottomSheet(context),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarHeader(
    BuildContext context,
    String name,
    String role,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerBg(context)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ValueListenableBuilder<String?>(
                valueListenable: avatarNotifier,
                builder: (context, avatar, _) {
                  final activeAvatar = avatar ?? _localAvatar;
                  return ClipOval(
                    child: activeAvatar != null
                        ? Hero(
                            tag: "profile_avatar",
                            child: Image.network(
                              activeAvatar,
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Hero(
                            tag: "profile_avatar",
                            child: Image.asset(
                              "assets/images/avatars/boy_14.png",
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                  );
                },
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: InkWell(
                  onTap: () => _showAvatarBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColor.primary_50,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      HugeIconsSolid.camera01,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: AppTheme.textTitle(
              context,
            ).copyWith(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: role == 'staff'
                  ? const Color(0xFFF57C00).withValues(alpha: 0.12)
                  : (role == 'admin'
                        ? const Color(0xFF4838D1).withValues(alpha: 0.12)
                        : const Color(0xFF2E7D32).withValues(alpha: 0.12)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  role == 'staff'
                      ? HugeIconsSolid.store01
                      : (role == 'admin'
                            ? HugeIconsSolid.shield01
                            : HugeIconsSolid.milkBottle),
                  size: 12,
                  color: role == 'staff'
                      ? const Color(0xFFF57C00)
                      : (role == 'admin'
                            ? const Color(0xFF4838D1)
                            : const Color(0xFF2E7D32)),
                ),
                const SizedBox(width: 5),
                Text(
                  role == 'staff'
                      ? "Dairy Vendor / Shopkeeper"
                      : (role == 'admin'
                            ? "Platform Operator"
                            : "Milk Buyer (Customer)"),
                  style: TextStyle(
                    fontFamily: AppFontFamily.poppinsSemiBold,
                    fontSize: 11,
                    color: role == 'staff'
                        ? const Color(0xFFF57C00)
                        : (role == 'admin'
                              ? const Color(0xFF4838D1)
                              : const Color(0xFF2E7D32)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Text(
      title,
      style: AppTheme.textLabel(
        context,
      ).copyWith(fontFamily: AppFontFamily.poppinsSemiBold, fontSize: 13),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerBg(context)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? trailingBadge,
    bool isMultiline = false,
    VoidCallback? onCopy,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
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
                  label,
                  style: AppTheme.textSearchInfoLabeled(
                    context,
                  ).copyWith(fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.textLabel(context).copyWith(
                    fontFamily: AppFontFamily.poppinsMedium,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (trailingBadge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                trailingBadge,
                style: TextStyle(
                  fontFamily: AppFontFamily.poppinsMedium,
                  fontSize: 10,
                  color: iconColor,
                ),
              ),
            ),
          ],
          if (onCopy != null) ...[
            IconButton(
              icon: const Icon(HugeIconsStroke.copy01, size: 16),
              color: AppTheme.iconColorThree(context),
              onPressed: onCopy,
              tooltip: "Copy $label",
            ),
          ],
          if (onEdit != null && onCopy == null && trailingBadge == null) ...[
            IconButton(
              icon: const Icon(HugeIconsStroke.edit01, size: 16),
              color: AppTheme.iconColorThree(context),
              onPressed: onEdit,
              tooltip: "Edit $label",
            ),
          ],
        ],
      ),
    );
  }
}
