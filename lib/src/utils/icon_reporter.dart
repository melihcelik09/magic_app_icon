import 'dart:io';

import 'package:image/image.dart' as img;

import 'translations.dart';

/// İkon üretim raporu için yardımcı sınıf
class IconReporter {
  /// Rapor oluştur
  static Future<String> generateReport({
    required String defaultIcon,
    required Map<String, String> alternateIcons,
    required String outputDir,
    required bool isIOS,
    String lang = 'en',
  }) async {
    t(String key) => Translations.get(key, lang);

    final buffer = StringBuffer();
    buffer.writeln('📊 ${t('report_title')}');
    buffer.writeln('====================\n');

    buffer.writeln('📱 ${t('platform')}: ${isIOS ? 'iOS' : 'Android'}');
    buffer.writeln('------------------\n');

    // Varsayılan ikon raporu
    buffer.writeln('🎨 ${t('default_icon')}');
    buffer.writeln('-----------------');
    await _writeIconInfo(buffer, defaultIcon, t);
    buffer.writeln();

    // Alternatif ikonlar raporu
    buffer.writeln('🔄 ${t('alternate_icons')}');
    buffer.writeln('------------------');
    for (final entry in alternateIcons.entries) {
      buffer.writeln('${entry.key}:');
      await _writeIconInfo(buffer, entry.value, t, indent: '  ');
    }
    buffer.writeln();

    // Çıktı dizini raporu
    buffer.writeln('📁 ${t('output_directory')}');
    buffer.writeln('--------------');
    await _writeOutputInfo(buffer, outputDir, isIOS, t);
    buffer.writeln();

    // Öneriler
    buffer.writeln('💡 ${t('suggestions')}');
    buffer.writeln('---------');
    buffer.writeln('✅ ${t('no_suggestions')}');

    return buffer.toString();
  }

  /// İkon analizi
  static Future<void> _writeIconInfo(
    StringBuffer buffer,
    String iconPath,
    Function(String) t, {
    String indent = '',
  }) async {
    final file = File(iconPath);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      final image = img.decodePng(bytes);
      if (image != null) {
        buffer
            .writeln('$indent📏 ${t('size')}: ${image.width}x${image.height}');
        buffer.writeln(
            '$indent💾 ${t('file_size')}: ${(bytes.length / 1024).toStringAsFixed(2)} KB');
        buffer.writeln('$indent🎯 ${t('format')}: png');
        buffer.writeln(
            '$indent🔍 ${t('alpha_channel')}: ${image.hasAlpha ? t('yes') : t('no')}');
      }
    }
  }

  /// Çıktı dizini analizi
  static Future<void> _writeOutputInfo(
    StringBuffer buffer,
    String outputDir,
    bool isIOS,
    Function(String) t,
  ) async {
    final dir = Directory(outputDir);
    if (await dir.exists()) {
      int fileCount = 0;
      int totalSize = 0;
      Map<String, int> densityCount = {};

      await for (final entity in dir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.png')) {
          fileCount++;
          totalSize += await entity.length();

          if (isIOS) {
            final name = entity.path.split('/').last;
            if (name.contains('@2x')) {
              densityCount['@2x'] = (densityCount['@2x'] ?? 0) + 1;
            } else if (name.contains('@3x')) {
              densityCount['@3x'] = (densityCount['@3x'] ?? 0) + 1;
            }
          }
        }
      }

      buffer.writeln('📁 ${t('total_files')}: $fileCount');
      buffer.writeln(
          '💾 ${t('total_size')}: ${(totalSize / 1024).toStringAsFixed(2)} KB');
      buffer.writeln('📍 ${t('location')}: $outputDir');

      if (isIOS && densityCount.isNotEmpty) {
        buffer.writeln('📱 ${t('density_distribution')}:');
        for (final entry in densityCount.entries) {
          buffer.writeln('   ${entry.key}: ${entry.value} ${t('files')}');
        }
      }
    }
  }
}
