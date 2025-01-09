import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageRestaurantsPage extends StatefulWidget {
  const ManageRestaurantsPage({super.key});

  @override
  _ManageRestaurantsPageState createState() => _ManageRestaurantsPageState();
}

class _ManageRestaurantsPageState extends State<ManageRestaurantsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> restaurants = [];
  List<Map<String, dynamic>> cities = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCityId;

  Future<void> _getCities() async {
    final QuerySnapshot citySnapshot =
    await _firestore.collection('cities').get();
    setState(() {
      cities = citySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();
    });
  }

  Future<void> _getRestaurants() async {
    final QuerySnapshot restaurantSnapshot =
    await _firestore.collection('restaurants').get();
    setState(() {
      restaurants = restaurantSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'imageUrl': doc['imageUrl'],
          'description': doc['description'],
          'cityId': doc['cityId'],
        };
      }).toList();
    });
  }

  void deleteRestaurant(String restaurantId) async {
    await _firestore.collection('restaurants').doc(restaurantId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Restaurant deleted successfully")),
    );
    _getRestaurants();
  }

  void addRestaurant() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _firestore.collection('restaurants').add({
        'name': _nameController.text,
        'imageUrl': _imageUrlController.text,
        'description': _descriptionController.text,
        'cityId': _selectedCityId,
      });

      _nameController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCityId = null;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restaurant added successfully")),
      );
      _getRestaurants();
    }
  }

  void updateRestaurant(String restaurantId) async {
    if (_formKey.currentState?.validate() ?? false) {
      await _firestore.collection('restaurants').doc(restaurantId).update({
        'name': _nameController.text,
        'imageUrl': _imageUrlController.text,
        'description': _descriptionController.text,
        'cityId': _selectedCityId,
      });

      _nameController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCityId = null;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restaurant updated successfully")),
      );
      _getRestaurants();
    }
  }

  void showRestaurantForm(
      {String? name,
        String? imageUrl,
        String? description,
        String? cityId,
        String? restaurantId}) {
    if (restaurantId != null) {
      _nameController.text = name!;
      _imageUrlController.text = imageUrl!;
      _descriptionController.text = description!;
      _selectedCityId = cityId;
    } else {
      _nameController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      _selectedCityId = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(restaurantId != null ? 'Edit Restaurant' : 'Add New Restaurant'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Restaurant Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an image URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCityId,
                  decoration: const InputDecoration(
                    labelText: 'Select City',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCityId = newValue;
                    });
                  },
                  items: cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city['id'],
                      child: Text(city['name']!),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_imageUrlController.text.isNotEmpty)
                  Image.network(
                    _imageUrlController.text,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
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
              if (restaurantId != null) {
                updateRestaurant(restaurantId);
              } else {
                addRestaurant();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6995B1),
            ),
            child: Text(restaurantId != null ? 'Update Restaurant' : 'Add Restaurant'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCities();
    _getRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Restaurants"),
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
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        restaurants[index]["name"]!,
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(restaurants[index]["description"]!),
                      leading: Image.network(
                        restaurants[index]["imageUrl"]!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showRestaurantForm(
                                name: restaurants[index]["name"],
                                imageUrl: restaurants[index]["imageUrl"],
                                description: restaurants[index]["description"],
                                cityId: restaurants[index]["cityId"],
                                restaurantId: restaurants[index]["id"],
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                deleteRestaurant(restaurants[index]["id"]!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => showRestaurantForm(),
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
              child: const Text("Add Restaurant"),
            ),
          ],
        ),
      ),
    );
  }
}

// This code defines a Flutter page for managing restaurants, including adding, updating, and deleting restaurants from a Firestore database. It also includes a form for inputting restaurant details and selecting a city.
