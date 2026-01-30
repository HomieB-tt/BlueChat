import 'package:flutter/material.dart';
import '../presentation/settings/settings.dart';
import '../presentation/chat_conversation/chat_conversation.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/device_discovery/device_discovery.dart';
import '../presentation/permission_request/permission_request.dart';
import '../presentation/bluetooth_onboarding/bluetooth_onboarding.dart';
import '../presentation/home_screen/home_screen.dart';

class AppRoutes {
  // TODO: Addition of other routes here
  static const String initial = '/';
  static const String settings = '/settings';
  static const String chatConversation = '/chat-conversation';
  static const String splash = '/splash-screen';
  static const String deviceDiscovery = '/device-discovery';
  static const String permissionRequest = '/permission-request';
  static const String bluetoothOnboarding = '/bluetooth-onboarding';
  static const String homeScreen = '/home-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    settings: (context) => const Settings(),
    chatConversation: (context) => const ChatConversation(),
    splash: (context) => const SplashScreen(),
    deviceDiscovery: (context) => const DeviceDiscovery(),
    permissionRequest: (context) => const PermissionRequest(),
    bluetoothOnboarding: (context) => const BluetoothOnboarding(),
    homeScreen: (context) => const HomeScreen(),
    // TODO: Addition of other routes here
  };
}
