import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageCitiesPage extends StatefulWidget {
  const ManageCitiesPage({super.key});

  @override
  _ManageCitiesPageState createState() => _ManageCitiesPageState();
}

class _ManageCitiesPageState extends State<ManageCitiesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  String? _editCityId;

  Future<List<Map<String, String>>> _getCities() async {
    QuerySnapshot querySnapshot = await _firestore.collection('cities').get();
    List<Map<String, String>> cities = [];
    for (var doc in querySnapshot.docs) {
      cities.add({
        "name": doc['name'],
        "imageUrl": doc['imageUrl'],
        "id": doc.id,
      });
    }
    return cities;
  }

  void deleteCity(String cityId) async {
    await _firestore.collection('cities').doc(cityId).delete();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("City deleted")),
    );
  }

  void saveCity() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_editCityId != null) {
        await _firestore.collection('cities').doc(_editCityId).update({
          'name': _cityController.text,
          'imageUrl': _imageUrlController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("City updated successfully")),
        );
      } else {
        await _firestore.collection('cities').add({
          'name': _cityController.text,
          'imageUrl': _imageUrlController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("City added successfully")),
        );
      }

      _cityController.clear();
      _imageUrlController.clear();
      _editCityId = null;
      Navigator.pop(context);
      setState(() {});
    }
  }

  void openAddCityForm() {
    _editCityId = null;
    _cityController.clear();
    _imageUrlController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New City'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a city name';
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: saveCity,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6995B1),
            ),
            child: const Text('Add City'),
          ),
        ],
      ),
    );
  }

  void openEditCityForm(String cityId, String cityName, String cityImageUrl) {
    _editCityId = cityId;
    _cityController.text = cityName;
    _imageUrlController.text = cityImageUrl;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit City'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a city name';
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: saveCity,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6995B1),
            ),
            child: const Text('Save City'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Cities"),
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
              child: FutureBuilder<List<Map<String, String>>>(
                future: _getCities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final cities = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            cities[index]["name"]!,
                            style: const TextStyle(fontSize: 18),
                          ),
                          leading: Image.network(
                            cities[index]["imageUrl"]!,
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
                                  openEditCityForm(
                                    cities[index]["id"]!,
                                    cities[index]["name"]!,
                                    cities[index]["imageUrl"]!,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteCity(cities[index]["id"]!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: openAddCityForm,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF6995B1),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Add City"),
            ),
          ],
        ),
      ),
    );
  }
}

// Firestore reference
// Form key for validation
// Store city ID if editing
// Function to fetch cities from Firestore
// Function to delete a city from Firestore
// Function to save or update a city to Firestore
// Function to open the form to add a city
// Function to open the form to edit a city
// Build method for the ManageCitiesPage widget
