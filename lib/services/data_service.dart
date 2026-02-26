import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
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
  static const String _cookiePrefix = 'secrandom_';

  static bool get _isWeb => kIsWeb;

  Future<String?> _getDataDirPath() async {
    if (_isWeb) {
      return null;
    }
    
    if (Platform.isAndroid || Platform.isIOS) {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dataDir = Directory(path.join(appDocDir.path, _dataDirName));
      
      if (!await dataDir.exists()) {
        await dataDir.create(recursive: true);
      }
      return dataDir.path;
    } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      final String rootPath = path.dirname(Platform.resolvedExecutable);
      final dataDir = Directory(path.join(rootPath, _dataDirName));
      
      if (!await dataDir.exists()) {
        await dataDir.create(recursive: true);
      }
      return dataDir.path;
    } else {
      return null;
    }
  }

  void _setWebCookie(String key, String value) {
    if (_isWeb) {
      final cookieName = '$_cookiePrefix$key';
      final cookieValue = Uri.encodeComponent(value);
      final expires = DateTime.now().add(const Duration(days: 365)).toUtc().toIso8601String();
      
      html.document.cookie = '$cookieName=$cookieValue; expires=$expires; path=/';
    }
  }

  String? _getWebCookie(String key) {
    if (_isWeb) {
      final cookies = html.document.cookie;
      if (cookies == null || cookies.isEmpty) {
        return null;
      }
      final cookieName = '$_cookiePrefix$key';
      final regex = RegExp('$cookieName=([^;]*)');
      final match = regex.firstMatch(cookies);
      return match?.group(1);
    }
    return null;
  }

  Future<File> _getStudentsFile() async {
    final dirPath = await _getDataDirPath();
    if (dirPath == null) {
      throw UnsupportedError('File system not available on web platform');
    }
    return File(path.join(dirPath, _studentsFileName));
  }

  Future<File> _getHistoryFile() async {
    final dirPath = await _getDataDirPath();
    if (dirPath == null) {
      throw UnsupportedError('File system not available on web platform');
    }
    return File(path.join(dirPath, _historyFileName));
  }

  Future<File> _getConfigFile() async {
    final dirPath = await _getDataDirPath();
    if (dirPath == null) {
      throw UnsupportedError('File system not available on web platform');
    }
    return File(path.join(dirPath, _configFileName));
  }

  Future<void> saveStudents(List<Student> students) async {
    try {
      if (!_isWeb) {
        final file = await _getStudentsFile();
        
        final Map<String, List<Map<String, dynamic>>> dataMap = {};
        
        for (var student in students) {
          if (!dataMap.containsKey(student.className)) {
            dataMap[student.className] = [];
          }
          final json = student.toJson();
          json.remove('class_name'); 
          dataMap[student.className]!.add(json);
        }

        final String data = const JsonEncoder.withIndent('  ').convert(dataMap);
        await file.writeAsString(data);
      } else {
        final Map<String, dynamic> dataMap = {};
        
        for (var student in students) {
          if (!dataMap.containsKey(student.className)) {
            dataMap[student.className] = [];
          }
          final json = student.toJson();
          json.remove('class_name'); 
          if (dataMap[student.className] is! List) {
            dataMap[student.className] = [];
          }
          (dataMap[student.className] as List).add(json);
        }
        
        final String jsonData = const JsonEncoder.withIndent('  ').convert(dataMap);
        
        if (jsonData.length > 1000000) {
          print('Warning: Students data is large (${jsonData.length} chars), may cause performance issues');
        }
        
        _setWebCookie(_studentsFileName, jsonData);
      }
    } catch (e) {
      print('Error saving students: $e');
      rethrow;
    }
  }

  Future<List<Student>> loadStudents() async {
    try {
      if (!_isWeb) {
        final file = await _getStudentsFile();
        if (!await file.exists()) {
          final initialData = _getInitialStudents();
          await saveStudents(initialData); 
          return initialData;
        }
        final String data = await file.readAsString();
        if (data.isEmpty) {
          final initialData = _getInitialStudents();
          await saveStudents(initialData);
          return initialData;
        }
        
        final Map<String, dynamic> jsonMap = json.decode(data);
        final List<Student> allStudents = [];

        if (jsonMap.containsKey(_rootKey)) {
          final List<dynamic> jsonList = jsonMap[_rootKey];
          return jsonList.map((json) {
              if (json is Map<String, dynamic>) {
                  json['class_name'] = '1';
              }
              return Student.fromJson(json);
          }).toList();
        }

        jsonMap.forEach((className, studentsList) {
          if (studentsList is List) {
            for (var studentJson in studentsList) {
              if (studentJson is Map<String, dynamic>) {
                 final mutableJson = Map<String, dynamic>.from(studentJson);
                 mutableJson['class_name'] = className;
                 allStudents.add(Student.fromJson(mutableJson));
              }
            }
          }
        });
        
        if (allStudents.isEmpty) {
          final initialData = _getInitialStudents();
          await saveStudents(initialData);
          return initialData;
        }
        
        return allStudents;
      } else {
        final String? jsonData = _getWebCookie(_studentsFileName);
        if (jsonData == null || jsonData.isEmpty) {
          final initialData = _getInitialStudents();
          await saveStudents(initialData);
          return initialData;
        }
        
        final Map<String, dynamic> jsonMap = json.decode(jsonData);
        final List<Student> allStudents = [];

        if (jsonMap.containsKey(_rootKey)) {
          final List<dynamic> jsonList = jsonMap[_rootKey];
          return jsonList.map((json) {
              if (json is Map<String, dynamic>) {
                  json['class_name'] = '1';
              }
              return Student.fromJson(json);
          }).toList();
        }

        jsonMap.forEach((className, studentsList) {
          if (studentsList is List) {
            for (var studentJson in studentsList) {
              if (studentJson is Map<String, dynamic>) {
                 final mutableJson = Map<String, dynamic>.from(studentJson);
                 mutableJson['class_name'] = className;
                 allStudents.add(Student.fromJson(mutableJson));
              }
            }
          }
        });
        
        if (allStudents.isEmpty) {
          final initialData = _getInitialStudents();
          await saveStudents(initialData);
          return initialData;
        }
        
        return allStudents;
      }
    } catch (e) {
      return _getInitialStudents();
    }
  }

  // Helper method to get class names from students file without parsing everything
  Future<List<String>> loadClassNames() async {
     try {
      if (!_isWeb) {
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
        
        return jsonMap.keys.toList();
      } else {
        final String? jsonData = _getWebCookie(_studentsFileName);
        if (jsonData == null || jsonData.isEmpty) {
          return ['1'];
        }
        
        final Map<String, dynamic> jsonMap = json.decode(jsonData);
        if (jsonMap.containsKey(_rootKey)) {
          return ['1'];
        }
        
        return jsonMap.keys.toList();
      }
    } catch (e) {
      return ['1'];
    }
  }

  Future<void> saveHistory(List<HistoryRecord> history) async {
    try {
      if (!_isWeb) {
        final file = await _getHistoryFile();
        final Map<String, dynamic> dataMap = {};
        
        for (var record in history) {
          final className = record.className;
          if (!dataMap.containsKey(className)) {
            dataMap[className] = [];
          }
          (dataMap[className] as List).add(record.toJson());
        }
        
        await file.writeAsString(const JsonEncoder.withIndent('  ').convert(dataMap));
      } else {
        final Map<String, dynamic> dataMap = {};
        
        for (var record in history) {
          final className = record.className;
          if (!dataMap.containsKey(className)) {
            dataMap[className] = [];
          }
          (dataMap[className] as List).add(record.toJson());
        }
        
        final String jsonData = const JsonEncoder.withIndent('  ').convert(dataMap);
        
        if (jsonData.length > 1000000) {
          print('Warning: History data is large (${jsonData.length} chars), may cause performance issues');
        }
        
        _setWebCookie(_historyFileName, jsonData);
      }
    } catch (e) {
      print('Error saving history: $e');
      rethrow;
    }
  }

  Future<List<HistoryRecord>> loadHistory() async {
    try {
      if (!_isWeb) {
        final file = await _getHistoryFile();
        if (!await file.exists()) {
          return [];
        }
        final String data = await file.readAsString();
        if (data.isEmpty) return [];
        
        final Map<String, dynamic> jsonMap = json.decode(data);
        final List<HistoryRecord> result = [];
        
        if (jsonMap.containsKey(_rootKey)) {
          final List<dynamic> jsonList = jsonMap[_rootKey];
          return jsonList.map((json) => HistoryRecord.fromJson(json)).toList();
        }
        
        for (var className in jsonMap.keys) {
          final List<dynamic> jsonList = jsonMap[className];
          for (var json in jsonList) {
            result.add(HistoryRecord.fromJson(json, className: className));
          }
        }
        
        return result;
      } else {
        final String? jsonData = _getWebCookie(_historyFileName);
        if (jsonData == null || jsonData.isEmpty) {
          return [];
        }
        
        final Map<String, dynamic> jsonMap = json.decode(jsonData);
        final List<HistoryRecord> result = [];
        
        if (jsonMap.containsKey(_rootKey)) {
          final List<dynamic> jsonList = jsonMap[_rootKey];
          return jsonList.map((json) => HistoryRecord.fromJson(json)).toList();
        }
        
        for (var className in jsonMap.keys) {
          final List<dynamic> jsonList = jsonMap[className];
          for (var json in jsonList) {
            result.add(HistoryRecord.fromJson(json, className: className));
          }
        }
        
        return result;
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> addHistoryRecord(HistoryRecord record) async {
    try {
      if (!_isWeb) {
        final file = await _getHistoryFile();
        Map<String, dynamic> dataMap = {};
        
        if (await file.exists()) {
          final String data = await file.readAsString();
          if (data.isNotEmpty) {
            try {
              dataMap = json.decode(data) as Map<String, dynamic>;
            } catch (e) {
              dataMap = {};
            }
          }
        }
        
        final className = record.className;
        if (!dataMap.containsKey(className)) {
          dataMap[className] = [];
        }
        (dataMap[className] as List).add(record.toJson());
        
        await file.writeAsString(const JsonEncoder.withIndent('  ').convert(dataMap));
      } else {
        Map<String, dynamic> dataMap = {};
        
        final String? existingData = _getWebCookie(_historyFileName);
        if (existingData != null && existingData.isNotEmpty) {
          try {
            dataMap = json.decode(existingData) as Map<String, dynamic>;
          } catch (e) {
            dataMap = {};
          }
        }
        
        final className = record.className;
        if (!dataMap.containsKey(className)) {
          dataMap[className] = [];
        }
        (dataMap[className] as List).add(record.toJson());
        
        final String jsonData = const JsonEncoder.withIndent('  ').convert(dataMap);
        
        if (jsonData.length > 1000000) {
          print('Warning: History data is large (${jsonData.length} chars), may cause performance issues');
        }
        
        _setWebCookie(_historyFileName, jsonData);
      }
    } catch (e) {
      print('Error adding history record: $e');
      rethrow;
    }
  }

  Future<void> saveConfig(AppConfig config) async {
    try {
      if (!_isWeb) {
        final file = await _getConfigFile();
        final Map<String, dynamic> dataMap = {
          _configRootKey: config.toJson(),
        };
        await file.writeAsString(const JsonEncoder.withIndent('  ').convert(dataMap));
      } else {
        final Map<String, dynamic> dataMap = {
          _configRootKey: config.toJson(),
        };
        final String jsonData = const JsonEncoder.withIndent('  ').convert(dataMap);
        
        if (jsonData.length > 1000000) {
          print('Warning: Config data is large (${jsonData.length} chars), may cause performance issues');
        }
        
        _setWebCookie(_configFileName, jsonData);
      }
    } catch (e) {
      print('Error saving config: $e');
      rethrow;
    }
  }

  Future<AppConfig> loadConfig() async {
    try {
      if (!_isWeb) {
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
      } else {
        final String? jsonData = _getWebCookie(_configFileName);
        if (jsonData == null || jsonData.isEmpty) {
          final defaultConfig = AppConfig.defaultConfig();
          await saveConfig(defaultConfig);
          return defaultConfig;
        }

        final Map<String, dynamic> jsonMap = json.decode(jsonData);
        if (jsonMap.containsKey(_configRootKey)) {
          return AppConfig.fromJson(jsonMap[_configRootKey]);
        }

        return AppConfig.defaultConfig();
      }
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
