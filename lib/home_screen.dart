import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_interest_calculator/utils/entry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double currentAmount = 0;
  List<InterestEntry> entries = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _calculateInterest() {
    final DateTime currentDate = DateTime.now();
    final DateTime lastEntryDate =
        entries.isNotEmpty ? entries.last.date : currentDate;
    final int monthsDiff = (currentDate.year - lastEntryDate.year) * 12 +
        currentDate.month -
        lastEntryDate.month;

    if (monthsDiff > 0) {
      final double interestRate = 0.03; // 3%
      final double interestAmount = currentAmount * interestRate * monthsDiff;
      currentAmount += interestAmount;

      // Add the interest entry to the list
      entries.add(InterestEntry(amount: interestAmount, date: currentDate));

      _saveData();
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentAmount = prefs.getDouble('currentAmount') ?? 0;
      entries = _deserializeEntries(prefs.getStringList('entries') ?? []);
    });
    _calculateInterest();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('currentAmount', currentAmount);
    await prefs.setStringList('entries', _serializeEntries(entries));
  }

  List<InterestEntry> _deserializeEntries(List<String> serialized) {
    return serialized.map((entry) {
      final parts = entry.split(',');
      return InterestEntry(
        amount: double.parse(parts[0]),
        date: DateFormat('yyyy-MM-dd').parse(parts[1]),
      );
    }).toList();
  }

  List<String> _serializeEntries(List<InterestEntry> entries) {
    return entries.map((entry) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(entry.date);
      return '${entry.amount.toStringAsFixed(2)},$formattedDate';
    }).toList();
  }

  void _addEntry(double amount, DateTime date) {
    setState(() {
      entries.add(InterestEntry(amount: amount, date: date));
      currentAmount += amount;
    });
    _calculateInterest();
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[200],
        centerTitle: true,
        title: const Text('SI Calculator'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Current Amount: Rs. ${currentAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  child: ListTile(
                    title: Text('Rs. ${entry.amount.toStringAsFixed(2)}'),
                    subtitle: Text(
                        'Date: ${DateFormat('yyyy-MM-dd').format(entry.date)}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddEntryDialog(BuildContext context) async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final currentDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
              ),
              TextField(
                controller: dateController,
                keyboardType: TextInputType.datetime,
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: currentDate,
                    firstDate: DateTime(currentDate.year - 10),
                    lastDate: currentDate,
                  );
                  if (selectedDate != null) {
                    dateController.text =
                        DateFormat('yyyy-MM-dd').format(selectedDate);
                  }
                },
                decoration: InputDecoration(labelText: 'Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                final date =
                    DateFormat('yyyy-MM-dd').parse(dateController.text);
                _addEntry(amount, date);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
