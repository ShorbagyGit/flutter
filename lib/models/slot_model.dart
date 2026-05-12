class SlotModel {
  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final String status;
  final String horseId;
  final String stableId;

  SlotModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.horseId,
    required this.stableId,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {

    String readNestedId(dynamic value) {
      if (value is Map<String, dynamic>) {
        return (value['id'] ?? value['horseId'] ?? value['stableId'] ?? '').toString();
      }
      return value?.toString() ?? '';
    }

    return SlotModel(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString().trim() ?? '',
      startTime: json['startTime']?.toString().trim() ?? '',
      endTime: json['endTime']?.toString().trim() ?? '',
      status: json['status']?.toString().trim() ?? '',
      horseId: readNestedId(json['horse'] ?? json['horseId'] ?? json['horse_id']),
      stableId: readNestedId(json['stable'] ?? json['stableId'] ?? json['stable_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'horse': {'id': horseId},
      'stable': {'id': stableId},
    };
  }
}
