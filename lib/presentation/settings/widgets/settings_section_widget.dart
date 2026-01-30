import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Reusable settings section widget with collapsible functionality
class SettingsSectionWidget extends StatefulWidget {
  final String title;
  final List<SettingsItemData> items;
  final bool initiallyExpanded;

  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.items,
    this.initiallyExpanded = true,
  });

  @override
  State<SettingsSectionWidget> createState() => _SettingsSectionWidgetState();
}

class _SettingsSectionWidgetState extends State<SettingsSectionWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(12),
              bottom: _isExpanded ? Radius.zero : const Radius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Column(
              children: widget.items.map((item) {
                return _buildSettingsItem(context, item);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, SettingsItemData item) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            if (item.leadingIcon != null)
              Container(
                margin: EdgeInsets.only(right: 3.w),
                child: CustomIconWidget(
                  iconName: item.leadingIcon!,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (item.subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: 0.5.h),
                      child: Text(
                        item.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (item.trailing != null) item.trailing!,
            if (item.hasDisclosure)
              CustomIconWidget(
                iconName: 'chevron_right',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// Data model for settings items
class SettingsItemData {
  final String title;
  final String? subtitle;
  final String? leadingIcon;
  final Widget? trailing;
  final bool hasDisclosure;
  final VoidCallback? onTap;

  SettingsItemData({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.hasDisclosure = false,
    this.onTap,
  });
}
