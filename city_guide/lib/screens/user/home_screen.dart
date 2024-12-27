import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'City Guide',
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6995B1),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to User Profile
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // City Selection Section
              Text(
                "Select Your City",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: 16),
              CitySelectionWidget(),

              SizedBox(height: 24),

              // Popular Attractions Section
              Text(
                "Popular Attractions",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: 16),
              PopularAttractionsWidget(),

              SizedBox(height: 24),

              // Explore More Section
              Text(
                "Explore More",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: 16),
              ExploreMoreWidget(),
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

// City Selection Widget
class CitySelectionWidget extends StatelessWidget {
  const CitySelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          CityCard(
              cityName: "New York", imageUrl: "assets/images/new_york.jpg"),
          CityCard(cityName: "Paris", imageUrl: "assets/images/paris.jpg"),
          CityCard(cityName: "Tokyo", imageUrl: "assets/images/tokyo.jpg"),
          CityCard(cityName: "London", imageUrl: "assets/images/london.jpg"),
        ],
      ),
    );
  }
}

// City Card
class CityCard extends StatelessWidget {
  final String cityName;
  final String imageUrl;

  const CityCard({super.key, required this.cityName, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to City Details
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black.withOpacity(0.6),
            child: Text(
              cityName,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// Popular Attractions Widget
class PopularAttractionsWidget extends StatelessWidget {
  const PopularAttractionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          AttractionCard(
            name: "Statue of Liberty",
            imageUrl: "assets/images/statue_of_liberty.jpg",
          ),
          AttractionCard(
            name: "Eiffel Tower",
            imageUrl: "assets/images/eiffel_tower.jpg",
          ),
          AttractionCard(
            name: "Mount Fuji",
            imageUrl: "assets/images/mount_fuji.jpg",
          ),
        ],
      ),
    );
  }
}

// Attraction Card
class AttractionCard extends StatelessWidget {
  final String name;
  final String imageUrl;

  const AttractionCard({super.key, required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Attraction Details
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black.withOpacity(0.6),
            child: Text(
              name,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// Explore More Widget
class ExploreMoreWidget extends StatelessWidget {
  const ExploreMoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          ExploreCard(name: "Events", icon: Icons.event),
          ExploreCard(name: "Restaurants", icon: Icons.restaurant),
          ExploreCard(name: "Hotels", icon: Icons.hotel),
        ],
      ),
    );
  }
}

// Explore Card
class ExploreCard extends StatelessWidget {
  final String name;
  final IconData icon;

  const ExploreCard({super.key, required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFDEAD6F),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
