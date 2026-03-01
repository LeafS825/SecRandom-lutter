class Prize {
  final String id;
  String name;
  double weight;
  int count;
  bool exist;

  Prize({
    required this.id,
    required this.name,
    this.weight = 1.0,
    this.count = 1,
    this.exist = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'count': count,
      'exist': exist,
    };
  }

  factory Prize.fromJson(Map<String, dynamic> json) {
    return Prize(
      id: json['id'] as String,
      name: json['name'] as String,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      count: json['count'] as int? ?? 1,
      exist: json['exist'] as bool? ?? true,
    );
  }

  Prize copyWith({
    String? id,
    String? name,
    double? weight,
    int? count,
    bool? exist,
  }) {
    return Prize(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      count: count ?? this.count,
      exist: exist ?? this.exist,
    );
  }
}
