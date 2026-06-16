class RoomNow {
  final String room;
  final String vacantUntil;
  final String vacantFor;

  RoomNow({
    required this.room,
    required this.vacantUntil,
    required this.vacantFor,
  });

  factory RoomNow.fromJson(Map<String, dynamic> json) {
    return RoomNow(
      room: json['room'] as String,
      vacantUntil: json['vacant_until'] as String,
      vacantFor: json['vacant_for'] as String,
    );
  }
}

class RoomSoon {
  final String room;
  final String vacantIn;
  final String at;

  RoomSoon({
    required this.room,
    required this.vacantIn,
    required this.at,
  });

  factory RoomSoon.fromJson(Map<String, dynamic> json) {
    return RoomSoon(
      room: json['room'] as String,
      vacantIn: json['vacant_in'] as String,
      at: json['at'] as String,
    );
  }
}

class RoomAvailability {
  final List<RoomNow> availableNow;
  final List<RoomSoon> availableSoon;

  RoomAvailability({
    required this.availableNow,
    required this.availableSoon,
  });

  factory RoomAvailability.fromJson(Map<String, dynamic> json) {
    return RoomAvailability(
      availableNow: (json['available_now'] as List<dynamic>)
          .map((e) => RoomNow.fromJson(e as Map<String, dynamic>))
          .toList(),
      availableSoon: (json['available_soon'] as List<dynamic>)
          .map((e) => RoomSoon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
