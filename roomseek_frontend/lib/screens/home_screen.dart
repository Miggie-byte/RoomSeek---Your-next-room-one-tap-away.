import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/room.dart';
import '../services/api_service.dart';
import '../widgets/room_card.dart';
import '../widgets/available_soon_card.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<RoomAvailability> _roomAvailability;
  String? _selectedDay;
  String? _selectedTime;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ScrollController _dayScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dayScrollController.dispose();
    super.dispose();
  }

  void _refreshData({String? day, String? time}) {
    final now = DateTime.now();
    final currentDay = day ?? DateFormat('EEEE').format(now).toUpperCase();
    final currentTime = time ?? DateFormat('h:mm a').format(now);

    setState(() {
      _selectedDay = currentDay;
      _selectedTime = currentTime;
      _roomAvailability = _apiService.fetchRooms(currentDay, currentTime);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedDay());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverHeader(context),
            SliverToBoxAdapter(
              child: FutureBuilder<RoomAvailability>(
                future: _roomAvailability,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1C1C1E),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }

                  if (!snapshot.hasData ||
                      (snapshot.data!.availableNow.isEmpty &&
                          snapshot.data!.availableSoon.isEmpty)) {
                    return _buildEmptyState();
                  }

                  final data = snapshot.data!;
                  final filteredNow = _searchQuery.isEmpty
                      ? data.availableNow
                      : data.availableNow
                          .where((r) => r.room
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();
                  final filteredSoon = _searchQuery.isEmpty
                      ? data.availableSoon
                      : data.availableSoon
                          .where((r) => r.room
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoChip(),
                        if (filteredNow.isNotEmpty) ...[
                          _buildSectionTitle('AVAILABLE NOW', filteredNow.length),
                          ...filteredNow.map((room) => RoomCard(room: room)),
                        ],
                        if (filteredSoon.isNotEmpty) ...[
                          _buildSectionTitle('UP NEXT', filteredSoon.length),
                          ...filteredSoon.map((room) => AvailableSoonCard(room: room)),
                        ],
                        if (filteredNow.isEmpty && filteredSoon.isEmpty)
                          _buildEmptyState(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: const Color(0xFFF5F5F7),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final isCollapsed =
              constraints.maxHeight <= kToolbarHeight + MediaQuery.of(context).padding.top + 10;
          return FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Container(
              color: const Color(0xFFF5F5F7),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.menu_rounded,
                            color: Color(0xFF1C1C1E),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'RoomSeek',
                          style: TextStyle(
                            color: const Color(0xFF1C1C1E),
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                      _buildFilterButton(context),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSearchBar(),
                ],
              ),
            ),
            title: isCollapsed
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      children: [
                        Expanded(child: _buildSearchBar(compact: true)),
                        const SizedBox(width: 8),
                        _buildFilterButton(context, compact: true),
                      ],
                    ),
                  )
                : null,
            titlePadding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          );
        },
      ),
      actions: const [SizedBox.shrink()],
    );
  }

  Widget _buildSearchBar({bool compact = false}) {
    return Container(
      height: compact ? 36 : 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1C1C1E),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search for rooms...',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade400,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.cancel_rounded,
                      color: Colors.grey.shade400, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: compact ? 8 : 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, {bool compact = false}) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<Map<String, String>>(
          context,
          MaterialPageRoute(
            builder: (context) => FilterScreen(
              initialDay: _selectedDay,
              initialTime: _selectedTime,
            ),
          ),
        );
        if (result != null) {
          _refreshData(day: result['day'], time: result['time']);
        }
      },
      child: Container(
        width: compact ? 36 : 44,
        height: compact ? 36 : 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.tune_rounded,
          color: const Color(0xFFFFC107),
          size: compact ? 18 : 20,
        ),
      ),
    );
  }

  void _scrollToSelectedDay() {
    final fullDays = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
    final index = fullDays.indexOf(_selectedDay ?? '');
    if (index == -1 || !_dayScrollController.hasClients) return;
    // Approximate pill width: selected ~200px, unselected ~60px, margin 8px
    double offset = 0;
    for (int i = 0; i < index; i++) {
      offset += 68; // unselected pill width + margin
    }
    // Center the selected pill in the viewport
    final screenWidth = _dayScrollController.position.viewportDimension;
    offset = offset - (screenWidth / 2) + 100;
    _dayScrollController.animateTo(
      offset.clamp(0.0, _dayScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  Widget _buildInfoChip() {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final fullDays = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        controller: _dayScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: List.generate(days.length, (index) {
            final isSelected = _selectedDay == fullDays[index];
            return GestureDetector(
              onTap: () => _refreshData(day: fullDays[index], time: _selectedTime),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.circle, size: 7, color: Color(0xFF34C759)),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      isSelected ? '${fullDays[index]}  ·  $_selectedTime' : days[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF6E6E73),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              fontSize: 13,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6E6E73),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: Color(0xFF1C1C1E), size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF6E6E73)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.search_off_rounded,
                  color: Colors.grey.shade300, size: 56),
            ),
            const SizedBox(height: 20),
            const Text(
              'No rooms found',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try adjusting your filters or search term.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6E6E73)),
            ),
          ],
        ),
      ),
    );
  }
}