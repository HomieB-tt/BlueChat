import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_icon_widget.dart';

/// Splash Screen - Branded launch experience with Bluetooth initialization
/// Displays app logo with pulse animation while checking permissions and paired devices
/// Navigates to appropriate screen based on Bluetooth status and user state
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final bool _isInitializing = true;
  String _statusMessage = 'Initializing Bluetooth...';

  @override
  void initState() {
    super.initState();
    _initializePulseAnimation();
    _initializeApp();
  }

  /// Initialize pulse animation for logo
  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  /// Initialize app and check Bluetooth status
  Future<void> _initializeApp() async {
    try {
      // Load persisted app state
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _statusMessage = 'Loading preferences...');

      // Simulate Bluetooth initialization and permission checks
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _statusMessage = 'Checking permissions...');

      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _statusMessage = 'Scanning for devices...');

      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _statusMessage = 'Loading conversations...');

      await Future.delayed(const Duration(milliseconds: 600));

      // Determine navigation path based on app state
      _navigateToNextScreen();
    } catch (e) {
      _showErrorDialog(
        'Bluetooth initialization failed. Please check your device settings.',
      );
    }
  }

  /// Navigate to appropriate screen based on initialization results
  void _navigateToNextScreen() {
    if (!mounted) return;

    // Check if user has completed onboarding
    final bool hasCompletedOnboarding = StorageService.getOnboardingCompleted();
    final bool hasGrantedPermissions = true; // Mock: Check actual permissions

    String nextRoute;
    if (!hasGrantedPermissions) {
      nextRoute = '/permission-request';
    } else if (!hasCompletedOnboarding) {
      nextRoute = '/bluetooth-onboarding';
    } else {
      nextRoute = '/home-screen';
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed(nextRoute);
      }
    });
  }

  /// Show error dialog for initialization failures
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Initialization Error',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushReplacementNamed('/settings');
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'bluetooth',
                          color: theme.colorScheme.primary,
                          size: 48,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 4.h),
              Text(
                'BlueChat',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Bluetooth Messaging',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 6.h),
              if (_isInitializing)
                Column(
                  children: [
                    SizedBox(
                      width: 10.w,
                      height: 10.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.9,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
