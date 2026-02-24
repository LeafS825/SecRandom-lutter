import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/student.dart';
import '../models/history_record.dart';
import '../models/app_config.dart';

class DataService {
  static const String _dataDirName = 'data';
  static const String _studentsFileName = 'students.json';
  static const String _historyFileName = 'history.json';
  static const String _configFileName = 'config.json';
  static const String _rootKey = 'class_name';
  static const String _configRootKey = 'config';

  Future<String> _getDataDirPath() async {
    Directory dataDir;
    if (Platform.isAndroid || Platform.isIOS) {
      // 移动端：使用应用文档目录（沙盒目录）
      final appDocDir = await getApplicationDocumentsDirectory();
      dataDir = Directory(path.join(appDocDir.path, _dataDirName));
    } else {
      // 桌面端：尝试使用可执行文件所在目录（便携式）
      final String rootPath = path.dirname(Platform.resolvedExecutable);
      dataDir = Directory(path.join(rootPath, _dataDirName));
    }

    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    return dataDir.path;
  }

  Future<File> _getStudentsFile() async {
    final dirPath = await _getDataDirPath();
    return File(path.join(dirPath, _studentsFileName));
  }

  Future<File> _getHistoryFile() async {
    final dirPath = await _getDataDirPath();
    return File(path.join(dirPath, _historyFileName));
  }

  Future<File> _getConfigFile() async {
    final dirPath = await _getDataDirPath();
    return File(path.join(dirPath, _configFileName));
  }

  Future<void> saveStudents(List<Student> students) async {
    final file = await _getStudentsFile();
    
    // Group students by class name
    final Map<String, List<Map<String, dynamic>>> dataMap = {};
    
    for (var student in students) {
      if (!dataMap.containsKey(student.className)) {
        dataMap[student.className] = [];
      }
      // Remove 'class_name' from stored json as it is the key
      final json = student.toJson();
      json.remove('class_name'); 
      dataMap[student.className]!.add(json);
    }

    final String data = const JsonEncoder.withIndent('  ').convert(dataMap);
    await file.writeAsString(data);
  }

  Future<List<Student>> loadStudents() async {
    try {
      final file = await _getStudentsFile();
      if (!await file.exists()) {
        final initialData = _getInitialStudents();
        await saveStudents(initialData); 
        return initialData;
      }
      final String data = await file.readAsString();
      if (data.isEmpty) return [];
      
      final Map<String, dynamic> jsonMap = json.decode(data);
      final List<Student> allStudents = [];

      // Check if it's the old format (contains _rootKey)
      if (jsonMap.containsKey(_rootKey)) {
        // Migration logic: treat all as class "1"
        final List<dynamic> jsonList = jsonMap[_rootKey];
        return jsonList.map((json) {
            // Add default class name
            if (json is Map<String, dynamic>) {
                json['class_name'] = '1';
                // If old format, group was actually class name, so we might want to keep it as group too?
                // Or maybe group was always '1' in old logic?
                // The prompt says "group字段有别的用" (group field has other uses).
                // So we should respect whatever is in the JSON for 'group'.
            }
            return Student.fromJson(json);
        }).toList();
      }

      // New format: Key is class name, Value is list of students
      jsonMap.forEach((className, studentsList) {
        if (studentsList is List) {
          for (var studentJson in studentsList) {
            if (studentJson is Map<String, dynamic>) {
               final mutableJson = Map<String, dynamic>.from(studentJson);
               mutableJson['class_name'] = className; // Inject class name
               allStudents.add(Student.fromJson(mutableJson));
            }
          }
        }
      });
      
      return allStudents;
    } catch (e) {
      return _getInitialStudents();
    }
  }

  // Helper method to get class names from students file without parsing everything
  Future<List<String>> loadClassNames() async {
     try {
      final file = await _getStudentsFile();
      if (!await file.exists()) {
        return ['1'];
      }
      final String data = await file.readAsString();
      if (data.isEmpty) return ['1'];
      
      final Map<String, dynamic> jsonMap = json.decode(data);
      if (jsonMap.containsKey(_rootKey)) {
        return ['1'];
      }
      
      // Filter out keys that might not be class names (though in new format all keys are class names)
      return jsonMap.keys.toList();
    } catch (e) {
      return ['1'];
    }
  }

  Future<void> saveHistory(List<HistoryRecord> history) async {
    final file = await _getHistoryFile();
    final Map<String, dynamic> dataMap = {
      _rootKey: history.map((h) => h.toJson()).toList(),
    };
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(dataMap));
  }

  Future<List<HistoryRecord>> loadHistory() async {
    try {
      final file = await _getHistoryFile();
      if (!await file.exists()) {
        return [];
      }
      final String data = await file.readAsString();
      if (data.isEmpty) return [];
      
      final Map<String, dynamic> jsonMap = json.decode(data);
      if (jsonMap.containsKey(_rootKey)) {
        final List<dynamic> jsonList = jsonMap[_rootKey];
        return jsonList.map((json) => HistoryRecord.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> saveConfig(AppConfig config) async {
    final file = await _getConfigFile();
    final Map<String, dynamic> dataMap = {
      _configRootKey: config.toJson(),
    };
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(dataMap));
  }

  Future<AppConfig> loadConfig() async {
    try {
      final file = await _getConfigFile();
      if (!await file.exists()) {
        final defaultConfig = AppConfig.defaultConfig();
        await saveConfig(defaultConfig);
        return defaultConfig;
      }
      final String data = await file.readAsString();
      if (data.isEmpty) return AppConfig.defaultConfig();

      final Map<String, dynamic> jsonMap = json.decode(data);
      if (jsonMap.containsKey(_configRootKey)) {
        return AppConfig.fromJson(jsonMap[_configRootKey]);
      }
      return AppConfig.defaultConfig();
    } catch (e) {
      return AppConfig.defaultConfig();
    }
  }

  List<Student> _getInitialStudents() {
    return List.generate(40, (index) {
      return Student(
        id: index + 1,
        name: '学生 ${index + 1}',
        gender: index % 2 == 0 ? '男' : '女',
        group: '1',
        className: '1', // Default class
        exist: true,
      );
    });
  }
}
