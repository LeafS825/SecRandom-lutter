import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

/// DrawSettingsScreen - 抽取设置页面
///
/// - 窄屏: 使用 Scaffold 完整页面
/// - 宽屏: 使用 DrawSettingsBody 作为 SettingsLayout 的 Detail 区域
class DrawSettingsScreen extends StatelessWidget {
  const DrawSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('抽取设置')),
      body: const DrawSettingsBody(),
    );
  }
}

/// 抽取设置的主体内容，可嵌入 SettingsLayout 的 Detail 区域
class DrawSettingsBody extends StatelessWidget {
  const DrawSettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.repeat),
                title: const Text('启用不重复抽取'),
                subtitle: const Text('开启后抽中过的学生在本轮不会再次被抽中；关闭后每次都从当前筛选全量中抽取。'),
                value: appProvider.nonRepeatEnabled,
                onChanged: appProvider.setNonRepeatEnabled,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.balance),
                title: const Text('启用公平抽取'),
                subtitle: const Text('开启后按历史抽取次数动态计算权重，降低重复抽中概率。'),
                value: appProvider.fairDrawEnabled,
                onChanged: appProvider.setFairDrawEnabled,
              ),
            ),
          ],
        );
      },
    );
  }
}
