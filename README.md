# Magic App Icon

Flutter uygulamalarında dinamik ikon değiştirme özelliği için geliştirilen bir paket.

[English](#english) | [Türkçe](#türkçe)

## English

### Features
- Dynamic app icon changing for iOS and Android
- Automatic icon generation for all required sizes
- CLI tool for easy icon management
- Platform-specific configuration generation
- Detailed validation and reporting
- Type-safe icon management

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  magic_app_icon: ^1.0.0
```

### Configuration

Add your icons configuration to `pubspec.yaml`:

```yaml
magic_app_icon:
  default_icon: assets/icons/default.png
  alternate_icons:
    red: assets/icons/red.png
    blue: assets/icons/blue.png
```

### Usage

1. Generate Icons
```bash
# For all platforms
dart run magic_app_icon

# For Android only
dart run magic_app_icon -p android

# For iOS only
dart run magic_app_icon -p ios
```

2. Use in Code
```dart
import 'package:magic_app_icon/magic_app_icon.dart';

// Get current icon
final currentIcon = await MagicAppIcon.getCurrentIcon();

// Change icon
await MagicAppIcon.changeIcon(AppIcon(name: 'red', path: 'assets/icons/red.png'));

// Check if feature is supported
final isSupported = await MagicAppIcon.isSupported();
```

### CLI Options
```bash
dart run magic_app_icon --help    # Show help
dart run magic_app_icon -v        # Show version
dart run magic_app_icon -c        # Validate configuration
dart run magic_app_icon -f config.yaml  # Use custom config file
dart run magic_app_icon -o build/icons  # Custom output directory
dart run magic_app_icon -q        # Quiet mode
```

### Platform Setup

#### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<application>
    <!-- Activity aliases will be added automatically -->
</application>
```

#### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleIcons</key>
<dict>
    <!-- Alternate icons will be added automatically -->
</dict>
```

## Türkçe

### Özellikler
- iOS ve Android için dinamik ikon değiştirme
- Tüm gerekli boyutlar için otomatik ikon üretimi
- Kolay ikon yönetimi için CLI aracı
- Platform özel konfigürasyon üretimi
- Detaylı doğrulama ve raporlama
- Tip güvenli ikon yönetimi

### Kurulum

Paket bağımlılığını `pubspec.yaml` dosyanıza ekleyin:

```yaml
dependencies:
  magic_app_icon: ^1.0.0
```

### Konfigürasyon

İkon konfigürasyonunu `pubspec.yaml` dosyanıza ekleyin:

```yaml
magic_app_icon:
  default_icon: assets/icons/default.png
  alternate_icons:
    red: assets/icons/red.png
    blue: assets/icons/blue.png
```

### Kullanım

1. İkonları Üret
```bash
# Tüm platformlar için
dart run magic_app_icon

# Sadece Android için
dart run magic_app_icon -p android

# Sadece iOS için
dart run magic_app_icon -p ios
```

2. Kodda Kullanım
```dart
import 'package:magic_app_icon/magic_app_icon.dart';

// Mevcut ikonu al
final currentIcon = await MagicAppIcon.getCurrentIcon();

// İkonu değiştir
await MagicAppIcon.changeIcon(AppIcon(name: 'red', path: 'assets/icons/red.png'));

// Özelliğin desteklenip desteklenmediğini kontrol et
final isSupported = await MagicAppIcon.isSupported();
```

### CLI Seçenekleri
```bash
dart run magic_app_icon --help    # Yardım göster
dart run magic_app_icon -v        # Versiyon göster
dart run magic_app_icon -c        # Konfigürasyonu doğrula
dart run magic_app_icon -f config.yaml  # Özel konfigürasyon dosyası kullan
dart run magic_app_icon -o build/icons  # Özel çıktı dizini
dart run magic_app_icon -q        # Sessiz mod
```

### Platform Kurulumu

#### Android
`android/app/src/main/AndroidManifest.xml` dosyasına ekleyin:
```xml
<application>
    <!-- Activity alias'ları otomatik eklenecek -->
</application>
```

#### iOS
`ios/Runner/Info.plist` dosyasına ekleyin:
```xml
<key>CFBundleIcons</key>
<dict>
    <!-- Alternatif ikonlar otomatik eklenecek -->
</dict>
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.
