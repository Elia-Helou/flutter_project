import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'bmi_result_screen.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({Key? key}) : super(key: key);

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  String gender = 'Male';
  final TextEditingController ageController = TextEditingController(text: '30');
  final TextEditingController weightController = TextEditingController(text: '70');
  final TextEditingController heightController = TextEditingController(text: '176');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI calculator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            const Text(
              'YOUR GENDER',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GenderButton(
                  label: 'Male',
                  selected: gender == 'Male',
                  onTap: () => setState(() => gender = 'Male'),
                ),
                const SizedBox(width: 16),
                _GenderButton(
                  label: 'Female',
                  selected: gender == 'Female',
                  onTap: () => setState(() => gender = 'Female'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AGE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _InputBox(
                        controller: ageController,
                        suffix: '',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('WEIGHT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _InputBox(
                        controller: weightController,
                        suffix: 'KG',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HEIGHT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _InputBox(
                  controller: heightController,
                  suffix: 'cm',
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final double weight = double.tryParse(weightController.text) ?? 0;
                  final double heightCm = double.tryParse(heightController.text) ?? 0;
                  final double heightM = heightCm / 100;
                  final double bmi = (heightM > 0) ? weight / (heightM * heightM) : 0;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BMIResultScreen(bmi: bmi),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.splashBackground,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'CALCULATE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _GenderButton({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: selected ? AppColors.splashBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black54, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String suffix;
  const _InputBox({required this.controller, required this.suffix});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black54, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black, fontSize: 18),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          if (suffix.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(suffix, style: const TextStyle(color: Colors.black54, fontSize: 16)),
            ),
        ],
      ),
    );
  }
} 