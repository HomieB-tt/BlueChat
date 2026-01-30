import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Permission Explanation Widget
/// Displays detailed explanation of technical requirements and privacy protection
class PermissionExplanationWidget extends StatelessWidget {
  const PermissionExplanationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Technical Requirements Section
          Text(
            'Technical Requirements',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 1.h),

          _buildExplanationItem(
            context,
            icon: 'bluetooth',
            title: 'Bluetooth Permission',
            description:
                'Enables direct device-to-device communication for message exchange without internet connectivity.',
          ),

          SizedBox(height: 1.5.h),

          _buildExplanationItem(
            context,
            icon: 'location_on',
            title: 'Location Permission',
            description:
                'Required by Android OS for Bluetooth device discovery. Your location data is never collected or stored.',
          ),

          SizedBox(height: 1.5.h),

          _buildExplanationItem(
            context,
            icon: 'refresh',
            title: 'Background Refresh',
            description:
                'Maintains active Bluetooth connections when app is minimized, ensuring reliable message delivery.',
          ),

          SizedBox(height: 2.h),

          // Privacy Protection Section
          Text(
            'Privacy Protection',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 1.h),

          _buildPrivacyItem(
            context,
            icon: 'lock',
            text:
                'All messages are transmitted directly between devices via Bluetooth',
          ),

          SizedBox(height: 1.h),

          _buildPrivacyItem(
            context,
            icon: 'cloud_off',
            text: 'No data is sent to external servers or stored in the cloud',
          ),

          SizedBox(height: 1.h),

          _buildPrivacyItem(
            context,
            icon: 'visibility_off',
            text:
                'Location permission is used only for device discovery, not tracking',
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(1.5.w),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: colorScheme.primary,
              size: 4.w,
            ),
          ),
        ),

        SizedBox(width: 2.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyItem(
    BuildContext context, {
    required String icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomIconWidget(
          iconName: icon,
          color: colorScheme.tertiary,
          size: 4.w,
        ),

        SizedBox(width: 2.w),

        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
