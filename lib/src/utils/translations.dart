/// Helper class for managing translations
class Translations {
  static const Map<String, Map<String, String>> _translations = {
    'tr': {
      'help': 'Yardım mesajını göster',
      'version': 'Versiyon bilgisini göster',
      'quiet': 'Sessiz mod (log gösterme)',
      'check': 'Sadece konfigürasyonu doğrula, üretim yapma',
      'report': 'Detaylı rapor göster',
      'platform': 'Hedef platform (android, ios veya all)',
      'config': 'Özel konfigürasyon dosyası yolu',
      'output_dir': 'İkonların üretileceği dizin',
      'lang': 'Dil seçimi (tr, en)',
      'description':
          '''Dinamik uygulama ikonu değiştirme özelliği için gerekli ikonları ve platform 
konfigürasyonlarını oluşturan araç.''',
      'usage': 'Kullanım',
      'options': 'Seçenekler',
      'examples': 'Örnekler',
      'configuration': 'Konfigürasyon',
      'note': 'Not',
      'all_platforms': 'Tüm platformlar için ikon üret',
      'android_only': 'Sadece Android için ikon üret',
      'ios_only': 'Sadece iOS için ikon üret',
      'validate_config': 'Konfigürasyonu doğrula',
      'custom_config': 'Özel konfigürasyon dosyası kullan',
      'custom_output': 'Özel çıktı dizini belirt',
      'quiet_mode': 'Sessiz modda çalıştır',
      'default_icon': 'Varsayılan ikon',
      'alternate_icons': 'Alternatif ikonlar',
      'red_icon': 'Kırmızı ikon',
      'blue_icon': 'Mavi ikon',
      'note_format':
          'İkon dosyaları PNG formatında ve şeffaf arka planlı olmalı',
      'note_sizes': 'Önerilen boyutlar',
      'note_square': 'Her ikon kare olmalı ve alpha kanalı içermeli',
      'note_size': 'Maksimum dosya boyutu: 1MB',
      'loading_config': 'Konfigürasyon yükleniyor...',
      'config_valid': 'Konfigürasyon geçerli',
      'generating_icons': 'İkonlar üretiliyor...',
      'updating_configs': 'Platform konfigürasyonları güncelleniyor...',
      'completed': 'İşlem tamamlandı!',
      'error_config_not_found': 'Konfigürasyon dosyası bulunamadı',
      'error_invalid_config':
          'Konfigürasyon dosyasında "magic_app_icon" bölümü bulunamadı',
      'error_config_error': 'Konfigürasyon yükleme hatası',
      'error_no_main_intent_filter':
          'Activity-alias içinde MAIN intent-filter bulunamadı',
      'error_plist_not_found': 'Info.plist dosyası bulunamadı',
      'error_unexpected': 'Beklenmeyen hata',
      'error_no_transparency':
          'İkon dosyası alpha kanalı (şeffaflık) içermiyor. iOS ve Android\'de düzgün çalışması için ikonların şeffaf arka plana sahip olması gerekiyor.',
      'error_invalid_size': 'İkon dosyası boyutu çok büyük',
      'error_not_square': 'İkon dosyası kare olmalı',
      'error_not_png': 'İkon dosyası PNG formatında olmalı',
      'error_file_not_found': 'İkon dosyası bulunamadı',
      'warning_no_transparency':
          'Uyarı: İkon dosyası şeffaf arka plan içermiyor. Bu, bazı platformlarda görüntüleme sorunlarına yol açabilir.',
      'default': 'varsayılan',
      'location': 'Konum',
      'note_transparency':
          'Şeffaf arka plan (alpha kanalı) iOS ve Android\'de dinamik ikon değişimi için önerilir. Zorunlu kontrol için pubspec.yaml\'da strict_alpha_check: true yapın.',
      'strict_mode': 'Katı mod (şeffaflık kontrolünü zorunlu kıl)',
      'report_title': 'İkon Üretim Raporu',
      'android_report': 'Android İkon Raporu',
      'ios_report': 'iOS İkon Raporu',
      'size': 'Boyut',
      'file_size': 'Dosya boyutu',
      'format': 'Format',
      'alpha_channel': 'Alpha kanalı',
      'yes': 'Var',
      'no': 'Yok',
      'total_files': 'Toplam dosya sayısı',
      'total_size': 'Toplam boyut',
      'density_distribution': 'Density dağılımı',
      'files': 'adet',
      'output_directory': 'Çıktı Dizini',
      'suggestions': 'Öneriler',
      'no_suggestions': 'Herhangi bir optimizasyon önerisi yok.',
      'creating_app_icons': 'AppIcons sınıfı oluşturuluyor...',
      'running_build_runner': 'Build runner çalıştırılıyor...',
    },
    'en': {
      'help': 'Show help message',
      'version': 'Show version information',
      'quiet': 'Quiet mode (no logging)',
      'check': 'Only validate configuration, no generation',
      'report': 'Show detailed report',
      'platform': 'Target platform (android, ios or all)',
      'config': 'Custom configuration file path',
      'output_dir': 'Output directory for icons',
      'lang': 'Language selection (tr, en)',
      'description':
          '''A tool for generating icons and platform configurations for dynamic app icon 
changing feature.''',
      'usage': 'Usage',
      'options': 'Options',
      'examples': 'Examples',
      'configuration': 'Configuration',
      'note': 'Note',
      'all_platforms': 'Generate icons for all platforms',
      'android_only': 'Generate icons for Android only',
      'ios_only': 'Generate icons for iOS only',
      'validate_config': 'Validate configuration',
      'custom_config': 'Use custom configuration file',
      'custom_output': 'Specify custom output directory',
      'quiet_mode': 'Run in quiet mode',
      'default_icon': 'Default icon',
      'alternate_icons': 'Alternate icons',
      'red_icon': 'Red icon',
      'blue_icon': 'Blue icon',
      'note_format':
          'Icon files must be in PNG format with transparent background',
      'note_sizes': 'Recommended sizes',
      'note_square': 'Each icon must be square and contain alpha channel',
      'note_size': 'Maximum file size: 1MB',
      'loading_config': 'Loading configuration...',
      'config_valid': 'Configuration is valid',
      'generating_icons': 'Generating icons...',
      'updating_configs': 'Updating platform configurations...',
      'completed': 'Process completed!',
      'error_config_not_found': 'Configuration file not found',
      'error_invalid_config':
          'Configuration file does not contain "magic_app_icon" section',
      'error_config_error': 'Configuration load error',
      'error_no_main_intent_filter':
          'MAIN intent-filter not found in activity-alias',
      'error_plist_not_found': 'Info.plist file not found',
      'error_unexpected': 'Unexpected error',
      'error_no_transparency':
          'Icon file does not contain alpha channel (transparency). Icons must have transparent background to work properly on iOS and Android.',
      'error_invalid_size': 'Icon file size is too large',
      'error_not_square': 'Icon file must be square',
      'error_not_png': 'Icon file must be PNG format',
      'error_file_not_found': 'Icon file not found',
      'warning_no_transparency':
          'Warning: Icon file does not contain transparent background. This might cause display issues on some platforms.',
      'default': 'default',
      'location': 'Location',
      'note_transparency':
          'Transparent background (alpha channel) is recommended for dynamic icon changing on iOS and Android. Set strict_alpha_check: true in pubspec.yaml to enforce this check.',
      'strict_mode': 'Strict mode (enforce transparency check)',
      'report_title': 'Icon Generation Report',
      'android_report': 'Android Icon Report',
      'ios_report': 'iOS Icon Report',
      'size': 'Size',
      'file_size': 'File size',
      'format': 'Format',
      'alpha_channel': 'Alpha channel',
      'yes': 'Yes',
      'no': 'No',
      'total_files': 'Total files',
      'total_size': 'Total size',
      'density_distribution': 'Density distribution',
      'files': 'files',
      'output_directory': 'Output Directory',
      'suggestions': 'Suggestions',
      'no_suggestions': 'No optimization suggestions.',
      'creating_app_icons': 'Creating AppIcons class...',
      'running_build_runner': 'Running build runner...',
    },
  };

  /// Get translation for a key
  static String get(String key, String lang) {
    return _translations[lang]?[key] ?? key;
  }
}
