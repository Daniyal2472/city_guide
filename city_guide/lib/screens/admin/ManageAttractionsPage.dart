import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageAttractionsPage extends StatefulWidget {
  const ManageAttractionsPage({super.key});

  @override
  _ManageAttractionsPageState createState() => _ManageAttractionsPageState();
}

class _ManageAttractionsPageState extends State<ManageAttractionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Change to dynamic to support Firestore data structure
  List<Map<String, dynamic>> attractions = [];
  List<Map<String, dynamic>> cities = [];

  // Controllers for form inputs
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCityId;

  // Fetch cities from Firestore
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

  // Fetch attractions from Firestore
  Future<void> _getAttractions() async {
    final QuerySnapshot attractionSnapshot =
    await _firestore.collection('attractions').get();
    setState(() {
      attractions = attractionSnapshot.docs.map((doc) {
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

  // Function to delete an attraction
  void deleteAttraction(String attractionId) async {
    await _firestore.collection('attractions').doc(attractionId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Attraction deleted successfully")),
    );
    _getAttractions(); // Refresh the attractions list
  }

  // Function to add a new attraction
  void addAttraction() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _firestore.collection('attractions').add({
        'name': _nameController.text,
        'imageUrl': _imageUrlController.text,
        'description': _descriptionController.text,
        'cityId': _selectedCityId, // Associate attraction with the selected city
      });

      _nameController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCityId = null; // Reset city dropdown
      });

      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attraction added successfully")),
      );
      _getAttractions(); // Refresh the attractions list
    }
  }

  // Function to update an existing attraction
  void updateAttraction(String attractionId) async {
    if (_formKey.currentState?.validate() ?? false) {
      await _firestore.collection('attractions').doc(attractionId).update({
        'name': _nameController.text,
        'imageUrl': _imageUrlController.text,
        'description': _descriptionController.text,
        'cityId': _selectedCityId, // Update associated city
      });

      _nameController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCityId = null; // Reset city dropdown
      });

      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attraction updated successfully")),
      );
      _getAttractions(); // Refresh the attractions list
    }
  }

  // Function to show the add/edit attraction form
  void showAttractionForm({String? name, String? imageUrl, String? description, String? cityId, String? attractionId}) {
    if (attractionId != null) {
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
        title: Text(attractionId != null ? 'Edit Attraction' : 'Add New Attraction'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Attraction Name',
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
              Navigator.pop(context); // Close the dialog without saving
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (attractionId != null) {
                updateAttraction(attractionId);
              } else {
                addAttraction();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6995B1), // Button color
            ),
            child: Text(attractionId != null ? 'Update Attraction' : 'Add Attraction'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCities(); // Fetch cities when the page loads
    _getAttractions(); // Fetch attractions when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Attractions"),
        backgroundColor: const Color(0xFF6995B1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // List of attractions
            Expanded(
              child: ListView.builder(
                itemCount: attractions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        attractions[index]["name"]!,
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(attractions[index]["description"]!),
                      leading: Image.network(
                        attractions[index]["imageUrl"]!,
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
                              showAttractionForm(
                                name: attractions[index]["name"],
                                imageUrl: attractions[index]["imageUrl"],
                                description: attractions[index]["description"],
                                cityId: attractions[index]["cityId"],
                                attractionId: attractions[index]["id"],
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteAttraction(attractions[index]["id"]!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Add Attraction Button
            ElevatedButton(
              onPressed: () => showAttractionForm(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF6995B1), // Button color
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
              ),
              child: const Text("Add Attraction"),
            ),
          ],
        ),
      ),
    );
  }
}

