import 'package:flutter/material.dart';

class StaffSalaryScreen extends StatefulWidget {
  @override
  _StaffSalaryScreenState createState() => _StaffSalaryScreenState();
}

class _StaffSalaryScreenState extends State<StaffSalaryScreen> {
  String? selectedStaff;
  final List<String> staffList = ['Amit Kumar', 'Priya Sharma', 'Rahul Mehra'];

  final TextEditingController basicSalaryController = TextEditingController();
  final TextEditingController workingDaysController = TextEditingController();
  final TextEditingController bonusController = TextEditingController();
  final TextEditingController deductionController = TextEditingController();

  double totalSalary = 0.0;

  void _calculateSalary() {
    final double basic = double.tryParse(basicSalaryController.text) ?? 0.0;
    final int days = int.tryParse(workingDaysController.text) ?? 0;
    final double bonus = double.tryParse(bonusController.text) ?? 0.0;
    final double deduction = double.tryParse(deductionController.text) ?? 0.0;

    double perDay = basic / 30;
    double salary = perDay * days + bonus - deduction;

    setState(() {
      totalSalary = salary;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double ratio = width < height ? height / width : width / height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Salary Calculation'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(ratio * 3),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Select Staff', ratio),
              DropdownButtonFormField<String>(
                value: selectedStaff,
                hint: Text('Choose Staff'),
                items: staffList.map((name) {
                  return DropdownMenuItem(value: name, child: Text(name));
                }).toList(),
                onChanged: (val) => setState(() => selectedStaff = val),
                decoration: _inputDecoration(ratio),
              ),
              SizedBox(height: ratio * 2),

              _buildLabel('Basic Salary (₹)', ratio),
              _buildTextField(basicSalaryController, 'Enter basic salary', TextInputType.number, ratio),

              _buildLabel('Working Days', ratio),
              _buildTextField(workingDaysController, 'Enter days', TextInputType.number, ratio),

              _buildLabel('Bonus (₹)', ratio),
              _buildTextField(bonusController, 'Enter bonus', TextInputType.number, ratio),

              _buildLabel('Deduction (₹)', ratio),
              _buildTextField(deductionController, 'Enter deduction', TextInputType.number, ratio),

              SizedBox(height: ratio * 2),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _calculateSalary,
                  icon: Icon(Icons.calculate),
                  label: Text('Calculate Salary'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: ratio*30, vertical: ratio*6),
                    textStyle: TextStyle(fontSize: ratio * 6),
                  ),
                ),
              ),
              SizedBox(height: ratio * 3),
              Center(
                child: Text(
                  'Total Salary: ₹${totalSalary.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: ratio * 7,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType type, double ratio) {
    return Padding(
      padding: EdgeInsets.only(bottom: ratio * 2),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: _inputDecoration(ratio).copyWith(hintText: hint),
      ),
    );
  }

  Widget _buildLabel(String text, double ratio) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: ratio * 6),
      ),
    );
  }

  InputDecoration _inputDecoration(double ratio) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(ratio * 3)),
      contentPadding: EdgeInsets.symmetric(horizontal: ratio * 5, vertical: ratio * 4),
    );
  }
}
