import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class ClassSettingsScreen extends StatelessWidget {
  const ClassSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final students = appProvider.allStudents;
    final groups = appProvider.groups;

    return Scaffold(
      appBar: AppBar(title: const Text('设置班级名称')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final className = groups[index];
          final studentCount = students.where((s) => s.className == className).length;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.class_outlined, color: Colors.blue),
              ),
              title: Text(className, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$studentCount 名学生'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: '重命名',
                    onPressed: () {
                      _showRenameDialog(context, className, appProvider);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: '删除',
                    onPressed: () {
                      _showDeleteDialog(context, className, appProvider, studentCount);
                    },
                  ),
                ],
              ),
              onTap: () {
                 _showRenameDialog(context, className, appProvider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context, appProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, String oldName, AppProvider provider) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改班级名称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '班级名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                provider.renameClass(oldName, newName);
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加班级'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '班级名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                provider.addClass(newName);
              }
              Navigator.pop(context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String className, AppProvider provider, int studentCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除班级'),
        content: Text('确定要删除班级 "$className" 吗？\n该班级的 $studentCount 名学生将被移动到默认班级。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              provider.deleteClass(className);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
