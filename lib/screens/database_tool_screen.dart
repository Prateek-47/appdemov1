import 'package:flutter/material.dart';
import '../models/person.dart';

class DatabaseToolScreen extends StatefulWidget {
  const DatabaseToolScreen({super.key});

  @override
  State<DatabaseToolScreen> createState() => _DatabaseToolScreenState();
}

class _DatabaseToolScreenState extends State<DatabaseToolScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Person> _filteredPeople = [];

  @override
  void initState() {
    super.initState();
    _filteredPeople = getPeople();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Person> getPeople() {
    return [
      Person(
        name: 'John Smith',
        address: '123 Main St, New York, NY 10001',
        phoneNumber: '+1 (555) 123-4567',
        email: 'john.smith@email.com',
        personalRemarks: 'Prefers morning meetings',
      ),
      Person(
        name: 'Sarah Johnson',
        address: '456 Park Ave, Boston, MA 02108',
        phoneNumber: '+1 (555) 234-5678',
        email: 'sarah.j@email.com',
        personalRemarks: 'Allergic to nuts',
      ),
      Person(
        name: 'Michael Brown',
        address: '789 Oak Dr, Chicago, IL 60601',
        phoneNumber: '+1 (555) 345-6789',
        email: 'm.brown@email.com',
        personalRemarks: 'Loves hiking',
      ),
      Person(
        name: 'Emily Davis',
        address: '321 Pine St, Seattle, WA 98101',
        phoneNumber: '+1 (555) 456-7890',
        email: 'emily.d@email.com',
        personalRemarks: 'Vegetarian',
      ),
      Person(
        name: 'David Wilson',
        address: '654 Maple Ave, San Francisco, CA 94101',
        phoneNumber: '+1 (555) 567-8901',
        email: 'd.wilson@email.com',
        personalRemarks: 'Night owl',
      ),
      Person(
        name: 'Celeste',
        address: 'Celeste Apartment, 789 Dream St, Los Angeles, CA 90001',
        phoneNumber: '+1 (555) 678-9012',
        email: 'celeste@email.com',
        personalRemarks: 'Apartment door password: 1234',
      ),
    ];
  }

  void _filterPeople(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredPeople = getPeople();
      } else {
        _filteredPeople = getPeople().where((person) {
          return person.name.toLowerCase().contains(_searchQuery) ||
              person.address.toLowerCase().contains(_searchQuery) ||
              person.phoneNumber.toLowerCase().contains(_searchQuery) ||
              person.email.toLowerCase().contains(_searchQuery) ||
              person.personalRemarks.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Tool'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, address, phone, email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterPeople('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterPeople,
            ),
          ),
          Expanded(
            child: _filteredPeople.isEmpty
                ? const Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPeople.length,
                    itemBuilder: (context, index) {
                      final person = _filteredPeople[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: Text(
                            person.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(Icons.location_on, 'Address', person.address),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(Icons.phone, 'Phone', person.phoneNumber),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(Icons.email, 'Email', person.email),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.note,
                                    'Personal Remarks',
                                    person.personalRemarks,
                                    isRemarks: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isRemarks = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: isRemarks ? Colors.red : Colors.black87,
                  fontWeight: isRemarks ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 