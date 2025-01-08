/// İkon bilgilerini tutan model
class AppIcon {
  /// İkon adı
  final String name;

  /// İkon dosya yolu
  final String path;

  const AppIcon({
    required this.name,
    required this.path,
  });

  /// İsme göre ikon bul
  static AppIcon? findByName(String name, List<AppIcon> icons) {
    return icons.firstWhere(
      (icon) => icon.name == name,
      orElse: () => icons.first,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppIcon &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          path == other.path;

  @override
  int get hashCode => name.hashCode ^ path.hashCode;

  @override
  String toString() => 'AppIcon($name)';
} 