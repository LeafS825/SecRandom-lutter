import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

import 'settings/name_settings_screen.dart';
import 'settings/gender_settings_screen.dart';
import 'settings/group_settings_screen.dart';
import 'settings/class_settings_screen.dart';

class StudentSettingsScreen extends StatefulWidget {
  const StudentSettingsScreen({super.key});

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  String _selectedClass = '1';

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final allStudents = appProvider.allStudents;
    
    // 获取所有唯一的班级/组别
    final List<String> classOptions = appProvider.groups;
    if (!classOptions.contains(_selectedClass) && classOptions.isNotEmpty) {
      _selectedClass = classOptions.first;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('点名名单设置'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                '点名名单',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  // 设置班级名称
                  _buildSettingRow(
                    icon: Icons.edit_note,
                    title: '设置班级名称',
                    subtitle: '设置当前班级名称',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ClassSettingsScreen()),
                      );
                    },
                  ),
                  
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // 选择班级
                  _buildSettingRow(
                    icon: Icons.bookmark_border,
                    title: '选择班级',
                    subtitle: '从已有班级中选择一个班级',
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

                  // 设置姓名
                  _buildSettingRow(
                    icon: Icons.person_outline,
                    title: '设置姓名',
                    subtitle: '设置学生姓名',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NameSettingsScreen(selectedClass: _selectedClass)),
                      );
                    },
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // 设置性别
                  _buildSettingRow(
                    icon: Icons.face,
                    title: '设置性别',
                    subtitle: '设置学生性别',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GenderSettingsScreen(selectedClass: _selectedClass)),
                      );
                    },
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // 设置小组
                  _buildSettingRow(
                    icon: Icons.group_work_outlined,
                    title: '设置小组',
                    subtitle: '设置学生所属小组',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GroupSettingsScreen(selectedClass: _selectedClass)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(icon, color: Theme.of(context).iconTheme.color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Theme.of(context).disabledColor),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}
