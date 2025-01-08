// ignore_for_file: type=lint

import 'package:magic_app_icon/src/models/app_icon.dart';

part 'app_icons.g.dart';

/// Uygulama ikonları için yardımcı sınıf
abstract class AppIcons {
  /// Singleton instance
  static AppIcons? _instance;
  
  // Avoid self instance
  AppIcons._();
  
  /// Instance'a erişim
  static AppIcons get instance => _instance ??= _AppIconsImpl();

  /// Varsayılan ikon
  AppIcon get defaultIcon;

  /// Tüm ikonları döndür
  List<AppIcon> get all;
}
