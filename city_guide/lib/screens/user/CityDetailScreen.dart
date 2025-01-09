import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AttractionDetailScreen.dart';

class CityDetailScreen extends StatelessWidget {
  final String cityId;
  final String cityName;

  const CityDetailScreen({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  Future<Map<String, dynamic>> fetchCityDetails() async {
    final DocumentSnapshot cityDoc =
    await FirebaseFirestore.instance.collection('cities').doc(cityId).get();
    return cityDoc.data() as Map<String, dynamic>? ?? {};
  }

  Future<List<Map<String, dynamic>>> fetchAttractions() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('attractions')
        .where('cityId', isEqualTo: cityId)
        .get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
        'imageUrl': doc['imageUrl'],
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchHotels() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('hotels')
        .where('cityId', isEqualTo: cityId)
        .get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
        'imageUrl': doc['imageUrl'],
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchRestaurants() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('cityId', isEqualTo: cityId)
        .get();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          cityName,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF6995B1),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchCityDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final cityDetails = snapshot.data ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cityDetails['imageUrl'] != null)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(cityDetails['imageUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  cityDetails['description'] ?? 'No description available.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: "Popular Attractions"),
                _buildListSection(
                  fetchAttractions(),
                  "No attractions found.",
                  context,
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: "Hotels"),
                _buildListSection(fetchHotels(), "No hotels found.", context),
                const SizedBox(height: 24),
                const SectionTitle(title: "Restaurants"),
                _buildListSection(
                  fetchRestaurants(),
                  "No restaurants found.",
                  context,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListSection(
      Future<List<Map<String, dynamic>>> fetchData,
      String emptyMessage,
      BuildContext context,
      ) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Text(emptyMessage);
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttractionDetailScreen(
                        attractionId: item['id'], // Pass the ID
                        attractionName: item['name'], // Pass the name
                      ),
                    ),
                  );
                },
                child: AttractionCard(
                  attractionName: item['name'],
                  imageUrl: item['imageUrl'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class AttractionCard extends StatelessWidget {
  final String attractionName;
  final String imageUrl;

  const AttractionCard({
    super.key,
    required this.attractionName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
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
          padding: const EdgeInsets.all(8.0),
          color: Colors.black.withOpacity(0.6),
          child: Text(
            attractionName,
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

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
      ),
    );
  }
}
