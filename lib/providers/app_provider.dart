import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/history_record.dart';
import '../services/data_service.dart';
import '../services/random_service.dart';
import '../models/app_config.dart';

class AppProvider with ChangeNotifier {
  final DataService _dataService = DataService();
  final RandomService _randomService = RandomService();

  List<Student> _allStudents = [];
  List<Student> _remainingStudents = [];
  List<Student> _currentSelection = [];
  List<HistoryRecord> _history = [];
  List<String> _groups = ['1'];
  Map<String, List<String>> _classGroups = {}; // ClassName -> List<GroupName>

  bool _isRolling = false;
  ThemeMode _themeMode = ThemeMode.system; // 默认跟随系统

  int _selectCount = 1;
  String? _selectedClass; // Null 表示全部
  String? _selectedGroup; // Null 表示全部小组
  String? _selectedGender; // Null 表示全部性别
  
  // 获取器
  List<Student> get allStudents => _allStudents;
  List<Student> get currentSelection => _currentSelection;
  bool get isRolling => _isRolling;
  ThemeMode get themeMode => _themeMode;
  int get selectCount => _selectCount;
  int get remainingCount => _remainingStudents.length;
  int get totalCount => _filteredStudents().length;
  String? get selectedClass => _selectedClass;
  String? get selectedGroup => _selectedGroup;
  String? get selectedGender => _selectedGender;
  List<HistoryRecord> get history => _history;

  // 获取筛选后的学生列表（用于动画显示）
  List<Student> get filteredStudents => _filteredStudents();
  List<String> get groups => _groups; // This is now class names

  // 构造函数
  AppProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _allStudents = await _dataService.loadStudents();
    _history = await _dataService.loadHistory();
    
    // 加载配置
    final config = await _dataService.loadConfig();
    _themeMode = _parseThemeMode(config.themeMode);
    _selectCount = config.selectCount;
    _selectedClass = config.selectedClass;

    // 合并配置中的 groups 和 JSON 文件中的 class keys
    // 注意：我们主要信任 JSON 文件中的 Key 作为班级列表，但也保留配置中的记录以防文件丢失或其他情况
    final jsonClassNames = await _dataService.loadClassNames();
    final configGroups = config.groups.toSet();
    
    _groups = {...configGroups, ...jsonClassNames}.toList()..sort();
    
    if (_groups.isEmpty) {
      _groups = ['1'];
    }

    // Initialize class groups
    _classGroups = Map.from(config.classGroups);
    // Merge with existing students' groups
    for (var student in _allStudents) {
      if (!_classGroups.containsKey(student.className)) {
        _classGroups[student.className] = [];
      }
      if (!_classGroups[student.className]!.contains(student.group)) {
        _classGroups[student.className]!.add(student.group);
      }
    }
    // Sort groups in each class
    _classGroups.forEach((key, value) {
      value.sort();
    });

    // 如果没有选择班级，默认选择第一个班级
    if (_selectedClass == null && _groups.isNotEmpty) {
      _selectedClass = _groups.first;
    }

    _resetRemaining();
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      case 'system': 
      default: return ThemeMode.system;
    }
  }
  
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      case ThemeMode.system: return 'system';
    }
  }

  Future<void> _saveConfig() async {
    final config = AppConfig(
      themeMode: _themeModeToString(_themeMode),
      selectCount: _selectCount,
      selectedClass: _selectedClass,
      groups: _groups,
      classGroups: _classGroups,
    );
    await _dataService.saveConfig(config);
  }

  // Group Management Methods

  List<String> getGroupsForClass(String? className) {
    if (className == null) return [];
    return _classGroups[className] ?? [];
  }

  Future<void> addGroupToClass(String className, String groupName) async {
    if (className.isEmpty || groupName.isEmpty) return;
    
    if (!_classGroups.containsKey(className)) {
      _classGroups[className] = [];
    }
    
    if (!_classGroups[className]!.contains(groupName)) {
      _classGroups[className]!.add(groupName);
      _classGroups[className]!.sort();
      await _saveConfig();
      notifyListeners();
    }
  }

  Future<void> renameGroupInClass(String className, String oldName, String newName) async {
    if (className.isEmpty || newName.isEmpty || oldName == newName) return;
    
    List<String> groups = _classGroups[className] ?? [];
    if (!groups.contains(oldName)) return;

    // 1. Add new group
    if (!groups.contains(newName)) {
      groups.add(newName);
      groups.sort();
    }
    
    // 2. Remove old group
    groups.remove(oldName);
    _classGroups[className] = groups;

    // 3. Update students
    bool studentsChanged = false;
    final List<Student> updatedStudents = [];
    for (var s in _allStudents) {
      if (s.className == className && s.group == oldName) {
        updatedStudents.add(Student(
          id: s.id,
          name: s.name,
          gender: s.gender,
          group: newName, // Update group name
          className: s.className,
          exist: s.exist,
        ));
        studentsChanged = true;
      } else {
        updatedStudents.add(s);
      }
    }

    if (studentsChanged) {
      _allStudents = updatedStudents;
      await _dataService.saveStudents(_allStudents);
      _resetRemaining();
    }

    await _saveConfig();
    notifyListeners();
  }

  Future<void> deleteGroupFromClass(String className, String groupName) async {
    if (className.isEmpty || groupName.isEmpty) return;
    
    List<String> groups = _classGroups[className] ?? [];
    if (!groups.contains(groupName)) return;

    // 1. Remove group
    groups.remove(groupName);
    _classGroups[className] = groups;

    // 2. Update students (Optional: clear group or keep it? 
    // Usually if a group is deleted, students shouldn't have it.
    // Let's set it to '1' or empty string? The previous logic used '1' as default.
    // Let's use '1' as default group if the specific group is deleted.
    bool studentsChanged = false;
    final List<Student> updatedStudents = [];
    for (var s in _allStudents) {
      if (s.className == className && s.group == groupName) {
        updatedStudents.add(Student(
          id: s.id,
          name: s.name,
          gender: s.gender,
          group: '1', // Reset to default group
          className: s.className,
          exist: s.exist,
        ));
        studentsChanged = true;
      } else {
        updatedStudents.add(s);
      }
    }

    if (studentsChanged) {
      _allStudents = updatedStudents;
      await _dataService.saveStudents(_allStudents);
      _resetRemaining();
    }

    await _saveConfig();
    notifyListeners();
  }

  Future<void> addClass(String className) async {
    if (className.isEmpty) return;
    if (!_groups.contains(className)) {
      _groups.add(className);
      _groups.sort();
      // Initialize class groups if not exists
      if (!_classGroups.containsKey(className)) {
        _classGroups[className] = ['1']; // Default group
      }
      await _saveConfig();
      notifyListeners();
    }
  }

  Future<void> renameClass(String oldName, String newName) async {
    if (newName.isEmpty || oldName == newName) return;
    
    // 1. 添加新班级（如果不存在）
    if (!_groups.contains(newName)) {
      _groups.add(newName);
      _groups.sort();
    }
    
    // 2. 移除旧班级
    if (_groups.contains(oldName)) {
      _groups.remove(oldName);
    }
    
    // 3. 更新所有相关学生
    bool studentsChanged = false;
    final List<Student> updatedStudents = [];
    for (var s in _allStudents) {
      if (s.className == oldName) {
        updatedStudents.add(Student(
          id: s.id,
          name: s.name,
          gender: s.gender,
          group: s.group,
          className: newName, // Update className
          exist: s.exist,
        ));
        studentsChanged = true;
      } else {
        updatedStudents.add(s);
      }
    }

    if (studentsChanged) {
      _allStudents = updatedStudents;
      await _dataService.saveStudents(_allStudents);
      _resetRemaining();
    }
    
    // 4. 如果当前选中的班级是被重命名的班级，更新选中状态
    if (_selectedClass == oldName) {
      _selectedClass = newName;
    }

    await _saveConfig();
    notifyListeners();
  }

  Future<void> deleteClass(String className) async {
    if (!_groups.contains(className)) return;

    // 1. 从列表中移除
    _groups.remove(className);

    // 2. 如果没有任何班级了，添加默认班级 '1'
    if (_groups.isEmpty) {
      _groups.add('1');
    }

    // 3. 直接删除该班级的所有学生
    _allStudents.removeWhere((s) => s.className == className);
    await _dataService.saveStudents(_allStudents);
    _resetRemaining();

    // 4. 删除该班级的小组配置
    _classGroups.remove(className);
    await _saveConfig();

    // 5. 如果当前选中的班级是被删除的班级，重置为全部或第一个
    if (_selectedClass == className) {
      _selectedClass = null; // 或者 _groups.first
    }

    await _saveConfig();
    notifyListeners();
  }


  void _resetRemaining() {
    _remainingStudents = List.from(_filteredStudents());
  }

  List<Student> _filteredStudents() {
    // 过滤掉 exist 为 false 的学生
    var filtered = _allStudents.where((s) => s.exist).toList();

    // 按班级筛选
    if (_selectedClass != null && _selectedClass != 'All') {
      filtered = filtered.where((s) => s.className == _selectedClass).toList();
    }

    // 按小组筛选
    if (_selectedGroup != null && _selectedGroup != 'All') {
      filtered = filtered.where((s) => s.group == _selectedGroup).toList();
    }

    // 按性别筛选
    if (_selectedGender != null && _selectedGender != 'All') {
      filtered = filtered.where((s) => s.gender == _selectedGender).toList();
    }

    return filtered;
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveConfig(); // 保存配置
    notifyListeners();
  }

  void setSelectCount(int count) {
    if (count < 1) count = 1;
    final maxCount = _filteredStudents().length;
    if (maxCount > 0 && count > maxCount) count = maxCount;
    _selectCount = count;
    _saveConfig();
    notifyListeners();
  }

  void setSelectedClass(String? className) {
    _selectedClass = className;
    // 切换班级时，重置小组和性别筛选
    _selectedGroup = null;
    _selectedGender = null;
    _resetRemaining();
    _saveConfig();
    notifyListeners();
  }

  void setSelectedGroup(String? groupName) {
    _selectedGroup = groupName;
    _resetRemaining();
    notifyListeners();
  }

  void setSelectedGender(String? gender) {
    _selectedGender = gender;
    _resetRemaining();
    notifyListeners();
  }

  Future<void> addStudent(String name, String gender, String group, String className) async {
    // Ensure class exists (className is what we manage in _groups)
    if (!_groups.contains(className)) {
      _groups.add(className);
      _groups.sort();
      await _saveConfig();
    }

    // ID 生成逻辑：在当前班级的学生中找最大 ID + 1，实现班级独立计数
    int newId = 1;
    final classStudents = _allStudents.where((s) => s.className == className).toList();
    if (classStudents.isNotEmpty) {
      newId = classStudents.map((s) => s.id).reduce((curr, next) => curr > next ? curr : next) + 1;
    }

    final newStudent = Student(
      id: newId,
      name: name,
      gender: gender,
      group: group,
      className: className,
      exist: true,
    );

    _allStudents.add(newStudent);
    await _dataService.saveStudents(_allStudents);
    _resetRemaining();
    notifyListeners();
  }

  Future<void> updateStudentName(int id, String newName) async {
    final index = _allStudents.indexWhere((s) => s.id == id && s.className == _selectedClass);
    if (index != -1) {
      final old = _allStudents[index];
      _allStudents[index] = Student(
        id: old.id,
        name: newName,
        gender: old.gender,
        group: old.group,
        className: old.className,
        exist: old.exist,
      );
      await _dataService.saveStudents(_allStudents);
      notifyListeners();
    }
  }

  Future<void> updateStudentGroup(int id, String newGroup) async {
    // This updates the 'group' field, not the class
    final index = _allStudents.indexWhere((s) => s.id == id && s.className == _selectedClass);
    if (index != -1) {
      final old = _allStudents[index];
      _allStudents[index] = Student(
        id: old.id,
        name: old.name,
        gender: old.gender,
        group: newGroup,
        className: old.className,
        exist: old.exist,
      );
      await _dataService.saveStudents(_allStudents);
      notifyListeners();
    }
  }

  Future<void> updateStudentGender(int id, String newGender) async {
    final index = _allStudents.indexWhere((s) => s.id == id && s.className == _selectedClass);
    if (index != -1) {
      final old = _allStudents[index];
      _allStudents[index] = Student(
        id: old.id,
        name: old.name,
        gender: newGender,
        group: old.group,
        className: old.className,
        exist: old.exist,
      );
      await _dataService.saveStudents(_allStudents);
      notifyListeners();
    }
  }

  Future<void> deleteStudent(int id) async {
    // 软删除：设置 exist 为 false，或者直接物理删除？
    // 考虑到用户明确说“删除”，且 JSON 结构有 exist 字段，我们可以选择软删除或物理删除。
    // 如果物理删除，ID 可能会有空缺。如果软删除，exist=false。
    // 为了符合一般用户习惯"删除"即消失，我们这里做物理删除，或者 exist=false 并不再显示。
    // 这里我们使用物理删除，简单直接。
    _allStudents.removeWhere((s) => s.id == id && s.className == _selectedClass);
    await _dataService.saveStudents(_allStudents);
    _resetRemaining();
    notifyListeners();
  }

  Future<void> startRollCall() async {
    if (_isRolling) return;
    
    _isRolling = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1)); 
    
    if (_remainingStudents.length < _selectCount) {
        _resetRemaining();
    }
    
    final picked = _randomService.pickRandomStudents(_remainingStudents, _selectCount);
    _currentSelection = picked;
    
    for (var s in picked) {
      _remainingStudents.removeWhere((r) => r.id == s.id);
    }

    // 添加到历史记录
    final now = DateTime.now();
    final timeStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    
    final newId = _history.isEmpty ? 1 : (_history.first.id + 1);
    
    final nameStr = picked.map((s) => s.name).join(',');

    final record = HistoryRecord(
      id: newId,
      name: nameStr,
      drawMethod: 1,
      drawTime: timeStr,
      drawPeopleNumbers: picked.length,
      drawGroup: _selectedGroup ?? '所有小组',
      drawGender: _selectedGender ?? '所有性别',
      className: _selectedClass ?? '1',
    );

    _history.insert(0, record);
    if (_history.length > 50) _history.removeLast(); 
    
    await _dataService.saveHistory(_history);

    _isRolling = false;
    notifyListeners();
  }
}
