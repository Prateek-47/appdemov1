import 'package:flutter/material.dart';

class FilesToolScreen extends StatelessWidget {
  const FilesToolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Files Tool'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 1, // Currently only Celeste's file
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text(
                'Celeste\'s Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: const Text('Saved from Comic Node'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.person, 'Name', 'Celeste'),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.location_on,
                        'Address',
                        'Celeste Apartment, 789 Dream St, Los Angeles, CA 90001',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.phone,
                        'Phone',
                        '+1 (555) 678-9012',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.email,
                        'Email',
                        'celeste@email.com',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.note,
                        'Important Note',
                        'Apartment door password: 1234',
                        isImportant: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isImportant = false}) {
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
                  color: isImportant ? Colors.red : Colors.black87,
                  fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 