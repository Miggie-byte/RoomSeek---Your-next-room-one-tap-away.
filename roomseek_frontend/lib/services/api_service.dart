import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';

class ApiService {
  static const String baseUrl = 'https://sakkdmijwj.execute-api.ap-southeast-1.amazonaws.com/prod';

  Future<RoomAvailability> fetchRooms(String day, String time) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rooms').replace(queryParameters: {
        'day': day,
        'time': time,
      }),
    );

    if (response.statusCode == 200) {
      final availability = RoomAvailability.fromJson(jsonDecode(response.body));
      return RoomAvailability(
        availableNow: availability.availableNow.map((r) => r.copyWith(day: day)).toList(),
        availableSoon: availability.availableSoon.map((r) => r.copyWith(day: day)).toList(),
      );
    } else {
      throw Exception('Failed to load rooms');
    }
  }
}
