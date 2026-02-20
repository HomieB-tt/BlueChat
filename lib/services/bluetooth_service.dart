import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutter_blue_plus;
import 'package:permission_handler/permission_handler.dart';
import '../core/env.dart';

/// Bluetooth device model for discovered devices
/// Note: This is a wrapper around flutter_reactive_ble's DiscoveredDevice
class BluetoothDevice {
  final String id;
  final String? name;
  final int rssi;
  final DateTime discoveredAt;
  final Map<String, dynamic> metadata;

  BluetoothDevice({
    required this.id,
    this.name,
    required this.rssi,
    DateTime? discoveredAt,
    this.metadata = const {},
  }) : discoveredAt = discoveredAt ?? DateTime.now();

  /// Create from flutter_reactive_ble's DiscoveredDevice
  factory BluetoothDevice.fromReactiveDevice(DiscoveredDevice device) {
    return BluetoothDevice(
      id: device.id,
      name: device.name,
      rssi: device.rssi,
      discoveredAt: DateTime.now(),
      metadata: {
        'serviceUuids': device.serviceUuids.map((u) => u.toString()).toList(),
        'manufacturerData': device.manufacturerData,
      },
    );
  }

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rssi': rssi,
      'discoveredAt': discoveredAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create from map
  factory BluetoothDevice.fromMap(Map<String, dynamic> map) {
    return BluetoothDevice(
      id: map['id'] as String,
      name: map['name'] as String?,
      rssi: map['rssi'] as int,
      discoveredAt: DateTime.tryParse(map['discoveredAt'] as String),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  /// Convert to the device format used in the app
  Map<String, dynamic> toAppDeviceFormat() {
    return {
      'id': id,
      'name': name ?? 'Unknown Device',
      'deviceType': _determineDeviceType(name),
      'signalStrength': rssi,
      'connectionStatus': 'available',
      'lastSeen': discoveredAt,
      'isPaired': false,
      'isBlocked': false,
      'nickname': null,
      'rssi': rssi,
    };
  }

  String _determineDeviceType(String? deviceName) {
    if (deviceName == null) return 'unknown';
    final name = deviceName.toLowerCase();
    if (name.contains('iphone') ||
        name.contains('pixel') ||
        name.contains('galaxy') ||
        name.contains('android')) {
      return 'phone';
    } else if (name.contains('macbook') ||
        name.contains('laptop') ||
        name.contains('computer') ||
        name.contains('pc')) {
      return 'computer';
    } else if (name.contains('ipad') ||
        name.contains('tablet') ||
        name.contains('tab')) {
      return 'tablet';
    }
    return 'unknown';
  }
}

/// Bluetooth connection state
enum BluetoothConnectionState {
  unknown,
  poweredOff,
  poweredOn,
  unauthorized,
  unsupported,
  resetting,
}

/// Bluetooth scanning service
/// Provides actual Bluetooth LE device discovery using flutter_reactive_ble
class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  // Flutter Reactive BLE instance
  FlutterReactiveBle? _ble;

  // Stream subscriptions
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;

  // Streams
  final StreamController<BluetoothDevice> _deviceDiscoverdController =
      StreamController<BluetoothDevice>.broadcast();
  final StreamController<BluetoothConnectionState> _connectionStateController =
      StreamController<BluetoothConnectionState>.broadcast();
  final StreamController<bool> _isScanningController =
      StreamController<bool>.broadcast();

  // Discovered devices cache
  final Map<String, BluetoothDevice> _discoveredDevices = {};

  /// Get discovered devices stream
  Stream<BluetoothDevice> get discoveredDevices =>
      _deviceDiscoverdController.stream;

  /// Get Bluetooth state stream
  Stream<BluetoothConnectionState> get connectionState =>
      _connectionStateController.stream;

  /// Get scanning state stream
  Stream<bool> get isScanning => _isScanningController.stream;

  /// Get Bluetooth adapter state as a stream
  Stream<flutter_blue_plus.BluetoothAdapterState> get bluetoothAdapterState =>
      flutter_blue_plus.FlutterBluePlus.adapterState;

  /// Get currently cached discovered devices
  List<BluetoothDevice> get cachedDevices => _discoveredDevices.values.toList();

  /// Initialize the Bluetooth service
  Future<void> initialize() async {
    if (kIsWeb) {
      // Web doesn't support native Bluetooth in this context
      _connectionStateController.add(BluetoothConnectionState.unsupported);
      return;
    }

    _ble = FlutterReactiveBle();

    // Monitor Bluetooth state
    _ble!.connectedDeviceStream.listen((update) {
      _handleConnectionStateUpdate(update);
    });
  }

  /// Handle connection state updates
  void _handleConnectionStateUpdate(ConnectionStateUpdate update) {
    BluetoothConnectionState state;
    switch (update.connectionState) {
      case DeviceConnectionState.connected:
        state = BluetoothConnectionState.poweredOn;
        break;
      case DeviceConnectionState.disconnected:
        state = BluetoothConnectionState.poweredOn;
        break;
      case DeviceConnectionState.connecting:
      case DeviceConnectionState.disconnecting:
        state = BluetoothConnectionState.poweredOn;
        break;
    }
    _connectionStateController.add(state);
  }

  /// Check if Bluetooth permissions are granted
  Future<bool> checkPermissions() async {
    if (kIsWeb) {
      // For web, we'll simulate permission check
      return true;
    }

    if (Platform.isAndroid) {
      final bluetoothScan = await Permission.bluetoothScan.status;
      final bluetoothConnect = await Permission.bluetoothConnect.status;
      final location = await Permission.location.status;

      return bluetoothScan.isGranted &&
          bluetoothConnect.isGranted &&
          location.isGranted;
    } else if (Platform.isIOS) {
      final bluetooth = await Permission.bluetooth.status;
      final location = await Permission.location.status;
      return bluetooth.isGranted && location.isGranted;
    }

    return false;
  }

  /// Request necessary Bluetooth permissions
  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      // Web handles permissions differently
      return true;
    }

    Map<Permission, PermissionStatus> statuses = {};

    if (Platform.isAndroid) {
      // Android requires multiple permissions for BLE scanning
      statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
        Permission.bluetoothAdvertise,
      ].request();
    } else if (Platform.isIOS) {
      // iOS requires Bluetooth and location permissions
      statuses = await [Permission.bluetooth, Permission.location].request();
    }

    // Check if all required permissions are granted
    return statuses.values.every((status) => status.isGranted);
  }

  /// Check if Bluetooth adapter is available
  Future<bool> isBluetoothAvailable() async {
    if (kIsWeb) {
      return false; // Web doesn't support native Bluetooth
    }

    if (_ble == null) return false;

    try {
      // Check Bluetooth status via permission
      if (Platform.isAndroid) {
        final status = await Permission.bluetooth.status;
        return status.isGranted;
      }
      if (Platform.isIOS) {
        final status = await Permission.bluetooth.status;
        return status.isGranted;
      }
      return true;
    } catch (e) {
      debugPrint('Error checking Bluetooth availability: $e');
      return false;
    }
  }

  /// Check if Bluetooth is currently turned on
  /// Returns true if Bluetooth is powered on and available
  Future<bool> isBluetoothOn() async {
    if (kIsWeb) {
      // For web, we can't reliably detect Bluetooth state without triggering a scan
      // The Web Bluetooth API requires explicit user permission to access Bluetooth
      // We'll return false and let the user proceed with onboarding
      // The actual Bluetooth functionality will work when the user runs a device scan
      return false;
    }

    try {
      // Check if Bluetooth adapter is on using flutter_blue_plus
      final bluetoothState = await flutter_blue_plus.FlutterBluePlus.adapterState.first;
      return bluetoothState == flutter_blue_plus.BluetoothAdapterState.on;
    } catch (e) {
      debugPrint('Error checking if Bluetooth is on: $e');
      // Fallback to checking permissions
      return await checkPermissions();
    }
  }

  /// Open device Bluetooth settings
  /// Returns true if settings were opened successfully
  Future<bool> openBluetoothSettings() async {
    try {
      // Use permission_handler to open app settings
      // This will open the app's settings page where Bluetooth can be enabled
      final opened = await openAppSettings();
      return opened;
    } catch (e) {
      debugPrint('Error opening Bluetooth settings: $e');
      return false;
    }
  }

  /// Start scanning for nearby Bluetooth LE devices
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
    List<Uuid>? services,
  }) async {
    if (kIsWeb) {
      debugPrint('Bluetooth scanning not supported on web');
      return;
    }

    if (_ble == null) {
      debugPrint('Bluetooth service not initialized');
      return;
    }

    // Clear previous discoveries
    _discoveredDevices.clear();

    // Notify scanning has started
    _isScanningController.add(true);

    try {
      // Subscribe to scan results using flutter_reactive_ble
      _scanSubscription = _ble!
          .scanForDevices(
            withServices: services ?? [Uuid.parse(BLEConstants.serviceUuid)],
            scanMode: ScanMode.lowLatency,
          )
          .listen(
            (device) {
              // Create our wrapper object
              final bluetoothDevice = BluetoothDevice.fromReactiveDevice(
                device,
              );

              // Update or add device to cache
              _discoveredDevices[device.id] = bluetoothDevice;

              // Emit device discovery event
              _deviceDiscoverdController.add(bluetoothDevice);
            },
            onError: (error) {
              debugPrint('Error during device scan: $error');
              stopScan();
            },
          );

      // Set timeout to stop scanning
      if (timeout.inMilliseconds > 0) {
        Future.delayed(timeout, () {
          if (_isScanningController.hasListener) {
            stopScan();
          }
        });
      }
    } catch (e) {
      debugPrint('Error starting scan: $e');
      _isScanningController.add(false);
    }
  }

  /// Stop scanning for devices
  Future<void> stopScan() async {
    if (_scanSubscription != null) {
      await _scanSubscription?.cancel();
      _scanSubscription = null;
    }
    _isScanningController.add(false);
  }

  /// Connect to a discovered device
  Future<void> connectToDevice(String deviceId) async {
    if (_ble == null || kIsWeb) return;

    try {
      _connectionSubscription = _ble!
          .connectToAdvertisingDevice(
            id: deviceId,
            prescanDuration: const Duration(seconds: 10),
            withServices: [Uuid.parse(BLEConstants.serviceUuid)],
          )
          .listen(
            (update) {
              _handleConnectionStateUpdate(update);
            },
            onError: (error) {
              debugPrint('Error connecting to device: $error');
            },
          );
    } catch (e) {
      debugPrint('Error initiating connection: $e');
    }
  }

  /// Disconnect from a device
  Future<void> disconnectFromDevice(String deviceId) async {
    if (_ble == null || kIsWeb) return;

    try {
      // Use the connection subscription to disconnect
      _connectionSubscription?.cancel();
      _connectionSubscription = null;
      debugPrint('Disconnected from device: $deviceId');
    } catch (e) {
      debugPrint('Error disconnecting from device: $e');
    }
  }

  /// Write data to a characteristic
  Future<void> writeCharacteristic({
    required String deviceId,
    required String characteristicId,
    required List<int> value,
    required String serviceUuid,
  }) async {
    if (_ble == null || kIsWeb) return;

    try {
      final characteristic = QualifiedCharacteristic(
        deviceId: deviceId,
        serviceId: Uuid.parse(serviceUuid),
        characteristicId: Uuid.parse(characteristicId),
      );

      await _ble!.writeCharacteristicWithResponse(characteristic, value: value);
    } catch (e) {
      debugPrint('Error writing to characteristic: $e');
    }
  }

  /// Read data from a characteristic
  Future<List<int>> readCharacteristic({
    required String deviceId,
    required String characteristicId,
    required String serviceUuid,
  }) async {
    if (_ble == null || kIsWeb) return [];

    try {
      final characteristic = QualifiedCharacteristic(
        deviceId: deviceId,
        serviceId: Uuid.parse(serviceUuid),
        characteristicId: Uuid.parse(characteristicId),
      );

      return await _ble!.readCharacteristic(characteristic);
    } catch (e) {
      debugPrint('Error reading from characteristic: $e');
      return [];
    }
  }

  /// Subscribe to characteristic notifications
  Stream<List<int>> subscribeToCharacteristic({
    required String deviceId,
    required String characteristicId,
    required String serviceUuid,
  }) {
    if (_ble == null || kIsWeb) {
      return Stream<List<int>>.empty();
    }

    final characteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: Uuid.parse(serviceUuid),
      characteristicId: Uuid.parse(characteristicId),
    );

    return _ble!.subscribeToCharacteristic(characteristic);
  }

  /// Clean up resources
  Future<void> dispose() async {
    await stopScan();
    await _connectionSubscription?.cancel();
    await _deviceDiscoverdController.close();
    await _connectionStateController.close();
    await _isScanningController.close();
  }
}
