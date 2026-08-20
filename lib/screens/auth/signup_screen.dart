import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_flags_plus/country_flags_plus.dart';
import 'package:dogardairy/models/country_model.dart';
import 'package:dogardairy/models/state_model.dart';
import 'package:dogardairy/services/api_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:step_progress/step_progress.dart';
import '/theme/theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late StepProgressController _stepProgressController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  // Location Form
  final TextEditingController _countrySearchController =
      TextEditingController();
  final TextEditingController _stateSearchController = TextEditingController();
  final TextEditingController _citySearchController = TextEditingController();

  bool _isFormValid = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureCPassword = true;
  CountryCode _selectedCountryCode = CountryCode.fromCountryCode('PK');

  int _currentStep = 0; // 0 = personal info, 1 = location
  CountryModel? _selectedCountry;
  StateModel? _selectedState;
  String _selectedCity = '';
  List<CountryModel> _countries = [];
  List<StateModel> _states = [];
  List<String> _cities = [];
  bool _isLoadingCountries = true;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentStep);
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _contactController.addListener(_validateForm);
    _stepProgressController = StepProgressController(totalSteps: 3);
    _stepProgressController.setCurrentStep(_currentStep);
    _selectedCountryCode = CountryCode.fromCountryCode('PK');
    _fetchCountries();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateForm();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _contactController.dispose();
    _stepProgressController.dispose();
    _countrySearchController.dispose();
    _stateSearchController.dispose();
    _citySearchController.dispose();
    super.dispose();
  }

  void _goToStep(int newStep) {
    if (newStep == _currentStep) return;
    setState(() {
      _currentStep = newStep;
      _isFormValid = _validateCurrentStep();
    });
    _stepProgressController.setCurrentStep(newStep);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        newStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  // In-memory local cache to optimize repeated lookups and step transitions
  static List<CountryModel>? _cachedCountries;
  static final Map<String, List<StateModel>> _cachedStates = {};
  static final Map<String, List<String>> _cachedCities = {};

  Future<void> _fetchCountries() async {
    if (_cachedCountries != null && _cachedCountries!.isNotEmpty) {
      setState(() {
        _countries = _cachedCountries!;
        _isLoadingCountries = false;
        _validateForm();
      });
      return;
    }

    setState(() => _isLoadingCountries = true);

    try {
      final response = await ApiService.getAllCountries();
      if (response.error == false) {
        _cachedCountries = response.countries;
        if (mounted) {
          setState(() {
            _countries = response.countries;
            _isLoadingCountries = false;
            _validateForm();
          });
        }
      }
    } catch (e) {
      debugPrint("fetch countries error: $e");
      if (mounted) setState(() => _isLoadingCountries = false);
    }
  }

  Future<void> _fetchStates(String country) async {
    if (_cachedStates.containsKey(country)) {
      setState(() {
        _states = _cachedStates[country]!;
        _isLoadingStates = false;
        _validateForm();
      });
      return;
    }

    setState(() {
      _isLoadingStates = true;
    });

    try {
      final response = await ApiService.getAllStates(country);
      if (response.error == false) {
        _cachedStates[country] = response.states;
        if (mounted) {
          setState(() {
            _states = response.states;
            _isLoadingStates = false;
            _validateForm();
          });
        }
      }
    } catch (e) {
      debugPrint("fetch states error: $e");
      if (mounted) setState(() => _isLoadingStates = false);
    }
  }

  Future<void> _fetchCities(String country, String state) async {
    final cacheKey = "$country:$state";
    if (_cachedCities.containsKey(cacheKey)) {
      setState(() {
        _cities = _cachedCities[cacheKey]!;
        _isLoadingCities = false;
        _validateForm();
      });
      return;
    }

    setState(() {
      _isLoadingCities = true;
    });

    try {
      final response = await ApiService.getAllCities(country, state);
      if (response.error == false) {
        _cachedCities[cacheKey] = response.cities;
        if (mounted) {
          setState(() {
            _cities = response.cities;
            _isLoadingCities = false;
            _validateForm();
          });
        }
      }
    } catch (e) {
      debugPrint("fetch cities error: $e");
      if (mounted) setState(() => _isLoadingCities = false);
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      // Validate only name field for step 0
      final isNameValid =
          _nameController.text.isNotEmpty &&
          _nameController.text.length >= 3 &&
          RegExp(r'^[a-zA-Z ]+$').hasMatch(_nameController.text);

      final isEmailValid =
          _emailController.text.isNotEmpty &&
          _emailController.text.length >= 5 &&
          RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
          ).hasMatch(_emailController.text);

      final isPasswordValid =
          _passwordController.text.isNotEmpty &&
          _passwordController.text.length >= 8;

      final isConfirmPasswordValid =
          _confirmPasswordController.text == _passwordController.text;

      return isNameValid &&
          isEmailValid &&
          isPasswordValid &&
          isConfirmPasswordValid;
    } else if (_currentStep == 1) {
      // Validate location fields for step 1
      return _selectedCountry != null &&
          _selectedState != null &&
          _selectedCity.isNotEmpty;
    } else {
      // Validate contact fields for step 2
      return _contactController.text.isNotEmpty &&
          _contactController.text.length >= 8 &&
          RegExp(r'^[0-9]+$').hasMatch(_contactController.text);
    }
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _validateCurrentStep();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      body: Form(
        key: _formKey,
        onChanged: _validateForm,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: StepProgress(
                totalSteps: 3,
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 30,
                ),
                controller: _stepProgressController,
                currentStep: _currentStep,
                onStepChanged: (index) => _goToStep(index),
                // lineSubTitles: const ['Step 2', 'Step 3'],
                nodeIconBuilder: (index, completedStepIndex) {
                  if (index <= completedStepIndex) {
                    return Text(
                      '${index + 1}',
                      style: AppTheme.textLabel(context).copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        color: AppColor.white,
                      ),
                    );
                  } else {
                    return Text(
                      '${index + 1}',
                      style: AppTheme.textSearchInfoLabeled(context).copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        color: AppTheme.iconColorThree(context),
                      ),
                    );
                  }
                },
                theme: StepProgressThemeData(
                  stepLineSpacing: 24,
                  defaultForegroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? AppColor.neutral_70
                      : AppColor.neutral_10,
                  activeForegroundColor: AppColor.primary_50,
                  // borderStyle: OuterBorderStyle(
                  //   borderWidth: 3,
                  //   defaultBorderColor: AppColor.neutral_70,
                  //   activeBorderColor: AppColor.primary_50,
                  // ),
                  stepLineStyle: StepLineStyle(
                    lineThickness: 8,
                    isBreadcrumb: false,
                    borderRadius: Radius.circular(10),
                  ),
                  lineLabelAlignment: Alignment.bottomCenter,
                  lineLabelStyle: StepLabelStyle(
                    margin: EdgeInsets.only(top: 5),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                      _isFormValid = _validateCurrentStep();
                    });
                    _stepProgressController.setCurrentStep(index);
                  },
                  children: [
                    _KeepAlivePage(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _buildPersonalInfoForm(),
                      ),
                    ),
                    _KeepAlivePage(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _buildLocationForm(),
                      ),
                    ),
                    _KeepAlivePage(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _buildContactForm(),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: child,
            ),
          );
        } else {
          return child;
        }
      },
    );
  }

  Widget _buildPersonalInfoForm() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: 'logo',
            child: Image.asset(
              AppTheme.appLogo(context),
              height: 100,
              width: 100,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "Personal Information",
            style: AppTheme.textTitle(context),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Full Name*',
              hintText: 'e.g. David Smith',
              counter: const SizedBox.shrink(),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                child: Icon(HugeIconsSolid.user03),
              ),
              suffixIcon: _isLoading
                  ? null
                  : _nameController.text.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(HugeIconsStroke.cancel02),
                        onPressed: () {
                          _nameController.clear(); // Clear the text field
                        },
                      ),
                    )
                  : null,
            ),
            style: AppInputDecoration.inputTextStyle(context),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              } else if (value.length < 3) {
                return 'Name must be at least 3 characters long';
              } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                return 'Name must contain only letters';
              }
              return null;
            },
            maxLength: 20,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Email Address*',
              hintText: 'e.g. david@example.com',
              counter: const SizedBox.shrink(),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                child: Icon(HugeIconsSolid.mail02),
              ),
              suffixIcon: _isLoading
                  ? null
                  : _emailController.text.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(HugeIconsStroke.cancel02),
                        onPressed: () {
                          _emailController.clear(); // Clear the text field
                        },
                      ),
                    )
                  : null,
            ),
            style: AppInputDecoration.inputTextStyle(context),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              } else if (value.length < 5) {
                return 'Email Address must be at least 5 characters long';
              } else if (!RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            maxLength: 40,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Password*',
              hintText: 'e.g. dav*****',
              counter: const SizedBox.shrink(),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                child: Icon(HugeIconsSolid.lockKey),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? HugeIconsSolid.viewOff
                        : HugeIconsSolid.eye,
                  ),
                  splashRadius: 20, // Smaller tap area
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
            ),
            style: AppInputDecoration.inputTextStyle(context),
            obscureText: _obscurePassword,
            obscuringCharacter: '•',
            keyboardType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              } else if (value.length < 8) {
                return 'Password must be at least 8 characters long';
              }
              return null;
            },
            maxLength: 20,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Confirm Password*',
              hintText: 'e.g. dav*****',
              counter: const SizedBox.shrink(),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                child: Icon(HugeIconsSolid.lockKey),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(
                    _obscureCPassword
                        ? HugeIconsSolid.viewOff
                        : HugeIconsSolid.eye,
                  ),
                  splashRadius: 20, // Smaller tap area
                  onPressed: () {
                    setState(() => _obscureCPassword = !_obscureCPassword);
                  },
                ),
              ),
            ),
            style: AppInputDecoration.inputTextStyle(context),
            obscureText: _obscureCPassword,
            obscuringCharacter: '•',
            keyboardType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your confirm password';
              } else if (value.length < 8) {
                return 'Confirm Password must be at least 8 characters long';
              } else if (value != _passwordController.text) {
                return 'Confirm Passwords do not match';
              }
              return null;
            },
            maxLength: 20,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 16,
            children: [
              Expanded(
                flex: 1,
                child: OutlineButton(
                  text: 'Cancel',
                  disabled: _isLoading,
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                ),
              ),
              Expanded(
                flex: 1,
                child: FlatButton(
                  text: 'Next',
                  disabled: !_isFormValid || _isLoading,
                  onPressed: (_isFormValid && !_isLoading)
                      ? () {
                          if (_validateCurrentStep()) {
                            _stepProgressController.nextStep();
                            _goToStep(1);
                          }
                        }
                      : null,
                  loading: _isLoading,
                  icon: Icons.arrow_forward_ios_rounded,
                  iconLeft: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: 'logo',
            child: Image.asset(
              AppTheme.appLogo(context),
              height: 100,
              width: 100,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "Contact Number",
            style: AppTheme.textTitle(context),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 20),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _contactController,
            style: AppInputDecoration.inputTextStyle(context),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Contact Number*',
              hintText: 'e.g. 1234567890',
              counter: const SizedBox.shrink(),
              prefixIcon: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CountryCodePicker(
                      key: ValueKey(_selectedCountryCode.code ?? 'PK'),
                      initialSelection: _selectedCountryCode.code ?? 'PK',
                      onInit: (country) {
                        if (country != null && mounted) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _selectedCountryCode = country;
                            });
                          });
                        }
                      },
                      onChanged: (country) {
                        setState(() {
                          _selectedCountryCode = country;
                        });
                      },
                      builder: (country) =>
                          AppInputDecoration.buildCountryCodeButton(
                            context,
                            country,
                          ),
                      padding: EdgeInsets.zero,
                      boxDecoration: AppTheme.dialogBg(context),
                      flagDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      flagWidth: 30,
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      favorite: ['PK'],
                      alignLeft: false,
                      showFlag: true,
                      showFlagDialog: true,
                      searchStyle: AppInputDecoration.inputTextStyle(context),
                      textStyle: AppInputDecoration.inputTextStyle(context),
                      dialogTextStyle: AppInputDecoration.inputTextStyle(
                        context,
                      ),
                      dialogBackgroundColor: AppTheme.screenBg(context),
                      headerTextStyle: AppTheme.textTitle(context),
                      headerText: 'Select Country/Region',
                      // dialogSize: Size(
                      //   MediaQuery.of(context).size.width * 0.9,
                      //   400,
                      // ),
                      closeIcon: Icon(HugeIconsStroke.cancel01),
                      pickerStyle: PickerStyle.dialog,
                      dialogItemPadding: EdgeInsetsGeometry.all(20),
                      searchDecoration: InputDecoration(
                        label: Text("Search Countries/Region"),
                        prefixIcon: Icon(HugeIconsSolid.search01),
                      ),
                      barrierColor: Colors.transparent,
                    ),
                    Container(height: 20, width: 1, color: Colors.grey),
                  ],
                ),
              ),
              suffixIcon: _isLoading
                  ? null
                  : _contactController.text.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(HugeIconsStroke.cancel02),
                        onPressed: () {
                          _contactController.clear(); // Clear the text field
                        },
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Only digits allowed';
              } else if (value.length < 8) {
                return 'Phone Number too short';
              }
              return null;
            },
            maxLength: 15,
          ),
          const SizedBox(height: 16),
          Text(
            "We'll call or text you to confirm your number. Standard message and data rates may apply.",
            style: AppTheme.textLabel(context).copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTheme.textLabel(context).copyWith(fontSize: 12),
              children: [
                const TextSpan(text: 'By register, you agree to our '),
                TextSpan(
                  text: 'Terms & Condition, ',
                  style: AppTheme.textLink(context).copyWith(fontSize: 12),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      debugPrint("Terms & Condition clicked");
                    },
                ),
                TextSpan(
                  text: 'Data Policy ',
                  style: AppTheme.textLink(context).copyWith(fontSize: 12),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      debugPrint("Data Policy clicked");
                    },
                ),
                const TextSpan(text: 'and '),
                TextSpan(
                  text: 'Cookies Policy.',
                  style: AppTheme.textLink(context).copyWith(fontSize: 12),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      debugPrint("Cookies Policy clicked");
                    },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 16,
            children: [
              Expanded(
                flex: 1,
                child: OutlineButton(
                  text: 'Back',
                  disabled: _isLoading,
                  onPressed: () {
                    _stepProgressController.previousStep();
                    _goToStep(1);
                    setState(() {
                      _validateForm();
                    });
                  },
                  icon: Icons.arrow_back_ios_rounded,
                ),
              ),
              Expanded(
                flex: 1,
                child: FlatButton(
                  text: 'Register',
                  disabled: !_isFormValid || _isLoading,
                  onPressed: (_isFormValid && !_isLoading)
                      ? () async {
                          if (!_validateCurrentStep()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please complete all fields'),
                              ),
                            );
                            return;
                          }
                          await _submitCompleteForm();
                        }
                      : null,
                  loading: _isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationForm() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: 'logo',
            child: Image.asset(
              AppTheme.appLogo(context),
              height: 100,
              width: 100,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "Where are you located?",
            style: AppTheme.textTitle(context),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 20),

          DropdownButtonHideUnderline(
            child: DropdownButtonFormField2<CountryModel>(
              isExpanded: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,

              decoration: InputDecoration(
                labelText: "Country*",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 6),
                  child: Icon(HugeIconsSolid.globe),
                ),
              ),
              value: _selectedCountry,
              validator: (value) =>
                  value == null ? 'Please select a country' : null,
              dropdownSearchData: DropdownSearchData<CountryModel>(
                searchController:
                    _countrySearchController, // ✅ search controller
                searchInnerWidgetHeight: 50,
                searchInnerWidget: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: TextFormField(
                    controller: _countrySearchController,
                    style: AppTheme.textLabel(context).copyWith(fontSize: 16),
                    decoration: InputDecoration(
                      isDense: false,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColor.neutral_90
                          : AppColor.white,
                      labelText: 'Search country...',
                      // hintStyle: AppTheme.textLabel(
                      //   context,
                      // ).copyWith(fontSize: 14, color: AppColor.neutral_40),
                      prefixIcon: const Icon(
                        HugeIconsStroke.search01,
                        size: 22,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                // ✅ Filter logic
                searchMatchFn: (item, searchValue) {
                  return item.value!.name.toLowerCase().contains(
                    searchValue.toLowerCase(),
                  );
                },
              ),

              // ✅ Clear search when dropdown closes
              onMenuStateChange: (isOpen) {
                if (!isOpen) {
                  _countrySearchController.clear();
                }
              },
              onChanged: _isLoadingCountries
                  ? null
                  : (CountryModel? value) {
                      if (value == _selectedCountry) return;
                      setState(() {
                        _selectedCountry = value;
                        _selectedState = null; // ✅ reset
                        _selectedCity = ''; // ✅ reset
                        _states = [];
                        _cities = [];
                        if (value != null && value.iso2.isNotEmpty) {
                          _selectedCountryCode = CountryCode.fromCountryCode(
                            value.iso2.toUpperCase(),
                          );
                        }
                      });
                      _validateForm();
                      if (value != null) {
                        _fetchStates(value.name);
                      }
                    },
              items: _isLoadingCountries
                  ? [
                      DropdownMenuItem(
                        value: null,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppTheme.inputProgress(context),
                              strokeWidth: 2,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        ),
                      ),
                    ]
                  : _countries.map((CountryModel country) {
                      return DropdownMenuItem<CountryModel>(
                        value: country,
                        child: Row(
                          spacing: 12,
                          children: [
                            CountryFlag.fromCountryCode(
                              country.iso2,
                              theme: const ImageTheme(
                                width: 30,
                                height: 20,
                                shape: RoundedRectangle(4),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                country.name,
                                style: AppTheme.textLabel(
                                  context,
                                ).copyWith(fontSize: 17),
                              ),
                            ),

                            if (_selectedCountry == country)
                              Icon(
                                HugeIconsSolid.checkmarkCircle01,
                                size: 20,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColor.neutral_70
                                    : AppColor.primary_50,
                              ),
                          ],
                        ),
                      );
                    }).toList(),

              iconStyleData: IconStyleData(
                icon: Icon(
                  HugeIconsSolid.arrowDown01,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColor.neutral_40
                      : AppColor.neutral_40,
                ),
                iconSize: 14,
              ),

              dropdownStyleData: DropdownStyleData(
                maxHeight: 260,
                elevation: 0,
                scrollPadding: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColor.neutral_80
                      : AppColor.neutral_5,
                ),
                offset: const Offset(0, -5),
                useSafeArea: true,
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(40),
                  thickness: WidgetStateProperty.all(5),
                ),
              ),

              menuItemStyleData: const MenuItemStyleData(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonHideUnderline(
            child: DropdownButtonFormField2<StateModel>(
              isExpanded: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,

              decoration: InputDecoration(
                labelText: "State*",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 6),
                  child: Icon(HugeIconsSolid.mapsLocation01),
                ),
              ),
              value: _selectedState,
              validator: (value) =>
                  value == null ? 'Please select a state' : null,
              dropdownSearchData: DropdownSearchData<StateModel>(
                searchController: _stateSearchController,
                searchInnerWidgetHeight: 50,
                searchInnerWidget: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: TextFormField(
                    controller: _stateSearchController,
                    style: AppTheme.textLabel(context).copyWith(fontSize: 16),
                    decoration: InputDecoration(
                      isDense: false,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColor.neutral_90
                          : AppColor.white,
                      labelText: 'Search state...',
                      prefixIcon: const Icon(
                        HugeIconsStroke.search01,
                        size: 22,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                // ✅ Filter logic
                searchMatchFn: (item, searchValue) {
                  return item.value!.name.toLowerCase().contains(
                    searchValue.toLowerCase(),
                  );
                },
              ),

              // ✅ Clear search when dropdown closes
              onMenuStateChange: (isOpen) {
                if (!isOpen) {
                  _stateSearchController.clear();
                }
              },
              onChanged: _selectedCountry == null
                  ? null
                  : (StateModel? value) {
                      if (value == _selectedState) return;
                      setState(() {
                        _selectedState = value;
                        _selectedCity = '';
                        _cities = [];
                      });
                      _validateForm();
                      if (value != null) {
                        _fetchCities(
                          _selectedCountry!.name,
                          _selectedState!.name,
                        );
                      }
                    },
              items: _isLoadingStates
                  ? [
                      DropdownMenuItem(
                        value: null,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppTheme.inputProgress(context),
                              strokeWidth: 2,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        ),
                      ),
                    ]
                  : _states.map((StateModel state) {
                      return DropdownMenuItem<StateModel>(
                        value: state,
                        child: Row(
                          spacing: 12,
                          children: [
                            Expanded(
                              child: Text(
                                state.name,
                                style: AppTheme.textLabel(
                                  context,
                                ).copyWith(fontSize: 17),
                              ),
                            ),

                            if (_selectedState == state)
                              Icon(
                                HugeIconsSolid.checkmarkCircle01,
                                size: 20,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColor.neutral_70
                                    : AppColor.primary_50,
                              ),
                          ],
                        ),
                      );
                    }).toList(),

              iconStyleData: IconStyleData(
                icon: Opacity(
                  opacity: _selectedCountry == null ? 0.3 : 1.0,
                  child: Icon(
                    HugeIconsSolid.arrowDown01,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.neutral_40
                        : AppColor.neutral_40,
                  ),
                ),
                iconSize: 14,
              ),

              dropdownStyleData: DropdownStyleData(
                maxHeight: 260,
                elevation: 0,
                scrollPadding: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColor.neutral_80
                      : AppColor.neutral_5,
                ),
                offset: const Offset(0, -5),
                useSafeArea: true,
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(40),
                  thickness: WidgetStateProperty.all(5),
                ),
              ),

              menuItemStyleData: const MenuItemStyleData(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonHideUnderline(
            child: DropdownButtonFormField2<String>(
              isExpanded: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,

              decoration: InputDecoration(
                labelText: "City*",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 6),
                  child: Icon(HugeIconsSolid.building02),
                ),
              ),
              value: _selectedCity.isEmpty ? null : _selectedCity,
              validator: (value) =>
                  value == null ? 'Please select a city' : null,
              dropdownSearchData: DropdownSearchData<String>(
                searchController: _citySearchController,
                searchInnerWidgetHeight: 50,
                searchInnerWidget: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: TextFormField(
                    controller: _citySearchController,
                    style: AppTheme.textLabel(context).copyWith(fontSize: 16),
                    decoration: InputDecoration(
                      isDense: false,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColor.neutral_90
                          : AppColor.white,
                      labelText: 'Search city...',
                      prefixIcon: const Icon(
                        HugeIconsStroke.search01,
                        size: 22,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                // ✅ Filter logic
                searchMatchFn: (item, searchValue) {
                  return item.value!.toLowerCase().contains(
                    searchValue.toLowerCase(),
                  );
                },
              ),

              // ✅ Clear search when dropdown closes
              onMenuStateChange: (isOpen) {
                if (!isOpen) {
                  _citySearchController.clear();
                }
              },
              onChanged: _selectedState == null
                  ? null
                  : (String? value) {
                      if (value == _selectedCity) return;
                      setState(() {
                        _selectedCity = value ?? '';
                      });
                      _validateForm();
                    },
              items: _isLoadingCities
                  ? [
                      DropdownMenuItem(
                        value: null,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppTheme.inputProgress(context),
                              strokeWidth: 2,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        ),
                      ),
                    ]
                  : _cities.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Row(
                          spacing: 12,
                          children: [
                            Expanded(
                              child: Text(
                                city,
                                style: AppTheme.textLabel(
                                  context,
                                ).copyWith(fontSize: 17),
                              ),
                            ),

                            if (_selectedCity == city)
                              Icon(
                                HugeIconsSolid.checkmarkCircle01,
                                size: 20,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColor.neutral_70
                                    : AppColor.primary_50,
                              ),
                          ],
                        ),
                      );
                    }).toList(),

              iconStyleData: IconStyleData(
                icon: Opacity(
                  opacity: _selectedState == null ? 0.3 : 1.0,
                  child: Icon(
                    HugeIconsSolid.arrowDown01,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.neutral_40
                        : AppColor.neutral_40,
                  ),
                ),
                iconSize: 14,
              ),

              dropdownStyleData: DropdownStyleData(
                maxHeight: 260,
                elevation: 0,
                scrollPadding: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColor.neutral_80
                      : AppColor.neutral_5,
                ),
                offset: const Offset(0, -5),
                useSafeArea: true,
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(40),
                  thickness: WidgetStateProperty.all(5),
                ),
              ),

              menuItemStyleData: const MenuItemStyleData(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 16,
            children: [
              Expanded(
                flex: 1,
                child: OutlineButton(
                  text: 'Back',
                  disabled: _isLoading,
                  onPressed: () {
                    _stepProgressController.previousStep();
                    _goToStep(0);
                    setState(() {
                      _validateForm();
                    });
                  },
                  icon: Icons.arrow_back_ios_rounded,
                ),
              ),
              Expanded(
                flex: 1,
                child: FlatButton(
                  text: 'Next',
                  disabled: !_isFormValid || _isLoading,
                  onPressed: (_isFormValid && !_isLoading)
                      ? () {
                          if (_validateCurrentStep()) {
                            _stepProgressController.nextStep();
                            _goToStep(2);
                          }
                        }
                      : null,
                  loading: _isLoading,
                  icon: Icons.arrow_forward_ios_rounded,
                  iconLeft: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitCompleteForm() async {
    if (!_validateCurrentStep()) return;
    setState(() => _isLoading = true);

    try {
      final formData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'pwd': _passwordController.text.trim(),
        'contact': _contactController.text.trim(),
        'country': _selectedCountry,
        'state': _selectedState,
        'city': _selectedCity,
      };

      // Call your API here
      debugPrint('Registration Form Data: $formData');
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) => const LoginScreen()),
        // );
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder:
        //         (_) => OTPVerificationScreen(
        //           phoneNumber: widget.phoneNumber,
        //           countryCode: widget.countryCode ?? '',
        //         ),
        //   ),
        // );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Helper widget to retain step state in PageView and prevent reloading on step transitions
class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
