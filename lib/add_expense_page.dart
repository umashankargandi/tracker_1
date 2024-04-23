import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'expense_service.dart'; // Make sure this points to your ExpenseService file

class AddExpensePage extends StatefulWidget {
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  List<String> _categories = [];
  List<String> _paymentModes = [];
  List<String> _paymentMadeBy = [];
  String? _selectedCategory;
  String? _selectedPaymentMode;
  String? _selectedPaymentMadeBy;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    final dropdownData = await ExpenseService.fetchDropdownData();
    setState(() {
      _categories = List<String>.from(dropdownData['categories'] ?? []);
      _paymentModes = List<String>.from(dropdownData['paymentModes'] ?? []);
      _paymentMadeBy = List<String>.from(dropdownData['paymentMadeBy'] ?? []);
      _selectedCategory = _categories.first;
      _selectedPaymentMode = _paymentModes.first;
      _selectedPaymentMadeBy = _paymentMadeBy.first;
    });
  }

  Future<bool> submitExpenseData(Map<String, dynamic> formData) async {
    return await ExpenseService.submitExpenseData(formData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                ),
                buildDropdownButtonFormField(
                    _categories,
                    _selectedCategory,
                    'Select Category',
                    (newValue) => setState(() => _selectedCategory = newValue)),
                buildDropdownButtonFormField(
                    _paymentModes,
                    _selectedPaymentMode,
                    'Select Payment Mode',
                    (newValue) =>
                        setState(() => _selectedPaymentMode = newValue)),
                buildDropdownButtonFormField(
                    _paymentMadeBy,
                    _selectedPaymentMadeBy,
                    'Select Payment Made By',
                    (newValue) =>
                        setState(() => _selectedPaymentMadeBy = newValue)),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an amount' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a description' : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final Map<String, dynamic> expenseData = {
                            'date': _dateController.text,
                            'category': _selectedCategory,
                            'paymentMode': _selectedPaymentMode,
                            'paymentMadeBy': _selectedPaymentMadeBy,
                            'amount': _amountController.text,
                            'description': _descriptionController.text,
                          };

                          final isSuccess =
                              await submitExpenseData(expenseData);

                          if (isSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Expense added')));
                            Navigator.of(context)
                                .pop(); // Optionally pop the context to return to the previous page
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failure to submit data, please retry')),
                            );
                          }
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownButtonFormField<String> buildDropdownButtonFormField(
      List<String> items,
      String? selectedValue,
      String hint,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: hint,
      ),
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) => value == null ? 'Please select a $hint' : null,
    );
  }
}
