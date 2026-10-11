import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Logic to mark all as read would go here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All marked as read")),
              );
            },
            child: const Text(
              "Mark all read",
              style: TextStyle(
                  color: Color(0xFF000033), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildNotificationItem(
            context: context,
            title: "Order Shipped! 🚚",
            message:
                "Your PlayStation 5 Slim has been shipped and is on its way. Track your package now.",
            time: "2 hours ago",
            icon: Icons.local_shipping_outlined,
            iconColor: Colors.green,
            isUnread: true,
          ),
          const Divider(
              height: 1, indent: 70, endIndent: 16, color: Color(0xFFEEEEEE)),
          _buildNotificationItem(
            context: context,
            title: "Flash Sale Alert! ⚡",
            message:
                "Get 20% off all gaming monitors for the next 24 hours. Don't miss out!",
            time: "5 hours ago",
            icon: Icons.local_offer_outlined,
            iconColor: Colors.orange,
            isUnread: true,
          ),
          const Divider(
              height: 1, indent: 70, endIndent: 16, color: Color(0xFFEEEEEE)),
          _buildNotificationItem(
            context: context,
            title: "Security Alert",
            message:
                "A new login was detected from Chrome on Windows. If this wasn't you, secure your account.",
            time: "Yesterday",
            icon: Icons.security_outlined,
            iconColor: Colors.red,
            isUnread: false,
          ),
          const Divider(
              height: 1, indent: 70, endIndent: 16, color: Color(0xFFEEEEEE)),
          _buildNotificationItem(
            context: context,
            title: "Welcome to TechFusion! 🎉",
            message:
                "Thanks for joining us. Complete your profile to get personalized recommendations.",
            time: "3 days ago",
            icon: Icons.celebration_outlined,
            iconColor: const Color(0xFF000033),
            isUnread: false,
          ),
        ],
      ),
    );
  }

  // Modern Notification Tile Builder
  Widget _buildNotificationItem({
    required BuildContext context,
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isUnread,
  }) {
    return Container(
      color:
          isUnread ? Colors.blue.shade50.withValues(alpha: 0.3) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isUnread ? Colors.black87 : Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
