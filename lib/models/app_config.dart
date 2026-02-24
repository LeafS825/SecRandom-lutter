class AppConfig {
  final String themeMode; // 'system', 'light', 'dark'
  final int selectCount;
  final String? selectedClass;
  final List<String> groups;
  final Map<String, List<String>> classGroups; // Map of class name to list of groups

  AppConfig({
    required this.themeMode,
    this.selectCount = 1,
    this.selectedClass,
    this.groups = const ['1'],
    this.classGroups = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'theme_mode': themeMode,
      'select_count': selectCount,
      'selected_class': selectedClass,
      'groups': groups,
      'class_groups': classGroups,
    };
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      themeMode: json['theme_mode'] ?? 'system',
      selectCount: json['select_count'] ?? 1,
      selectedClass: json['selected_class'],
      groups: (json['groups'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['1'],
      classGroups: (json['class_groups'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              (value as List<dynamic>).map((e) => e.toString()).toList(),
            ),
          ) ??
          {},
    );
  }

  // 默认配置
  factory AppConfig.defaultConfig() {
    return AppConfig(
      themeMode: 'system',
      selectCount: 1,
      selectedClass: null,
      groups: ['1'],
      classGroups: {},
    );
  }
}
