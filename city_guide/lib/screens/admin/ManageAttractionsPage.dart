import 'package:flutter/material.dart';

class ManageAttractionsPage extends StatefulWidget {
  const ManageAttractionsPage({super.key});

  @override
  _ManageAttractionsPageState createState() => _ManageAttractionsPageState();
}

class _ManageAttractionsPageState extends State<ManageAttractionsPage> {
  // Static list of attractions
  final List<Map<String, String>> attractions = [
    {
      "name": "Eiffel Tower",
      "imageUrl": "https://example.com/eiffel.jpg",
      "description": "A wrought-iron lattice tower in Paris."
    },
    {
      "name": "Statue of Liberty",
      "imageUrl": "https://example.com/statue.jpg",
      "description": "A colossal neoclassical sculpture on Liberty Island."
    },
  ];

  // Controllers for form inputs
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Function to delete an attraction
  void deleteAttraction(int index) {
    setState(() {
      attractions.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Attraction deleted successfully")),
    );
  }

  // Function to add a new attraction
  void addAttraction() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        attractions.add({
          "name": _nameController.text,
          "imageUrl": _imageUrlController.text,
          "description": _descriptionController.text,
        });
      });
      _nameController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attraction added successfully")),
      );
    }
  }

  // Function to show the add/edit attraction form
  void showAttractionForm({String? name, String? imageUrl, String? description, int? index}) {
    if (index != null) {
      _nameController.text = name!;
      _imageUrlController.text = imageUrl!;
      _descriptionController.text = description!;
    } else {
      _nameController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index != null ? 'Edit Attraction' : 'Add New Attraction'),
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
              if (index != null) {
                setState(() {
                  attractions[index] = {
                    "name": _nameController.text,
                    "imageUrl": _imageUrlController.text,
                    "description": _descriptionController.text,
                  };
                });
                Navigator.pop(context); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Attraction updated successfully")),
                );
              } else {
                addAttraction();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6995B1), // Button color
            ),
            child: Text(index != null ? 'Update Attraction' : 'Add Attraction'),
          ),
        ],
      ),
    );
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
                                index: index,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteAttraction(index),
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
