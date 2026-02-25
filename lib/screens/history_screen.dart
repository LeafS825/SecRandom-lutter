import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedClass = '1'; // 默认班级
  String _viewMode = '全部记录'; // 默认查看模式

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final allStudents = appProvider.allStudents;
    final history = appProvider.history;

    // 获取所有唯一的班级名称
    final Set<String> classNames = allStudents.map((s) => s.className).toSet();
    final List<String> classOptions = classNames.toList()..sort();
    if (!classOptions.contains(_selectedClass) && classOptions.isNotEmpty) {
      _selectedClass = classOptions.first;
    }

    // 过滤当前选中班级的学生
    final filteredStudents = allStudents.where((s) => s.className == _selectedClass).toList();

    // 过滤当前选中班级的历史记录
    final filteredHistory = history.where((h) => h.className == _selectedClass).toList();

    // 计算点名次数（只统计当前班级的历史记录）
    final Map<String, int> callCounts = {};
    for (var record in filteredHistory) {
      final names = record.name.split(',').map((e) => e.trim()).toList();
      for (var name in names) {
        callCounts[name] = (callCounts[name] ?? 0) + 1;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                '点名历史记录表格',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            
            // 主卡片
            Card(
              elevation: 0, // 扁平风格
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  // 筛选器 1: 选择班级
                  _buildFilterRow(
                    icon: Icons.bookmark_outline,
                    title: '选择班级',
                    subtitle: '选择要查看历史记录的班级',
                    trailing: DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButton<String>(
                          value: classOptions.contains(_selectedClass) ? _selectedClass : null,
                          isDense: true,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color, // 修复下拉菜单文字颜色
                          ),
                          dropdownColor: Theme.of(context).cardColor, // 修复下拉菜单背景色
                          items: classOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() => _selectedClass = newValue);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // 筛选器 2: 查看模式
                  _buildFilterRow(
                    icon: Icons.description_outlined,
                    title: '查看模式',
                    subtitle: '选择历史记录的查看方式',
                    trailing: DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButton<String>(
                          value: _viewMode,
                          isDense: true,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color, // 修复下拉菜单文字颜色
                          ),
                          dropdownColor: Theme.of(context).cardColor, // 修复下拉菜单背景色
                          items: <String>['全部记录', '仅看点名'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() => _viewMode = newValue);
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 数据表格
                  SizedBox(
                    width: double.infinity,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Theme.of(context).dividerColor,
                      ),
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (Theme.of(context).brightness == Brightness.dark) {
                              return const Color(0xFF303030); // 明确的深灰色
                            }
                            return const Color(0xFFFAFAFA);
                          },
                        ),
                        columnSpacing: 24,
                        horizontalMargin: 24,
                        columns: [
                          DataColumn(label: Expanded(child: Center(child: Text('学号', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))))),
                          DataColumn(label: Expanded(child: Center(child: Text('姓名', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))))),
                          DataColumn(label: Expanded(child: Center(child: Text('点名次数', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))))),
                          DataColumn(label: Expanded(child: Center(child: Text('权重', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))))),
                        ],
                        rows: filteredStudents.map((student) {
                          final count = callCounts[student.name] ?? 0;
                          final weight = "1.00"; 
                          
                          return DataRow(
                            cells: [
                              DataCell(Center(child: Text(student.id.toString(), style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))),
                              DataCell(Center(child: Text(student.name, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))),
                              DataCell(Center(child: Text(count.toString(), style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))),
                              DataCell(Center(child: Text(weight, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  // 如果列表为空，显示占位高度
                  if (filteredStudents.isEmpty)
                    const SizedBox(height: 200, child: Center(child: Text('暂无数据'))),
                    
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // 使用卡片颜色
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Theme.of(context).dividerColor), // 使用分割线颜色
        ),
        child: Icon(icon, color: Theme.of(context).iconTheme.color, size: 20), // 使用主题图标颜色
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }
}
