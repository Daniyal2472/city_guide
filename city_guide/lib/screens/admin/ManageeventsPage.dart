import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  _ManageEventsPageState createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> cities = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();

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

  Future<void> _getEvents() async {
    final QuerySnapshot eventSnapshot =
    await _firestore.collection('events').get();
    setState(() {
      events = eventSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'eventName': doc['eventName'],
          'imageUrl': doc['imageUrl'],
          'description': doc['description'],
          'eventDate': doc['eventDate'],
          'cityId': doc['cityId'],
        };
      }).toList();
    });
  }

  void deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event deleted successfully")),
    );
    _getEvents();
  }

  void addEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _firestore.collection('events').add({
        'eventName': _eventNameController.text,
        'imageUrl': _imageUrlController.text,
        'description': _descriptionController.text,
        'eventDate': _eventDateController.text,
        'cityId': _selectedCityId,
      });

      _eventNameController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      _eventDateController.clear();
      setState(() {
        _selectedCityId = null;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event added successfully")),
      );
      _getEvents();
    }
  }

  void updateEvent(String eventId) async {
    if (_formKey.currentState?.validate() ?? false) {
      await _firestore.collection('events').doc(eventId).update({
        'eventName': _eventNameController.text,
        'imageUrl': _imageUrlController.text,
        'description': _descriptionController.text,
        'eventDate': _eventDateController.text,
        'cityId': _selectedCityId,
      });

      _eventNameController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      _eventDateController.clear();
      setState(() {
        _selectedCityId = null;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event updated successfully")),
      );
      _getEvents();
    }
  }

  void showEventForm(
      {String? eventName,
        String? imageUrl,
        String? description,
        String? eventDate,
        String? cityId,
        String? eventId}) {
    if (eventId != null) {
      _eventNameController.text = eventName!;
      _imageUrlController.text = imageUrl!;
      _descriptionController.text = description!;
      _eventDateController.text = eventDate!;
      _selectedCityId = cityId;
    } else {
      _eventNameController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      _eventDateController.clear();
      _selectedCityId = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(eventId != null ? 'Edit Event' : 'Add New Event'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _eventNameController,
                  decoration: const InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event name';
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
                TextFormField(
                  controller: _eventDateController,
                  decoration: const InputDecoration(
                    labelText: 'Event Date',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      _eventDateController.text =
                      "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an event date';
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
              if (eventId != null) {
                updateEvent(eventId);
              } else {
                addEvent();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6995B1),
            ),
            child: Text(eventId != null ? 'Update Event' : 'Add Event'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCities();
    _getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Events"),
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
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        events[index]["eventName"]!,
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(events[index]["description"]!),
                      leading: Image.network(
                        events[index]["imageUrl"]!,
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
                              showEventForm(
                                eventName: events[index]["eventName"],
                                imageUrl: events[index]["imageUrl"],
                                description: events[index]["description"],
                                eventDate: events[index]["eventDate"],
                                cityId: events[index]["cityId"],
                                eventId: events[index]["id"],
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                deleteEvent(events[index]["id"]!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => showEventForm(),
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
              child: const Text("Add Event"),
            ),
          ],
        ),
      ),
    );
  }
}

// This code defines a Flutter app screen for managing events. It includes functionalities to add, update, and delete events from a Firestore database. The screen displays a list of events and allows the user to add new events or edit existing ones through a form. The form includes fields for event name, image URL, description, event date, and city selection. The code also handles form validation and displays appropriate messages upon successful operations.
