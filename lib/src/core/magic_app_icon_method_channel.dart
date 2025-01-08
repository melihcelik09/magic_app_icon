import 'package:flutter/services.dart';
import 'magic_app_icon_platform_interface.dart';

/// Method channel implementation of [MagicAppIconPlatform].
class MethodChannelMagicAppIcon extends MagicAppIconPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('magic_app_icon');

  @override
  Future<bool> changeIcon(String iconName) async {
    try {
      final bool result = await methodChannel.invokeMethod('changeIcon', {
        'iconName': iconName,
      });
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to change icon: ${e.message}');
    }
  }

  @override
  Future<String?> getCurrentIcon() async {
    try {
      final String? result = await methodChannel.invokeMethod('getCurrentIcon');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to get current icon: ${e.message}');
    }
  }
} 