import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

/// 主题模式选择组件
/// 可嵌入 SettingsLayout 的 Detail 区域
class ThemeModeBody extends StatelessWidget {
  const ThemeModeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.wb_sunny),
                title: const Text('浅色模式'),
                trailing: Radio<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: appProvider.themeMode,
                  onChanged: (value) => appProvider.setThemeMode(value!),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.nights_stay),
                title: const Text('深色模式'),
                trailing: Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: appProvider.themeMode,
                  onChanged: (value) => appProvider.setThemeMode(value!),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings_suggest),
                title: const Text('跟随系统'),
                trailing: Radio<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: appProvider.themeMode,
                  onChanged: (value) => appProvider.setThemeMode(value!),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
