import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../widgets/settings_layout.dart';
import 'settings/about_settings_screen.dart';
import 'settings/account_settings_screen.dart';
import 'settings/data_management_screen.dart';
import 'settings/draw_settings_screen.dart';
import 'settings/lottery_settings_screen.dart';
import 'settings/personalization_settings_screen.dart';
import 'settings/rollcall_settings_screen.dart';

/// SettingsScreen - 设置页面
///
/// - 窄屏 (< 900px): 使用移动端列表布局，点击项跳转到新页面
/// - 宽屏 (>= 900px): 使用 SettingsLayout 的 Master-Detail 布局
///   - 左侧：设置项导航列表（Master）
///   - 右侧：选中项的详细内容（Detail）
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsLayout(
      title: '设置',
      items: _buildSettingItems(),
    );
  }

  List<SettingItem> _buildSettingItems() {
    return [
      SettingItem(
        title: '账户',
        icon: Icons.person_outline,
        pageBuilder: () => const AccountSettingsBody(),
        routeName: '/settings/account',
      ),
      SettingItem(
        title: '点名名单设置',
        icon: Icons.people,
        pageBuilder: () => const RollCallSettingsBody(),
        routeName: '/settings/rollcall',
        actionsBuilder: (context) {
          final provider = context.read<AppProvider>();
          return [
            TextButton.icon(
              onPressed: () => RollCallSettingsScreen.showQuickImportDialog(context, provider),
              icon: const Icon(Icons.file_upload, size: 18),
              label: const Text('快速导入'),
            ),
          ];
        },
      ),
      SettingItem(
        title: '抽奖设置',
        icon: Icons.card_giftcard,
        pageBuilder: () => const LotterySettingsBody(),
        routeName: '/settings/lottery',
        actionsBuilder: (context) {
          return [
            TextButton.icon(
              onPressed: () => LotterySettingsBody.showQuickImport(),
              icon: const Icon(Icons.file_upload, size: 18),
              label: const Text('快速导入'),
            ),
          ];
        },
      ),
      SettingItem(
        title: '抽取设置',
        icon: Icons.casino,
        pageBuilder: () => const DrawSettingsBody(),
        routeName: '/settings/draw',
      ),
      SettingItem(
        title: '个性化',
        icon: Icons.text_fields,
        pageBuilder: () => const PersonalizationSettingsBody(),
        routeName: '/settings/personalization',
      ),
      SettingItem(
        title: '数据管理',
        icon: Icons.storage,
        pageBuilder: () => const DataManagementBody(),
        routeName: '/settings/data',
      ),
      SettingItem(
        title: '关于',
        icon: Icons.info,
        pageBuilder: () => const AboutSettingsBody(),
        routeName: '/settings/about',
      ),
    ];
  }
}
