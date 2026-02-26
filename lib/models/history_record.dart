class HistoryRecord {
  final int id;
  final String name;
  final int drawMethod;
  final String drawTime;
  final int drawPeopleNumbers;
  final String drawGroup;
  final String drawGender;
  final String className;

  HistoryRecord({
    required this.id,
    required this.name,
    required this.drawMethod,
    required this.drawTime,
    required this.drawPeopleNumbers,
    required this.drawGroup,
    required this.drawGender,
    required this.className,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'draw_method': drawMethod,
      'draw_time': drawTime,
      'draw_people_numbers': drawPeopleNumbers,
      'draw_group': drawGroup,
      'draw_gender': drawGender,
    };
  }

  factory HistoryRecord.fromJson(Map<String, dynamic> json, {String? className}) {
    return HistoryRecord(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      drawMethod: json['draw_method'] is int ? json['draw_method'] : int.tryParse(json['draw_method'].toString()) ?? 1,
      drawTime: json['draw_time'] ?? '',
      drawPeopleNumbers: json['draw_people_numbers'] is int ? json['draw_people_numbers'] : int.tryParse(json['draw_people_numbers'].toString()) ?? 1,
      drawGroup: json['draw_group'] ?? '未知',
      drawGender: json['draw_gender'] ?? '未知',
      className: className ?? json['class_name'] ?? '1',
    );
  }
}
