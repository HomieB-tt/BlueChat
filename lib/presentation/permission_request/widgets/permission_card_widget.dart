import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Permission Card Widget
/// Displays individual permission information with icon, title, and description
class PermissionCardWidget extends StatelessWidget {
  final String iconName;
  final String title;
  final String description;
  final bool isGranted;

  const PermissionCardWidget({
    super.key,
    required this.iconName,
    required this.title,
    required this.description,
    this.isGranted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: isGranted
              ? colorScheme.tertiary.withValues(alpha: 0.3)
              : colorScheme.outline,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Permission Icon
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: isGranted
                  ? colorScheme.tertiaryContainer
                  : colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: isGranted ? 'check_circle' : iconName,
                color: isGranted
                    ? colorScheme.tertiary
                    : colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Permission Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
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

          // Status Indicator
          if (isGranted)
            CustomIconWidget(
              iconName: 'check_circle',
              color: colorScheme.tertiary,
              size: 5.w,
            ),
        ],
      ),
    );
  }
}
