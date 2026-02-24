# SecRandom (随机点名软件)

基于 Material Design 3 规范构建的 Flutter 随机点名应用程序。

## 功能特性

- **随机点名**：从名单中公平地随机抽取学生。
- **公平算法**：确保所有学生在重复被点名之前都已被点名一次（除非重置）。
- **Material Design 3**：采用 Navigation Rail（侧边导航栏）和响应式布局的现代化 UI。
- **历史记录**：记录过去的点名结果。
- **数据持久化**：本地保存学生数据和历史记录。

## 项目结构

- `lib/models`: 数据模型 (`Student` - 学生)。
- `lib/services`: 业务逻辑 (`RandomService` - 随机服务, `DataService` - 数据服务)。
- `lib/providers`: 状态管理 (`AppProvider` - 应用提供者)。
- `lib/screens`: UI 屏幕 (`HomeScreen` - 主页, `HistoryScreen` - 历史记录, `SettingsScreen` - 设置)。
- `lib/widgets`: 可复用组件 (`NavRail` - 导航栏, `ControlPanel` - 控制面板, `NameDisplay` - 名字显示)。

## 环境要求

- Flutter SDK: >=3.11.0
- Dart SDK: >=3.0.0

## 快速开始

1.  克隆仓库。
2.  运行 `flutter pub get` 安装依赖。
3.  运行 `flutter run` 启动应用程序。

## 测试

运行单元测试：
```bash
flutter test test/unit_test.dart
```

## 自定义

要更新学生名单，目前应用程序在首次运行时会生成模拟数据。您可以修改 `lib/services/data_service.dart` 中的 `_getInitialStudents` 方法，或自行实现导入功能。
