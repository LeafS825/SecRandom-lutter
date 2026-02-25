import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/student.dart';

class NameSettingsScreen extends StatelessWidget {
  final String? selectedClass;
  const NameSettingsScreen({super.key, this.selectedClass});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final students = selectedClass == null
        ? appProvider.allStudents
        : appProvider.allStudents.where((s) => s.className == selectedClass).toList();

    return Scaffold(
      appBar: AppBar(title: Text('设置姓名 ${selectedClass != null ? "($selectedClass)" : ""}')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(child: Text('${student.id}')),
              title: Text(student.name),
              subtitle: Text('${student.gender} | ${student.group}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _showEditNameDialog(context, student, appProvider);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmDialog(context, student, appProvider);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddStudentDialog(context, appProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, Student student, AppProvider provider) {
    final controller = TextEditingController(text: student.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改姓名'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '姓名'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.updateStudentName(student.id, controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Student student, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除学生'),
        content: Text('确定要删除学生 "${student.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteStudent(student.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context, AppProvider provider) {
    final nameController = TextEditingController();
    // Default group to 1
    final groupController = TextEditingController(text: '1');
    String gender = '男';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('添加学生'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '姓名'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: const InputDecoration(labelText: '性别'),
                    items: ['男', '女', '未知'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => gender = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: groupController,
                    decoration: const InputDecoration(labelText: '小组'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    provider.addStudent(
                      nameController.text.trim(),
                      gender,
                      groupController.text.trim(),
                      selectedClass ?? '1', // Pass selected class
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('添加'),
              ),
            ],
          );
        },
      ),
    );
  }
}
