import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageReviewsPage extends StatefulWidget {
  const ManageReviewsPage({super.key});

  @override
  _ManageReviewsPageState createState() => _ManageReviewsPageState();
}

class _ManageReviewsPageState extends State<ManageReviewsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> reviews = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reviewTitleController = TextEditingController();
  final TextEditingController _reviewContentController =
  TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  Future<void> _getReviews() async {
    final QuerySnapshot reviewSnapshot =
    await _firestore.collection('reviews').get();
    setState(() {
      reviews = reviewSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'reviewTitle': doc['reviewTitle'],
          'reviewContent': doc['reviewContent'],
          'rating': doc['rating'],
          'userName': doc['userName'],
        };
      }).toList();
    });
  }

  void deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review deleted successfully")),
    );
    _getReviews();
  }

  void addReview() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _firestore.collection('reviews').add({
        'reviewTitle': _reviewTitleController.text,
        'reviewContent': _reviewContentController.text,
        'rating': _ratingController.text,
        'userName': _userNameController.text,
      });

      _reviewTitleController.clear();
      _reviewContentController.clear();
      _ratingController.clear();
      _userNameController.clear();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review added successfully")),
      );
      _getReviews();
    }
  }

  void updateReview(String reviewId) async {
    if (_formKey.currentState?.validate() ?? false) {
      await _firestore.collection('reviews').doc(reviewId).update({
        'reviewTitle': _reviewTitleController.text,
        'reviewContent': _reviewContentController.text,
        'rating': _ratingController.text,
        'userName': _userNameController.text,
      });

      _reviewTitleController.clear();
      _reviewContentController.clear();
      _ratingController.clear();
      _userNameController.clear();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review updated successfully")),
      );
      _getReviews();
    }
  }

  void showReviewForm(
      {String? reviewTitle,
        String? reviewContent,
        String? rating,
        String? userName,
        String? reviewId}) {
    if (reviewId != null) {
      _reviewTitleController.text = reviewTitle!;
      _reviewContentController.text = reviewContent!;
      _ratingController.text = rating!;
      _userNameController.text = userName!;
    } else {
      _reviewTitleController.clear();
      _reviewContentController.clear();
      _ratingController.clear();
      _userNameController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reviewId != null ? 'Edit Review' : 'Add New Review'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _reviewTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Review Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a review title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reviewContentController,
                  decoration: const InputDecoration(
                    labelText: 'Review Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter review content';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ratingController,
                  decoration: const InputDecoration(
                    labelText: 'Rating (1-5)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a rating';
                    }
                    final rating = int.tryParse(value);
                    if (rating == null || rating < 1 || rating > 5) {
                      return 'Please enter a valid rating between 1 and 5';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _userNameController,
                  decoration: const InputDecoration(
                    labelText: 'User Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the user\'s name';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reviewId != null) {
                updateReview(reviewId);
              } else {
                addReview();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6995B1),
            ),
            child: Text(reviewId != null ? 'Update Review' : 'Add Review'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Reviews"),
        backgroundColor: const Color(0xFF6995B1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        reviews[index]["reviewTitle"]!,
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                          "Rating: ${reviews[index]["rating"]}, ${reviews[index]["reviewContent"]}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showReviewForm(
                                reviewTitle: reviews[index]["reviewTitle"],
                                reviewContent: reviews[index]["reviewContent"],
                                rating: reviews[index]["rating"],
                                userName: reviews[index]["userName"],
                                reviewId: reviews[index]["id"],
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                deleteReview(reviews[index]["id"]!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => showReviewForm(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF6995B1),
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Add Review"),
            ),
          ],
        ),
      ),
    );
  }
}
