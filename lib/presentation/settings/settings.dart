import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './widgets/action_button_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';
import '../../services/storage_service.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late bool _autoDiscovery;
  late bool _backgroundScanning;
  late bool _messageAlerts;
  late bool _connectionAlerts;
  late bool _soundEnabled;
  late bool _messageEncryption;
  late bool _autoBackup;
  late int _connectionTimeout;
  late String _dataRetention;
  late String _themeMode;
  late String _language;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _autoDiscovery = StorageService.getAutoDiscovery();
      _backgroundScanning = StorageService.getBackgroundScanning();
      _messageAlerts = StorageService.getMessageAlerts();
      _connectionAlerts = StorageService.getConnectionAlerts();
      _soundEnabled = StorageService.getSoundEnabled();
      _messageEncryption = StorageService.getMessageEncryption();
      _autoBackup = StorageService.getAutoBackup();
      _connectionTimeout = StorageService.getConnectionTimeout();
      _dataRetention = StorageService.getDataRetention();
      _themeMode = StorageService.getThemeMode();
      _language = StorageService.getLanguage();
      _notificationsEnabled = StorageService.getNotificationsEnabled();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
      body: Column(
        children: [
          ProfileHeaderWidget(appVersion: '1.0.0', isBluetoothEnabled: true),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              children: [
                SettingsSectionWidget(
                  title: 'Appearance',
                  items: [
                    SettingsItemData(
                      title: 'Theme',
                      subtitle: _themeMode == 'dark'
                          ? 'Dark'
                          : _themeMode == 'system'
                          ? 'System'
                          : 'Light',
                      leadingIcon: 'brightness_6',
                      hasDisclosure: true,
                      onTap: () => _showThemeDialog(),
                    ),
                  ],
                ),
                SettingsSectionWidget(
                  title: 'Language & Region',
                  items: [
                    SettingsItemData(
                      title: 'App Language',
                      subtitle: _language,
                      leadingIcon: 'language',
                      hasDisclosure: true,
                      onTap: () => _showLanguageDialog(),
                    ),
                  ],
                ),
                SettingsSectionWidget(
                  title: 'Connection Preferences',
                  items: [
                    SettingsItemData(
                      title: 'Auto-Discovery',
                      subtitle: 'Automatically discover nearby devices',
                      leadingIcon: 'bluetooth_searching',
                      trailing: Switch(
                        value: _autoDiscovery,
                        onChanged: (value) {
                          setState(() {
                            _autoDiscovery = value;
                          });
                          StorageService.setAutoDiscovery(value);
                        },
                      ),
                    ),
                    SettingsItemData(
                      title: 'Connection Timeout',
                      subtitle: '$_connectionTimeout seconds',
                      leadingIcon: 'timer',
                      hasDisclosure: true,
                      onTap: () => _showTimeoutDialog(),
                    ),
                    SettingsItemData(
                      title: 'Background Scanning',
                      subtitle: 'Keep scanning when app is in background',
                      leadingIcon: 'settings_backup_restore',
                      trailing: Switch(
                        value: _backgroundScanning,
                        onChanged: (value) {
                          setState(() {
                            _backgroundScanning = value;
                          });
                          StorageService.setBackgroundScanning(value);
                        },
                      ),
                    ),
                  ],
                ),
                SettingsSectionWidget(
                  title: 'Notifications',
                  items: [
                    SettingsItemData(
                      title: 'Enable Notifications',
                      subtitle: 'Receive all app notifications',
                      leadingIcon: 'notifications_active',
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          StorageService.setNotificationsEnabled(value);
                        },
                      ),
                    ),
                    SettingsItemData(
                      title: 'Message Alerts',
                      subtitle: 'Notify when new messages arrive',
                      leadingIcon: 'notifications',
                      trailing: Switch(
                        value: _messageAlerts,
                        onChanged: (value) {
                          setState(() {
                            _messageAlerts = value;
                          });
                          StorageService.setMessageAlerts(value);
                        },
                      ),
                    ),
                    SettingsItemData(
                      title: 'Connection Status',
                      subtitle: 'Alert on connection changes',
                      leadingIcon: 'link',
                      trailing: Switch(
                        value: _connectionAlerts,
                        onChanged: (value) {
                          setState(() {
                            _connectionAlerts = value;
                          });
                          StorageService.setConnectionAlerts(value);
                        },
                      ),
                    ),
                    SettingsItemData(
                      title: 'Sound',
                      subtitle: 'Enable notification sounds',
                      leadingIcon: 'volume_up',
                      trailing: Switch(
                        value: _soundEnabled,
                        onChanged: (value) {
                          setState(() {
                            _soundEnabled = value;
                          });
                          StorageService.setSoundEnabled(value);
                        },
                      ),
                    ),
                  ],
                ),
                SettingsSectionWidget(
                  title: 'Privacy & Security',
                  items: [
                    SettingsItemData(
                      title: 'Message Encryption',
                      subtitle: 'Encrypt all messages end-to-end',
                      leadingIcon: 'lock',
                      trailing: Switch(
                        value: _messageEncryption,
                        onChanged: (value) {
                          setState(() {
                            _messageEncryption = value;
                          });
                          StorageService.setMessageEncryption(value);
                        },
                      ),
                    ),
                    SettingsItemData(
                      title: 'Conversation Backups',
                      subtitle: 'Automatically backup conversations',
                      leadingIcon: 'backup',
                      trailing: Switch(
                        value: _autoBackup,
                        onChanged: (value) {
                          setState(() {
                            _autoBackup = value;
                          });
                          StorageService.setAutoBackup(value);
                        },
                      ),
                    ),
                    SettingsItemData(
                      title: 'Data Retention',
                      subtitle: _dataRetention,
                      leadingIcon: 'schedule',
                      hasDisclosure: true,
                      onTap: () => _showRetentionDialog(),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                ActionButtonWidget(
                  title: 'Export Conversations',
                  subtitle: 'Save all conversations to file',
                  iconName: 'file_download',
                  onTap: () => _showExportDialog(),
                ),
                ActionButtonWidget(
                  title: 'Clear Message History',
                  subtitle: 'Delete all conversation data',
                  iconName: 'delete_sweep',
                  isDestructive: true,
                  onTap: () => _showClearHistoryDialog(),
                ),
                ActionButtonWidget(
                  title: 'Reset App Data',
                  subtitle: 'Reset all settings to default',
                  iconName: 'restore',
                  isDestructive: true,
                  onTap: () => _showResetDialog(),
                ),
                SizedBox(height: 2.h),
                SettingsSectionWidget(
                  title: 'Support & Help',
                  items: [
                    SettingsItemData(
                      title: 'Help Center',
                      subtitle: 'Get help and support',
                      leadingIcon: 'help_outline',
                      hasDisclosure: true,
                      onTap: () => _showHelpDialog(),
                    ),
                    SettingsItemData(
                      title: 'Contact Support',
                      subtitle: 'Reach out to our support team',
                      leadingIcon: 'support_agent',
                      hasDisclosure: true,
                      onTap: () => _showContactSupportDialog(),
                    ),
                    SettingsItemData(
                      title: 'Report a Problem',
                      subtitle: 'Let us know about issues',
                      leadingIcon: 'bug_report',
                      hasDisclosure: true,
                      onTap: () => _showReportProblemDialog(),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Light'),
                value: 'light',
                groupValue: _themeMode,
                onChanged: (value) {
                  setState(() {
                    _themeMode = value!;
                  });
                  StorageService.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Dark'),
                value: 'dark',
                groupValue: _themeMode,
                onChanged: (value) {
                  setState(() {
                    _themeMode = value!;
                  });
                  StorageService.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('System'),
                value: 'system',
                groupValue: _themeMode,
                onChanged: (value) {
                  setState(() {
                    _themeMode = value!;
                  });
                  StorageService.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    final languages = [
      'English',
      'Spanish',
      'French',
      'German',
      'Chinese',
      'Japanese',
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final language = languages[index];
                return RadioListTile<String>(
                  title: Text(language),
                  value: language,
                  groupValue: _language,
                  onChanged: (value) {
                    setState(() {
                      _language = value!;
                    });
                    StorageService.setLanguage(value!);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Help Center'),
          content: const Text(
            'Welcome to BlueChat Help Center!\n\n'
            'Here you can find answers to common questions and learn how to use the app effectively.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showContactSupportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Contact Support'),
          content: const Text(
            'Need help? Reach out to us:\n\n'
            'Email: support@bluechat.app\n'
            'Response time: 24-48 hours',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showReportProblemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report a Problem'),
          content: const Text(
            'Found a bug or issue?\n\n'
            'Please email us at:\nbugs@bluechat.app\n\n'
            'Include details about the problem and steps to reproduce it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        int tempTimeout = _connectionTimeout;

        return AlertDialog(
          title: Text('Connection Timeout'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$tempTimeout seconds',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Slider(
                    value: tempTimeout.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 22,
                    label: '$tempTimeout seconds',
                    onChanged: (value) {
                      setDialogState(() {
                        tempTimeout = value.toInt();
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _connectionTimeout = tempTimeout;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showRetentionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final options = ['7 days', '30 days', '90 days', 'Forever'];

        return AlertDialog(
          title: Text('Data Retention Period'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _dataRetention,
                onChanged: (value) {
                  setState(() {
                    _dataRetention = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Export Conversations'),
          content: Text(
            'Export all conversation history to a file. This may take a few moments.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Conversations exported successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text('Export'),
            ),
          ],
        );
      },
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: Text('Clear Message History'),
          content: Text(
            'This will permanently delete all conversation history. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Message history cleared'),
                    backgroundColor: theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: Text('Reset App Data'),
          content: Text(
            'This will reset all settings to default values and clear all data. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('App data reset successfully'),
                    backgroundColor: theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Privacy Policy...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Terms of Service...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening support contact...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
