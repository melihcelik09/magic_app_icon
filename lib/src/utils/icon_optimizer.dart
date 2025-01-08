import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../exceptions/magic_app_icon_exception.dart';
import 'cli_utils.dart';

/// İkon optimizasyonu için yardımcı sınıf
class IconOptimizer {
  /// İkonu optimize et
  static Future<void> optimize(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw MagicAppIconException(
        'FILE_NOT_FOUND',
        'Dosya bulunamadı: $path'
      );
    }

    CliUtils.printInfo('İkon optimizasyonu başlatılıyor...');
    
    final bytes = await file.readAsBytes();
    final image = img.decodePng(Uint8List.fromList(bytes));
    if (image == null) {
      throw MagicAppIconException(
        'INVALID_IMAGE',
        'Görüntü dosyası okunamadı'
      );
    }

    // İkon bilgilerini göster
    CliUtils.showIconInfo(image, path);
    CliUtils.showIconPreview(image, title: 'Orijinal İkon');

    // Optimize edilmiş görüntüyü kaydet
    CliUtils.printInfo('Optimizasyon işlemi başlıyor...');
    final optimized = await _optimizeImage(image);
    
    // Optimizasyon sonucunu göster
    CliUtils.showIconPreview(optimized, title: 'Optimize Edilmiş İkon');
    
    final optimizedBytes = img.encodePng(optimized, level: 9);
    await file.writeAsBytes(optimizedBytes);
    
    final savedSize = (bytes.length - optimizedBytes.length) / 1024;
    CliUtils.printSuccess('Optimizasyon tamamlandı! ${savedSize.toStringAsFixed(1)} KB kazanıldı');
  }

  /// Görüntüyü optimize et
  static Future<img.Image> _optimizeImage(img.Image image) async {
    // İşlemi farklı bir isolate'de yap
    final result = await Isolate.run(() {
      var currentStep = 0;
      const totalSteps = 2;

      // Boyutlandırma
      var optimized = image;
      if (image.width > 1024 || image.height > 1024) {
        CliUtils.showDetailedProgress(++currentStep, totalSteps, 
          'Boyutlandırma yapılıyor...',
          detail: '${image.width}x${image.height} → 1024x1024'
        );
        
        optimized = img.copyResize(
          image,
          width: image.width > 1024 ? 1024 : image.width,
          height: image.height > 1024 ? 1024 : image.height,
          interpolation: img.Interpolation.cubic,
        );
      }

      // Renk optimizasyonu
      CliUtils.showDetailedProgress(++currentStep, totalSteps, 
        'Renk paleti optimize ediliyor...',
        detail: '16M renk → 256 renk'
      );
      optimized = img.quantize(optimized, numberOfColors: 256);
      
      return optimized;
    });

    return result;
  }

  /// İkon kalitesini kontrol et
  static Future<void> checkQuality(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw MagicAppIconException(
        'FILE_NOT_FOUND',
        'Dosya bulunamadı: $path'
      );
    }

    CliUtils.printInfo('İkon kalite kontrolü başlatılıyor...');
    
    final bytes = await file.readAsBytes();
    final image = img.decodePng(Uint8List.fromList(bytes));
    if (image == null) {
      throw MagicAppIconException(
        'INVALID_IMAGE',
        'Görüntü dosyası okunamadı'
      );
    }

    // İkon bilgilerini göster
    CliUtils.showIconInfo(image, path);
    CliUtils.showIconPreview(image, title: 'Kontrol Edilen İkon');

    var currentCheck = 0;
    const totalChecks = 2;

    // Boyut kontrolü
    CliUtils.showDetailedProgress(++currentCheck, totalChecks, 
      'Çözünürlük kontrolü yapılıyor...',
      detail: '${image.width}x${image.height}'
    );
    
    if (image.width < 1024 || image.height < 1024) {
      throw MagicAppIconException(
        'LOW_RESOLUTION',
        'İkon çözünürlüğü çok düşük. En az 1024x1024 piksel olmalı.'
      );
    }

    // Alpha kanalı kontrolü
    CliUtils.showDetailedProgress(++currentCheck, totalChecks, 
      'Alpha kanalı kontrolü yapılıyor...'
    );
    
    final hasTransparency = await _checkTransparencyParallel(image);
    if (!hasTransparency) {
      throw MagicAppIconException(
        'NO_TRANSPARENCY',
        'İkon saydamlık içermiyor. Alpha kanalı gerekli.'
      );
    }

    CliUtils.printSuccess('Kalite kontrolü başarıyla tamamlandı!');
  }

  /// Alpha kanalı kontrolünü paralel olarak yap
  static Future<bool> _checkTransparencyParallel(img.Image image) async {
    // Görüntüyü parçalara böl
    final int rowsPerChunk = (image.height / (Platform.numberOfProcessors - 1)).ceil();
    final chunks = <Future<bool>>[];

    for (var i = 0; i < image.height; i += rowsPerChunk) {
      final endRow = (i + rowsPerChunk).clamp(0, image.height);
      chunks.add(Isolate.run(() {
        // Her chunk'ı ayrı bir isolate'de kontrol et
        for (var y = i; y < endRow; y++) {
          for (var x = 0; x < image.width; x++) {
            final pixel = image.getPixel(x, y);
            if (pixel.a < 255) { // Alpha değeri
              return true;
            }
          }
        }
        return false;
      }));

      // İlerlemeyi göster
      CliUtils.showDetailedProgress(i + rowsPerChunk, image.height,
        'Alpha kanalı taranıyor...',
        detail: 'Satır ${i + 1} - $endRow'
      );
    }

    // Tüm chunk'ların sonuçlarını bekle
    final results = await Future.wait(chunks);
    return results.contains(true);
  }
} 