import 'dart:io';

import 'package:xml/xml.dart';

import '../config/magic_app_icon_config.dart';
import '../exceptions/magic_app_icon_exception.dart';

/// Platform konfigürasyonları için yardımcı sınıf
class PlatformConfigGenerator {
  final MagicAppIconConfig config;
  final String _lang;

  PlatformConfigGenerator(
    this.config, {
    String lang = 'en',
  }) : _lang = lang;

  /// Konfigürasyonları üret
  Future<void> generate() async {
    if (config.android) {
      await _generateAndroidConfig();
    }
    if (config.ios) {
      await _generateIOSConfig();
    }
  }

  /// Android konfigürasyonunu üret
  Future<void> _generateAndroidConfig() async {
    final manifestFile =
        File('${config.outputDir}/android/app/src/main/AndroidManifest.xml');
    if (!await manifestFile.exists()) {
      throw MagicAppIconException.noMainIntentFilter(_lang);
    }

    final manifestContent = await manifestFile.readAsString();
    final manifest = XmlDocument.parse(manifestContent);

    // MainActivity'yi bul
    final application = manifest.findAllElements('application').first;
    final mainActivity = application.findElements('activity').firstWhere(
          (element) => element.getAttribute('android:name') == '.MainActivity',
        );

    // MainActivity'nin konfigürasyonunu güncelle
    mainActivity.setAttribute('android:enabled', 'true');
    mainActivity.setAttribute('android:exported', 'true');
    mainActivity.setAttribute('android:launchMode', 'singleTask');

    // MainActivity'nin intent-filter'ını kontrol et veya ekle
    mainActivity.findElements('intent-filter').firstWhere(
      (element) => element.findElements('action').any((action) =>
          action.getAttribute('android:name') == 'android.intent.action.MAIN'),
      orElse: () {
        final filter = XmlElement(
          XmlName('intent-filter'),
          [],
          [
            XmlElement(
              XmlName('action'),
              [
                XmlAttribute(
                    XmlName('android:name'), 'android.intent.action.MAIN')
              ],
            ),
            XmlElement(
              XmlName('category'),
              [
                XmlAttribute(
                    XmlName('android:name'), 'android.intent.category.LAUNCHER')
              ],
            ),
          ],
        );
        mainActivity.children.add(filter);
        return filter;
      },
    );

    // Mevcut activity-alias'ları ve metadata'yı temizle
    final existingAliases = application.findElements('activity-alias').toList();
    final existingMetadata = application.findElements('meta-data').toList();
    final existingComments =
        application.children.whereType<XmlComment>().toList();

    for (final alias in existingAliases) {
      application.children.remove(alias);
    }
    for (final metadata in existingMetadata) {
      application.children.remove(metadata);
    }
    for (final comment in existingComments) {
      application.children.remove(comment);
    }

    // Alternatif ikonlar için activity-alias'ları MainActivity'nin hemen altına ekle
    final activityIndex = application.children.indexOf(mainActivity);
    var currentIndex = activityIndex + 1;

    for (final entry in config.alternateIcons.entries) {
      final name = entry.key.toLowerCase();
      final displayName =
          entry.key.substring(0, 1).toUpperCase() + entry.key.substring(1);

      // Yorum satırını ekle
      application.children.insert(
        currentIndex++,
        XmlComment(' $displayName Icon Alias '),
      );

      // Activity-alias'ı ekle
      final alias = XmlElement(
        XmlName('activity-alias'),
        [
          XmlAttribute(XmlName('android:name'), '.$name'),
          XmlAttribute(XmlName('android:enabled'), 'false'),
          XmlAttribute(XmlName('android:icon'),
              '@mipmap/ic_launcher_${entry.key.toLowerCase()}'),
          XmlAttribute(XmlName('android:label'), 'Magic App Icon'),
          XmlAttribute(XmlName('android:targetActivity'), '.MainActivity'),
          XmlAttribute(XmlName('android:exported'), 'true'),
        ],
        [
          XmlElement(
            XmlName('intent-filter'),
            [],
            [
              XmlElement(
                XmlName('action'),
                [
                  XmlAttribute(
                      XmlName('android:name'), 'android.intent.action.MAIN')
                ],
              ),
              XmlElement(
                XmlName('category'),
                [
                  XmlAttribute(XmlName('android:name'),
                      'android.intent.category.LAUNCHER')
                ],
              ),
            ],
          ),
        ],
      );
      application.children.insert(currentIndex++, alias);
    }

    // Flutter metadata'sını en sona ekle
    application.children.add(
      XmlElement(
        XmlName('meta-data'),
        [
          XmlAttribute(XmlName('android:name'), 'flutterEmbedding'),
          XmlAttribute(XmlName('android:value'), '2'),
        ],
      ),
    );

    // Manifest dosyasını kaydet
    await manifestFile.writeAsString(manifest.toXmlString(pretty: true));
  }

  /// iOS konfigürasyonunu üret
  Future<void> _generateIOSConfig() async {
    final infoPlistFile = File('${config.outputDir}/ios/Runner/Info.plist');
    if (!await infoPlistFile.exists()) {
      throw MagicAppIconException.plistNotFound(_lang);
    }

    final content = await infoPlistFile.readAsString();
    final document = XmlDocument.parse(content);
    final rootDict = document.findAllElements('dict').first;

    // Tüm CFBundleIcons girişlerini temizle
    final allNodes = rootDict.children.toList();
    for (var i = 0; i < allNodes.length; i++) {
      final node = allNodes[i];
      if (node is XmlElement &&
          node.name.local == 'key' &&
          node.value == 'CFBundleIcons') {
        // CFBundleIcons key'ini sil
        rootDict.children.remove(node);
        // Sonraki dict elemanını sil (eğer varsa)
        if (i + 1 < allNodes.length) {
          rootDict.children.remove(allNodes[i + 1]);
        }
      }
    }

    // Yeni CFBundleIcons ekle
    rootDict.children.addAll([
      XmlElement(XmlName('key'))..children.add(XmlText('CFBundleIcons')),
      XmlElement(XmlName('dict'))
        ..children.addAll([
          // Ana icon
          XmlElement(XmlName('key'))
            ..children.add(XmlText('CFBundlePrimaryIcon')),
          XmlElement(XmlName('dict'))
            ..children.addAll([
              XmlElement(XmlName('key'))
                ..children.add(XmlText('CFBundleIconFiles')),
              XmlElement(XmlName('array'))
                ..children.add(
                  XmlElement(XmlName('string'))
                    ..children.add(XmlText('AppIcon')),
                ),
              XmlElement(XmlName('key'))
                ..children.add(XmlText('CFBundleIconName')),
              XmlElement(XmlName('string'))..children.add(XmlText('AppIcon')),
            ]),
          // Alternatif iconlar
          if (config.alternateIcons.isNotEmpty) ...[
            XmlElement(XmlName('key'))
              ..children.add(XmlText('CFBundleAlternateIcons')),
            XmlElement(XmlName('dict'))
              ..children.addAll(
                config.alternateIcons.entries.expand((entry) => [
                      XmlElement(XmlName('key'))
                        ..children.add(XmlText(entry.key)),
                      XmlElement(XmlName('dict'))
                        ..children.addAll([
                          XmlElement(XmlName('key'))
                            ..children.add(XmlText('CFBundleIconFiles')),
                          XmlElement(XmlName('array'))
                            ..children.add(
                              XmlElement(XmlName('string'))
                                ..children.add(XmlText(
                                    'Alternate Icons/${entry.key}/AppIcon-${entry.key.toLowerCase()}')),
                            ),
                          XmlElement(XmlName('key'))
                            ..children.add(XmlText('CFBundleIconName')),
                          XmlElement(XmlName('string'))
                            ..children.add(
                                XmlText('AppIcon-${entry.key.toLowerCase()}')),
                          XmlElement(XmlName('key'))
                            ..children.add(XmlText('UIPrerenderedIcon')),
                          XmlElement(XmlName('false')),
                        ]),
                    ]),
              ),
          ],
        ]),
    ]);

    // Info.plist'i kaydet
    await infoPlistFile.writeAsString(document.toXmlString(pretty: true));
  }
}
