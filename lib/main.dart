import 'package:flutter/material.dart';
import 'package:magic_app_icon/app.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
void main() {
  runApp(
    MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: const IconChanger(),
    ),
  );
}
