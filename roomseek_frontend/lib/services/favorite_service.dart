import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/room.dart';

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal() {
    _loadFavorites();
  }

  static const String _storageKey = 'favorited_rooms';
  final ValueNotifier<List<dynamic>> favoritesNotifier = ValueNotifier([]);

  List<dynamic> get favorites => favoritesNotifier.value;

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString(_storageKey);
    
    if (storedData != null) {
      final List<dynamic> decoded = jsonDecode(storedData);
      final List<dynamic> loadedFavorites = decoded.map((item) {
        if (item['type'] == 'now') {
          return RoomNow.fromJson(item);
        } else {
          return RoomSoon.fromJson(item);
        }
      }).toList();
      favoritesNotifier.value = loadedFavorites;
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      favoritesNotifier.value.map((room) {
        if (room is RoomNow) return room.toJson();
        if (room is RoomSoon) return room.toJson();
        return {};
      }).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  void toggleFavorite(dynamic room) {
    final current = List<dynamic>.from(favoritesNotifier.value);
    final index = current.indexWhere((r) => _isSameRoom(r, room));
    
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.add(room);
    }
    favoritesNotifier.value = current;
    _saveFavorites();
  }

  bool isFavorited(dynamic room) {
    return favoritesNotifier.value.any((r) => _isSameRoom(r, room));
  }

  bool _isSameRoom(dynamic r1, dynamic r2) {
    if (r1.runtimeType != r2.runtimeType) return false;
    return r1.room == r2.room && r1.day == r2.day;
  }
}
