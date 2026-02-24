import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;
        final isHeightConstrained = screenHeight < 400;
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isCompact ? 12 : 16)),
          color: Theme.of(context).cardColor,
          child: Container(
            width: isCompact ? null : 280,
            constraints: BoxConstraints(
              minWidth: isCompact ? 0 : 280,
              maxWidth: isCompact ? double.infinity : 320,
            ),
            padding: EdgeInsets.all(isCompact ? 8.0 : 20.0),
            child: _buildLayout(context, appProvider, isCompact, isHeightConstrained),
          ),
        );
      },
    );
  }

  Widget _buildLayout(BuildContext context, AppProvider appProvider, bool isCompact, bool isHeightConstrained) {
    if (isHeightConstrained) {
      return _buildUltraCompactLayout(context, appProvider);
    } else if (!isCompact) {
      return _buildNormalLayout(context, appProvider);
    } else {
      return _buildCompactLayout(context, appProvider);
    }
  }

  Widget _buildNormalLayout(BuildContext context, AppProvider appProvider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 计数器行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: () => appProvider.setSelectCount(appProvider.selectCount - 1),
              icon: const Icon(Icons.remove),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${appProvider.selectCount}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => appProvider.setSelectCount(appProvider.selectCount + 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // 开始按钮
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: appProvider.isRolling ? null : () => appProvider.startRollCall(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF66CCFF),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(appProvider.isRolling ? '点名中...' : '开始'),
          ),
        ),
        const SizedBox(height: 20),

        // 班级下拉菜单
        DropdownButtonFormField<String>(
          value: appProvider.selectedClass,
          decoration: InputDecoration(
            labelText: '班级',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('所有班级')),
            const DropdownMenuItem(value: 'Class 1', child: Text('班级 1')),
            const DropdownMenuItem(value: 'Class 2', child: Text('班级 2')),
          ],
          onChanged: (value) => appProvider.setSelectedClass(value),
        ),
        const SizedBox(height: 16),

        // 其他筛选器占位符
        DropdownButtonFormField<String>(
          value: 'All Students',
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          items: const [
            DropdownMenuItem(value: 'All Students', child: Text('所有学生')),
          ],
          onChanged: (value) {},
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: 'All Genders',
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          items: const [
            DropdownMenuItem(value: 'All Genders', child: Text('所有性别')),
          ],
          onChanged: (value) {},
        ),
        
        // 状态文本
        const SizedBox(height: 20),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            '总人数: ${appProvider.totalCount} | 剩余: ${appProvider.remainingCount}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context, AppProvider appProvider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 计数器行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: () => appProvider.setSelectCount(appProvider.selectCount - 1),
              icon: const Icon(Icons.remove, size: 20),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${appProvider.selectCount}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => appProvider.setSelectCount(appProvider.selectCount + 1),
              icon: const Icon(Icons.add, size: 20),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 开始按钮
        SizedBox(
          height: 44,
          child: FilledButton(
            onPressed: appProvider.isRolling ? null : () => appProvider.startRollCall(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF66CCFF),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(appProvider.isRolling ? '点名中...' : '开始'),
          ),
        ),
        const SizedBox(height: 12),

        // 班级下拉菜单
        DropdownButtonFormField<String>(
          value: appProvider.selectedClass,
          decoration: InputDecoration(
            labelText: '班级',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('所有班级', style: TextStyle(fontSize: 13))),
            const DropdownMenuItem(value: 'Class 1', child: Text('班级 1', style: TextStyle(fontSize: 13))),
            const DropdownMenuItem(value: 'Class 2', child: Text('班级 2', style: TextStyle(fontSize: 13))),
          ],
          onChanged: (value) => appProvider.setSelectedClass(value),
        ),
        const SizedBox(height: 12),

        // 小组和性别选择在同一行
        Row(
          children: [
            // 小组选择
            Expanded(
              child: DropdownButtonFormField<String>(
                value: 'All Students',
                decoration: InputDecoration(
                  labelText: '小组',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  isDense: true,
                  labelStyle: const TextStyle(fontSize: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'All Students', child: Text('所有学生', style: TextStyle(fontSize: 12))),
                ],
                onChanged: (value) {},
              ),
            ),
            const SizedBox(width: 8),
            
            // 性别选择
            Expanded(
              child: DropdownButtonFormField<String>(
                value: 'All Genders',
                decoration: InputDecoration(
                  labelText: '性别',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  isDense: true,
                  labelStyle: const TextStyle(fontSize: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'All Genders', child: Text('所有性别', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: 'Male', child: Text('男', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: 'Female', child: Text('女', style: TextStyle(fontSize: 12))),
                ],
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        
        // 状态文本
        const SizedBox(height: 12),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            '${appProvider.totalCount}/${appProvider.remainingCount}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildUltraCompactLayout(BuildContext context, AppProvider appProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 计数器行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filledTonal(
                onPressed: () => appProvider.setSelectCount(appProvider.selectCount - 1),
                icon: const Icon(Icons.remove, size: 16),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${appProvider.selectCount}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => appProvider.setSelectCount(appProvider.selectCount + 1),
                icon: const Icon(Icons.add, size: 16),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
          
          // 开始按钮
          SizedBox(
            height: 32,
            child: FilledButton(
              onPressed: appProvider.isRolling ? null : () => appProvider.startRollCall(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF66CCFF),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(appProvider.isRolling ? '点名中...' : '开始'),
            ),
          ),

          // 班级下拉菜单
          DropdownButtonFormField<String>(
            value: appProvider.selectedClass,
            decoration: InputDecoration(
              labelText: '班级',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              isDense: true,
              labelStyle: const TextStyle(fontSize: 11),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('所有班级', style: TextStyle(fontSize: 11))),
              const DropdownMenuItem(value: 'Class 1', child: Text('班级 1', style: TextStyle(fontSize: 11))),
              const DropdownMenuItem(value: 'Class 2', child: Text('班级 2', style: TextStyle(fontSize: 11))),
            ],
            onChanged: (value) => appProvider.setSelectedClass(value),
          ),

          // 小组和性别选择在同一行
          Row(
            children: [
              // 小组选择
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: 'All Students',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    isDense: true,
                    labelStyle: const TextStyle(fontSize: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'All Students', child: Text('所有学生', style: TextStyle(fontSize: 10))),
                  ],
                  onChanged: (value) {},
                ),
              ),
              const SizedBox(width: 6),
              
              // 性别选择
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: 'All Genders',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    isDense: true,
                    labelStyle: const TextStyle(fontSize: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'All Genders', child: Text('所有性别', style: TextStyle(fontSize: 10))),
                    DropdownMenuItem(value: 'Male', child: Text('男', style: TextStyle(fontSize: 10))),
                    DropdownMenuItem(value: 'Female', child: Text('女', style: TextStyle(fontSize: 10))),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          
          // 状态文本
          Text(
            '${appProvider.totalCount}/${appProvider.remainingCount}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
