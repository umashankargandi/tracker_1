import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_expense_page.dart';
import 'expense_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Daily Expenses'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<dynamic>> dailyExpenses;

  @override
  void initState() {
    super.initState();
    dailyExpenses =
        ExpenseService.fetchAllExpenses(); // Use the corrected method name here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<dynamic>>(
        future: dailyExpenses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            List<dynamic> data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                var expense = snapshot.data![index];
                DateTime parsedDate = DateTime.parse(expense['date']);
                String formattedDate =
                    DateFormat('d\'th\' MMMM yyyy').format(parsedDate);

                // Replace with currency formatting library if dealing with decimals
                String formattedAmount = '₹${expense['total'].toString()}';

                return Card(
                  child: ListTile(
                    title: Text(formattedDate),
                    trailing: Text(
                      formattedAmount,
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      // Implement onTap to show more details or edit/delete functionality
                    },
                  ),
                );
              },
            );
          } else {
            return Text('No expenses found');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddExpensePage())),
        tooltip: 'Add Expense',
        child: Icon(Icons.add),
      ),
    );
  }
}
