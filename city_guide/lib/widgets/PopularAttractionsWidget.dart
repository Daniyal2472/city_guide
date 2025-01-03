import 'package:flutter/material.dart';



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
              CitySelectionWidget(),  // Add your CitySelectionWidget here

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
              PopularAttractionsWidget(),  // Add the PopularAttractionsWidget here

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
              ExploreMoreWidget(),  // Add ExploreMoreWidget here
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
          CityCard(cityName: "New York", imageUrl: "https://example.com/new_york.jpg"),
          CityCard(cityName: "Paris", imageUrl: "https://example.com/paris.jpg"),
          CityCard(cityName: "Tokyo", imageUrl: "https://example.com/tokyo.jpg"),
          CityCard(cityName: "London", imageUrl: "https://example.com/london.jpg"),
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
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// Popular Attractions Widget (already added in the previous message)
class PopularAttractionsWidget extends StatelessWidget {
  const PopularAttractionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // Adjust height for better visibility
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          AttractionCard(
            name: "Statue of Liberty",
            imageUrl: "https://example.com/statue_of_liberty.jpg", // Replace with actual image URL
          ),
          AttractionCard(
            name: "Eiffel Tower",
            imageUrl: "https://example.com/eiffel_tower.jpg", // Replace with actual image URL
          ),
          AttractionCard(
            name: "Mount Fuji",
            imageUrl: "https://example.com/mount_fuji.jpg", // Replace with actual image URL
          ),
          AttractionCard(
            name: "Great Wall of China",
            imageUrl: "https://example.com/great_wall_of_china.jpg", // Replace with actual image URL
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
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black.withOpacity(0.6),
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Explore More Widget (already added in the previous message)
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
