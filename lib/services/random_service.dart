import 'dart:math';
import '../models/student.dart';

class RandomService {
  final Random _random = Random();

  /// 从 [availableStudents] 中返回 [count] 个唯一的学生。
  /// 如果 [count] 大于可用数量，则返回所有可用学生。
  List<Student> pickRandomStudents(List<Student> availableStudents, int count) {
    if (availableStudents.isEmpty) return [];
    
    // 创建副本以避免在打乱时修改原始列表
    List<Student> pool = List.from(availableStudents);
    pool.shuffle(_random);
    
    return pool.take(count).toList();
  }
}
