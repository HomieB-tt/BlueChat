import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/app_export.dart';
import '../../services/bluetooth_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/benefit_card_widget.dart';
import './widgets/onboarding_page_widget.dart';

/// Bluetooth Onboarding screen that educates first-time users about offline messaging
/// capabilities and required permissions through mobile-optimized flow.
class BluetoothOnboarding extends StatefulWidget {
  const BluetoothOnboarding({super.key});

  @override
  State<BluetoothOnboarding> createState() => _BluetoothOnboardingState();
}

class _BluetoothOnboardingState extends State<BluetoothOnboarding>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  bool _isLoading = false;
  bool _isBluetoothOn = false;

  final BluetoothService _bluetoothService = BluetoothService();

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Connect Without Internet",
      "description":
          "Send messages directly to nearby devices using Bluetooth technology. No cellular data or WiFi required.",
      "lottieAsset":
          "https://lottie.host/4d3c8f3e-8f3e-4f3e-8f3e-4d3c8f3e8f3e/animation.json",
      "benefits": [
        {
          "icon": "wifi_off",
          "title": "No Internet Required",
          "description":
              "Stay connected in remote areas without network coverage",
        },
        {
          "icon": "lock",
          "title": "Private & Secure",
          "description":
              "Direct device-to-device communication keeps your messages private",
        },
        {
          "icon": "flash_on",
          "title": "Instant Connection",
          "description":
              "Quick pairing and messaging with nearby Bluetooth devices",
        },
      ],
    },
    {
      "title": "Discover Nearby Devices",
      "description":
          "Automatically find and connect to other BlueChat users within Bluetooth range.",
      "lottieAsset":
          "https://lottie.host/5e4d9g4f-9g4f-5g4f-9g4f-5e4d9g4f9g4f/animation.json",
      "benefits": [
        {
          "icon": "bluetooth_searching",
          "title": "Auto Discovery",
          "description": "Automatically detect nearby devices running BlueChat",
        },
        {
          "icon": "people",
          "title": "Multiple Connections",
          "description": "Connect with multiple devices simultaneously",
        },
        {
          "icon": "speed",
          "title": "Fast Pairing",
          "description": "Quick and easy device pairing process",
        },
      ],
    },
    {
      "title": "Start Messaging",
      "description":
          "Send text messages, manage conversations, and stay connected offline.",
      "lottieAsset":
          "https://lottie.host/6f5e0h5g-0h5g-6h5g-0h5g-6f5e0h5g0h5g/animation.json",
      "benefits": [
        {
          "icon": "chat",
          "title": "Offline Messaging",
          "description":
              "Send and receive messages without internet connection",
        },
        {
          "icon": "history",
          "title": "Message History",
          "description": "View conversation history with timestamps",
        },
        {
          "icon": "notifications",
          "title": "Instant Notifications",
          "description": "Get notified when new messages arrive",
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    _checkBluetoothStatus();
    // Add observer to detect when app resumes from background
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check Bluetooth status when app resumes (user returns from settings)
    if (state == AppLifecycleState.resumed) {
      _checkBluetoothStatus();
    }
  }

  /// Check if Bluetooth is currently turned on
  Future<void> _checkBluetoothStatus() async {
    try {
      final isOn = await _bluetoothService.isBluetoothOn();
      if (mounted) {
        setState(() {
          _isBluetoothOn = isOn;
        });
      }
    } catch (e) {
      debugPrint('Error checking Bluetooth status: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  /// Show dialog to prompt user to turn on Bluetooth
  void _showBluetoothOffDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Bluetooth Required',
            style: theme.textTheme.titleLarge,
          ),
          content: Text(
            'BlueChat requires Bluetooth to be turned on to discover and connect to nearby devices. Please enable Bluetooth in your phone settings.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Open Bluetooth settings
                await _bluetoothService.openBluetoothSettings();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleContinue() async {
    // Check if Bluetooth is on
    final isBluetoothOn = await _bluetoothService.isBluetoothOn();
    
    if (!isBluetoothOn) {
      // Show dialog to prompt user to turn on Bluetooth
      _showBluetoothOffDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // Mark onboarding as completed
    await StorageService.setOnboardingCompleted(true);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      // Navigate to permission request screen to grant necessary permissions
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed('/permission-request');
    }
  }

  void _handleSkip() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            'Limited Functionality',
            style: theme.textTheme.titleLarge,
          ),
          content: Text(
            'Skipping Bluetooth setup will limit app functionality. You can enable it later in Settings.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Mark onboarding as completed even when skipping
                await StorageService.setOnboardingCompleted(true);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                // Navigate to permission request screen even when skipping
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushReplacementNamed('/permission-request');
              },
              child: const Text('Continue Anyway'),
            ),
          ],
        );
      },
    );
  }

  void _handleBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed('/splash-screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _handleBack,
                    icon: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: theme.colorScheme.onSurface,
                      size: 24,
                    ),
                    tooltip: 'Back',
                  ),
                  Text(
                    'Step ${_currentPage + 1} of ${_onboardingData.length}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: _handleSkip,
                    child: Text(
                      'Skip',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    title: _onboardingData[index]["title"] as String,
                    description:
                        _onboardingData[index]["description"] as String,
                    lottieAsset:
                        _onboardingData[index]["lottieAsset"] as String,
                    benefits: (_onboardingData[index]["benefits"] as List)
                        .map(
                          (benefit) => BenefitCardWidget(
                            icon: benefit["icon"] as String,
                            title: benefit["title"] as String,
                            description: benefit["description"] as String,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingData.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: theme.colorScheme.primary,
                      dotColor: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 8,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  _currentPage == _onboardingData.length - 1
                      ? Column(
                          children: [
                            // Bluetooth Status Card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: _isBluetoothOn
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isBluetoothOn
                                      ? Colors.green.withValues(alpha: 0.3)
                                      : Colors.red.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10.w,
                                    height: 10.w,
                                    decoration: BoxDecoration(
                                      color: _isBluetoothOn
                                          ? Colors.green.withValues(alpha: 0.2)
                                          : Colors.red.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: CustomIconWidget(
                                        iconName: _isBluetoothOn
                                            ? 'bluetooth'
                                            : 'bluetooth_disabled',
                                        color: _isBluetoothOn
                                            ? Colors.green
                                            : Colors.red,
                                        size: 5.w,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Bluetooth Status',
                                          style: theme.textTheme.labelLarge?.copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          _isBluetoothOn ? 'Enabled' : 'Disabled',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: _isBluetoothOn
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!_isBluetoothOn)
                                    TextButton(
                                      onPressed: () async {
                                        await _bluetoothService.openBluetoothSettings();
                                        // Re-check Bluetooth status after returning
                                        await _checkBluetoothStatus();
                                      },
                                      child: Text(
                                        'Turn On',
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 3.h),
                            SizedBox(
                              width: double.infinity,
                              height: 6.h,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : _handleContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconWidget(
                                            iconName: _isBluetoothOn
                                                ? 'check'
                                                : 'arrow_forward',
                                            color: theme.colorScheme.onPrimary,
                                            size: 20,
                                          ),
                                          SizedBox(width: 2.w),
                                          Text(
                                            _isBluetoothOn
                                                ? 'Continue'
                                                : 'Continue Anyway',
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onPrimary,
                                                ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            if (!_isBluetoothOn) ...[
                              SizedBox(height: 1.h),
                              Text(
                                'You can enable Bluetooth later in settings',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 6.h,
                          child: ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Next',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                CustomIconWidget(
                                  iconName: 'arrow_forward',
                                  color: theme.colorScheme.onPrimary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
