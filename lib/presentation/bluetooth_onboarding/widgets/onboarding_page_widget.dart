import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Individual onboarding page widget that displays title, description,
/// animation, and benefit cards for each onboarding step.
class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String description;
  final String lottieAsset;
  final List<Widget> benefits;

  const OnboardingPageWidget({
    super.key,
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.benefits,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 2.h),
          Container(
            width: 80.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'bluetooth_connected',
                color: theme.colorScheme.primary,
                size: 120,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ...benefits,
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
