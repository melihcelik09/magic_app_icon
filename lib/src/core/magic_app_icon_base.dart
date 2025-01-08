import 'dart:async';

import 'package:flutter/services.dart';

import '../models/app_icon.dart';

/// String'den AppIcon'a dönüşüm için extension
extension StringToAppIcon on String {
  /// String'i AppIcon'a dönüştür
  AppIcon toAppIcon() => AppIcon(name: this, path: 'assets/icons/$this.png');
}

/// Magic App Icon için ana sınıf
class MagicAppIcon {
  static const MethodChannel _channel = MethodChannel('magic_app_icon');

  /// Mevcut ikonu al
  static Future<AppIcon> getCurrentIcon() async {
    final String? iconName = await _channel.invokeMethod('getCurrentIcon');
    return (iconName ?? 'default').toAppIcon();
  }

  /// İkonu değiştir
  static Future<void> changeIcon(AppIcon icon) async {
    await _channel.invokeMethod('changeIcon', {'iconName': icon.name});
  }

  /// İkon değiştirme özelliğinin desteklenip desteklenmediğini kontrol et
  static Future<bool> isSupported() async {
    return await _channel.invokeMethod('isSupported') ?? false;
  }
}
