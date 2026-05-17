class User {
  final String? id;
  final String name;
  final String email;
  final String? password;
  final String contact;
  final String? city;
  final String? address;
  final String? profilePic;
  final String? gender;
  final int? age;
  final double? feeAmount;
  final DateTime? feeDueDate;
  final DateTime? membershipStart;
  final DateTime? membershipEnd;
  final String status;
  final String? emergencyContact;
  final String? bloodGroup;
  final double? weight;
  final double? height;
  final int role;
  final String? membershipId;
  final String? batch;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    required this.contact,
    this.city,
    this.address,
    this.profilePic,
    this.gender,
    this.age,
    this.feeAmount,
    this.feeDueDate,
    this.membershipStart,
    this.membershipEnd,
    this.status = 'active',
    this.emergencyContact,
    this.bloodGroup,
    this.weight,
    this.height,
    this.role = 0,
    this.membershipId,
    this.batch,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      city: json['city'] as String?,
      address: json['address'] as String?,
      profilePic: json['profilePic'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      feeAmount: (json['feeAmount'] as num?)?.toDouble(),
      feeDueDate: json['feeDueDate'] != null ? DateTime.tryParse(json['feeDueDate'].toString()) : null,
      membershipStart: json['membershipStart'] != null ? DateTime.tryParse(json['membershipStart'].toString()) : null,
      membershipEnd: json['membershipEnd'] != null ? DateTime.tryParse(json['membershipEnd'].toString()) : null,
      status: json['status'] as String? ?? 'active',
      emergencyContact: json['emergencyContact'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      role: json['role'] as int? ?? 0,
      membershipId: json['membershipId'] as String?,
      batch: json['batch'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'email': email,
      if (password != null) 'password': password,
      'contact': contact,
      if (city != null) 'city': city,
      if (address != null) 'address': address,
      if (profilePic != null) 'profilePic': profilePic,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      if (feeAmount != null) 'feeAmount': feeAmount,
      if (feeDueDate != null) 'feeDueDate': feeDueDate!.toIso8601String(),
      if (membershipStart != null) 'membershipStart': membershipStart!.toIso8601String(),
      if (membershipEnd != null) 'membershipEnd': membershipEnd!.toIso8601String(),
      'status': status,
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
      if (bloodGroup != null) 'bloodGroup': bloodGroup,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      'role': role,
      if (membershipId != null) 'membershipId': membershipId,
      if (batch != null) 'batch': batch,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? contact,
    String? city,
    String? address,
    String? profilePic,
    String? gender,
    int? age,
    double? feeAmount,
    DateTime? feeDueDate,
    DateTime? membershipStart,
    DateTime? membershipEnd,
    String? status,
    String? emergencyContact,
    String? bloodGroup,
    double? weight,
    double? height,
    int? role,
    String? membershipId,
    String? batch,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      contact: contact ?? this.contact,
      city: city ?? this.city,
      address: address ?? this.address,
      profilePic: profilePic ?? this.profilePic,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      feeAmount: feeAmount ?? this.feeAmount,
      feeDueDate: feeDueDate ?? this.feeDueDate,
      membershipStart: membershipStart ?? this.membershipStart,
      membershipEnd: membershipEnd ?? this.membershipEnd,
      status: status ?? this.status,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      role: role ?? this.role,
      membershipId: membershipId ?? this.membershipId,
      batch: batch ?? this.batch,
    );
  }

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isBlocked => status == 'blocked';
  bool get isAdmin => role == 1;

  bool get isMembershipExpired {
    if (membershipEnd == null) return false;
    return membershipEnd!.isBefore(DateTime.now());
  }

  int get daysUntilExpiry {
    if (membershipEnd == null) return 0;
    return membershipEnd!.difference(DateTime.now()).inDays;
  }

  String get displayName => name.isNotEmpty ? name : email;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
