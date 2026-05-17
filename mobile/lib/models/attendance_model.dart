class Attendance {
  final String? id;
  final String userId;
  final String? userName;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? markedBy;

  Attendance({
    this.id,
    required this.userId,
    this.userName,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.markedBy,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    String userId = '';
    String? userName;
    if (json['user'] is Map) {
      userId = json['user']['_id'] as String? ?? '';
      userName = json['user']['name'] as String?;
    } else {
      userId = json['user'] as String? ?? '';
    }

    return Attendance(
      id: json['_id'] as String?,
      userId: userId,
      userName: userName,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      checkInTime: json['checkInTime'] != null ? DateTime.tryParse(json['checkInTime'].toString()) : null,
      checkOutTime: json['checkOutTime'] != null ? DateTime.tryParse(json['checkOutTime'].toString()) : null,
      markedBy: json['markedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'date': date.toIso8601String(),
      if (checkInTime != null) 'checkInTime': checkInTime!.toIso8601String(),
      if (checkOutTime != null) 'checkOutTime': checkOutTime!.toIso8601String(),
      if (markedBy != null) 'markedBy': markedBy,
    };
  }
}
