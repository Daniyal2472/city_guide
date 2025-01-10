import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class AttractionDetailScreen extends StatefulWidget {
  final String attractionId;
  final String attractionName;

  const AttractionDetailScreen({
    super.key,
    required this.attractionId,
    required this.attractionName,
  });

  @override
  State<AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
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
            .collection('ratings')
            .doc('${widget.attractionId}_${currentUser.uid}')
            .get();

        if (doc.exists) {
          setState(() {
            _currentUserRating = doc.data()?['rating']?.toDouble() ?? 0.0;
            print("rating taken");
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user rating: $e");
    }
  }

  Future<Map<String, dynamic>> fetchAttractionDetails() async {
    print(widget.attractionId);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('attractions')
          .doc(widget.attractionId)
          .get();

      if (doc.exists) {
        print("attractions taken");
        return doc.data() as Map<String, dynamic>;
      } else {
        throw Exception("Attraction not found");
      }
    } catch (e) {
      throw Exception("Error fetching attraction details: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchReviewsWithUserDetails() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('attractionId', isEqualTo: widget.attractionId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> reviews = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final data = doc.data();
          final String userId = data['userId'] ?? 'Unknown user';
          final Timestamp createdAt = data['createdAt'] as Timestamp;

          // Fetch user details
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

  Future<double> fetchAverageRating() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('attractionId', isEqualTo: widget.attractionId)
          .get();

      if (querySnapshot.docs.isEmpty) return 0.0;

      double totalRating = 0.0;
      int count = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        totalRating += data['rating'] as double;
        count++;
      }

      return totalRating / count;
    } catch (e) {
      throw Exception("Error fetching average rating: $e");
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

      setState(() {}); // Refresh the reviews section
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> submitRating(double rating) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      await FirebaseFirestore.instance
          .collection('ratings')
          .doc('${widget.attractionId}_${currentUser.uid}')
          .set({
        'attractionId': widget.attractionId,
        'userId': currentUser.uid,
        'rating': rating,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rating submitted successfully")),
      );

      setState(() {
        _currentUserRating = rating;
      });
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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

          final String imageUrl = attraction['imageUrl'] ?? '';
          final String description = attraction['description'] ?? 'No description available';

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
                    widget.attractionName,
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
                  const SizedBox(height: 24),
                  FutureBuilder<double>(
                    future: fetchAverageRating(),
                    builder: (context, ratingSnapshot) {
                      if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (ratingSnapshot.hasError) {
                        return Text("Error: ${ratingSnapshot.error}");
                      }

                      final averageRating = ratingSnapshot.data ?? 0.0;
                      return Row(
                        children: [
                          const Text(
                            "Average Rating:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, color: Colors.amber),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  RatingBar.builder(
                    initialRating: _currentUserRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      submitRating(rating);
                    },
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
