import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:logging/logging.dart';

import '../config/magic_app_icon_config.dart';
import '../exceptions/magic_app_icon_exception.dart';
import '../utils/icon_reporter.dart';
import '../utils/translations.dart';
import '../utils/cli_utils.dart';

/// İkon üretimi için yardımcı sınıf
class IconGenerator {
  final MagicAppIconConfig config;
  final String _lang;
  final bool _showReport;
  final _logger = Logger('IconGenerator');

  IconGenerator(
    this.config, {
    String lang = 'en',
    bool showReport = false,
  })  : _lang = lang,
        _showReport = showReport;

  /// İkonları üret
  Future<void> generate() async {
    await _validateIcons();
    await _generateAndroidIcons();
    await _generateIOSIcons();
    await _generateReport();
  }

  /// İkonları validate et
  Future<void> _validateIcons() async {
    // Varsayılan ikonu validate et
    await _validateIcon(config.defaultIcon);

    // Alternatif ikonları validate et
    for (final entry in config.alternateIcons.entries) {
      await _validateIcon(entry.value);
    }
  }

  /// İkonu validate et
  Future<void> _validateIcon(String iconPath) async {
    final file = File(iconPath);
    if (!await file.exists()) {
      throw MagicAppIconException(
        'FILE_NOT_FOUND',
        Translations.get('error_file_not_found', _lang),
        iconPath,
      );
    }

    final bytes = await File(iconPath).readAsBytes();
    final image = img.decodePng(bytes);
    if (image == null) {
      throw MagicAppIconException(
        'NOT_PNG',
        Translations.get('error_not_png', _lang),
        iconPath,
      );
    }

    if (image.width != image.height) {
      throw MagicAppIconException(
        'NOT_SQUARE',
        Translations.get('error_not_square', _lang),
        iconPath,
      );
    }

    if (!image.hasAlpha) {
      if (config.strictAlphaCheck) {
        throw MagicAppIconException(
          'NO_TRANSPARENCY',
          Translations.get('error_no_transparency', _lang),
          iconPath,
        );
      } else {
        CliUtils.printWarning(Translations.get('warning_no_transparency', _lang));
      }
    }

    if (bytes.length > 1024 * 1024) {
      // 1MB
      throw MagicAppIconException(
        'INVALID_SIZE',
        Translations.get('error_invalid_size', _lang),
        iconPath,
      );
    }
  }

  /// Android ikonlarını üret
  Future<void> _generateAndroidIcons() async {
    final androidDir =
        Directory('${config.outputDir}/android/app/src/main/res');
    if (!await androidDir.exists()) {
      await androidDir.create(recursive: true);
    }

    // Varsayılan ikonu üret
    await _generateAndroidIcon(config.defaultIcon, 'ic_launcher');

    // Alternatif ikonları üret
    for (final entry in config.alternateIcons.entries) {
      await _generateAndroidIcon(
          entry.value, 'ic_launcher_${entry.key.toLowerCase()}');
    }
  }

  /// iOS ikonlarını üret
  Future<void> _generateIOSIcons() async {
    final iosDir = Directory('${config.outputDir}/ios/Runner');
    if (!await iosDir.exists()) {
      await iosDir.create(recursive: true);
    }

    // Eski alternatif iconları temizle
    final assetsDir = Directory('${iosDir.path}/Assets.xcassets');
    if (await assetsDir.exists()) {
      final entries = await assetsDir.list().toList();
      for (var entry in entries) {
        if (entry is Directory && 
            entry.path.contains('AppIcon-') && 
            entry.path.endsWith('.appiconset')) {
          await entry.delete(recursive: true);
        }
      }
    } else {
      await assetsDir.create(recursive: true);
    }

    // Varsayılan icon
    final defaultIconDir = Directory('${assetsDir.path}/AppIcon.appiconset');
    if (!await defaultIconDir.exists()) {
      await defaultIconDir.create(recursive: true);
    }
    await _generateIOSIcon(
      config.defaultIcon,
      defaultIconDir.path,
      'AppIcon',
    );

    // Alternatif iconlar için ayrı klasör
    final alternateIconsDir = Directory('${iosDir.path}/Alternate Icons');
    if (await alternateIconsDir.exists()) {
      await alternateIconsDir.delete(recursive: true);
    }
    await alternateIconsDir.create(recursive: true);

    // Alternatif iconlar
    for (final entry in config.alternateIcons.entries) {
      final iconDir = Directory('${alternateIconsDir.path}/${entry.key}');
      if (!await iconDir.exists()) {
        await iconDir.create(recursive: true);
      }
      await _generateIOSIcon(
        entry.value,
        iconDir.path,
        'AppIcon-${entry.key.toLowerCase()}',
      );
    }
  }

  /// Android ikonu üret
  Future<void> _generateAndroidIcon(String sourcePath, String iconName) async {
    final sourceImage = img.decodePng(await File(sourcePath).readAsBytes());
    if (sourceImage == null) {
      throw MagicAppIconException(
          'INVALID_IMAGE', 'İkon dosyası okunamadı: $sourcePath');
    }

    final densities = {
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    };

    for (final entry in densities.entries) {
      final density = entry.key;
      final size = entry.value;
      final resized = img.copyResize(sourceImage, width: size, height: size);

      final targetDir = Directory(
          '${config.outputDir}/android/app/src/main/res/mipmap-$density');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final targetPath = '${targetDir.path}/$iconName.png';
      await File(targetPath).writeAsBytes(img.encodePng(resized));
    }
  }

  /// iOS için icon dosyalarını oluştur
  Future<void> _generateIOSIcon(
      String iconPath, String directory, String iconName) async {
    final image = img.decodePng(await File(iconPath).readAsBytes());
    if (image == null) return;

    // Tüm boyutlar için icon dosyalarını oluştur
    final sizeConfigs = {
      '20x20': {'scales': [1, 2, 3], 'idiom': 'universal'},
      '29x29': {'scales': [1, 2, 3], 'idiom': 'universal'},
      '40x40': {'scales': [1, 2, 3], 'idiom': 'universal'},
      '60x60': {'scales': [2, 3], 'idiom': 'iphone'},
      '76x76': {'scales': [1, 2], 'idiom': 'ipad'},
      '83.5x83.5': {'scales': [2], 'idiom': 'ipad', 'exactSize': 167},
      '1024x1024': {'scales': [1], 'idiom': 'ios-marketing'},
    };

    for (final size in sizeConfigs.keys) {
      final config = sizeConfigs[size]!;
      final dimensions = size.split('x').map((e) => double.parse(e)).toList();
      
      for (final scale in config['scales'] as List<int>) {
        int scaledWidth;
        int scaledHeight;
        
        if (config.containsKey('exactSize')) {
          // Eğer tam boyut belirtilmişse onu kullan
          scaledWidth = scaledHeight = config['exactSize'] as int;
        } else {
          // Normal hesaplama
          scaledWidth = (dimensions[0] * scale).toInt();
          scaledHeight = (dimensions[1] * scale).toInt();
        }

        final resizedImage = img.copyResize(
          image,
          width: scaledWidth,
          height: scaledHeight,
          interpolation: img.Interpolation.linear,
        );

        final iconFile = File('$directory/$iconName-$size@${scale}x.png');
        await iconFile.writeAsBytes(img.encodePng(resizedImage));
      }
    }

    // Contents.json dosyasını oluştur
    final contents = {
      "images": [
        for (final size in sizeConfigs.entries)
          for (final scale in size.value['scales'] as List<int>)
            {
              "size": size.key,
              "idiom": size.value['idiom'],
              "filename": "$iconName-${size.key}@${scale}x.png",
              "scale": "${scale}x"
            }
      ],
      "info": {"version": 1, "author": "xcode"}
    };

    final contentsFile = File('$directory/Contents.json');
    await contentsFile.writeAsString(json.encode(contents));
  }

  /// Rapor oluştur
  Future<void> _generateReport() async {
    if (!_showReport) return; // Rapor gösterimi kapalıysa çık

    if (config.android) {
      final androidReport = await IconReporter.generateReport(
        defaultIcon: config.defaultIcon,
        alternateIcons: config.alternateIcons,
        outputDir: '${config.outputDir}/android',
        isIOS: false,
        lang: _lang,
      );
      _logger.info('\n${Translations.get('android_report', _lang)}:');
      _logger.info(androidReport);
    }

    if (config.ios) {
      final iosReport = await IconReporter.generateReport(
        defaultIcon: config.defaultIcon,
        alternateIcons: config.alternateIcons,
        outputDir: '${config.outputDir}/ios',
        isIOS: true,
        lang: _lang,
      );
      _logger.info('\n${Translations.get('ios_report', _lang)}:');
      _logger.info(iosReport);
    }
  }
}
