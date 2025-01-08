import '../utils/translations.dart';

/// Özel hata sınıfı
class MagicAppIconException implements Exception {
  final String code;
  final String message;
  final String? details;

  MagicAppIconException(this.code, this.message, [this.details]);

  @override
  String toString() => '$code: $message';

  /// Hata mesajı oluştur
  static MagicAppIconException noMainIntentFilter(String lang) {
    return MagicAppIconException(
      'NO_MAIN_INTENT_FILTER',
      Translations.get('error_no_main_intent_filter', lang),
    );
  }

  /// Konfigürasyon bulunamadı hatası
  static MagicAppIconException configNotFound(String path, String lang) {
    return MagicAppIconException(
      'CONFIG_NOT_FOUND',
      Translations.get('error_config_not_found', lang),
      path,
    );
  }

  /// Geçersiz konfigürasyon hatası
  static MagicAppIconException invalidConfig(String path, String lang) {
    return MagicAppIconException(
      'INVALID_CONFIG',
      Translations.get('error_invalid_config', lang),
      path,
    );
  }

  /// Konfigürasyon yükleme hatası
  static MagicAppIconException configError(String error, String lang) {
    return MagicAppIconException(
      'CONFIG_ERROR',
      '${Translations.get('error_config_error', lang)}: $error',
    );
  }

  /// Info.plist bulunamadı hatası
  static MagicAppIconException plistNotFound(String lang) {
    return MagicAppIconException(
      'PLIST_NOT_FOUND',
      Translations.get('error_plist_not_found', lang),
    );
  }
} 