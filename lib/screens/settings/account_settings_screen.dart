import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
export '../../providers/auth_provider.dart';

/// 账户功能是否启用
/// 通过环境变量控制: flutter run --dart-define=ACCOUNT_ENABLED=true
const bool kAccountEnabled = bool.fromEnvironment(
  'ACCOUNT_ENABLED',
  defaultValue: false,
);

/// AccountSettingsScreen - 账户设置页面
///
/// - 窄屏: 使用 Scaffold 完整页面
/// - 宽屏: 使用 AccountSettingsBody 作为 SettingsLayout 的 Detail 区域
///   - 采用双栏布局：左栏用户信息，右栏账户详情
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('账户设置')),
      body: const AccountSettingsBody(),
    );
  }
}

/// 账户设置的主体内容，可嵌入 SettingsLayout 的 Detail 区域
class AccountSettingsBody extends StatelessWidget {
  const AccountSettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kAccountEnabled && !kDebugMode) {
      return _buildComingSoon(context);
    }

    final authProvider = context.watch<AuthProvider>();
    final userInfo = authProvider.userInfo;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        if (isWide) {
          return _buildWideLayout(context, userInfo);
        } else {
          return _buildNarrowLayout(context, userInfo);
        }
      },
    );
  }

  Widget _buildComingSoon(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            '账户功能暂未开放',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '敬请期待',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, userInfo) {
    return ListView(
      children: [
        _buildUserInfoCard(context, userInfo),
        const SizedBox(height: 16),
        _buildAccountDetailsCard(context, userInfo),
        const SizedBox(height: 32),
        _buildLogoutButton(context),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, userInfo) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildUserInfoCard(context, userInfo, isCompact: false),
                const SizedBox(height: 24),
                _buildLogoutButton(context),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 6,
            child: _buildAccountDetailsCard(context, userInfo),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, userInfo, {bool isCompact = true}) {
    return Card(
      margin: isCompact ? const EdgeInsets.all(16) : EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: userInfo?.avatarUrl != null
                  ? CachedNetworkImageProvider(userInfo!.avatarUrl!)
                  : null,
              child: userInfo?.avatarUrl == null
                  ? Text(
                      userInfo?.name[0] ?? 'U',
                      style: const TextStyle(fontSize: 32),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              userInfo?.name ?? '用户',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              userInfo?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetailsCard(BuildContext context, userInfo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            title: const Text('账户详情'),
            titleTextStyle: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(height: 1),
          _buildDetailItem(
            context,
            icon: Icons.badge_outlined,
            label: '用户 ID',
            value: userInfo?.userId ?? '-',
          ),
          _buildDetailItem(
            context,
            icon: Icons.shield_outlined,
            label: '权限等级',
            value: userInfo?.role ?? '-',
          ),
          if (userInfo?.githubUsername != null)
            _buildDetailItem(
              context,
              icon: Icons.code,
              label: 'GitHub',
              value: userInfo!.githubUsername!,
            ),
          _buildDetailItem(
            context,
            icon: Icons.calendar_today_outlined,
            label: '注册时间',
            value: _formatDate(userInfo?.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label),
      subtitle: Text(value),
      dense: true,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(Icons.logout),
        label: const Text('退出登录'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？本地数据将保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pop(dialogContext);
                // 在 SettingsLayout 的 Detail 区域中不需要再 pop 两层
                // 只有在独立页面时才需要
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已退出登录')),
                );
              }
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }
}
