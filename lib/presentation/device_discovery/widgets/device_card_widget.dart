import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Device Card Widget - Displays individual Bluetooth device information
/// with swipe actions and connection controls
class DeviceCardWidget extends StatelessWidget {
  final Map<String, dynamic> device;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onForget;
  final VoidCallback onBlock;
  final VoidCallback onAssignNickname;
  final VoidCallback onViewDetails;
  final VoidCallback onOpenChat;

  const DeviceCardWidget({
    super.key,
    required this.device,
    required this.onConnect,
    required this.onDisconnect,
    required this.onForget,
    required this.onBlock,
    required this.onAssignNickname,
    required this.onViewDetails,
    required this.onOpenChat,
  });

  IconData _getDeviceIcon() {
    switch (device["deviceType"]) {
      case "phone":
        return Icons.smartphone;
      case "tablet":
        return Icons.tablet;
      case "computer":
        return Icons.computer;
      default:
        return Icons.bluetooth;
    }
  }

  Color _getSignalColor(ThemeData theme) {
    final signalStrength = device["signalStrength"] as int;
    if (signalStrength > -50) {
      return theme.colorScheme.tertiary;
    } else if (signalStrength > -70) {
      return Colors.orange;
    } else {
      return theme.colorScheme.error;
    }
  }

  int _getSignalBars() {
    final signalStrength = device["signalStrength"] as int;
    if (signalStrength > -50) return 3;
    if (signalStrength > -70) return 2;
    return 1;
  }

  String _getLastSeenText() {
    final lastSeen = device["lastSeen"] as DateTime;
    final difference = DateTime.now().difference(lastSeen);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnected = device["connectionStatus"] == "connected";
    final isConnecting = device["connectionStatus"] == "connecting";
    final isPaired = device["isPaired"] as bool;
    final messageCount = device["messageCount"] as int?;

    return Slidable(
      key: ValueKey(device["id"]),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (isPaired)
            SlidableAction(
              onPressed: (_) => onForget(),
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              icon: Icons.delete_outline,
              label: 'Forget',
            ),
          SlidableAction(
            onPressed: (_) => onBlock(),
            backgroundColor: theme.colorScheme.error.withValues(alpha: 0.8),
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.block,
            label: 'Block',
          ),
        ],
      ),
      child: InkWell(
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'edit',
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    title: const Text('Assign Nickname'),
                    onTap: () {
                      Navigator.pop(context);
                      onAssignNickname();
                    },
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'info_outline',
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    title: const Text('View Details'),
                    onTap: () {
                      Navigator.pop(context);
                      onViewDetails();
                    },
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          );
        },
        onTap: isConnected ? onOpenChat : null,
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isConnected
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isConnected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: isConnected
                      ? theme.colorScheme.tertiary.withValues(alpha: 0.1)
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDeviceIcon(),
                  color: isConnected
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            device["nickname"] ?? device["name"],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (messageCount != null && messageCount > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              messageCount > 99
                                  ? '99+'
                                  : messageCount.toString(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onError,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            3,
                            (index) => Container(
                              width: 1.w,
                              height: 2.h,
                              margin: EdgeInsets.only(right: 0.5.w),
                              decoration: BoxDecoration(
                                color: index < _getSignalBars()
                                    ? _getSignalColor(theme)
                                    : theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          _getLastSeenText(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (isConnected) ...[
                          SizedBox(width: 2.w),
                          Container(
                            width: 2.w,
                            height: 2.w,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Connected',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              isConnecting
                  ? SizedBox(
                      width: 6.w,
                      height: 6.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : isConnected
                  ? IconButton(
                      onPressed: onDisconnect,
                      icon: CustomIconWidget(
                        iconName: 'link_off',
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      tooltip: 'Disconnect',
                    )
                  : ElevatedButton(
                      onPressed: onConnect,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        minimumSize: Size(0, 4.h),
                      ),
                      child: Text(
                        isPaired ? 'Connect' : 'Pair',
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
