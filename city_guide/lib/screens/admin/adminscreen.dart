import 'package:city_guide/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Handle logout functionality
              try {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                print('Preferences cleared successfully.');

                // Navigate to the login page
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) =>  LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                print('Error during logout: $e');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              const Text(
                "Welcome, Admin!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  color: Color(0xFFDEAD6F),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Manage your platform efficiently using the tools below.",
                style: TextStyle(fontSize: 16, color: Color(0xFF727272)),
              ),
              const SizedBox(height: 32),

              // Dashboard Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardCard(
                    title: "Cities",
                    count: 10,
                    icon: Icons.location_city,
                    color: Colors.blue,
                    onTap: () {
                      // Navigate to Manage Cities
                    },
                  ),
                  DashboardCard(
                    title: "Attractions",
                    count: 45,
                    icon: Icons.place,
                    color: Colors.green,
                    onTap: () {
                      // Navigate to Manage Attractions
                    },
                  ),
                  DashboardCard(
                    title: "Users",
                    count: 1200,
                    icon: Icons.people,
                    color: Colors.orange,
                    onTap: () {
                      // Navigate to User Management
                    },
                  ),
                  DashboardCard(
                    title: "Reviews",
                    count: 150,
                    icon: Icons.rate_review,
                    color: Colors.purple,
                    onTap: () {
                      // Navigate to Manage Reviews
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Management Sections
              const SectionHeader(title: "Management"),
              AdminActionCard(
                title: "Manage Cities",
                description: "Add, edit, or delete city data.",
                icon: Icons.location_city,
                onTap: () {
                  // Navigate to Manage Cities Page
                },
              ),
              AdminActionCard(
                title: "Manage Attractions",
                description: "Add, edit, or delete attractions.",
                icon: Icons.place,
                onTap: () {
                  // Navigate to Manage Attractions Page
                },
              ),
              AdminActionCard(
                title: "Manage Reviews",
                description: "Moderate user reviews.",
                icon: Icons.rate_review,
                onTap: () {
                  // Navigate to Manage Reviews Page
                },
              ),
              AdminActionCard(
                title: "Event Management",
                description: "Add, edit, or delete city-specific events.",
                icon: Icons.event,
                onTap: () {
                  // Navigate to Event Management Page
                },
              ),

              const SizedBox(height: 32),

              // Notifications Section
              const SectionHeader(title: "Notifications"),
              AdminActionCard(
                title: "Create Notifications",
                description: "Send notifications to users.",
                icon: Icons.notifications,
                onTap: () {
                  // Navigate to Notifications Page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Widgets

class DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 4 - 16,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              "$count",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
      ),
    );
  }
}

class AdminActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const AdminActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: const Color(0xFF6995B1)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder LoginPage
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: const Text('Login Page'),
      ),
    );
  }
}
