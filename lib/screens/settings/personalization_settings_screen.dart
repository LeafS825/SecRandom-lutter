import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_config.dart';
import '../../providers/app_provider.dart';

/// PersonalizationSettingsScreen - 个性化设置页面
///
/// - 窄屏: 使用 Scaffold 完整页面，垂直列表
/// - 宽屏: 使用 PersonalizationSettingsBody 作为 SettingsLayout 的 Detail 区域
///   - 采用双栏并排卡片布局
class PersonalizationSettingsScreen extends StatelessWidget {
  const PersonalizationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个性化')),
      body: const PersonalizationSettingsBody(),
    );
  }
}

/// 个性化设置的主体内容，可嵌入 SettingsLayout 的 Detail 区域
class PersonalizationSettingsBody extends StatelessWidget {
  const PersonalizationSettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            if (isWide) {
              return _buildWideLayout(context, appProvider);
            } else {
              return _buildNarrowLayout(context, appProvider);
            }
          },
        );
      },
    );
  }

  Widget _buildNarrowLayout(BuildContext context, AppProvider appProvider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsSectionCard(
          title: '抽人设置',
          icon: Icons.person_search,
          children: [
            _AnimationModeTile(
              title: '点名动画模式',
              currentMode: appProvider.rollcallAnimationMode,
              onModeChanged: appProvider.setRollcallAnimationMode,
            ),
            const SizedBox(height: 12),
            _FontSizeSliderTile(
              label: '抽人结果字号',
              value: appProvider.rollcallResultFontSize,
              onChanged: appProvider.setRollcallResultFontSize,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSectionCard(
          title: '抽奖设置',
          icon: Icons.card_giftcard,
          children: [
            _AnimationModeTile(
              title: '抽奖动画模式',
              currentMode: appProvider.lotteryAnimationMode,
              onModeChanged: appProvider.setLotteryAnimationMode,
            ),
            const SizedBox(height: 12),
            _FontSizeSliderTile(
              label: '抽奖结果字号',
              value: appProvider.lotteryResultFontSize,
              onChanged: appProvider.setLotteryResultFontSize,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, AppProvider appProvider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _SettingsSectionCard(
              title: '抽人设置',
              icon: Icons.person_search,
              children: [
                _AnimationModeTile(
                  title: '点名动画模式',
                  currentMode: appProvider.rollcallAnimationMode,
                  onModeChanged: appProvider.setRollcallAnimationMode,
                ),
                const SizedBox(height: 12),
                _FontSizeSliderTile(
                  label: '抽人结果字号',
                  value: appProvider.rollcallResultFontSize,
                  onChanged: appProvider.setRollcallResultFontSize,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SettingsSectionCard(
              title: '抽奖设置',
              icon: Icons.card_giftcard,
              children: [
                _AnimationModeTile(
                  title: '抽奖动画模式',
                  currentMode: appProvider.lotteryAnimationMode,
                  onModeChanged: appProvider.setLotteryAnimationMode,
                ),
                const SizedBox(height: 12),
                _FontSizeSliderTile(
                  label: '抽奖结果字号',
                  value: appProvider.lotteryResultFontSize,
                  onChanged: appProvider.setLotteryResultFontSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon),
              title: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _FontSizeSliderTile extends StatelessWidget {
  const _FontSizeSliderTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.toStringAsFixed(0);

    return Column(
      children: [
        ListTile(title: Text(label), trailing: Text(displayValue)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Slider(
            value: value,
            min: 24,
            max: 72,
            divisions: 48,
            label: displayValue,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

const List<DropdownMenuItem<AnimationMode>> _animationModeOptions = [
  DropdownMenuItem(
    value: AnimationMode.manualStop,
    child: Text('手动停止'),
  ),
  DropdownMenuItem(
    value: AnimationMode.auto,
    child: Text('自动播放'),
  ),
  DropdownMenuItem(
    value: AnimationMode.none,
    child: Text('无动画'),
  ),
];

class _AnimationModeTile extends StatelessWidget {
  const _AnimationModeTile({
    required this.title,
    required this.currentMode,
    required this.onModeChanged,
  });

  final String title;
  final AnimationMode currentMode;
  final ValueChanged<AnimationMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.animation_outlined),
      title: Text(title),
      trailing: SizedBox(
        width: 140,
        child: DropdownButtonFormField<AnimationMode>(
          initialValue: currentMode,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(),
          ),
          items: _animationModeOptions,
          onChanged: (value) {
            if (value != null) {
              onModeChanged(value);
            }
          },
        ),
      ),
    );
  }
}
