import 'package:SecRandom_lutter/models/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig fair draw', () {
    test('fromJson should default fairDrawEnabled to true for old data', () {
      final config = AppConfig.fromJson({
        'theme_mode': 'system',
        'select_count': 1,
      });

      expect(config.fairDrawEnabled, isTrue);
    });

    test('toJson should persist fairDrawEnabled', () {
      final config = AppConfig(
        themeMode: 'dark',
        selectCount: 2,
        fairDrawEnabled: false,
      );

      final json = config.toJson();
      expect(json['fair_draw_enabled'], isFalse);
    });
  });
}
