import 'package:flutter/material.dart';
import '../widgets/nav_rail.dart';
import '../widgets/control_panel.dart';
import '../widgets/name_display.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 手机/平板断点
        final bool isWideScreen = constraints.maxWidth > 800;
        final bool isRailVisible = constraints.maxWidth > 450; 

        return Scaffold(
          bottomNavigationBar: !isRailVisible 
            ? NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.people_outline), label: '点名'),
                  NavigationDestination(icon: Icon(Icons.history_outlined), label: '历史记录'),
                  NavigationDestination(icon: Icon(Icons.settings_outlined), label: '设置'),
                ],
              )
            : null,
          body: Row(
            children: [
              if (isRailVisible)
                NavRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              if (isRailVisible) const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: _buildBody(isWideScreen),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildBody(bool isWideScreen) {
    switch (_selectedIndex) {
      case 0:
        if (isWideScreen) {
          final screenHeight = MediaQuery.of(context).size.height;
          final isHeightConstrained = screenHeight < 400;
          
          // 宽屏模式下使用 Stack 布局，左侧显示抽取结果，控制面板在右下角
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Stack(
              children: [
                // 左侧抽取结果区域 - 只在控制面板左侧区域内显示
                Positioned(
                  left: 0,
                  right: isHeightConstrained ? 280 : 304, // 高度不足时减少右边距
                  top: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: NameDisplay(isWideScreen: true),
                  ),
                ),
                // 右下角控制面板 - 高度不足时撑满屏幕高度
                Positioned(
                  right: isHeightConstrained ? 0 : 24.0,
                  top: isHeightConstrained ? 0 : null,
                  bottom: isHeightConstrained ? 0 : 24.0,
                  child: Container(
                    height: isHeightConstrained ? double.infinity : null,
                    decoration: isHeightConstrained ? BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(-2, 0),
                        ),
                      ],
                    ) : null,
                    child: const ControlPanel(),
                  ),
                ),
              ],
            ),
          );
        } else {
          // 窄屏模式下使用 Column 布局，抽取结果在上方，控制面板固定在底部
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Column(
              children: [
                // 抽取结果区域 - 占据整个可用空间
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: NameDisplay(isWideScreen: false),
                  ),
                ),
                // 底部控制面板 - 固定在底部
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0), // 减小内边距
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: const ControlPanel(),
                ),
              ],
            ),
          );
        }
      case 1:
        return const HistoryScreen();
      case 2:
        return const SettingsScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}
