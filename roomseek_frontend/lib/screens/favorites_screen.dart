import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/favorite_service.dart';
import '../widgets/room_card.dart';
import '../widgets/available_soon_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteService = FavoriteService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontWeight: FontWeight.w800,
            fontSize: 28,
            letterSpacing: -0.8,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: favoriteService.favoritesNotifier,
        builder: (context, favorites, _) {
          if (favorites.isEmpty) {
            return _buildEmptyState();
          }

          final groupedFavorites = _groupFavoritesByDay(favorites);
          final days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
          final activeDays = days.where((day) => groupedFavorites.containsKey(day)).toList();

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: activeDays.length,
            itemBuilder: (context, index) {
              final day = activeDays[index];
              final rooms = groupedFavorites[day]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDayHeader(day),
                  ...rooms.map((room) {
                    if (room is RoomNow) {
                      return RoomCard(room: room);
                    } else if (room is RoomSoon) {
                      return AvailableSoonCard(room: room);
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<String, List<dynamic>> _groupFavoritesByDay(List<dynamic> favorites) {
    final Map<String, List<dynamic>> groups = {};
    for (var room in favorites) {
      final day = room.day ?? 'UNKNOWN';
      if (!groups.containsKey(day)) {
        groups[day] = [];
      }
      groups[day]!.add(room);
    }
    return groups;
  }

  Widget _buildDayHeader(String day) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade500,
                letterSpacing: 2.0,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.favorite_rounded, size: 64, color: Colors.grey.shade200),
          ),
          const SizedBox(height: 24),
          const Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rooms you heart will appear here.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
