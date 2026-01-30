import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/device_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/scanning_animation_widget.dart';
import '../../services/storage_service.dart';

/// Device Discovery Screen - Bluetooth device scanning and pairing interface
class DeviceDiscovery extends StatefulWidget {
  const DeviceDiscovery({super.key});

  @override
  State<DeviceDiscovery> createState() => _DeviceDiscoveryState();
}

class _DeviceDiscoveryState extends State<DeviceDiscovery> {
  bool _isScanning = false;
  final bool _hasPermission = true;
  final List<Map<String, dynamic>> _discoveredDevices = [];
  final List<Map<String, dynamic>> _connectedDevices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _startInitialScan();
  }

  void _loadDevices() {
    // Load from storage
    final savedDevices = StorageService.loadDevices();
    if (savedDevices.isNotEmpty) {
      _discoveredDevices.addAll(savedDevices);
    } else {
      // Load mock devices
      _discoveredDevices.addAll([
        {
          "id": "device_001",
          "name": "Sarah's iPhone 13",
          "deviceType": "phone",
          "signalStrength": -45,
          "connectionStatus": "available",
          "lastSeen": DateTime.now().subtract(const Duration(seconds: 5)),
          "isPaired": false,
          "isBlocked": false,
          "nickname": null,
        },
        {
          "id": "device_002",
          "name": "Michael's MacBook Pro",
          "deviceType": "computer",
          "signalStrength": -62,
          "connectionStatus": "available",
          "lastSeen": DateTime.now().subtract(const Duration(seconds: 12)),
          "isPaired": true,
          "isBlocked": false,
          "nickname": "Work Laptop",
        },
        {
          "id": "device_003",
          "name": "Galaxy Tab S8",
          "deviceType": "tablet",
          "signalStrength": -78,
          "connectionStatus": "available",
          "lastSeen": DateTime.now().subtract(const Duration(seconds: 8)),
          "isPaired": false,
          "isBlocked": false,
          "nickname": null,
        },
        {
          "id": "device_004",
          "name": "Emma's Pixel 7",
          "deviceType": "phone",
          "signalStrength": -55,
          "connectionStatus": "connected",
          "lastSeen": DateTime.now(),
          "isPaired": true,
          "isBlocked": false,
          "nickname": "Emma",
          "messageCount": 3,
        },
      ]);
    }

    _connectedDevices.addAll(
      _discoveredDevices
          .where((device) => device["connectionStatus"] == "connected")
          .toList(),
    );
  }

  void _startInitialScan() {
    setState(() => _isScanning = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    });
  }

  Future<void> _refreshDevices() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isScanning = false;
        for (var device in _discoveredDevices) {
          device["lastSeen"] = DateTime.now().subtract(
            Duration(seconds: (device["signalStrength"] as int).abs() ~/ 10),
          );
        }
      });
    }
  }

  void _manualScan() {
    if (_isScanning) return;
    setState(() => _isScanning = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    });
  }

  void _connectToDevice(Map<String, dynamic> device) {
    setState(() {
      device["connectionStatus"] = "connecting";
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          device["connectionStatus"] = "connected";
          device["isPaired"] = true;
          device["messageCount"] = 0;
          if (!_connectedDevices.contains(device)) {
            _connectedDevices.add(device);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connected to ${device["nickname"] ?? device["name"]}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _disconnectDevice(Map<String, dynamic> device) {
    setState(() {
      device["connectionStatus"] = "available";
      _connectedDevices.remove(device);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Disconnected from ${device["nickname"] ?? device["name"]}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _forgetDevice(Map<String, dynamic> device) {
    setState(() {
      device["isPaired"] = false;
      device["connectionStatus"] = "available";
      device["nickname"] = null;
      _connectedDevices.remove(device);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Forgot ${device["name"]}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _blockDevice(Map<String, dynamic> device) {
    setState(() {
      device["isBlocked"] = true;
      device["connectionStatus"] = "blocked";
      _connectedDevices.remove(device);
      _discoveredDevices.remove(device);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Blocked ${device["name"]}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _assignNickname(Map<String, dynamic> device) {
    final TextEditingController nicknameController = TextEditingController(
      text: device["nickname"] ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Assign Nickname', style: theme.textTheme.titleLarge),
          content: TextField(
            controller: nicknameController,
            decoration: const InputDecoration(
              labelText: 'Nickname',
              hintText: 'Enter a friendly name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  device["nickname"] = nicknameController.text.trim().isEmpty
                      ? null
                      : nicknameController.text.trim();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _viewDeviceDetails(Map<String, dynamic> device) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text('Device Details', style: theme.textTheme.titleLarge),
            SizedBox(height: 2.h),
            _buildDetailRow(
              'Name',
              device["nickname"] ?? device["name"],
              theme,
            ),
            _buildDetailRow('Device ID', device["id"], theme),
            _buildDetailRow('Type', device["deviceType"], theme),
            _buildDetailRow(
              'Signal Strength',
              '${device["signalStrength"]} dBm',
              theme,
            ),
            _buildDetailRow('Status', device["connectionStatus"], theme),
            _buildDetailRow('Paired', device["isPaired"] ? 'Yes' : 'No', theme),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(Map<String, dynamic> device) {
    Navigator.of(context, rootNavigator: true).pushNamed('/chat-conversation');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Devices',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 2.w,
                                height: 2.w,
                                decoration: BoxDecoration(
                                  color: _isScanning
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.tertiary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                _isScanning ? 'Scanning...' : 'Ready',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _isScanning ? null : _manualScan,
                      icon: CustomIconWidget(
                        iconName: 'refresh',
                        color: _isScanning
                            ? theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              )
                            : theme.colorScheme.primary,
                        size: 24,
                      ),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _buildDevicesTab(theme)),
        ],
      ),
    );
  }

  Widget _buildDevicesTab(ThemeData theme) {
    final availableDevices = _discoveredDevices
        .where((device) => !(device["isBlocked"] as bool))
        .toList();

    return RefreshIndicator(
      onRefresh: _refreshDevices,
      child: _isScanning && availableDevices.isEmpty
          ? ScanningAnimationWidget(isScanning: _isScanning)
          : availableDevices.isEmpty
          ? EmptyStateWidget(onScan: _manualScan, hasPermission: _hasPermission)
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              itemCount: availableDevices.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final device = availableDevices[index];
                return DeviceCardWidget(
                  device: device,
                  onConnect: () => _connectToDevice(device),
                  onDisconnect: () => _disconnectDevice(device),
                  onForget: () => _forgetDevice(device),
                  onBlock: () => _blockDevice(device),
                  onAssignNickname: () => _assignNickname(device),
                  onViewDetails: () => _viewDeviceDetails(device),
                  onOpenChat: () => _openChat(device),
                );
              },
            ),
    );
  }
}
