import 'package:flutter/material.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  List<double> pinPositions = [0.5, 0.5, 0.5]; // Current position of each pin (0 to 1)
  List<double> targetPositions = [0.3, 0.6, 0.8]; // Target positions for unlocking
  bool isUnlocked = false;
  double tolerance = 0.05; // Tolerance for alignment

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
    isUnlocked = allAligned;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lockpicking Challenge'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isUnlocked ? 'Unlocked!' : 'Align pins with target markers',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Text('Pin ${index + 1}', style: const TextStyle(fontSize: 16)),
                          SizedBox(
                            height: 300,
                            width: 200,
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
              ],
            ),
          ),
        ),
      ),
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