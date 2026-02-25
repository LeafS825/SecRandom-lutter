import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class GroupAllocationScreen extends StatelessWidget {
  final String? selectedClass;
  const GroupAllocationScreen({super.key, this.selectedClass});

  @override
  Widget build(BuildContext context) {
    if (selectedClass == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('分配小组')),
        body: const Center(child: Text('请先选择一个班级')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('分配小组 ($selectedClass)')),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final groups = appProvider.getGroupsForClass(selectedClass);
          final students = selectedClass == null
              ? appProvider.allStudents
              : appProvider.allStudents.where((s) => s.className == selectedClass).toList();

          if (groups.isEmpty) {
            return const Center(child: Text('暂无小组，请先在设置中添加小组'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${student.id}')),
                  title: Text(student.name),
                  trailing: DropdownButton<String>(
                    value: groups.contains(student.group) ? student.group : null,
                    hint: const Text('选择小组'),
                    items: groups.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        appProvider.updateStudentGroup(student.id, newValue);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
