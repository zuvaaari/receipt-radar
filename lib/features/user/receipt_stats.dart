import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../authentication/login.dart';
import '../home/home.dart';
import 'user_profile.dart';

class ReceiptStats extends StatefulWidget {
  const ReceiptStats({Key? key}) : super(key: key);

  @override
  _ReceiptStatsState createState() => _ReceiptStatsState();
}

class _ReceiptStatsState extends State<ReceiptStats> {
  List<BarChartGroupData> _barChartGroupData = [];
  final List<String> categories = []; // To store expense categories
  final Map<String, int> categoryCounts =
      {}; // To store frequency of each category
  double maxYValue = 0; // Initialize maxYValue

  @override
  void initState() {
    super.initState();
    _fetchAndProcessData();
  }

  Future<String> generateCsvFromExpenses(
      List<Map<String, dynamic>> expenses) async {
    List<List<dynamic>> rows = [
      <String>['Date', 'Category', 'Merchant', 'Total Price', 'Payment Method'],
      // Header row
    ];

    for (var expense in expenses) {
      rows.add([
        expense['date'],
        expense['category'],
        expense['merchant'],
        expense['totalPrice'],
        expense['paymentMethod']
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  //Share and generate expense report (CSV format)
  Future<void> _downloadExpenseReport(String csvString) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/expense_report.csv';
    final file = File(path);

    await file.writeAsString(csvString);

    Share.shareFiles([path], text: 'Your Expense Report');
  }

  /*
  Future<String> _saveFile(String csvString) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/expenses.csv';
    final file = File(filePath);
    await file.writeAsString(csvString);
    return filePath;
  } */

  Future<List<Map<String, dynamic>>> fetchExpenseData() async {
    List<Map<String, dynamic>> expenses = [];
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('receipts')
        .get();

    for (var doc in snapshot.docs) {
      expenses.add(doc.data() as Map<String, dynamic>);
    }

    return expenses;
  }

  //get the receipt data from the current user
  Future<void> _fetchAndProcessData() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('receipts')
        .get()
        .then((querySnapshot) {
      Map<String, double> localCategoryAmounts = {};
      for (var doc in querySnapshot.docs) {
        String category = doc['category'];
        double _totalExpenditure = 0;
        double totalPrice = (doc['totalPrice'] is num)
            ? (doc['totalPrice'] as num).toDouble()
            : 0;
        localCategoryAmounts[category] =
            (localCategoryAmounts[category] ?? 0) + totalPrice;
      }

      // Sort localCategoryAmounts by value in descending order
      var sortedEntries = localCategoryAmounts.entries.toList()
        ..sort(
            (a, b) => b.value.compareTo(a.value)); // Sort in descending order

      // Limit to top 3 categories
      var topEntries = sortedEntries.take(3).toList();

      Map<String, double> sortedAndLimitedCategoryAmounts = {
        for (var entry in topEntries) entry.key: entry.value
      };

      double tempMaxYValue = sortedAndLimitedCategoryAmounts.isNotEmpty
          ? sortedAndLimitedCategoryAmounts.values.first * 1.25
          : 0;

      setState(() {
        _barChartGroupData.clear();
        categories.clear();
        categories.addAll(sortedAndLimitedCategoryAmounts.keys);
        maxYValue = tempMaxYValue;
        _generateBarChartData(sortedAndLimitedCategoryAmounts);
      });
    });
  }

  //Takes a map of the category amounts
  //Change that data into a suitable format using fl_chart
  void _generateBarChartData(Map<String, double> categoryAmounts) {
    List<BarChartGroupData> tempBarChartGroupData = [];
    int barGroupIndex = 0;

    categoryAmounts.forEach((category, amount) {
      final barGroup = BarChartGroupData(
        x: barGroupIndex++,
        barRods: [BarChartRodData(toY: amount, color: Colors.white)],
        showingTooltipIndicators: [0],
      );
      tempBarChartGroupData.add(barGroup);
    });

    _barChartGroupData = tempBarChartGroupData;
  }

  //Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text("Receipt Statistics",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20))),
        // Updated title
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Color(0xFF457D58)],
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'Sign Out') {
                // Show confirmation dialog
                final bool confirmSignOut = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color(0xFF457D58),
                          title: Text(
                            'Sign Out',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to sign out?',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                'Sign Out',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ) ??
                    false; // In case the dialog is dismissed

                // If the user confirmed, sign out and navigate
                if (confirmSignOut) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Sign Out',
                child: Text('Sign Out'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                  ),
                  // Adjust the padding if needed
                  child: Center(
                    child: Text(
                      'Total Expenditure per Category (RM)',
                      // The title for your chart
                      style: TextStyle(
                        fontSize: 18, // Adjust the font size if needed
                        fontWeight: FontWeight.bold,
                        color:
                            Colors.blueGrey[800], // Adjust the color if needed
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40), // You can adjust this space
                AspectRatio(
                  aspectRatio: 1.7,
                  child: Card(
                    color: const Color(0xFF457D58),
                    child: BarChart(
                      BarChartData(
                        maxY: maxYValue,
                        barGroups: _barChartGroupData,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final String title = categories[value.toInt()];
                                return SideTitleWidget(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 15,
                                    ),
                                  ),
                                  axisSide: meta.axisSide,
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        //maxY: categoryCounts.values.reduce(max).toDouble() * 3, //limits the height of the bar
                        //maxY: maxYValue,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final expenses = await fetchExpenseData();
                      final csvString = await generateCsvFromExpenses(expenses);
                      await _downloadExpenseReport(csvString);
                    },
                    icon: Icon(Icons.download, color: Colors.white),
                    label: Text('Download Expense Report',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF457D58), Colors.black],
            //Color(0xFFE8F5ED), the light green one
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // Set background to transparent
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.dashboard, color: Colors.white),
                //add something that wont do anything if u already on this page
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              label: '',
            ),
            //BottomNavigationBarItem(
            //icon: Icon(Icons.add_a_photo, size: 50, color: Colors.white),
            //label: '', // Empty label
            //),
            BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.account_circle, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfile()),
                  );
                },
              ),
              label: '', // Empty label
            ),
          ],
          //currentIndex: _selectedIndex,
          onTap: (index) {
            // Handle navigation
          },
        ),
      ),
    );
  }
}
