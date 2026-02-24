class Student {
  final int id;
  final String name;
  final String gender;
  final String group;
  final String className; // New field to store class name independently
  final bool exist;

  Student({
    required this.id,
    required this.name,
    required this.gender,
    required this.group,
    this.className = '1', // Default class name
    required this.exist,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'group': group,
      'class_name': className, // Save class name
      'exist': exist,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      gender: json['gender'] ?? '未知',
      group: json['group'] ?? '1',
      className: json['class_name'] ?? '1', // Load class name or default
      exist: json['exist'] is bool ? json['exist'] : (json['exist'].toString().toLowerCase() == 'true'),
    );
  }
}
