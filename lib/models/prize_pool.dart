class PrizePool {
  final String name;
  int drawType;
  int drawMode;
  int halfRepeat;
  int clearRecord;
  String? defaultPool;

  PrizePool({
    required this.name,
    this.drawType = 0,
    this.drawMode = 0,
    this.halfRepeat = 0,
    this.clearRecord = 0,
    this.defaultPool,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'drawType': drawType,
      'drawMode': drawMode,
      'halfRepeat': halfRepeat,
      'clearRecord': clearRecord,
      'defaultPool': defaultPool,
    };
  }

  factory PrizePool.fromJson(Map<String, dynamic> json) {
    return PrizePool(
      name: json['name'] as String,
      drawType: json['drawType'] as int? ?? 0,
      drawMode: json['drawMode'] as int? ?? 0,
      halfRepeat: json['halfRepeat'] as int? ?? 0,
      clearRecord: json['clearRecord'] as int? ?? 0,
      defaultPool: json['defaultPool'] as String?,
    );
  }

  PrizePool copyWith({
    String? name,
    int? drawType,
    int? drawMode,
    int? halfRepeat,
    int? clearRecord,
    String? defaultPool,
  }) {
    return PrizePool(
      name: name ?? this.name,
      drawType: drawType ?? this.drawType,
      drawMode: drawMode ?? this.drawMode,
      halfRepeat: halfRepeat ?? this.halfRepeat,
      clearRecord: clearRecord ?? this.clearRecord,
      defaultPool: defaultPool ?? this.defaultPool,
    );
  }
}
