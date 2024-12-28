# Magic App Icon 📱

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-blue.svg)](https://github.com/melihcelik09/magic_app_icon)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/melihcelik09/magic_app_icon/pulls)

A Flutter application that demonstrates dynamic app icon changing functionality, allowing users to switch app icons at runtime.

## 🗂 Project Structure

```
magic_app_icon/
├── lib/
│   ├── main.dart           # Entry point of the application
│   ├── app.dart            # Main application setup and routing
│   └── dynamic_icon_changer.dart  # Icon changing functionality
├── assets/
│   └── images/            # Application images and icons
├── ios/                   # iOS specific configurations
│   └── Runner/
│       ├── Info.plist    # Contains alternate icon configurations
│       └── Assets.xcassets # Contains icon assets
├── android/              # Android specific configurations
├── pubspec.yaml         # Flutter dependencies and assets configuration
└── pubspec.lock        # Lock file for dependencies
```

## 🛠 Technical Implementation

### 📱 iOS Implementation
The app utilizes iOS's native alternate icons feature. This is implemented through:
1. Configuration in Info.plist to declare alternate icons
2. Using `setAlternateIconName` method from UIKit
3. Icons are stored in Assets.xcassets

### 🤖 Android Implementation
Android implementation uses Activity Aliases approach:
1. Defined in AndroidManifest.xml
2. Each icon variant has its own activity-alias
3. Icons are enabled/disabled through package manager
4. Requires app restart for changes to take effect

### 🎯 Flutter Logic
The app uses a simple and efficient architecture:
1. `DynamicIconChanger` class handles icon changes through platform channels
2. Uses a single `MethodChannel` named 'dynamic_icon_changer' for native communication
3. Implements an enum `MagicIcon` to manage different icon variants (default, red, purple)
4. Each icon variant has a name and associated asset path
5. Error handling for platform-specific failures

## ⚙️ Setup and Configuration

### 📋 Prerequisites
- Flutter SDK (latest stable version)
- Xcode for iOS development
- Android Studio for Android development

### 🚀 Installation Steps
1. Clone the repository
```bash
git clone [repository-url]
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### ➕ Adding New Icons
To add a new icon variant:

#### For iOS:
1. Add icon assets to Assets.xcassets
2. Update Info.plist with new alternate icon name
3. Add corresponding icon files in the project

#### For Android:
1. Add new icon resource to res/mipmap
2. Create new activity-alias in AndroidManifest.xml
3. Update icon changing logic in native code

## 📦 Dependencies

- flutter_sdk: ^3.0.0
- package_info_plus: ^8.1.2 (for package information)

## 📖 Detailed Implementation Guide

### 1. Flutter Implementation

#### Setup Method Channel
```dart
// In dynamic_icon_changer.dart
class DynamicIconChanger {
  static const String _channelName = 'dynamic_icon_changer';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static Future<void> changeIcon(String iconName) async {
    try {
      await _channel.invokeMethod('updateIcon', {'iconName': iconName});
    } on PlatformException catch (e) {
      throw ('Failed to change icon: ${e.message}');
    }
  }
}
```

#### Define Icon Variants
```dart
enum MagicIcon {
  defaultIcon(name: "default", asset: "assets/images/default.png"),
  redIcon(name: "red", asset: "assets/images/red.png"),
  purpleIcon(name: "purple", asset: "assets/images/purple.png");

  final String name;
  final String asset;

  const MagicIcon({
    required this.name,
    required this.asset,
  });
}
```

### 2. iOS Configuration

#### Update Info.plist
Add the following to your Info.plist:
```xml
<key>CFBundleIcons</key>
<dict>
    <key>CFBundleAlternateIcons</key>
    <dict>
        <key>red</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>red</string>
            </array>
        </dict>
        <key>purple</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>purple</string>
            </array>
        </dict>
    </dict>
</dict>
```

### 3. Android Configuration

#### Update AndroidManifest.xml
Add activity aliases for each icon variant:
```xml
<manifest>
    <application>
        <!-- Default Activity -->
        <activity android:name=".MainActivity"
            android:exported="true"
            android:enabled="true">
            <!-- ... existing intent filter ... -->
        </activity>

        <!-- Red Icon Alias -->
        <activity-alias
            android:name=".RedIcon"
            android:enabled="false"
            android:icon="@mipmap/ic_launcher_red"
            android:targetActivity=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity-alias>

        <!-- Purple Icon Alias -->
        <activity-alias
            android:name=".PurpleIcon"
            android:enabled="false"
            android:icon="@mipmap/ic_launcher_purple"
            android:targetActivity=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity-alias>
    </application>
</manifest>
```

## 🎨 Icon Requirements

### 📱 iOS Icon Sizes
- iPhone (60pt): 180x180px (@3x), 120x120px (@2x)
- iPad (76pt): 152x152px (@2x)
- iPad Pro (83.5pt): 167x167px (@2x)
- App Store: 1024x1024px

### 🤖 Android Icon Sizes
- mdpi: 48x48px
- hdpi: 72x72px
- xhdpi: 96x96px
- xxhdpi: 144x144px
- xxxhdpi: 192x192px
- Play Store: 512x512px

## ⚡️ Quick Start Guide

1. **Prepare Your Icons**
   ```bash
   assets/
   ├── images/
   │   ├── default.png
   │   ├── red.png
   │   └── purple.png
   ```

2. **Update pubspec.yaml**
   ```yaml
   flutter:
     assets:
       - assets/images/
   ```

3. **Add Platform Configurations**
   - Follow iOS and Android configuration steps above

4. **Implement Icon Change**
   ```dart
   // Example implementation in a StatefulWidget
   class IconChangerWidget extends StatefulWidget {
     @override
     _IconChangerWidgetState createState() => _IconChangerWidgetState();
   }

   class _IconChangerWidgetState extends State<IconChangerWidget> {
     MagicIcon _currentIcon = MagicIcon.defaultIcon;

     void _changeIcon(MagicIcon newIcon) async {
       try {
         await DynamicIconChanger.changeIcon(newIcon.name);
         setState(() => _currentIcon = newIcon);
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Icon changed successfully!')),
         );
       } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to change icon: $e')),
         );
       }
     }

     @override
     Widget build(BuildContext context) {
       return Column(
         children: MagicIcon.values.map((icon) => 
           ElevatedButton(
             onPressed: () => _changeIcon(icon),
             child: Text('Change to ${icon.name} icon'),
           ),
         ).toList(),
       );
     }
   }
   ```

## 🗺 Feature Roadmap

- [ ] 🔔 Support for iOS Notification Badge customization
- [ ] 🎨 Dynamic icon generation from templates
- [ ] 🌙 Support for seasonal icon changes
- [ ] ⏰ Background icon change scheduling
- [ ] 👁 Icon preview before applying
- [ ] 🎬 Support for animated icons (Android only)
- [ ] 🌓 Integration with system theme changes
- [ ] 📊 Icon change analytics and tracking

## ⚠️ Known Limitations

### 📱 iOS
- Icon changes are immediate but may require a few seconds to reflect
- Limited to static images (no animations)
- Maximum of 30 alternate icons

### 🤖 Android
- Requires app restart for icon changes
- Some launchers may cache icons
- Adaptive icon support varies by device

## 💡 Best Practices

### 🚀 Performance
- Cache icon change status
- Implement proper error handling
- Consider device-specific limitations

### 👥 User Experience
- Provide visual feedback during icon changes
- Show preview of icons before changing
- Handle background/foreground state changes

### ✅ Testing
- Test on multiple devices and OS versions
- Verify icon appearance on different launchers
- Check memory usage with multiple icon changes

## 🤝 Contributing

We welcome contributions! Here's how you can help:

- 🐛 Report bugs
- 💡 Suggest features
- 🔧 Submit pull requests
- 📖 Improve documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
<p align="center">Made with ❤️ by melihcelik09</p>
