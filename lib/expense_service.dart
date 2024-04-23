import 'dart:convert';

import 'package:http/http.dart' as http;

class ExpenseService {
  // Your Google Apps Script Web App URL
  static const String _baseUrl =
      'https://script.google.com/macros/s/AKfycbymQOf7NDeuLZutSkTiHhXS72dfz56dQ20z8Pgss_HDgG10C6kflgnN-OC7u0w78-JRmg/exec';

  // Fetch dropdown data for Categories, Payment Modes, and Payment Made By
  static Future<Map<String, dynamic>> fetchDropdownData() async {
    final response =
        await http.get(Uri.parse('$_baseUrl?action=fetchDropdownData'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load dropdown data');
    }
  }

  /// Fetch all expenses
  static Future<List<dynamic>> fetchAllExpenses() async {
    final response =
        await http.get(Uri.parse('$_baseUrl?action=fetchAllExpenses'));
    if (response.statusCode == 200) {
      return json.decode(response.body); // Directly decode response as a list
    } else {
      throw Exception('Failed to load all expenses');
    }
  }

  // Submit a new expense entry to the Google Sheet via the Google Apps Script
  static Future<bool> submitExpenseData(
      Map<String, dynamic> expenseData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?action=submitExpense'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(expenseData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      // Assuming your Google Apps Script returns {"result": "success"} on successful insertion
      return responseData['result'] == 'success';
    } else {
      // Log or handle HTTP request errors if needed
      print(
          'Failed to submit expense data: HTTP status ${response.statusCode}');
      return false;
    }
  }
}
