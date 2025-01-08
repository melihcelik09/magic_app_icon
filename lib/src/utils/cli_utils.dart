import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:logging/logging.dart';

/// CLI yardımcı sınıfı
class CliUtils {
  static final _logger = Logger('CliUtils');
  
  // ANSI renk kodları
  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _blue = '\x1B[34m';
  static const _magenta = '\x1B[35m';
  static const _cyan = '\x1B[36m';
  static const _white = '\x1B[37m';
  static const _reset = '\x1B[0m';
  static const _bold = '\x1B[1m';

  // Progress bar karakterleri
  static const _progressFull = '█';
  static const _progressEmpty = '░';
  static const _tick = '✓';
  static const _cross = '✗';
  static const _warning = '⚠';
  static const _info = 'ℹ';

  /// Logger'ı yapılandır
  static void configureLogger({bool quiet = false}) {
    Logger.root.level = quiet ? Level.SEVERE : Level.INFO;
    Logger.root.onRecord.listen((record) {
      if (!quiet) {
        stdout.writeln(record.message);
      }
    });
  }

  /// Başlık yazdır
  static void printTitle(String title) {
    _logger.info('\n$_cyan╔${'═' * (title.length + 2)}╗$_reset');
    _logger.info('$_cyan║ $_yellow$title $_cyan║$_reset');
    _logger.info('$_cyan╚${'═' * (title.length + 2)}╝$_reset\n');
  }

  /// Başarı mesajı yazdır
  static void printSuccess(String message) {
    _logger.info('$_green$_tick $_bold$message$_reset');
  }

  /// Hata mesajı yazdır
  static void printError(String message) {
    _logger.severe('$_red$_cross $message$_reset');
  }

  /// Uyarı mesajı yazdır
  static void printWarning(String message) {
    _logger.warning('$_yellow$_warning $message$_reset');
  }

  /// Bilgi mesajı yazdır
  static void printInfo(String message) {
    _logger.info('$_blue$_info $message$_reset');
  }

  /// Detaylı progress bar göster
  static void showDetailedProgress(int current, int total, String message, {String? detail}) {
    const width = 30;
    final progress = (current / total * width).round();
    final percentage = (current / total * 100).toStringAsFixed(1);
    
    final bar = List.filled(progress, _progressFull).join('') +
        List.filled(width - progress, _progressEmpty).join('');
    
    final progressMessage = StringBuffer('\r');
    progressMessage.write('$_cyan$message$_reset\n');
    progressMessage.write('$_white[$bar] $_bold$percentage%$_reset');
    
    if (detail != null) {
      progressMessage.write('\n$_magenta$detail$_reset');
    }

    if (current == total) {
      _logger.info(progressMessage.toString());
      printSuccess('İşlem tamamlandı!');
    } else {
      stdout.write(progressMessage.toString());
    }
  }

  /// İkon önizlemesi göster
  static void showIconPreview(img.Image image, {String? title}) {
    const previewWidth = 20;
    const previewHeight = 10;
    
    if (title != null) {
      _logger.info('\n$_bold$title$_reset');
    }

    final resized = img.copyResize(image, 
      width: previewWidth, 
      height: previewHeight,
      interpolation: img.Interpolation.average
    );

    final buffer = StringBuffer('\n');
    buffer.writeln('$_cyan┌${'─' * (previewWidth * 2)}┐$_reset');

    for (var y = 0; y < previewHeight; y++) {
      buffer.write('$_cyan│$_reset');
      for (var x = 0; x < previewWidth; x++) {
        final pixel = resized.getPixel(x, y);
        final alpha = pixel.a;
        
        if (alpha < 128) {
          buffer.write('  '); // Transparan
        } else {
          final brightness = (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114).round();
          buffer.write(brightness > 128 ? '██' : '▒▒');
        }
      }
      buffer.writeln('$_cyan│$_reset');
    }

    buffer.writeln('$_cyan└${'─' * (previewWidth * 2)}┘$_reset');
    _logger.info(buffer.toString());
  }

  /// Batch işlem durumunu göster
  static void showBatchProgress(String operation, int current, int total, List<String> processedItems) {
    final buffer = StringBuffer('\n');
    buffer.writeln('$_bold$operation$_reset');
    buffer.writeln('$_cyan[$current/$total] İşlenen dosyalar:$_reset');
    
    for (var i = 0; i < processedItems.length; i++) {
      final item = processedItems[i];
      final isLast = i == processedItems.length - 1;
      final prefix = isLast ? '└── ' : '├── ';
      buffer.writeln('$_white$prefix$item$_reset');
    }

    if (current < total) {
      buffer.write('$_yellow└── İşlem devam ediyor...$_reset');
    }

    // Önceki çıktıyı temizle ve yenisini yazdır
    stdout.write('\x1B[2J\x1B[0;0H'); // Terminal temizleme
    stdout.write(buffer.toString());
  }

  /// İkon bilgilerini göster
  static void showIconInfo(img.Image image, String path) {
    final fileSize = File(path).lengthSync();
    final buffer = StringBuffer('\n');
    
    buffer.writeln('$_bold$_white📊 İkon Bilgileri:$_reset');
    buffer.writeln('$_cyan├── Boyut: $_white${image.width}x${image.height}px$_reset');
    buffer.writeln('$_cyan├── Dosya: $_white${(fileSize / 1024).toStringAsFixed(1)} KB$_reset');
    buffer.writeln('$_cyan├── Format: $_white PNG$_reset');
    buffer.writeln('$_cyan└── Alpha: $_white${image.hasAlpha ? "Var" : "Yok"}$_reset');

    _logger.info(buffer.toString());
  }
}
