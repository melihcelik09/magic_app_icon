# Magic App Icon Example

Bu örnek uygulama, Magic App Icon paketinin nasıl kullanılacağını gösterir.

## Başlangıç

1. İkonları assets/icons/ klasörüne ekleyin
2. pubspec.yaml'da ikonları tanımlayın:
```yaml
magic_app_icon:
  default_icon: "assets/icons/default.png"
  alternate_icons:
    red: "assets/icons/red.png"
    blue: "assets/icons/blue.png"
    purple: "assets/icons/purple.png"
```

3. CLI komutunu çalıştırın:
```bash
dart run magic_app_icon
```

4. Oluşturulan AppIcons sınıfını kullanın:
```dart
// İkon değiştirme
await MagicAppIcon.setIcon(
  iconName: AppIcons.red,
);

// Mevcut ikonu alma
final currentIcon = await MagicAppIcon.getActiveIcon();
final iconPath = AppIcons.values[currentIcon] ?? AppIcons.defaultIcon;
```
