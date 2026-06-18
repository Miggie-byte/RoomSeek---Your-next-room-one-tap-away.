import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/favorite_service.dart';
import 'room_detail_modal.dart';

class RoomCard extends StatelessWidget {
  final RoomNow room;
  final String? targetTime;

  const RoomCard({super.key, required this.room, this.targetTime});

  @override
  Widget build(BuildContext context) {
    final favoriteService = FavoriteService();
    
    return ValueListenableBuilder(
      valueListenable: favoriteService.favoritesNotifier,
      builder: (context, favorites, _) {
        final isFavorited = favoriteService.isFavorited(room);
        
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Room number block
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          room.room,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF34C759).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'VACANT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A7F3C),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildMetric(Icons.timer_outlined, 'UNTIL', room.vacantUntil),
                              const SizedBox(width: 20),
                              _buildMetric(Icons.hourglass_bottom_rounded, 'FOR', room.vacantFor),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Arrow
                    IconButton(
                      onPressed: () => RoomDetailModal.show(
                        context,
                        roomNumber: room.room,
                        schedule: room.schedule,
                        targetTime: targetTime,
                      ),
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade300,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Diagonal Star Tag
            Positioned(
              left: 20,
              top: 7,
              child: GestureDetector(
                onTap: () => favoriteService.toggleFavorite(room),
                child: ClipPath(
                  clipper: DiagonalCornerClipper(),
                  child: Container(
                    width: 36,
                    height: 36,
                    color: isFavorited ? const Color(0xFFFFC107) : Colors.grey.shade200,
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Icon(
                        isFavorited ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 14,
                        color: isFavorited ? Colors.white : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildMetric(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6E6E73),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(icon, size: 13, color: const Color(0xFFFFC107)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DiagonalCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}