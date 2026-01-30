import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Message Bubble Widget
/// Displays individual message with platform-specific styling
class MessageBubbleWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final VoidCallback onRetry;
  final String Function(DateTime) formatTimestamp;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.onRetry,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSent = message["isSent"] as bool;
    final status = message["status"] as String;
    final text = message["text"] as String;
    final timestamp = message["timestamp"] as DateTime;

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: isSent
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent) SizedBox(width: 2.w),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 75.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: isSent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(isSent ? 16 : 4),
                  bottomRight: Radius.circular(isSent ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSent
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTimestamp(timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSent
                              ? theme.colorScheme.onPrimary.withValues(
                                  alpha: 0.7,
                                )
                              : theme.colorScheme.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                      ),
                      if (isSent) ...[
                        SizedBox(width: 1.w),
                        _buildStatusIcon(status, theme),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isSent && status == "failed") ...[
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'refresh',
                  color: theme.colorScheme.error,
                  size: 16,
                ),
              ),
            ),
          ],
          if (isSent) SizedBox(width: 2.w),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status, ThemeData theme) {
    switch (status) {
      case "sending":
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.onPrimary.withValues(alpha: 0.7),
            ),
          ),
        );
      case "sent":
        return CustomIconWidget(
          iconName: 'check',
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
          size: 14,
        );
      case "delivered":
        return CustomIconWidget(
          iconName: 'done_all',
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
          size: 14,
        );
      case "failed":
        return CustomIconWidget(
          iconName: 'error_outline',
          color: theme.colorScheme.error,
          size: 14,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
