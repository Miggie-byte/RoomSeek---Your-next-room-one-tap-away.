class ScheduleSlot {
  final String startTime;
  final String endTime;

  ScheduleSlot({
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

class RoomNow {
  final String room;
  final String vacantUntil;
  final String vacantFor;
  final String? day;
  final List<ScheduleSlot> schedule;

  RoomNow({
    required this.room,
    required this.vacantUntil,
    required this.vacantFor,
    this.day,
    this.schedule = const [],
  });

  RoomNow copyWith({String? day, List<ScheduleSlot>? schedule}) {
    return RoomNow(
      room: room,
      vacantUntil: vacantUntil,
      vacantFor: vacantFor,
      day: day ?? this.day,
      schedule: schedule ?? this.schedule,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room': room,
      'vacant_until': vacantUntil,
      'vacant_for': vacantFor,
      'day': day,
      'type': 'now',
      'schedule': schedule.map((e) => e.toJson()).toList(),
    };
  }

  factory RoomNow.fromJson(Map<String, dynamic> json) {
    return RoomNow(
      room: json['room'] as String,
      vacantUntil: json['vacant_until'] as String,
      vacantFor: json['vacant_for'] as String,
      day: json['day'] as String?,
      schedule: (json['schedule'] as List<dynamic>?)
              ?.map((e) => ScheduleSlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RoomSoon {
  final String room;
  final String vacantIn;
  final String at;
  final String? day;
  final List<ScheduleSlot> schedule;

  RoomSoon({
    required this.room,
    required this.vacantIn,
    required this.at,
    this.day,
    this.schedule = const [],
  });

  RoomSoon copyWith({String? day, List<ScheduleSlot>? schedule}) {
    return RoomSoon(
      room: room,
      vacantIn: vacantIn,
      at: at,
      day: day ?? this.day,
      schedule: schedule ?? this.schedule,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room': room,
      'vacant_in': vacantIn,
      'at': at,
      'day': day,
      'type': 'soon',
      'schedule': schedule.map((e) => e.toJson()).toList(),
    };
  }

  factory RoomSoon.fromJson(Map<String, dynamic> json) {
    return RoomSoon(
      room: json['room'] as String,
      vacantIn: json['vacant_in'] as String,
      at: json['at'] as String,
      day: json['day'] as String?,
      schedule: (json['schedule'] as List<dynamic>?)
              ?.map((e) => ScheduleSlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
