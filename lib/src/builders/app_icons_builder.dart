import 'package:build/build.dart';
import 'package:yaml/yaml.dart';

/// Create AppIcons builder
Builder appIconsBuilder(BuilderOptions options) => _AppIconsBuilder();

/// Code generator for AppIcons
class _AppIconsBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.g.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Generate only for app_icons.dart file
    if (!buildStep.inputId.path.endsWith('app_icons.dart')) {
      return;
    }

    try {
      // Read configuration from pubspec.yaml
      final pubspecContent = await buildStep.readAsString(
        AssetId(buildStep.inputId.package, 'pubspec.yaml'),
      );
      final pubspec = loadYaml(pubspecContent) as Map;
      final config = pubspec['magic_app_icon'] as Map?;

      if (config == null) {
        throw Exception('''
magic_app_icon configuration not found in pubspec.yaml.
Please add a configuration like this:

magic_app_icon:
  default_icon: "assets/icons/app_icon.png"
  alternate_icons:
    dark: "assets/icons/app_icon_dark.png"
    light: "assets/icons/app_icon_light.png"
''');
      }

      final defaultIcon = config['default_icon'] as String?;
      if (defaultIcon == null) {
        throw Exception('''
default_icon not defined in pubspec.yaml.
Please specify the default icon path:

magic_app_icon:
  default_icon: "assets/icons/app_icon.png"
''');
      }

      final alternateIcons = config['alternate_icons'] as Map?;
      if (alternateIcons == null) {
        throw Exception('''
alternate_icons not defined in pubspec.yaml.
Please specify alternate icons:

magic_app_icon:
  alternate_icons:
    dark: "assets/icons/app_icon_dark.png"
    light: "assets/icons/app_icon_light.png"
''');
      }

      // Start code generation
      final buffer = StringBuffer();

      // Part directive
      buffer.writeln("part of 'app_icons.dart';");
      buffer.writeln();

      // Code for _AppIconsImpl class
      buffer.writeln('''
class _AppIconsImpl extends AppIcons {
  _AppIconsImpl() : super._();

  /// Default icon
  @override
  AppIcon get defaultIcon => const AppIcon(
    name: 'default',
    path: '$defaultIcon',
  );
''');

      // Getters for alternate icons
      for (final entry in alternateIcons.entries) {
        final name = entry.key as String;
        final path = entry.value as String;

        buffer.writeln('''
  /// $name icon
  AppIcon get $name => const AppIcon(
    name: '$name',
    path: '$path',
  );
''');
      }

      // Getter for all icons
      buffer.writeln('''
  /// Get all icons
  @override
  List<AppIcon> get all => [
    defaultIcon,
    ${alternateIcons.keys.join(',\n    ')},
  ];
}
''');

      // Create the file
      final outputId = buildStep.inputId.changeExtension('.g.dart');
      await buildStep.writeAsString(outputId, buffer.toString());
    } catch (e) {
      log.severe('Error while generating AppIcons: $e');
      rethrow;
    }
  }
}
