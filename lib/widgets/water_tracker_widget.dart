import 'package:flutter/material.dart';

class WaterTrackerWidget extends StatefulWidget {
  const WaterTrackerWidget({Key? key}) : super(key: key);

  @override
  State<WaterTrackerWidget> createState() => _WaterTrackerWidgetState();
}

class _WaterTrackerWidgetState extends State<WaterTrackerWidget> {
  final int totalCups = 12;
  final double goalLiters = 3.0;
  late final double cupVolume;
  int cupsDrunk = 0;

  @override
  void initState() {
    super.initState();
    cupVolume = goalLiters / totalCups;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Water Tracker  ${(cupsDrunk * cupVolume).toStringAsFixed(2)} / $goalLiters L',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(totalCups, (index) {
            bool isFilled = index < cupsDrunk;
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (cupsDrunk == index) {
                    cupsDrunk++;
                  } else if (cupsDrunk > index) {
                    cupsDrunk = index;
                  }
                  if (cupsDrunk > totalCups) cupsDrunk = totalCups;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: isFilled ? Colors.blue : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: isFilled ? 44 : 0,
                      decoration: BoxDecoration(
                        color: Colors.blue[300],
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.local_drink,
                      size: 44,
                      color: isFilled ? Colors.blue : Colors.grey[300],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                cupsDrunk = 0;
              });
            },
            child: const Text('Reset'),
          ),
        ),
      ],
    );
  }
} 