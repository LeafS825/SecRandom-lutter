import 'package:flutter/foundation.dart' show debugPrint;
import 'package:logger/logger.dart';
import '../services/log_service.dart';

/// 应用日志工具
///
/// 使用方式:
/// ```dart
/// import '../utils/logger.dart';
///
/// logger.e('错误信息', error: e, stackTrace: stackTrace);
/// logger.w('警告信息');
/// logger.i('信息');
/// logger.d('调试信息');
/// ```
final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  output: AppLogOutput(),
);

/// 自定义日志输出，同时保存到 SharedPreferences
class AppLogOutput extends LogOutput {
  final AppLogService _logService = AppLogService();

  @override
  void output(OutputEvent event) {
    // 先打印到控制台
    event.lines.forEach(debugPrint);

    // 异步保存到存储
    _saveLog(event);
  }

  void _saveLog(OutputEvent event) async {
    try {
      final level = _convertLevel(event.level);
      final message = event.lines.join('\n');

      await _logService.addLog(LogEntry(
        timestamp: DateTime.now(),
        level: level,
        message: message,
      ));
    } catch (_) {
      // 日志保存失败时静默处理，避免递归错误
    }
  }

  LogLevel _convertLevel(Level level) {
    switch (level) {
      case Level.trace:
        return LogLevel.verbose;
      case Level.debug:
        return LogLevel.debug;
      case Level.info:
        return LogLevel.info;
      case Level.warning:
        return LogLevel.warning;
      case Level.error:
        return LogLevel.error;
      case Level.fatal:
        return LogLevel.wtf;
      default:
        return LogLevel.debug;
    }
  }
}
