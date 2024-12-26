import 'package:flutter/services.dart';

class DynamicIconChanger {
  static const String _channelName = 'dynamic_icon_changer';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static Future<void> changeIcon(String iconName) async {
    try {
      await _channel.invokeMethod('updateIcon', {'iconName': iconName});
    } on PlatformException catch (e) {
      throw ('Failed to change icon: ${e.message}');
    }
  }
}
