class Plan {
  final String? id;
  final String planName;
  final String? monthlyPlanAmount;
  final String? yearlyPlanAmount;
  final String? waterStations;
  final String? lockerRooms;
  final String? wifiService;
  final String? cardioClass;
  final String? refreshment;
  final String? groupFitnessClasses;
  final String? personalTrainer;
  final String? specialEvents;
  final String? cafeOrLounge;
  final DateTime? createdAt;

  Plan({
    this.id,
    required this.planName,
    this.monthlyPlanAmount,
    this.yearlyPlanAmount,
    this.waterStations,
    this.lockerRooms,
    this.wifiService,
    this.cardioClass,
    this.refreshment,
    this.groupFitnessClasses,
    this.personalTrainer,
    this.specialEvents,
    this.cafeOrLounge,
    this.createdAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['_id'] as String?,
      planName: json['planName'] as String? ?? '',
      monthlyPlanAmount: json['monthlyPlanAmount'] as String?,
      yearlyPlanAmount: json['yearlyPlanAmount'] as String?,
      waterStations: json['waterStations'] as String?,
      lockerRooms: json['lockerRooms'] as String?,
      wifiService: json['wifiService'] as String?,
      cardioClass: json['cardioClass'] as String?,
      refreshment: json['refreshment'] as String?,
      groupFitnessClasses: json['groupFitnessClasses'] as String?,
      personalTrainer: json['personalTrainer'] as String?,
      specialEvents: json['specialEvents'] as String?,
      cafeOrLounge: json['cafeOrLounge'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planName': planName,
      if (monthlyPlanAmount != null) 'monthlyPlanAmount': monthlyPlanAmount,
      if (yearlyPlanAmount != null) 'yearlyPlanAmount': yearlyPlanAmount,
      if (waterStations != null) 'waterStations': waterStations,
      if (lockerRooms != null) 'lockerRooms': lockerRooms,
      if (wifiService != null) 'wifiService': wifiService,
      if (cardioClass != null) 'cardioClass': cardioClass,
      if (refreshment != null) 'refreshment': refreshment,
      if (groupFitnessClasses != null) 'groupFitnessClasses': groupFitnessClasses,
      if (personalTrainer != null) 'personalTrainer': personalTrainer,
      if (specialEvents != null) 'specialEvents': specialEvents,
      if (cafeOrLounge != null) 'cafeOrLounge': cafeOrLounge,
    };
  }

  List<MapEntry<String, String>> get amenities {
    final list = <MapEntry<String, String>>[];
    if (waterStations != null && waterStations!.isNotEmpty) {
      list.add(MapEntry('Water Stations', waterStations!));
    }
    if (lockerRooms != null && lockerRooms!.isNotEmpty) {
      list.add(MapEntry('Locker Rooms', lockerRooms!));
    }
    if (wifiService != null && wifiService!.isNotEmpty) {
      list.add(MapEntry('WiFi', wifiService!));
    }
    if (cardioClass != null && cardioClass!.isNotEmpty) {
      list.add(MapEntry('Cardio Class', cardioClass!));
    }
    if (refreshment != null && refreshment!.isNotEmpty) {
      list.add(MapEntry('Refreshments', refreshment!));
    }
    if (groupFitnessClasses != null && groupFitnessClasses!.isNotEmpty) {
      list.add(MapEntry('Group Fitness', groupFitnessClasses!));
    }
    if (personalTrainer != null && personalTrainer!.isNotEmpty) {
      list.add(MapEntry('Personal Trainer', personalTrainer!));
    }
    if (specialEvents != null && specialEvents!.isNotEmpty) {
      list.add(MapEntry('Special Events', specialEvents!));
    }
    if (cafeOrLounge != null && cafeOrLounge!.isNotEmpty) {
      list.add(MapEntry('Cafe/Lounge', cafeOrLounge!));
    }
    return list;
  }
}
