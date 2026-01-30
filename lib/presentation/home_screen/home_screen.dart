import 'package:flutter/material.dart';

import '../../widgets/custom_bottom_bar.dart';
import '../device_discovery/device_discovery.dart';
import '../messages_view/messages_view.dart';
import '../settings/settings.dart';

/// Home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

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
