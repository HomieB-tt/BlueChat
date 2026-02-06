import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/app_export.dart';
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
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  bool _isLoading = false;

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _handleEnableBluetooth() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

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
                  SizedBox(width: 48),
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
                            SizedBox(
                              width: double.infinity,
                              height: 6.h,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : _handleEnableBluetooth,
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
                                            iconName: 'bluetooth',
                                            color: theme.colorScheme.onPrimary,
                                            size: 20,
                                          ),
                                          SizedBox(width: 2.w),
                                          Text(
                                            'Enable Bluetooth',
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
                            SizedBox(height: 2.h),
                            TextButton(
                              onPressed: _handleSkip,
                              child: Text(
                                'Skip for Now',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
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
