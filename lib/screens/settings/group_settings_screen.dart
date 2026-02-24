import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import 'group_allocation_screen.dart';

class GroupSettingsScreen extends StatelessWidget {
  final String? selectedClass;
  const GroupSettingsScreen({super.key, this.selectedClass});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final groups = appProvider.getGroupsForClass(selectedClass);
    final students = selectedClass != null
        ? appProvider.allStudents.where((s) => s.className == selectedClass).toList()
        : appProvider.allStudents;

    if (selectedClass == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('设置小组')),
        body: const Center(child: Text('请先选择一个班级')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('设置小组 ($selectedClass)'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.group_add),
            label: const Text('分配成员'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupAllocationScreen(selectedClass: selectedClass),
                ),
              );
            },
          ),
        ],
      ),
      body: groups.isEmpty
          ? const Center(child: Text('暂无小组，请添加'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final groupName = groups[index];
                final studentCount = students.where((s) => s.group == groupName).length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.group_work, color: Colors.purple),
                    ),
                    title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('$studentCount 名学生'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: '重命名',
                          onPressed: () {
                            _showRenameDialog(context, groupName, appProvider);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: '删除',
                          onPressed: () {
                            _showDeleteDialog(context, groupName, appProvider, studentCount);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                       _showRenameDialog(context, groupName, appProvider);
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

  void _showAddDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加小组'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '小组名称',
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
              if (newName.isNotEmpty && selectedClass != null) {
                provider.addGroupToClass(selectedClass!, newName);
              }
              Navigator.pop(context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, String oldName, AppProvider provider) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改小组名称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '小组名称',
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
              if (newName.isNotEmpty && newName != oldName && selectedClass != null) {
                provider.renameGroupInClass(selectedClass!, oldName, newName);
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String groupName, AppProvider provider, int studentCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除小组'),
        content: Text('确定要删除小组 "$groupName" 吗？\n该小组的 $studentCount 名学生将被移动到默认小组 (1)。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              if (selectedClass != null) {
                provider.deleteGroupFromClass(selectedClass!, groupName);
              }
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
