import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

import '../exceptions/magic_app_icon_exception.dart';
import 'cli_utils.dart';

/// İkon doğrulama için yardımcı sınıf
class IconValidator {
  /// İkonu doğrula
  static Future<void> validate(String iconPath, {required bool isIOS}) async {
    CliUtils.printInfo('İkon doğrulama başlatılıyor...');
    var currentCheck = 0;
    const totalChecks = 4;

    // Dosya var mı kontrol et
    CliUtils.showDetailedProgress(
        ++currentCheck, totalChecks, 'Dosya kontrolü yapılıyor...',
        detail: 'Dosya: $iconPath');

    final file = File(iconPath);
    if (!await file.exists()) {
      throw MagicAppIconException(
        'FILE_NOT_FOUND',
        'İkon dosyası bulunamadı: $iconPath',
      );
    }

    // PNG formatında mı kontrol et
    CliUtils.showDetailedProgress(
        ++currentCheck, totalChecks, 'Format kontrolü yapılıyor...',
        detail: 'Beklenen: PNG');

    if (path.extension(iconPath).toLowerCase() != '.png') {
      throw MagicAppIconException(
        'INVALID_FORMAT',
        'İkon dosyası PNG formatında olmalı',
      );
    }

    // Dosya boyutu kontrolü
    CliUtils.showDetailedProgress(
        ++currentCheck, totalChecks, 'Dosya boyutu kontrolü yapılıyor...',
        detail: 'Maksimum: 1MB');

    final fileSize = await file.length();
    if (fileSize > 1024 * 1024) {
      // 1MB
      throw MagicAppIconException(
        'FILE_TOO_LARGE',
        'İkon dosyası çok büyük: ${(fileSize / 1024).round()} KB',
      );
    }

    // Görüntü kontrolü - paralel işlem
    CliUtils.showDetailedProgress(
        ++currentCheck, totalChecks, 'Görüntü analizi yapılıyor...',
        detail: 'Platform: ${isIOS ? "iOS" : "Android"}');

    final bytes = await file.readAsBytes();
    await _validateImageParallel(Uint8List.fromList(bytes), iconPath, isIOS);

    CliUtils.printSuccess('Doğrulama başarıyla tamamlandı!');
  }

  /// Görüntüyü paralel olarak doğrula
  static Future<void> _validateImageParallel(Uint8List bytes, String path, bool isIOS) async {
    await Isolate.run(() async {
      final image = img.decodePng(bytes);
      if (image == null) {
        throw MagicAppIconException(
          'INVALID_IMAGE',
          'İkon dosyası geçerli bir PNG değil',
        );
      }

      // İkon bilgilerini göster
      CliUtils.showIconInfo(image, path);
      CliUtils.showIconPreview(image, title: 'Doğrulanan İkon');

      // Kare kontrolü
      if (image.width != image.height) {
        throw MagicAppIconException(
          'NOT_SQUARE',
          'İkon kare olmalı',
        );
      }

      // Platform spesifik boyut kontrolü
      if (isIOS) {
        await _validateIOSIcon(image, path);
      } else {
        await _validateAndroidIcon(image, path);
      }

      // Alpha kanalı kontrolü - optimize edilmiş
      if (!await _hasAlphaOptimized(image)) {
        throw MagicAppIconException(
          'NO_TRANSPARENCY',
          'İkon dosyası alpha kanalı içermiyor',
        );
      }
    });
  }

  /// iOS ikonu doğrula
  static Future<void> _validateIOSIcon(img.Image image, String path) async {
    final filename = path.split('/').last.toLowerCase();
    final size = image.width;

    CliUtils.showDetailedProgress(1, 1, 'iOS boyut kontrolü yapılıyor...',
        detail: 'Boyut: ${size}x$size');

    if (filename.contains('@2x')) {
      if (size != 120) {
        throw MagicAppIconException(
          'INVALID_SIZE',
          '@2x ikon 120x120 piksel olmalı',
        );
      }
    } else if (filename.contains('@3x')) {
      if (size != 180) {
        throw MagicAppIconException(
          'INVALID_SIZE',
          '@3x ikon 180x180 piksel olmalı',
        );
      }
    } else {
      if (size < 120) {
        throw MagicAppIconException(
          'INVALID_SIZE',
          'İkon en az 120x120 piksel olmalı',
        );
      }
    }
  }

  /// Android ikonu doğrula
  static Future<void> _validateAndroidIcon(img.Image image, String path) async {
    final filename = path.split('/').last.toLowerCase();
    final size = image.width;

    final expectedSize = _getExpectedSize(filename);
    CliUtils.showDetailedProgress(1, 1, 'Android boyut kontrolü yapılıyor...',
        detail: expectedSize != null
            ? 'Beklenen: ${expectedSize}x$expectedSize'
            : 'Minimum: 48x48');

    if (expectedSize != null && size != expectedSize) {
      throw MagicAppIconException(
        'INVALID_SIZE',
        'İkon ${expectedSize}x$expectedSize piksel olmalı',
      );
    }

    if (size < 48) {
      throw MagicAppIconException(
        'INVALID_SIZE',
        'İkon en az 48x48 piksel olmalı',
      );
    }
  }

  /// Beklenen boyutu al
  static int? _getExpectedSize(String filename) {
    if (filename.contains('mdpi')) return 48;
    if (filename.contains('hdpi')) return 72;
    if (filename.contains('xhdpi')) return 96;
    if (filename.contains('xxhdpi')) return 144;
    if (filename.contains('xxxhdpi')) return 192;
    return null;
  }

  /// Alpha kanalı kontrolü - optimize edilmiş versiyon
  static Future<bool> _hasAlphaOptimized(img.Image image) async {
    final rowsPerChunk =
        (image.height / (Platform.numberOfProcessors - 1)).ceil();
    final chunks = <Future<bool>>[];

    for (var i = 0; i < image.height; i += rowsPerChunk) {
      final endRow = (i + rowsPerChunk).clamp(0, image.height);
      chunks.add(Isolate.run(() {
        for (var y = i; y < endRow; y++) {
          for (var x = 0; x < image.width; x++) {
            final pixel = image.getPixel(x, y);
            if (pixel.a < 255) {
              return true;
            }
          }
        }
        return false;
      }));

      // İlerlemeyi göster
      CliUtils.showDetailedProgress(
          i + rowsPerChunk, image.height, 'Alpha kanalı taranıyor...',
          detail: 'Satır ${i + 1} - $endRow');
    }

    final results = await Future.wait(chunks);
    return results.contains(true);
  }
}
