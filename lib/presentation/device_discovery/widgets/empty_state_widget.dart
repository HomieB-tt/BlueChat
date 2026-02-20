import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Empty State Widget - Displays when no devices are found
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onScan;
  final bool hasPermission;

  const EmptyStateWidget({
    super.key,
    required this.onScan,
    required this.hasPermission,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bluetooth_disabled,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'No Devices Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              hasPermission
                  ? 'We couldn\'t find any nearby Bluetooth devices. Try the following:'
                  : 'Please turn on Bluetooth to discover nearby devices.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            if (hasPermission) ...[
              _buildTroubleshootingTip(
                context,
                Icons.bluetooth,
                'Enable Bluetooth',
                'Make sure Bluetooth is turned on in your device settings',
              ),
              SizedBox(height: 2.h),
              _buildTroubleshootingTip(
                context,
                Icons.visibility,
                'Make Devices Visible',
                'Ensure nearby devices have Bluetooth visibility enabled',
              ),
              SizedBox(height: 2.h),
              _buildTroubleshootingTip(
                context,
                Icons.location_on,
                'Enable Location',
                'Location services may be required for device discovery',
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onScan,
                  icon: CustomIconWidget(
                    iconName: 'refresh',
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: const Text('Scan Again'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Manual Pairing'),
                        content: const Text(
                          'To manually pair a device:\n\n'
                          '1. Go to your device\'s Bluetooth settings\n'
                          '2. Find and select the device you want to pair\n'
                          '3. Complete the pairing process\n'
                          '4. Return to BlueChat to start messaging',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: CustomIconWidget(
                    iconName: 'settings',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: const Text('Manual Pairing'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onScan,
                  icon: CustomIconWidget(
                    iconName: 'settings',
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: const Text('Turn On Bluetooth'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingTip(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
