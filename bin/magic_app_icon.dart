import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:magic_app_icon/src/config/magic_app_icon_config.dart';
import 'package:magic_app_icon/src/exceptions/magic_app_icon_exception.dart';
import 'package:magic_app_icon/src/generators/icon_generator.dart';
import 'package:magic_app_icon/src/generators/platform_config_generator.dart';
import 'package:magic_app_icon/src/utils/cli_utils.dart';
import 'package:magic_app_icon/src/utils/translations.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const String version = '1.0.0';
final _logger = Logger('magic_app_icon');

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show help message',
      negatable: false,
    )
    ..addFlag(
      'version',
      abbr: 'v',
      help: 'Show version information',
      negatable: false,
    )
    ..addFlag(
      'quiet',
      abbr: 'q',
      help: 'Quiet mode (no logging)',
      defaultsTo: false,
    )
    ..addFlag(
      'check',
      abbr: 'c',
      help: 'Only validate configuration, no generation',
      defaultsTo: false,
    )
    ..addFlag(
      'report',
      abbr: 'r',
      help: 'Show detailed report',
      defaultsTo: false,
    )
    ..addOption(
      'platform',
      abbr: 'p',
      help: 'Target platform (android, ios or all)',
      allowed: ['android', 'ios', 'all'],
      defaultsTo: 'all',
    )
    ..addOption(
      'config',
      abbr: 'f',
      help: 'Custom configuration file path',
      defaultsTo: 'pubspec.yaml',
    )
    ..addOption(
      'output-dir',
      abbr: 'o',
      help: 'Output directory for icons',
      defaultsTo: '.',
    )
    ..addOption(
      'lang',
      abbr: 'l',
      help: 'Language selection (tr, en)',
      allowed: ['tr', 'en'],
      defaultsTo: 'en',
    );

  String lang = 'en';
  try {
    final results = parser.parse(args);
    lang = results['lang'] as String;

    // Logger'ı yapılandır
    CliUtils.configureLogger(quiet: results['quiet'] as bool);

    if (results['help']) {
      _printUsage(parser, lang: lang);
      exit(0);
    }

    if (results['version']) {
      CliUtils.printInfo('Magic App Icon Generator v$version');
      exit(0);
    }

    final quiet = results['quiet'] as bool;
    final check = results['check'] as bool;
    final showReport = results['report'] as bool;
    final platform = results['platform'] as String;
    final configPath = results['config'] as String;
    final outputDir = results['output-dir'] as String;

    if (!quiet) {
      CliUtils.printTitle('Magic App Icon Generator');
    }

    // Konfigürasyon dosyasını oku
    if (!quiet) {
      CliUtils.printInfo('⚙️ ${Translations.get('loading_config', lang)}');
    }

    final configFile = File(configPath);
    if (!await configFile.exists()) {
      throw MagicAppIconException(
        'CONFIG_NOT_FOUND',
        Translations.get('error_config_not_found', lang),
      );
    }

    final yaml = loadYaml(await configFile.readAsString()) as YamlMap;
    if (!yaml.containsKey('magic_app_icon')) {
      throw MagicAppIconException(
        'INVALID_CONFIG',
        Translations.get('error_invalid_config', lang),
      );
    }

    final config = MagicAppIconConfig.fromYaml(
      yaml['magic_app_icon'] as YamlMap,
      outputDir: outputDir,
      android: platform == 'all' || platform == 'android',
      ios: platform == 'all' || platform == 'ios',
    );

    // Validate configuration only
    if (check) {
      if (!quiet) {
        CliUtils.printSuccess('✅ ${Translations.get('config_valid', lang)}');
      }
      exit(0);
    }

    // Create app_icons.dart file
    if (!quiet) {
      CliUtils.printInfo('📝 ${Translations.get('creating_app_icons', lang)}');
    }
    await _createAppIconsFile();

    // Run build_runner
    if (!quiet) {
      CliUtils.printInfo(
        '🏗️ ${Translations.get('running_build_runner', lang)}',
      );
    }
    await _runBuildRunner();

    // Generate icons
    if (!quiet) {
      CliUtils.printInfo('🎨 ${Translations.get('generating_icons', lang)}');
    }

    final generator = IconGenerator(
      config,
      lang: lang,
      showReport: showReport,
    );
    await generator.generate();

    // Update platform configurations
    if (!quiet) {
      CliUtils.printInfo('⚙️ ${Translations.get('updating_configs', lang)}');
    }

    final platformGenerator = PlatformConfigGenerator(config, lang: lang);
    await platformGenerator.generate();

    if (!quiet) {
      CliUtils.printSuccess('✅ ${Translations.get('completed', lang)}');
    }
  } on MagicAppIconException catch (e) {
    CliUtils.printError(
        '❌ ${e.message}${e.details != null ? '\n   ${Translations.get('location', lang)}: ${e.details}' : ''}');
    exit(1);
  } catch (e) {
    CliUtils.printError('❌ ${Translations.get('error_unexpected', lang)}: $e');
    exit(1);
  }
}

/// Run build_runner
Future<void> _runBuildRunner() async {
  final result = await Process.run(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    runInShell: true,
  );

  if (result.exitCode != 0) {
    throw MagicAppIconException(
      'BUILD_RUNNER_ERROR',
      'Build runner execution failed: ${result.stderr}',
    );
  }
}

/// Create app_icons.dart file
Future<void> _createAppIconsFile() async {
  // Check example/lib directory first
  final exampleLibDir = Directory('example/lib');
  if (await exampleLibDir.exists()) {
    final appIconsFile = File(p.join('example/lib', 'app_icons.dart'));
    if (!await appIconsFile.exists()) {
      await appIconsFile.writeAsString('''
// ignore_for_file: type=lint

import 'package:magic_app_icon/src/models/app_icon.dart';

part 'app_icons.g.dart';

/// Helper class for app icons
abstract class AppIcons {
  /// Singleton instance
  static AppIcons? _instance;
  
  // Avoid self instance
  AppIcons._();
  
  /// Access to instance
  static AppIcons get instance => _instance ??= _AppIconsImpl();

  /// Default icon
  AppIcon get defaultIcon;

  /// Get all icons
  List<AppIcon> get all;
}

class _AppIconsImpl extends AppIcons {
  _AppIconsImpl() : super._();
}
''');
    }
    return;
  }

  // If example directory doesn't exist, create in lib directory
  final libDir = Directory('lib');
  if (!await libDir.exists()) {
    await libDir.create();
  }

  final appIconsFile = File(p.join('lib', 'app_icons.dart'));
  if (!await appIconsFile.exists()) {
    await appIconsFile.writeAsString('''
// ignore_for_file: type=lint

import 'package:magic_app_icon/src/models/app_icon.dart';

part 'app_icons.g.dart';

/// Helper class for app icons
abstract class AppIcons {
  /// Singleton instance
  static AppIcons? _instance;
  
  // Avoid self instance
  AppIcons._();
  
  /// Access to instance
  static AppIcons get instance => _instance ??= _AppIconsImpl();

  /// Default icon
  AppIcon get defaultIcon;

  /// Get all icons
  List<AppIcon> get all;
}

class _AppIconsImpl extends AppIcons {
  _AppIconsImpl() : super._();
}
''');
  }
}

void _printUsage(ArgParser parser, {String lang = 'en'}) {
  String t(String key) => Translations.get(key, lang);

  _logger.info('''
🎨 Magic App Icon Generator v$version
====================================

${t('description')}

📋 ${t('usage')}:
  dart run magic_app_icon [${t('options').toLowerCase()}]

🛠️  ${t('options')}:
  -h, --help                 ${t('help')}
  -v, --version              ${t('version')}
  -q, --quiet                ${t('quiet')}
  -c, --check                ${t('check')}
  -p, --platform             ${t('platform')} [${t('default')}: all]
  -f, --config               ${t('config')} [${t('default')}: pubspec.yaml]
  -o, --output-dir           ${t('output_dir')} [${t('default')}: .]
  -l, --lang                 ${t('lang')} [${t('default')}: en]

📝 ${t('examples')}:
  ▸ ${t('all_platforms')}:
    dart run magic_app_icon

  ▸ ${t('android_only')}:
    dart run magic_app_icon -p android

  ▸ ${t('ios_only')}:
    dart run magic_app_icon -p ios

  ▸ ${t('validate_config')}:
    dart run magic_app_icon -c

  ▸ ${t('custom_config')}:
    dart run magic_app_icon -f icon.yaml

  ▸ ${t('custom_output')}:
    dart run magic_app_icon -o build/icons

  ▸ ${t('quiet_mode')}:
    dart run magic_app_icon -q

💡 ${t('configuration')} (pubspec.yaml):
  magic_app_icon:
    default_icon: assets/icons/default.png      🎯 ${t('default_icon')}
    alternate_icons:                            🔄 ${t('alternate_icons')}
      red: assets/icons/red.png                 🔴 ${t('red_icon')}
      blue: assets/icons/blue.png               🔵 ${t('blue_icon')}
    android: true                               # Android support (optional)
    ios: true                                   # iOS support (optional)
    strict_alpha_check: false                   # Alpha transparency check (optional)

ℹ️  ${t('note')}: 
  • ${t('note_format')}
  • ${t('note_sizes')}:
    ▸ Android: 192x192 (xxxhdpi for)
    ▸ iOS: 180x180 (@3x for)
  • ${t('note_square')}
  • ${t('note_size')}
  • ${t('note_transparency')}
''');
}
