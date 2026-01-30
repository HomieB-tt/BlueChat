import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/permission_card_widget.dart';
import './widgets/permission_explanation_widget.dart';

/// Permission Request Screen
/// Guides users through granting essential Bluetooth and location permissions
/// with clear explanations and native system integration
class PermissionRequest extends StatefulWidget {
  const PermissionRequest({super.key});

  @override
  State<PermissionRequest> createState() => _PermissionRequestState();
}

class _PermissionRequestState extends State<PermissionRequest> {
  bool _isLoading = false;
  bool _showLearnMore = false;
  Map<String, PermissionStatus> _permissionStatuses = {};

  @override
  void initState() {
    super.initState();
    _checkPermissionStatuses();
  }

  /// Check current permission statuses
  Future<void> _checkPermissionStatuses() async {
    if (kIsWeb) {
      // Web doesn't require explicit permission handling for Bluetooth
      setState(() {
        _permissionStatuses = {
          'bluetooth': PermissionStatus.granted,
          'location': PermissionStatus.granted,
        };
      });
      return;
    }

    final bluetoothStatus = await Permission.bluetooth.status;
    final locationStatus = await Permission.location.status;

    setState(() {
      _permissionStatuses = {
        'bluetooth': bluetoothStatus,
        'location': locationStatus,
      };
    });

    // Auto-advance if all permissions granted
    if (bluetoothStatus.isGranted && locationStatus.isGranted) {
      _navigateToDeviceDiscovery();
    }
  }

  /// Request all required permissions sequentially
  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        // Web: Bluetooth handled by browser, auto-advance
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToDeviceDiscovery();
        return;
      }

      // Mobile: Request permissions sequentially
      bool allGranted = true;

      // Request Bluetooth permission
      final bluetoothStatus = await Permission.bluetooth.request();
      _permissionStatuses['bluetooth'] = bluetoothStatus;

      if (!bluetoothStatus.isGranted) {
        allGranted = false;
      }

      // Request Location permission (Android only)
      if (Platform.isAndroid) {
        final locationStatus = await Permission.location.request();
        _permissionStatuses['location'] = locationStatus;

        if (!locationStatus.isGranted) {
          allGranted = false;
        }
      }

      setState(() => _isLoading = false);

      if (allGranted) {
        _navigateToDeviceDiscovery();
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog();
    }
  }

  /// Navigate to Device Discovery screen
  void _navigateToDeviceDiscovery() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed('/device-discovery');
  }

  void _navigateToNextScreen() {
    Navigator.of(context).pushReplacementNamed('/home-screen');
  }

  /// Show dialog when permissions are denied
  void _showPermissionDeniedDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permissions Required', style: theme.textTheme.titleLarge),
        content: Text(
          'BlueChat needs Bluetooth and Location permissions to discover and connect to nearby devices. Please grant these permissions to continue.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: theme.textTheme.titleLarge),
        content: Text(
          'An error occurred while requesting permissions. Please try again.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 4.h),

                // Permission Icon
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'bluetooth_searching',
                      color: colorScheme.primary,
                      size: 12.w,
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                // Header Title
                Text(
                  'Enable Communication',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 1.h),

                // Subtitle
                Text(
                  'Grant permissions to enable offline messaging through Bluetooth connectivity',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 4.h),

                // Permission Cards
                PermissionCardWidget(
                  iconName: 'bluetooth',
                  title: 'Bluetooth Access',
                  description:
                      'Required for device communication and message exchange',
                  isGranted:
                      _permissionStatuses['bluetooth']?.isGranted ?? false,
                ),

                SizedBox(height: 2.h),

                if (!kIsWeb && Platform.isAndroid)
                  PermissionCardWidget(
                    iconName: 'location_on',
                    title: 'Location Access',
                    description:
                        'Required for discovering nearby Bluetooth devices (Android requirement)',
                    isGranted:
                        _permissionStatuses['location']?.isGranted ?? false,
                  ),

                if (!kIsWeb && Platform.isAndroid) SizedBox(height: 2.h),

                PermissionCardWidget(
                  iconName: 'refresh',
                  title: 'Background Refresh',
                  description: 'Maintains connections when app is minimized',
                  isGranted: true,
                ),

                SizedBox(height: 4.h),

                // Grant Permissions Button
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _requestPermissions,
                    child: _isLoading
                        ? SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            'Grant Permissions',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Learn More Button
                TextButton(
                  onPressed: () {
                    setState(() => _showLearnMore = !_showLearnMore);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Learn More',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      CustomIconWidget(
                        iconName: _showLearnMore
                            ? 'expand_less'
                            : 'expand_more',
                        color: colorScheme.primary,
                        size: 5.w,
                      ),
                    ],
                  ),
                ),

                // Expandable Learn More Section
                if (_showLearnMore) ...[
                  SizedBox(height: 2.h),
                  PermissionExplanationWidget(),
                ],

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
