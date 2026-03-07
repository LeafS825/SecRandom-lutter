import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

class DrawSettingsScreen extends StatelessWidget {
  const DrawSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('抽取设置')),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return ListView(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.balance),
                title: const Text('启用公平抽取'),
                subtitle: const Text('开启后按历史抽取次数动态计算权重，降低重复抽中概率。'),
                value: appProvider.fairDrawEnabled,
                onChanged: appProvider.setFairDrawEnabled,
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('当前策略'),
                subtitle: Text('使用固定参数（频率权重 + 差值保护逻辑），不开放手动调参。'),
              ),
            ],
          );
        },
      ),
    );
  }
}
