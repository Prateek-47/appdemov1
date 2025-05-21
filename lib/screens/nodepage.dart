import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

import 'PlayGamePage.dart';
import '../services/auth_service.dart'; // <- Import your AuthService

class NodePage extends StatefulWidget {
  final String nodeId;

  NodePage({required this.nodeId});

  @override
  _NodePageState createState() => _NodePageState();
}

class _NodePageState extends State<NodePage> {
  List<String> imageUrls = [];
  bool isLoading = true;
  bool isScoreUpdated = false;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    final apiUrl = 'http://192.168.63.92:5000/api/nodes/${widget.nodeId}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            imageUrls = List<String>.from(data['images']);
            isLoading = false;
          });
        } else {
          throw Exception(data['error']);
        }
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _updateUserScore() async {
    if (isScoreUpdated || AuthService.userId == null) return;

    final apiUrl = 'http://192.168.63.92:5000/leaderboard/update/${AuthService.userId}';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'xp': 10}),
      );

      if (response.statusCode == 200) {
        setState(() {
          isScoreUpdated = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Score updated successfully!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Bufkes()),
        );
      } else {
        throw Exception('Failed to update score');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating score: $e')),
      );
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('House Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👤 Name: John Doe'),
            Text('📍 Address: 123 Elm Street, Gotham City'),
            Text('📞 Phone: +1 234 567 8901'),
            Text('🏠 House Number: 42'),
            Text('🔐 House Password: openSesame'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Node: ${widget.nodeId}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : imageUrls.isEmpty
              ? Center(child: Text('No images found.'))
              : NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                      _updateUserScore();
                    }
                    return true;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      final imageUrl = imageUrls[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            if (index == 1)
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: ElevatedButton(
                                  onPressed: _showInfoDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black87,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('View'),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
