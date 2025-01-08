import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'magic_app_icon_method_channel.dart';

/// Platform interface for magic_app_icon plugin.
abstract class MagicAppIconPlatform extends PlatformInterface {
  MagicAppIconPlatform() : super(token: _token);

  static final Object _token = Object();

  static MagicAppIconPlatform _instance = MethodChannelMagicAppIcon();

  /// Platform-specific implementation of magic_app_icon.
  static MagicAppIconPlatform get instance => _instance;

  /// Platform-specific implementation should set this with their own
  /// platform-specific class that extends [MagicAppIconPlatform] when
  /// they register themselves.
  static set instance(MagicAppIconPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Changes the app icon to the specified icon name.
  Future<bool> changeIcon(String iconName) {
    throw UnimplementedError('changeIcon() has not been implemented.');
  }

  /// Gets the current icon name.
  Future<String?> getCurrentIcon() {
    throw UnimplementedError('getCurrentIcon() has not been implemented.');
  }
} 