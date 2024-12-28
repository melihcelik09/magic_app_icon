import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magic_app_icon/dynamic_icon_changer.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

class IconChanger extends StatelessWidget {
  const IconChanger({super.key});

  void _changeIcon(BuildContext context, {required MagicIcon icon}) async {
    try {
      await DynamicIconChanger.changeIcon(icon.name);
      if (!context.mounted) return;
      if (Platform.isIOS) return;
      await _showDialog(context, icon: icon);
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, message: 'Failed to change icon: $e');
    }
  }

  void _showSnackBar(BuildContext context, {String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? ""),
      ),
    );
  }

  Future<void> _showDialog(BuildContext context,
      {required MagicIcon icon}) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    await showAdaptiveDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Row(
            children: [
              Expanded(child: Image.asset(icon.asset)),
              Expanded(
                flex: 2,
                child: Text(
                  "You have the changed the icon for ${packageInfo.appName}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change App Icon'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _changeIcon(
                context,
                icon: MagicIcon.defaultIcon,
              ),
              child: const Text('Set Default Icon'),
            ),
            ElevatedButton(
              onPressed: () => _changeIcon(
                context,
                icon: MagicIcon.redIcon,
              ),
              child: const Text('Set Red Icon'),
            ),
            ElevatedButton(
              onPressed: () => _changeIcon(
                context,
                icon: MagicIcon.purpleIcon,
              ),
              child: const Text('Set Purple Icon'),
            ),
          ],
        ),
      ),
    );
  }
}
