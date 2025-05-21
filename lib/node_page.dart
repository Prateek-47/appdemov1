import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'dart:convert';
import 'dart:math';
class NodePage extends StatefulWidget {
  final String nodeId;

  const NodePage({
    super.key,
    required this.nodeId,
  });

  @override
  State<NodePage> createState() => _NodePageState();
}

class _NodePageState extends State<NodePage> {
  List<String> imageUrls = [];
  bool isLoading = true;
  String? error;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _hasShownPopup = false;
  String _enteredPassword = '';
  bool _isPasswordCorrect = false;
  bool _isLockpickingUnlocked = false;
  bool _hasTriggeredFindGame = false;
  // Lockpicking game state
  List<double> pinPositions = [0.5, 0.5, 0.5];
  List<double> targetPositions = [0.3, 0.6, 0.8];
  double tolerance = 0.05;

  @override
  void initState() {
    super.initState();
    //_fetchImages();


  // // Load images directly from static URLs for testing
  // setState(() {
  //   imageUrls = ["https://comics-strips.s3.amazonaws.com/node1/page1.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=tpLPuvUaVZhpGMSimE9akgB0GuM%3D",
  //   "https://comics-strips.s3.amazonaws.com/node1/page2.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=oAReRsA3A6PuEMewMKBcUSSb5Xw%3D",
  //   "https://comics-strips.s3.amazonaws.com/node1/page3.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=o4vOR9eHVeRJ%2FryqHzHTlMKWYH4%3D",
  //   "https://comics-strips.s3.amazonaws.com/node1/page4.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=O71I7NtXcNDFr0ce1MAMN0WF5SA%3D",
  //   "https://comics-strips.s3.amazonaws.com/node1/page5.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=W4vB9T3IJmvkMPMQG4R5NMulN8E%3D",
  //   "https://comics-strips.s3.amazonaws.com/node1/page6.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=CYl4l2hX5m79naTKIWZBbSHtzps%3D"];
  //   isLoading = false;
  // });
  //   // Preload all images in advance
  // for (final url in imageUrls) {
  //   precacheImage(NetworkImage(url), context);
  // }

  // Delay all context-dependent work
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final urls = [
      "https://comics-strips.s3.us-east-1.amazonaws.com/node1/page1.jpg",
      "https://comics-strips.s3.us-east-1.amazonaws.com/node1/page2.jpg",
      "https://comics-strips.s3.us-east-1.amazonaws.com/node1/page3.jpg",
      "https://comics-strips.s3.us-east-1.amazonaws.com/node1/page4.jpg",
      "https://comics-strips.s3.us-east-1.amazonaws.com/node1/page5.jpg",
      "https://comics-strips.s3.us-east-1.amazonaws.com/node1/page6.jpg"
    ];

    // Precache images
    for (final url in urls) {
      precacheImage(NetworkImage(url), context);
    }

    // Then update state
    setState(() {
      imageUrls = urls;
      isLoading = false;
    });
  });
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

void _onPageChanged() {
  int page = _pageController.page?.round() ?? 0;

  if (page == 5 && !_hasTriggeredFindGame) {
    _hasTriggeredFindGame = true;
    Future.delayed(const Duration(seconds: 3), () {
                                if (mounted) {
                                  Future.microtask(_triggerFindItemGame); // ensures dialog shows after build
                                }
                              });
    
  }
}

  Future<void> _fetchImages() async {
    try {
      final response = await AuthService.get('/api/nodes/${widget.nodeId}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['images'] != null) {
          setState(() {
            imageUrls = List<String>.from(data['images']);
            isLoading = false;
            error = null;
          });
        } else {
          setState(() {
            error = 'No images found for this node';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        setState(() {
          error = 'Failed to load images. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching images: $e');
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _showCelesteInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Important Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Celeste\'s Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File saved to Files Tool'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('View'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Later'),
          ),
        ],
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

  void _showPasswordDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      String tempPassword = '';
      return AlertDialog(
        title: const Text('Enter Password'),
        content: TextField(
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          onChanged: (value) {
            tempPassword = value;
          },
          decoration: const InputDecoration(
            labelText: '4-digit Password',
            counterText: '',
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
              if (tempPassword == '1234') {
                setState(() {
                  _isPasswordCorrect = true;
                });
                Navigator.pop(context);
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Incorrect password. Try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}


  void _checkPassword() {
    if (_enteredPassword == '1234') {
      setState(() {
        _isPasswordCorrect = true;
      });
      Navigator.pop(context);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect password. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _enteredPassword = '';
      });
    }
  }

  void _showLockpickingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LockpickingDialog(
        onUnlock: (unlocked) {
          setState(() {
            _isLockpickingUnlocked = unlocked;
          });
        //   _pageController.nextPage(
        //   duration: const Duration(milliseconds: 300),
        //   curve: Curves.easeInOut,
        // );
        },
      ),
    );
  }
void _triggerFindItemGame() {
  _hasTriggeredFindGame = true;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => FindItemDialog(
      targetItem: '🔑',
      onFound: () {
        Navigator.pop(context);
        setState(() {
          _hasTriggeredFindGame = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You found the key!'),
            backgroundColor: Colors.green,
          ),
        );
        
      },
    ),
  );
}


void _nextPage() {
  if (_currentPage <= imageUrls.length + 1) {
    if (_currentPage == 5 && !_hasTriggeredFindGame) {
      print('Triggering find item game'); 
      print(_currentPage); // ✅ Check if this prints
      _triggerFindItemGame();
      return;
    } else if (_currentPage == 3 && !_isPasswordCorrect) {
      _showPasswordDialog();
      return;
    } else if (_currentPage == 2 && !_isLockpickingUnlocked) {
      _showLockpickingDialog();
      print('Triggering find item game'); // ✅ Check if this prints
      return;
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
    }
  }
}


  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Node: ${widget.nodeId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // isLoading = true;
                // error = null;
                imageUrls = ["https://comics-strips.s3.amazonaws.com/node1/page1.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=tpLPuvUaVZhpGMSimE9akgB0GuM%3D",
    "https://comics-strips.s3.amazonaws.com/node1/page2.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=oAReRsA3A6PuEMewMKBcUSSb5Xw%3D",
    "https://comics-strips.s3.amazonaws.com/node1/page3.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=o4vOR9eHVeRJ%2FryqHzHTlMKWYH4%3D",
    "https://comics-strips.s3.amazonaws.com/node1/page4.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=O71I7NtXcNDFr0ce1MAMN0WF5SA%3D",
    "https://comics-strips.s3.amazonaws.com/node1/page5.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=W4vB9T3IJmvkMPMQG4R5NMulN8E%3D",
    "https://comics-strips.s3.amazonaws.com/node1/page6.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=CYl4l2hX5m79naTKIWZBbSHtzps%3D"];
    isLoading = false;
              });
              //_fetchImages();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // isLoading = true;
                            // error = null;
                            imageUrls = ["https://comics-strips.s3.amazonaws.com/node1/page1.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=tpLPuvUaVZhpGMSimE9akgB0GuM%3D",
    "https://comics-strips.s3.amazonaws.com/node1/page2.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=oAReRsA3A6PuEMewMKBcUSSb5Xw%3D",
    "https://comics-strips.s3.amazonaws.com/node1/page3.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=o4vOR9eHVeRJ%2FryqHzHTlMKWYH4%3D",
    "https://comics-strips.s3.amazonaws.com/node1/page4.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=O71I7NtXcNDFr0ce1MAMN0WF5SA%3D",
    "https://comics-strips.s3.amazonaws.com/node1/page5.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=W4vB9T3IJmvkMPMQG4R5NMulN8E%3D",
    "https://comics-strips.s3.amazonaws.com/node1/page6.jpg?AWSAccessKeyId=AKIA6ODU76EFXTFICWNQ&Expires=1747826027&Signature=CYl4l2hX5m79naTKIWZBbSHtzps%3D"];
    isLoading = false;
                          });
                         // _fetchImages();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : imageUrls.isEmpty
                  ? const Center(child: Text('No images found.'))
                  : Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: imageUrls.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                            // Show popup when reaching the second image with 3-second delay
                            if (index == 1 && !_hasShownPopup) {
                              _hasShownPopup = true;
                                Future.delayed(const Duration(seconds: 3), () {
                                  if (mounted) {
                                    _showCelesteInfoDialog();
                                  }
                                });
                            }
                          },
                          itemBuilder: (context, index) {
                            return Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrls[index],
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading image: $error');
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error_outline, color: Colors.red),
                                            SizedBox(height: 8),
                                            Text(
                                              'Failed to load image',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        // Navigation buttons
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(
                                Icons.chevron_left,
                                size: 40,
                                color: Colors.white,
                              ),
                              onPressed: _currentPage > 0 ? _previousPage : null,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                shape: const CircleBorder(),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(
                                Icons.chevron_right,
                                size: 40,
                                color: Colors.white,
                              ),
                              onPressed: _currentPage < imageUrls.length - 1 ? _nextPage : null,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                shape: const CircleBorder(),
                              ),
                            ),
                          ),
                        ),
                        // Page indicator
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              imageUrls.length,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentPage == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class LockpickingDialog extends StatefulWidget {
  final Function(bool) onUnlock;

  const LockpickingDialog({
    super.key,
    required this.onUnlock,
  });

  @override
  State<LockpickingDialog> createState() => _LockpickingDialogState();
}

class _LockpickingDialogState extends State<LockpickingDialog> {
  List<double> pinPositions = [0.5, 0.5, 0.5];
  List<double> targetPositions = [0.3, 0.6, 0.8];
  bool isUnlocked = false;
  double tolerance = 0.05;

  void updatePinPosition(int pinIndex, double newValue) {
    setState(() {
      pinPositions[pinIndex] = newValue.clamp(0.0, 1.0);
      checkUnlock();
    });
  }

  void checkUnlock() {
    bool allAligned = true;
    for (int i = 0; i < 3; i++) {
      double diff = (pinPositions[i] - targetPositions[i]).abs();
      if (diff > tolerance) {
        allAligned = false;
        break;
      }
    }
    if (allAligned && !isUnlocked) {
      setState(() {
        isUnlocked = true;
      });
      widget.onUnlock(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick the Lock'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isUnlocked ? 'Unlocked!' : 'Align pins with target markers',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Text('Pin ${index + 1}', style: const TextStyle(fontSize: 16)),
                        SizedBox(
                          height: 300,
                          width: 60,
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: CustomPaint(
                              painter: SliderTrackPainter(
                                pinPosition: pinPositions[index],
                                targetPosition: targetPositions[index],
                              ),
                              child: Slider(
                                value: pinPositions[index],
                                onChanged: (value) => updatePinPosition(index, value),
                                min: 0.0,
                                max: 1.0,
                                activeColor: Colors.blue,
                                inactiveColor: Colors.grey[300],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (isUnlocked)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
      ],
    );
  }
}

class SliderTrackPainter extends CustomPainter {
  final double pinPosition;
  final double targetPosition;

  SliderTrackPainter({required this.pinPosition, required this.targetPosition});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw track background
    final trackPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      trackPaint,
    );

    // Draw target marker
    final targetX = size.width * targetPosition;
    final targetPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(targetX - 5, 0, 10, size.height),
      targetPaint,
    );

    // Draw pin position marker
    final pinX = size.width * pinPosition;
    final pinPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(pinX - 2, 0, 4, size.height),
      pinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 

class FindItemDialog extends StatefulWidget {
  final String targetItem;
  final VoidCallback onFound;

  const FindItemDialog({
    super.key,
    required this.targetItem,
    required this.onFound,
  });

  @override
  State<FindItemDialog> createState() => _FindItemDialogState();
}

class _FindItemDialogState extends State<FindItemDialog> {
  late List<String> items;

  @override
  void initState() {
    super.initState();
    items = _generateItems();
  }

  List<String> _generateItems() {
    List<String> allItems = ['🍎', '🔧', '🧪', '🔑', '📦', '💎', '🧲', '🎯'];
    List<String> shuffled = List.generate(20, (_) {
      return allItems[Random().nextInt(allItems.length)];
    });

    // Ensure the target item is in the list
    shuffled[Random().nextInt(shuffled.length)] = widget.targetItem;
    return shuffled;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Find the ${widget.targetItem}'),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (items[index] == widget.targetItem) {
                  widget.onFound();
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.white,
                ),
                child: Text(
                  items[index],
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
