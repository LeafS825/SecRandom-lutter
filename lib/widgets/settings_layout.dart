import 'package:flutter/material.dart';

/// 设置项数据结构
class SettingItem {
  final String title;
  final IconData icon;
  final Widget Function() pageBuilder;
  final String routeName;
  final List<Widget> Function(BuildContext)? actionsBuilder;

  const SettingItem({
    required this.title,
    required this.icon,
    required this.pageBuilder,
    required this.routeName,
    this.actionsBuilder,
  });
}

/// 通用设置布局组件
///
/// 支持两种模式：
/// - 紧凑模式 (< 900px): 保持移动端 Scaffold 堆栈布局
/// - 扩展模式 (>= 900px): Master-Detail 双栏布局
class SettingsLayout extends StatefulWidget {
  final List<SettingItem> items;
  final String title;
  final int initialIndex;

  const SettingsLayout({
    super.key,
    required this.items,
    required this.title,
    this.initialIndex = 0,
  });

  @override
  State<SettingsLayout> createState() => _SettingsLayoutState();
}

class _SettingsLayoutState extends State<SettingsLayout> {
  late int _selectedIndex;

  static const double _kCompactBreakpoint = 900;
  static const double _kMasterWidth = 300;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildMasterPanel() {
    return Container(
      width: _kMasterWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = index == _selectedIndex;

                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () => _onItemSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel() {
    if (widget.items.isEmpty) {
      return const Center(child: Text('暂无设置项'));
    }

    final item = widget.items[_selectedIndex];
    final actions = item.actionsBuilder?.call(context) ?? [];

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (actions.isNotEmpty) ...actions,
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: item.pageBuilder(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLayout() {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];

        return ListTile(
          leading: Icon(item.icon),
          title: Text(item.title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            final actions = item.actionsBuilder?.call(context) ?? [];
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text(item.title),
                    actions: actions.isNotEmpty ? actions : null,
                  ),
                  body: item.pageBuilder(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExpandedLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMasterPanel(),
        Container(
          width: 1,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(child: _buildDetailPanel()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isExpanded = constraints.maxWidth >= _kCompactBreakpoint;

        if (isExpanded) {
          return _buildExpandedLayout();
        } else {
          return _buildCompactLayout();
        }
      },
    );
  }
}
