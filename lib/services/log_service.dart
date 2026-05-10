import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 日志级别枚举
enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  wtf,
}

/// 日志条目
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? error;
  final String? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'level': level.index,
    'message': message,
    'error': error,
    'stackTrace': stackTrace,
  };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
    timestamp: DateTime.parse(json['timestamp']),
    level: LogLevel.values[json['level']],
    message: json['message'],
    error: json['error'],
    stackTrace: json['stackTrace'],
  );
}

/// 应用日志服务
/// 
/// 负责日志的存储、开关控制、清除和导出
class AppLogService {
  static final AppLogService _instance = AppLogService._internal();
  factory AppLogService() => _instance;
  AppLogService._internal();

  static const String _logsKey = 'app_logs';
  static const String _loggingEnabledKey = 'logging_enabled';
  static const int _maxLogCount = 500;

  SharedPreferences? _prefs;
  bool _initialized = false;

  /// 初始化
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// 是否启用了日志记录
  Future<bool> isLoggingEnabled() async {
    await init();
    return _prefs?.getBool(_loggingEnabledKey) ?? true;
  }

  /// 设置日志开关
  Future<void> setLoggingEnabled(bool enabled) async {
    await init();
    await _prefs?.setBool(_loggingEnabledKey, enabled);
  }

  /// 添加日志条目
  Future<void> addLog(LogEntry entry) async {
    await init();
    
    final enabled = await isLoggingEnabled();
    if (!enabled) return;

    final logs = await _getLogs();
    logs.add(entry);

    // 保持最多 _maxLogCount 条日志
    while (logs.length > _maxLogCount) {
      logs.removeAt(0);
    }

    await _saveLogs(logs);
  }

  /// 获取所有日志
  Future<List<LogEntry>> getLogs() async {
    await init();
    return await _getLogs();
  }

  /// 清除所有日志
  Future<void> clearLogs() async {
    await init();
    await _prefs?.remove(_logsKey);
  }

  /// 导出日志为字符串
  Future<String> exportLogsAsString() async {
    final logs = await getLogs();
    if (logs.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('=== SecRandom Lite 日志导出 ===');
    buffer.writeln('导出时间: ${DateTime.now().toIso8601String()}');
    buffer.writeln('日志总数: ${logs.length}');
    buffer.writeln('');

    for (final log in logs) {
      buffer.writeln(_formatLogEntry(log));
    }

    return buffer.toString();
  }

  /// 获取日志级别标签
  static String getLevelLabel(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return 'VERBOSE';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.wtf:
        return 'WTF';
    }
  }

  /// 获取日志级别颜色
  static int getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return 0xFF9E9E9E;
      case LogLevel.debug:
        return 0xFF2196F3;
      case LogLevel.info:
        return 0xFF4CAF50;
      case LogLevel.warning:
        return 0xFFFF9800;
      case LogLevel.error:
        return 0xFFF44336;
      case LogLevel.wtf:
        return 0xFF9C27B0;
    }
  }

  // 私有方法

  Future<List<LogEntry>> _getLogs() async {
    final jsonString = _prefs?.getString(_logsKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => LogEntry.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveLogs(List<LogEntry> logs) async {
    final jsonList = logs.map((e) => e.toJson()).toList();
    await _prefs?.setString(_logsKey, json.encode(jsonList));
  }

  String _formatLogEntry(LogEntry entry) {
    final time = entry.timestamp.toIso8601String();
    final level = getLevelLabel(entry.level).padRight(7);
    final msg = entry.message;
    
    if (entry.error != null) {
      return '[$time] [$level] $msg\nError: ${entry.error}';
    }
    return '[$time] [$level] $msg';
  }
}
