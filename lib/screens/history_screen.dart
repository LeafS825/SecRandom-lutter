import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/student.dart';
import '../models/history_record.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedClass = '1'; // 默认班级
  String _viewMode = '全部记录'; // 默认查看模式
  String? _selectedStudent;
  int? _sortColumn;
  bool _sortAscending = true;

  // 分段加载相关状态
  final int _batchSize = 30; // 每次加载的行数
  int _currentRow = 0; // 当前加载到的行数
  int _totalRows = 0; // 总行数
  bool _isLoading = false; // 是否正在加载数据
  bool _hasLoadedAll = false; // 是否已加载全部数据

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoading || _hasLoadedAll) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const delta = 200.0; // 滚动阈值

    if (maxScroll - currentScroll <= delta) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (_isLoading || _hasLoadedAll || _currentRow >= _totalRows) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 模拟异步加载，确保UI更新
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        final newRow = _currentRow + _batchSize;
        _currentRow = newRow > _totalRows ? _totalRows : newRow;
        _hasLoadedAll = _currentRow >= _totalRows;
        _isLoading = false;
      });
    });
  }

  void _resetPagination() {
    setState(() {
      _currentRow = 0; // 重置为0，让build方法自动设置初始加载量
      _totalRows = 0;
      _isLoading = false;
      _hasLoadedAll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final allStudents = appProvider.allStudents;
    final history = appProvider.history;

    final Set<String> classNames = allStudents.map((s) => s.className).toSet();
    final List<String> classOptions = classNames.toList()..sort();
    if (!classOptions.contains(_selectedClass) && classOptions.isNotEmpty) {
      _selectedClass = classOptions.first;
    }

    // 过滤当前选中班级的学生
    final filteredStudents = allStudents.where((s) => s.className == _selectedClass).toList();
    // 过滤当前选中班级的历史记录
    final filteredHistory = history.where((h) => h.className == _selectedClass).toList();

    // 计算点名次数（只统计当前班级的历史记录）
    final Map<String, int> callCounts = {};
    for (var record in filteredHistory) {
      final names = record.name.split(',').map((e) => e.trim()).toList();
      for (var name in names) {
        callCounts[name] = (callCounts[name] ?? 0) + 1;
      }
    }

    final List<Student> displayData = _getDisplayData(filteredStudents, filteredHistory, callCounts);
    final List<String> headers = _getHeaders();
    
    // 计算总数据量
    final List<List<String>> allTableData = _getTableData(displayData, filteredHistory, callCounts);
    _totalRows = allTableData.length;
    
    // 首次加载时自动设置初始加载量
    if (_currentRow == 0 && _totalRows > 0) {
      _currentRow = _totalRows < _batchSize ? _totalRows : _batchSize;
    }
    
    // 只显示当前已加载的数据
    final List<List<String>> tableData = allTableData.take(_currentRow).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                '点名历史记录表格',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            
            Card(
              elevation: 0, // 扁平风格
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  // 筛选器 1: 选择班级
                  _buildFilterRow(
                    icon: Icons.bookmark_outline,
                    title: '选择班级',
                    subtitle: '选择要查看历史记录的班级',
                    trailing: DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButton<String>(
                          value: classOptions.contains(_selectedClass) ? _selectedClass : null,
                          isDense: true,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          dropdownColor: Theme.of(context).cardColor,
                          items: classOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedClass = newValue;
                                _selectedStudent = null;
                                _resetPagination();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // 筛选器 2: 查看模式
                  _buildFilterRow(
                    icon: Icons.description_outlined,
                    title: '查看模式',
                    subtitle: '选择历史记录的查看方式',
                    trailing: DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButton<String>(
                          value: _viewMode,
                          isDense: true,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          dropdownColor: Theme.of(context).cardColor,
                          items: <String>['全部记录', '按时间查看', '个人记录'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _viewMode = newValue;
                                  _selectedStudent = null;
                                  _sortColumn = null;
                                  _sortAscending = true;
                                  _resetPagination();
                                });
                              }
                            },
                        ),
                      ),
                    ),
                  ),

                  if (_viewMode == '个人记录')
                    Column(
                      children: [
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _buildFilterRow(
                          icon: Icons.person_outline,
                          title: '选择学生',
                          subtitle: '选择要查看历史记录的学生',
                          trailing: DropdownButtonHideUnderline(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedStudent,
                                isDense: true,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                                dropdownColor: Theme.of(context).cardColor,
                                hint: Text('请选择学生', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                                items: filteredStudents.map((student) {
                                  return DropdownMenuItem<String>(
                                    value: student.name,
                                    child: Text(student.name),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedStudent = newValue;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // 数据表格
                  SizedBox(
                    width: double.infinity,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Theme.of(context).dividerColor,
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            if (Theme.of(context).brightness == Brightness.dark) {
                              return const Color(0xFF303030);
                            }
                            return const Color(0xFFFAFAFA);
                          },
                        ),
                        columnSpacing: 24,
                        horizontalMargin: 24,
                        sortColumnIndex: _sortColumn,
                        sortAscending: _sortAscending,
                        columns: headers.asMap().entries.map((entry) {
                          return DataColumn(
                            label: Expanded(child: Center(child: Text(entry.value, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))),
                            onSort: _viewMode == '全部记录' && entry.key < 4 ? (columnIndex, ascending) {
                              setState(() {
                                _sortColumn = columnIndex;
                                _sortAscending = ascending;
                                _resetPagination();
                              });
                            } : null,
                          );
                        }).toList(),
                        rows: tableData.map((row) {
                          return DataRow(
                            cells: row.map((cell) {
                              return DataCell(Center(child: Text(cell, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))));
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  // 加载指示器
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  
                  // 已加载全部数据提示
                  if (_hasLoadedAll && _totalRows > 0)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          '已加载全部数据',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  
                  // 如果列表为空，显示占位高度
                  if (tableData.isEmpty && !_isLoading)
                    const SizedBox(height: 200, child: Center(child: Text('暂无数据'))),
                    
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getHeaders() {
    switch (_viewMode) {
      case '按时间查看':
        return ['点名时间', '学号', '姓名', '性别', '小组'];
      case '个人记录':
        return ['点名时间', '点名模式', '点名人数', '性别限制', '小组限制'];
      default:
        return ['学号', '姓名', '性别', '小组', '点名次数', '权重'];
    }
  }

  List<Student> _getDisplayData(List<Student> students, List<HistoryRecord> history, Map<String, int> callCounts) {
    if (_viewMode == '全部记录' || _viewMode == '按时间查看') {
      return students;
    }
    return [];
  }

  List<List<String>> _getTableData(List<Student> displayData, List<HistoryRecord> history, Map<String, int> callCounts) {
    switch (_viewMode) {
      case '全部记录':
        final sortedData = List<Student>.from(displayData);
        if (_sortColumn != null && _sortColumn! >= 0) {
          sortedData.sort((a, b) {
            int result = 0;
            switch (_sortColumn!) {
              case 0:
                result = a.id.compareTo(b.id);
                break;
              case 1:
                result = a.name.compareTo(b.name);
                break;
              case 2:
                result = a.gender.compareTo(b.gender);
                break;
              case 3:
                result = a.group.compareTo(b.group);
                break;
            }
            return _sortAscending ? result : -result;
          });
        }
        return sortedData.map((student) {
          final count = callCounts[student.name] ?? 0;
          const weight = "1.00";
          return [
            student.id.toString(),
            student.name,
            student.gender,
            student.group,
            count.toString(),
            weight,
          ];
        }).toList();

      case '按时间查看':
        final sortedHistory = List<HistoryRecord>.from(history);
        sortedHistory.sort((a, b) => b.drawTime.compareTo(a.drawTime));
        final studentMap = {for (var s in displayData) s.name: s};
        final List<List<String>> result = [];
        for (var record in sortedHistory) {
          final names = record.name.split(',').map((e) => e.trim()).toList();
          for (var name in names) {
            final student = studentMap[name];
            if (student != null) {
              result.add([
                record.drawTime,
                student.id.toString(),
                student.name,
                student.gender,
                student.group,
              ]);
            }
          }
        }
        return result;

      case '个人记录':
        if (_selectedStudent == null) return [];
        final studentHistory = history.where((h) => h.name.contains(_selectedStudent!)).toList();
        studentHistory.sort((a, b) => b.drawTime.compareTo(a.drawTime));
        return studentHistory.map((record) {
          final drawMethod = record.drawMethod == 1 ? '随机抽取' : '公平抽取';
          return [
            record.drawTime,
            drawMethod,
            record.drawPeopleNumbers.toString(),
            record.drawGender,
            record.drawGroup,
          ];
        }).toList();

      default:
        return [];
    }
  }

  Widget _buildFilterRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // 使用卡片颜色
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Theme.of(context).dividerColor), // 使用分割线颜色
        ),
        child: Icon(icon, color: Theme.of(context).iconTheme.color, size: 20), // 使用主题图标颜色
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }
}
