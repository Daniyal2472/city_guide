import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CityDetailScreen extends StatelessWidget {
  final String cityId;
  final String cityName;

  const CityDetailScreen({super.key, required this.cityId, required this.cityName});

  Future<Map<String, dynamic>> fetchCityDetails() async {
    final DocumentSnapshot cityDoc =
    await FirebaseFirestore.instance.collection('cities').doc(cityId).get();
    return cityDoc.data() as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchCityEvents() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('cityId', isEqualTo: cityId)
        .get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> fetchCityAttractions() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('attractions')
        .where('cityId', isEqualTo: cityId)
        .get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City Image and Description
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
                    cityDetails['description'] ?? 'No description available',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Events Section
                  const SectionTitle(title: "Events"),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchCityEvents(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      final events = snapshot.data ?? [];
                      if (events.isEmpty) {
                        return const Text("No events found.");
                      }
                      return Column(
                        children: events.map((event) {
                          return ListTile(
                            leading: Image.network(
                              event['imageUrl'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(event['name']),
                            subtitle: Text(event['date']),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Attractions Section
                  const SectionTitle(title: "Attractions"),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchCityAttractions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      final attractions = snapshot.data ?? [];
                      if (attractions.isEmpty) {
                        return const Text("No attractions found.");
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: attractions.length,
                        itemBuilder: (context, index) {
                          return AttractionCard(
                            attractionName: attractions[index]['name'],
                            imageUrl: attractions[index]['imageUrl'],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
    return GestureDetector(
      onTap: () {
        // Navigate to attraction details
      },
      child: Container(
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
              attractionName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
