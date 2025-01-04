import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageHotelsPage extends StatefulWidget {
  const ManageHotelsPage({super.key});

  @override
  _ManageHotelsPageState createState() => _ManageHotelsPageState();
}

class _ManageHotelsPageState extends State<ManageHotelsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getCitiesForDropdown() async {
    final QuerySnapshot citySnapshot = await _firestore.collection('cities').get();
    return citySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
      };
    }).toList();
  }


  List<Map<String, dynamic>> hotels = [];
  List<Map<String, dynamic>> cities = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCityId;

  @override
  void initState() {
    super.initState();
    _getCities();
    _getHotels();
  }

  // Fetch cities from Firestore
  Future<void> _getCities() async {
    final QuerySnapshot citySnapshot = await _firestore.collection('cities').get();
    setState(() {
      cities = citySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();
    });
  }

  // Fetch hotels from Firestore
  Future<void> _getHotels() async {
    final QuerySnapshot hotelSnapshot = await _firestore.collection('hotels').get();
    setState(() {
      hotels = hotelSnapshot.docs.map((doc) {
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

  // Add a new hotel
  void addHotel() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _firestore.collection('hotels').add({
        'name': _nameController.text,
        'imageUrl': _imageUrlController.text,
        'description': _descriptionController.text,
        'cityId': _selectedCityId,
      });

      _clearForm();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hotel added successfully")),
      );
      _getHotels();
    }
  }

  // Update an existing hotel
  void updateHotel(String hotelId) async {
    if (_formKey.currentState?.validate() ?? false) {
      await _firestore.collection('hotels').doc(hotelId).update({
        'name': _nameController.text,
        'imageUrl': _imageUrlController.text,
        'description': _descriptionController.text,
        'cityId': _selectedCityId,
      });

      _clearForm();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hotel updated successfully")),
      );
      _getHotels();
    }
  }

  // Delete a hotel
  void deleteHotel(String hotelId) async {
    await _firestore.collection('hotels').doc(hotelId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Hotel deleted successfully")),
    );
    _getHotels();
  }

  // Clear form fields
  void _clearForm() {
    _nameController.clear();
    _imageUrlController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCityId = null;
    });
  }

  // Show the add/edit hotel form
  void showHotelForm({
    String? name,
    String? imageUrl,
    String? description,
    String? cityId,
    String? hotelId,
  }) {
    if (hotelId != null) {
      _nameController.text = name!;
      _imageUrlController.text = imageUrl!;
      _descriptionController.text = description!;
      _selectedCityId = cityId;
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hotelId != null ? 'Edit Hotel' : 'Add New Hotel'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getCitiesForDropdown(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            final cityList = snapshot.data ?? [];
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Hotel Name',
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
                      items: cityList.map((city) {
                        return DropdownMenuItem<String>(
                          value: city['id'],
                          child: Text(city['name']),
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
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (hotelId != null) {
                updateHotel(hotelId);
              } else {
                addHotel();
              }
            },
            child: Text(hotelId != null ? 'Update Hotel' : 'Add Hotel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Hotels"),
        backgroundColor: const Color(0xFF6995B1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: hotels.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        hotels[index]["name"],
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(hotels[index]["description"]),
                      leading: Image.network(
                        hotels[index]["imageUrl"],
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
                              showHotelForm(
                                name: hotels[index]["name"],
                                imageUrl: hotels[index]["imageUrl"],
                                description: hotels[index]["description"],
                                cityId: hotels[index]["cityId"],
                                hotelId: hotels[index]["id"],
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteHotel(hotels[index]["id"]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => showHotelForm(),
              child: const Text("Add Hotel"),
            ),
          ],
        ),
      ),
    );
  }
}
