import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../widgets/custom_bottom_bar.dart';
import '../device_discovery/device_discovery.dart';
import '../messages_view/messages_view.dart';
import '../settings/settings.dart';
import '../../services/bluetooth_service.dart';

/// Home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final BluetoothService _bluetoothService = BluetoothService();

  @override
  void initState() {
    super.initState();
    _initializeBluetoothCheck();
  }

  /// Check Bluetooth status on app start and show toast if off
  Future<void> _initializeBluetoothCheck() async {
    // Initialize Bluetooth service first
    await _bluetoothService.initialize();
    
    // Check if Bluetooth is on
    final isBluetoothOn = await _bluetoothService.isBluetoothOn();
    
    if (mounted && !isBluetoothOn) {
      // Show toast message to enable Bluetooth
      Fluttertoast.showToast(
        msg: 'Please enable Bluetooth to scan nearby devices and connect',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 4,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [DeviceDiscovery(), MessagesView(), Settings()],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        messagesBadgeCount: 0,
        devicesBadgeCount: 0,
      ),
    );
  }
}
