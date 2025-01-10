import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _currentUserRating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserRating();
  }

  Future<void> _fetchCurrentUserRating() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final doc = await FirebaseFirestore.instance
            .collection('restaurantRatings')
            .doc('${widget.restaurantId}_${currentUser.uid}')
            .get();

        if (doc.exists) {
          setState(() {
            _currentUserRating = doc.data()?['rating']?.toDouble() ?? 0.0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user rating: $e");
    }
  }

  Future<Map<String, dynamic>> fetchRestaurantDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        throw Exception("Restaurant not found");
      }
    } catch (e) {
      throw Exception("Error fetching restaurant details: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchReviewsWithUserDetails() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('restaurantReviews')
          .where('restaurantId', isEqualTo: widget.restaurantId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> reviews = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final data = doc.data();
          final String userId = data['userId'] ?? 'Unknown user';
          final Timestamp createdAt = data['createdAt'] as Timestamp;

          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          final String userName = userDoc.exists
              ? (userDoc.data()?['fullName'] ?? 'Anonymous')
              : 'Anonymous';

          return {
            'review': data['review'] ?? 'No review',
            'userName': userName,
            'createdAt': createdAt.toDate(),
          };
        }).toList(),
      );
      return reviews;
    } catch (e) {
      throw Exception("Error fetching reviews with user details: $e");
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

      await FirebaseFirestore.instance.collection('restaurantReviews').add({
        'restaurantId': widget.restaurantId,
        'userId': currentUser.uid,
        'review': reviewText,
        'createdAt': Timestamp.now(),
      });

      _reviewController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review added successfully")),
      );

      setState(() {}); // Refresh the reviews section
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
        title: Text(widget.restaurantName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchRestaurantDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final restaurant = snapshot.data;
          if (restaurant == null) {
            return const Center(child: Text("Restaurant not found"));
          }

          final String imageUrl = restaurant['imageUrl'] ?? '';
          final String description = restaurant['description'] ?? 'No description available';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        imageUrl,
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text('Image not available'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.restaurantName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchReviewsWithUserDetails(),
                    builder: (context, reviewsSnapshot) {
                      if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (reviewsSnapshot.hasError) {
                        return Center(child: Text("Error: ${reviewsSnapshot.error}"));
                      }

                      final reviews = reviewsSnapshot.data ?? [];
                      if (reviews.isEmpty) {
                        return const Text("No reviews yet.");
                      }

                      return Column(
                        children: reviews.map((review) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(review['review']),
                              subtitle: Text(
                                "User: ${review['userName']}\nDate: ${DateFormat('yyyy-MM-dd – kk:mm').format(review['createdAt'])}",
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _reviewController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Write your review here...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: addReview,
                    child: const Text("Submit Review"),
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
