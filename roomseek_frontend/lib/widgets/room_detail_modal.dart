import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/room.dart';

class RoomDetailModal extends StatelessWidget {
  final String room;
  final String building;
  final String floor;
  final List<ScheduleSlot> schedule;
  final String? targetTime;

  const RoomDetailModal({
    super.key,
    required this.room,
    required this.building,
    required this.floor,
    required this.schedule,
    this.targetTime,
  });

  static void show(BuildContext context, {required String roomNumber, required List<ScheduleSlot> schedule, String? targetTime}) {
    // Improved floor derivation
    String derivedFloor;
    if (roomNumber.length >= 4) {
      // e.g., "1902" -> Level 19
      derivedFloor = 'Level ${roomNumber.substring(0, 2)}';
    } else if (roomNumber.length == 3) {
      // e.g., "902" -> Level 9
      derivedFloor = 'Level ${roomNumber.substring(0, 1)}';
    } else {
      derivedFloor = 'Level 1';
    }

    const building = 'Blessed Giorgio Frassati Building';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RoomDetailModal(
        room: roomNumber,
        building: building,
        floor: derivedFloor,
        schedule: schedule,
        targetTime: targetTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      room,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1C1C1E),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        floor,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            const Text(
              'AVAILABILITY SCHEDULE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFF6E6E73),
              ),
            ),
            const SizedBox(height: 16),
            if (schedule.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No schedule information available for today.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...schedule.asMap().entries.map((entry) {
                final status = _getSlotStatus(entry.key, schedule);
                return _buildSlotItem(entry.value, status);
              }),
          ],
        ),
      ),
    );
  }

  String _sanitizeTime(String time) {
    final t = time.toUpperCase().replaceAll(' ', '');
    if (t.contains('AM')) {
      return t.replaceFirst('AM', ' AM');
    } else if (t.contains('PM')) {
      return t.replaceFirst('PM', ' PM');
    }
    return time;
  }

  _SlotStatus _getSlotStatus(int index, List<ScheduleSlot> allSlots) {
    if (targetTime == null) return _SlotStatus.none;

    final format = DateFormat('h:mm a');
    DateTime? target;
    try {
      target = format.parse(_sanitizeTime(targetTime!));
    } catch (_) {
      return _SlotStatus.none;
    }

    // Find the index of the NOW slot
    int nowIdx = -1;
    for (int i = 0; i < allSlots.length; i++) {
      try {
        final s = format.parse(_sanitizeTime(allSlots[i].startTime));
        final e = format.parse(_sanitizeTime(allSlots[i].endTime));
        if ((target.isAtSameMomentAs(s) || target.isAfter(s)) && target.isBefore(e)) {
          nowIdx = i;
          break;
        }
      } catch (_) {}
    }

    if (index == nowIdx) return _SlotStatus.now;

    // Determine NEXT slot
    if (nowIdx != -1) {
      // If there's a NOW slot, the one immediately after is NEXT
      return index == nowIdx + 1 ? _SlotStatus.next : _SlotStatus.none;
    } else {
      // If no NOW slot, NEXT is the first slot that starts after targetTime
      int firstUpcomingIdx = -1;
      for (int i = 0; i < allSlots.length; i++) {
        try {
          final s = format.parse(_sanitizeTime(allSlots[i].startTime));
          if (s.isAfter(target)) {
            firstUpcomingIdx = i;
            break;
          }
        } catch (_) {}
      }
      return index == firstUpcomingIdx ? _SlotStatus.next : _SlotStatus.none;
    }
  }

  Widget _buildSlotItem(ScheduleSlot slot, _SlotStatus status) {
    Color? badgeColor;
    Color? textColor;
    String? label;

    if (status == _SlotStatus.now) {
      badgeColor = const Color(0xFF34C759).withValues(alpha: 0.12);
      textColor = const Color(0xFF1A7F3C);
      label = 'NOW';
    } else if (status == _SlotStatus.next) {
      badgeColor = const Color(0xFF007AFF).withValues(alpha: 0.12);
      textColor = const Color(0xFF0056B3);
      label = 'NEXT';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              size: 16,
              color: Color(0xFFFFC107),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${slot.startTime} - ${slot.endTime}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const Spacer(),
          if (label != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _SlotStatus { now, next, none }