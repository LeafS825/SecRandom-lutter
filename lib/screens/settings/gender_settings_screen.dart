import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class GenderSettingsScreen extends StatelessWidget {
  final String? selectedClass;
  const GenderSettingsScreen({super.key, this.selectedClass});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final students = selectedClass != null
        ? appProvider.allStudents.where((s) => s.className == selectedClass).toList()
        : appProvider.allStudents;

    return Scaffold(
      appBar: AppBar(title: Text('设置性别 ${selectedClass != null ? "($selectedClass)" : ""}')),
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
              trailing: DropdownButton<String>(
                value: student.gender,
                items: ['男', '女', '未知'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    // TODO: Update gender
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
