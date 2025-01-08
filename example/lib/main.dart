import 'package:flutter/material.dart';
import 'package:magic_app_icon/magic_app_icon.dart';
import 'package:magic_app_icon_example/app_icons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic App Icon Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Magic App Icon Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AppIcon? _currentIcon;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentIcon();
  }

  Future<void> _changeAppIcon(AppIcon icon) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await MagicAppIcon.changeIcon(icon);
      setState(() => _currentIcon = icon);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İkon başarıyla değiştirildi: ${icon.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İkon değiştirilemedi: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCurrentIcon() async {
    try {
      final activeIconName = await MagicAppIcon.getCurrentIcon();
      setState(() {
        _currentIcon = activeIconName;
      });
    } catch (e) {
      debugPrint('İkon yüklenemedi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Uygulama İkonunu Seçin',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                ...AppIcons.instance.all.map((icon) => RadioListTile<AppIcon>(
                      title: Text(icon.name),
                      secondary: Image.asset(
                        icon.path,
                        width: 48,
                        height: 48,
                      ),
                      value: icon,
                      groupValue: _currentIcon,
                      onChanged: (value) => _changeAppIcon(icon),
                    )),
              ],
            ),
    );
  }
}
