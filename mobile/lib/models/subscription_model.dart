class Subscription {
  final String? id;
  final String? userName;
  final String? planType;
  final String? planAmount;
  final String? userId;
  final String? planId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final DateTime? createdAt;

  Subscription({
    this.id,
    this.userName,
    this.planType,
    this.planAmount,
    this.userId,
    this.planId,
    this.startDate,
    this.endDate,
    this.status,
    this.createdAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    String? userId;
    if (json['user'] is Map) {
      userId = json['user']['_id'] as String?;
    } else {
      userId = json['user'] as String?;
    }

    String? planId;
    if (json['plan'] is Map) {
      planId = json['plan']['_id'] as String?;
    } else {
      planId = json['plan'] as String?;
    }

    return Subscription(
      id: json['_id'] as String?,
      userName: json['userName'] as String?,
      planType: json['planType'] as String?,
      planAmount: json['planAmount'] as String?,
      userId: userId,
      planId: planId,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'].toString()) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'].toString()) : null,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userName != null) 'userName': userName,
      if (planType != null) 'planType': planType,
      if (planAmount != null) 'planAmount': planAmount,
      if (userId != null) 'user': userId,
      if (planId != null) 'plan': planId,
    };
  }
}
