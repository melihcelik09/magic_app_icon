part of 'app_icons.dart';

class _AppIconsImpl extends AppIcons {
  _AppIconsImpl() : super._();

  /// Default icon
  @override
  AppIcon get defaultIcon => const AppIcon(
    name: 'default',
    path: 'assets/icons/default.png',
  );

  /// red icon
  AppIcon get red => const AppIcon(
    name: 'red',
    path: 'assets/icons/red.png',
  );

  /// purple icon
  AppIcon get purple => const AppIcon(
    name: 'purple',
    path: 'assets/icons/purple.png',
  );

  /// Get all icons
  @override
  List<AppIcon> get all => [
    defaultIcon,
    red,
    purple,
  ];
}

