import 'package:flutter/material.dart';

class ManageCitiesPage extends StatefulWidget {
  const ManageCitiesPage({super.key});

  @override
  _ManageCitiesPageState createState() => _ManageCitiesPageState();
}

class _ManageCitiesPageState extends State<ManageCitiesPage> {
  // Static data of cities
  final List<Map<String, String>> cities = [
    {"name": "New York", "imageUrl": "https://example.com/ny.jpg"},
    {"name": "Los Angeles", "imageUrl": "https://example.com/la.jpg"},
    // Add more cities with their image URLs
  ];

  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  // Function to delete a city
  void deleteCity(int index) {
    setState(() {
      cities.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("City deleted: ${cities[index]}")),
    );
  }

  // Function to add a new city
  void addCity() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        cities.add({
          "name": _cityController.text,
          "imageUrl": _imageUrlController.text,
        });
      });
      _cityController.clear();
      _imageUrlController.clear();
      Navigator.pop(context); // Close the dialog after adding
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("City added successfully")),
      );
    }
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
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // List of cities
            Expanded(
              child: ListView.builder(
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
                          // Edit button
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Edit city: ${cities[index]["name"]}")),
                              );
                            },
                          ),
                          // Delete button
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteCity(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Add City Button (more unique with gradient and styling)
            ElevatedButton(
              onPressed: () {
                // Open the form to add a new city
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add New City'),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Image widget added above the form
                          const SizedBox(height: 16),
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
                          // Display the image preview if URL is provided
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
                          Navigator.pop(context); // Close the dialog without adding
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: addCity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6995B1), // Button color
                        ),
                        child: const Text('Add City'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF6995B1), // Button color
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
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
