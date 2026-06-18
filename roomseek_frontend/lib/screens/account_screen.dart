import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        title: const Text(
          '',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontWeight: FontWeight.w800,
            fontSize: 28,
            letterSpacing: -0.8,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF1C1C1E),
              child: Icon(Icons.person_rounded, size: 50, color: Color(0xFFFFC107)),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Guest User',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildOption(Icons.settings_outlined, 'Settings'),
          _buildOption(Icons.notifications_none_rounded, 'Notifications'),
          _buildOption(Icons.help_outline_rounded, 'Help & Support'),
          _buildOption(Icons.logout_rounded, 'Logout', color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? const Color(0xFF1C1C1E)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color ?? const Color(0xFF1C1C1E),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }
}
