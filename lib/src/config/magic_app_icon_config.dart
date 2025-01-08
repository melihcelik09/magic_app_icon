import 'dart:io';
import 'package:yaml/yaml.dart';
import '../exceptions/magic_app_icon_exception.dart';

/// Ana konfigürasyon sınıfı
class MagicAppIconConfig {
  final String defaultIcon;
  final Map<String, String> alternateIcons;
  final String outputDir;
  final bool android;
  final bool ios;
  final bool strictAlphaCheck;

  const MagicAppIconConfig({
    required this.defaultIcon,
    required this.alternateIcons,
    required this.outputDir,
    this.android = true,
    this.ios = true,
    this.strictAlphaCheck = false,
  });

  /// YAML'dan konfigürasyon oluştur
  factory MagicAppIconConfig.fromYaml(
    YamlMap yaml, {
    String outputDir = '.',
    bool android = true,
    bool ios = true,
  }) {
    final defaultIcon = yaml['default_icon'] as String?;
    if (defaultIcon == null) {
      throw MagicAppIconException(
        'MISSING_DEFAULT_ICON',
        'Default icon is required',
      );
    }

    final alternateIcons = <String, String>{};
    final alternateIconsYaml = yaml['alternate_icons'] as YamlMap?;
    if (alternateIconsYaml != null) {
      for (final entry in alternateIconsYaml.entries) {
        alternateIcons[entry.key.toString()] = entry.value.toString();
      }
    }

    return MagicAppIconConfig(
      defaultIcon: defaultIcon,
      alternateIcons: alternateIcons,
      outputDir: outputDir,
      android: yaml['android'] as bool? ?? android,
      ios: yaml['ios'] as bool? ?? ios,
      strictAlphaCheck: yaml['strict_alpha_check'] as bool? ?? false,
    );
  }

  /// pubspec.yaml'dan konfigürasyonu yükle
  static Future<MagicAppIconConfig> load({
    String? configPath,
    bool android = true,
    bool ios = true,
    String? outputDir,
    bool strictAlphaCheck = false,
  }) async {
    try {
      final configFile = File(configPath ?? 'pubspec.yaml');
      if (!await configFile.exists()) {
        throw MagicAppIconException(
          'CONFIG_NOT_FOUND',
          '$configPath dosyası bulunamadı'
        );
      }

      final content = await configFile.readAsString();
      final yaml = loadYaml(content) as YamlMap;
      
      if (!yaml.containsKey('magic_app_icon')) {
        throw MagicAppIconException(
          'INVALID_CONFIG',
          '$configPath içinde magic_app_icon konfigürasyonu bulunamadı'
        );
      }

      final magicConfig = yaml['magic_app_icon'] as YamlMap;
      final config = MagicAppIconConfig.fromYaml(magicConfig);
      await _validateConfig(config);
      return config;
    } catch (e) {
      if (e is MagicAppIconException) rethrow;
      throw MagicAppIconException(
        'CONFIG_ERROR',
        'Konfigürasyon yükleme hatası: $e'
      );
    }
  }

  /// Konfigürasyonu doğrula
  static Future<void> _validateConfig(MagicAppIconConfig config) async {
    // Varsayılan ikon kontrolü
    if (!await File(config.defaultIcon).exists()) {
      throw MagicAppIconException(
        'MISSING_DEFAULT_ICON',
        'Varsayılan ikon bulunamadı: ${config.defaultIcon}'
      );
    }

    // Alternatif ikonların kontrolü
    for (final entry in config.alternateIcons.entries) {
      if (!await File(entry.value).exists()) {
        throw MagicAppIconException(
          'MISSING_ALTERNATE_ICON',
          'Alternatif ikon bulunamadı: ${entry.value} (${entry.key})'
        );
      }
    }
  }
} 