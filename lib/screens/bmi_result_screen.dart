import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../services/database_service.dart';
import '../providers/user_provider.dart';
import 'dart:math' as math;

class BMIResultScreen extends StatefulWidget {
  final double bmi;
  final double weight;
  final double height;
  
  const BMIResultScreen({
    Key? key, 
    required this.bmi,
    required this.weight,
    required this.height,
  }) : super(key: key);

  @override
  State<BMIResultScreen> createState() => _BMIResultScreenState();
}

class _BMIResultScreenState extends State<BMIResultScreen> {
  bool _isSaving = false;

  Future<void> _saveResults() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) {
        throw Exception('User not logged in');
      }

      await DatabaseService.instance.saveBMIResults(
        userId: user.id,
        weight: widget.weight,
        height: widget.height,
        bmiValue: widget.bmi,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('BMI results saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving results: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String getBMICategory() {
    if (widget.bmi < 18.5) return 'UNDERWEIGHT';
    if (widget.bmi < 25) return 'NORMAL';
    if (widget.bmi < 30) return 'OVERWEIGHT';
    return 'OBESE';
  }

  String getBMIMessage() {
    if (widget.bmi < 18.5) {
      return "Your BMI is below normal. Consider a balanced diet to reach a healthy weight.";
    } else if (widget.bmi < 25) {
      return "Congratulations! You're in a great place now.\nKeep up your healthy habits to maintain your healthy weight.";
    } else if (widget.bmi < 30) {
      return "Your BMI is above normal. Consider healthy eating and exercise.";
    } else {
      return "Your BMI is in the obese range. Consult a healthcare provider for advice.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Your BMI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Gauge
              Center(
                child: SizedBox(
                  width: 300,
                  height: 220,
                  child: CustomPaint(
                    painter: _BMIGaugePainter(bmi: widget.bmi),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your BMI',
                style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.bmi.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                getBMICategory(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                getBMIMessage(),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveResults,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.splashBackground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Results',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.splashBackground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _BMIGaugePainter extends CustomPainter {
  final double bmi;
  _BMIGaugePainter({required this.bmi});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width * 0.9 / 2;
    final startAngle = math.pi;
    final sweepAngle = math.pi;
    final ranges = [
      [16, 18.5, Colors.blue],
      [18.5, 25, Colors.green],
      [25, 30, Colors.orange],
      [30, 40, Colors.red],
    ];
    final minBMI = 16.0;
    final maxBMI = 40.0;
    // Draw colored arcs
    double lastEnd = startAngle;
    for (var range in ranges) {
      final rangeStart = (range[0] as num).toDouble();
      final rangeEnd = (range[1] as num).toDouble();
      final color = range[2] as Color;
      final rangeSweep = sweepAngle * (rangeEnd - rangeStart) / (maxBMI - minBMI);
      final paint = Paint()
        ..color = color
        ..strokeWidth = 18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        lastEnd,
        rangeSweep,
        false,
        paint,
      );
      lastEnd += rangeSweep;
    }
    // Draw ticks and labels
    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    for (double v = minBMI; v <= maxBMI; v += 5) {
      final angle = startAngle + sweepAngle * (v - minBMI) / (maxBMI - minBMI);
      final tickStart = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );
      final tickEnd = Offset(
        center.dx + (radius + 10) * math.cos(angle),
        center.dy + (radius + 10) * math.sin(angle),
      );
      canvas.drawLine(tickStart, tickEnd, tickPaint);
      final textPainter = TextPainter(
        text: TextSpan(
          text: v.toInt().toString(),
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelOffset = Offset(
        center.dx + (radius + 28) * math.cos(angle) - textPainter.width / 2,
        center.dy + (radius + 28) * math.sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }
    // Draw pointer
    final pointerAngle = startAngle + sweepAngle * ((bmi - minBMI) / (maxBMI - minBMI)).clamp(0, 1);
    final pointerPaint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final pointerEnd = Offset(
      center.dx + (radius - 30) * math.cos(pointerAngle),
      center.dy + (radius - 30) * math.sin(pointerAngle),
    );
    canvas.drawLine(center, pointerEnd, pointerPaint);
    // Draw pointer knob
    final knobPaint = Paint()..color = Colors.black;
    canvas.drawCircle(center, 10, knobPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 