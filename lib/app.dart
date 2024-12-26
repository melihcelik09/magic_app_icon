import 'package:flutter/material.dart';
import 'package:magic_app_icon/dynamic_icon_changer.dart';
import 'package:magic_app_icon/main.dart';

class IconChanger extends StatelessWidget {
  const IconChanger({super.key});

  void _changeIcon(String iconName) async {
    try {
      await DynamicIconChanger.changeIcon(iconName);
      _showSnackBar('Icon changed to $iconName successfully.');
    } catch (e) {
      _showSnackBar('Failed to change icon: $e');
    }
  }

  void _showSnackBar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
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
              onPressed: () => _changeIcon('Default'),
              child: const Text('Set Default Icon'),
            ),
            ElevatedButton(
              onPressed: () => _changeIcon('Red'),
              child: const Text('Set Red Icon'),
            ),
            ElevatedButton(
              onPressed: () => _changeIcon('Purple'),
              child: const Text('Set Purple Icon'),
            ),
          ],
        ),
      ),
    );
  }
}
