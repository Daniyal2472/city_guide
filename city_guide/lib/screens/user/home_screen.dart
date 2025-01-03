import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/PopularAttractionsWidget.dart';
import '../auth/login.dart';
import 'CityDetailScreen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<Map<String, String>> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return {
          'name': userDoc['fullName'] ?? 'User',
          'email': userDoc['email'] ?? 'No email provided',
        };
      }
    }
    return {
      'name': 'Guest',
      'email': 'No email provided',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'City Guide',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF6995B1),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.account_circle, size: 28),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                logout(context);
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: FutureBuilder<Map<String, String>>(
          future: fetchUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final userDetails = snapshot.data ?? {'name': 'Guest', 'email': 'No email provided'};

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF6995B1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150/0000FF/808080?text=User+Image'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Hello, ${userDetails['name']}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userDetails['email']!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('Map'),
                  onTap: () {
                    // Navigate to Map
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    // Navigate to Settings
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () => logout(context),
                ),
              ],
            );
          },
        ),
      ),
      body:  SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title: "Select Your City"),
              SizedBox(height: 16),
              CitySelectionWidget(),
              SizedBox(height: 24),
              SectionTitle(title: "Popular Attractions"),
              SizedBox(height: 16),
              PopularAttractionsWidget(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        selectedItemColor: const Color(0xFF6995B1),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}

class CitySelectionWidget extends StatelessWidget {
  const CitySelectionWidget({super.key});

  Future<List<Map<String, dynamic>>> fetchCities() async {
    final QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('cities').get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
        'imageUrl': doc['imageUrl'],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchCities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final cities = snapshot.data ?? [];
        return SizedBox(
          height: 120,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cities.map((city) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to city details or perform an action
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CityDetailPage(cityName: city['name']),
                        ),
                      );
                    },
                    child: CityCard(
                      cityName: city['name'],
                      imageUrl: city['imageUrl'],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class CityCard extends StatelessWidget {
  final String cityName;
  final String imageUrl;

  const CityCard({super.key, required this.cityName, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Text(
            cityName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder for CityDetailPage
class CityDetailPage extends StatelessWidget {
  final String cityName;

  const CityDetailPage({super.key, required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
      ),
      body: Center(
        child: Text("Details for $cityName"),
      ),
    );
  }
}

// Logout function
void logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logout failed: ${e.toString()}")),
    );
  }
}
