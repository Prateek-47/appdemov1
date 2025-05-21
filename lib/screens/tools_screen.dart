import 'package:flutter/material.dart';
import 'database_tool_screen.dart';
import 'files_tool_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildToolCard(
            context,
            'Database Tool',
            Icons.storage,
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DatabaseToolScreen(),
                ),
              );
            },
          ),
          _buildToolCard(
            context,
            'Map Tool',
            Icons.map,
            Colors.green,
            () {
              // TODO: Navigate to Map Tool
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Map Tool coming soon!')),
              );
            },
          ),
          _buildToolCard(
            context,
            'Files Tool',
            Icons.folder,
            Colors.orange,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FilesToolScreen(),
                ),
              );
            },
          ),
          _buildToolCard(
            context,
            'Browser Tool',
            Icons.web,
            Colors.purple,
            () {
              // TODO: Navigate to Browser Tool
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Browser Tool coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.7),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 