import 'package:flutter/material.dart';

/// Custom bottom navigation bar for Bluetooth messaging app
/// Implements thumb-accessible primary navigation with device management,
/// messages, and settings tabs as per Tactical Minimalism design principles.
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when a navigation item is tapped
  final Function(int) onTap;

  /// Optional badge count for messages tab (unread messages)
  final int? messagesBadgeCount;

  /// Optional badge count for devices tab (connection alerts)
  final int? devicesBadgeCount;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.messagesBadgeCount,
    this.devicesBadgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurfaceVariant,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            // Devices Tab - Primary entry point for connection management
            BottomNavigationBarItem(
              icon: _buildIconWithBadge(
                icon: Icons.bluetooth_outlined,
                activeIcon: Icons.bluetooth,
                badgeCount: devicesBadgeCount,
                isSelected: currentIndex == 0,
                context: context,
              ),
              label: 'Devices',
              tooltip: 'Device Discovery',
            ),

            // Messages Tab - Quick access to conversations
            BottomNavigationBarItem(
              icon: _buildIconWithBadge(
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                badgeCount: messagesBadgeCount,
                isSelected: currentIndex == 1,
                context: context,
              ),
              label: 'Messages',
              tooltip: 'Recent Conversations',
            ),

            // Settings Tab - Secondary access for configuration
            BottomNavigationBarItem(
              icon: _buildIconWithBadge(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                badgeCount: null,
                isSelected: currentIndex == 2,
                context: context,
              ),
              label: 'Settings',
              tooltip: 'App Configuration',
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an icon with optional badge for notification counts
  Widget _buildIconWithBadge({
    required IconData icon,
    required IconData activeIcon,
    required int? badgeCount,
    required bool isSelected,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final iconWidget = Icon(isSelected ? activeIcon : icon, size: 24);

    // Return icon without badge if count is null or zero
    if (badgeCount == null || badgeCount <= 0) {
      return iconWidget;
    }

    // Return icon with badge
    return Badge(
      label: Text(
        badgeCount > 99 ? '99+' : badgeCount.toString(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: colorScheme.onError,
        ),
      ),
      backgroundColor: colorScheme.error,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: iconWidget,
    );
  }
}
