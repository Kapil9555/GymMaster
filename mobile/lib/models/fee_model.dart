class FeePayment {
  final String? id;
  final String userId;
  final String? userName;
  final double amount;
  final DateTime? dueDate;
  final DateTime? paymentDate;
  final bool isPaid;
  final String paymentMethod;
  final String? month;
  final int? months;
  final DateTime? coverFrom;
  final DateTime? coverTo;
  final String? remarks;
  final String? receiptNumber;
  final String? collectedBy;
  final double? discount;
  final String? discountType;
  final double? balanceAmount;
  final DateTime? createdAt;

  FeePayment({
    this.id,
    required this.userId,
    this.userName,
    required this.amount,
    this.dueDate,
    this.paymentDate,
    this.isPaid = false,
    this.paymentMethod = 'cash',
    this.month,
    this.months,
    this.coverFrom,
    this.coverTo,
    this.remarks,
    this.receiptNumber,
    this.collectedBy,
    this.discount,
    this.discountType,
    this.balanceAmount,
    this.createdAt,
  });

  factory FeePayment.fromJson(Map<String, dynamic> json) {
    // Handle user field being either string ID or populated object
    String userId = '';
    String? userName;
    if (json['user'] is Map) {
      userId = json['user']['_id'] as String? ?? '';
      userName = json['user']['name'] as String?;
    } else {
      userId = json['user'] as String? ?? '';
    }

    return FeePayment(
      id: json['_id'] as String?,
      userId: userId,
      userName: userName,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'].toString()) : null,
      paymentDate: json['paymentDate'] != null ? DateTime.tryParse(json['paymentDate'].toString()) : null,
      isPaid: json['isPaid'] as bool? ?? false,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      month: json['month'] as String?,
      months: json['months'] as int?,
      coverFrom: json['coverFrom'] != null ? DateTime.tryParse(json['coverFrom'].toString()) : null,
      coverTo: json['coverTo'] != null ? DateTime.tryParse(json['coverTo'].toString()) : null,
      remarks: json['remarks'] as String?,
      receiptNumber: json['receiptNumber'] as String?,
      collectedBy: json['collectedBy'] as String?,
      discount: (json['discount'] as num?)?.toDouble(),
      discountType: json['discountType'] as String?,
      balanceAmount: (json['balanceAmount'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'amount': amount,
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      if (paymentDate != null) 'paymentDate': paymentDate!.toIso8601String(),
      'isPaid': isPaid,
      'paymentMethod': paymentMethod,
      if (month != null) 'month': month,
      if (months != null) 'months': months,
      if (coverFrom != null) 'coverFrom': coverFrom!.toIso8601String(),
      if (coverTo != null) 'coverTo': coverTo!.toIso8601String(),
      if (remarks != null) 'remarks': remarks,
      if (receiptNumber != null) 'receiptNumber': receiptNumber,
      if (collectedBy != null) 'collectedBy': collectedBy,
      if (discount != null) 'discount': discount,
      if (discountType != null) 'discountType': discountType,
      if (balanceAmount != null) 'balanceAmount': balanceAmount,
    };
  }

  String get statusText => isPaid ? 'Paid' : 'Unpaid';

  bool get isOverdue {
    if (isPaid) return false;
    if (dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate!).inDays;
  }

  double get finalAmount {
    if (discount == null || discount == 0) return amount;
    if (discountType == 'percentage') {
      return amount - (amount * discount! / 100);
    }
    return amount - discount!;
  }
}

class FeeSummary {
  final double totalCollected;
  final double totalDue;
  final int totalPaid;
  final int totalUnpaid;
  final int overdueCount;
  final double monthlyCollection;

  FeeSummary({
    this.totalCollected = 0,
    this.totalDue = 0,
    this.totalPaid = 0,
    this.totalUnpaid = 0,
    this.overdueCount = 0,
    this.monthlyCollection = 0,
  });

  factory FeeSummary.fromJson(Map<String, dynamic> json) {
    return FeeSummary(
      totalCollected: (json['totalCollected'] as num?)?.toDouble() ?? 0,
      totalDue: (json['totalDue'] as num?)?.toDouble() ?? 0,
      totalPaid: json['totalPaid'] as int? ?? 0,
      totalUnpaid: json['totalUnpaid'] as int? ?? 0,
      overdueCount: json['overdueCount'] as int? ?? 0,
      monthlyCollection: (json['monthlyCollection'] as num?)?.toDouble() ?? 0,
    );
  }
}
