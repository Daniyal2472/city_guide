import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AttractionDetailScreen extends StatefulWidget {
  final String attractionId;
  final String attractionName;

  const AttractionDetailScreen({
    super.key,
    required this.attractionId,
    required this.attractionName,
  });

  @override
  _AttractionDetailScreenState createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  final TextEditingController _reviewController = TextEditingController();

  Future<Map<String, dynamic>> fetchAttractionDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('attractions')
          .doc(widget.attractionId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        throw Exception("Attraction not found");
      }
    } catch (e) {
      throw Exception("Error fetching attraction details: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchReviews() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('attractionId', isEqualTo: widget.attractionId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'review': data['review'] ?? 'No review',
          'userId': data['userId'] ?? 'Unknown user',
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      throw Exception("Error fetching reviews: $e");
    }
  }

  Future<void> addReview() async {
    final reviewText = _reviewController.text.trim();
    if (reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review cannot be empty")),
      );
      return;
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      await FirebaseFirestore.instance.collection('reviews').add({
        'attractionId': widget.attractionId,
        'userId': currentUser.uid,
        'review': reviewText,
        'createdAt': Timestamp.now(),
      });

      _reviewController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review added successfully")),
      );

      // Refresh the reviews section
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.attractionName),
        backgroundColor: const Color(0xFF6995B1),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchAttractionDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final attraction = snapshot.data;
          if (attraction == null) {
            return const Center(child: Text("Attraction not found"));
          }

          final String name = attraction['name'] ?? 'No name available';
          final String imageUrl = attraction['imageUrl'] ?? '';
          final String description = attraction['description'] ?? 'No description available';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attraction Image
                  imageUrl.isNotEmpty
                      ? Image.network(imageUrl)
                      : const Placeholder(fallbackHeight: 200),
                  const SizedBox(height: 16),

                  // Attraction Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Attraction Description
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Add Review Section
                  const Text(
                    'Add Your Review:',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Write a review',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: addReview,
                    child: const Text('Submit Review'),
                  ),
                  const SizedBox(height: 16),

                  // Display Reviews Section
                  const Text(
                    'Reviews:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchReviews(),
                    builder: (context, reviewsSnapshot) {
                      if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (reviewsSnapshot.hasError) {
                        return Text("Error: ${reviewsSnapshot.error}");
                      }

                      final reviews = reviewsSnapshot.data ?? [];
                      if (reviews.isEmpty) {
                        return const Text("No reviews yet.");
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(review['review']),
                              subtitle: Text(
                                "User: ${review['userId']}\nDate: ${review['createdAt']}",
                              ),
                            ),
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
