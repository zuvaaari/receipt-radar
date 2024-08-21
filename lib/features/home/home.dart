import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:receipt_radar_1/features/services/database.dart';
import 'package:receipt_radar_1/features/user/user_profile.dart';
import '../authentication/login.dart';
import '../receipt/receipt_details.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchReceipt = ''; // Stores the search information
  final TextEditingController _searchController =
      TextEditingController(); //Input for text and listens for and controls the text
  final FirebaseAuth _auth = FirebaseAuth.instance; //Auth purposes
  int _selectedIndex = 0; //Related to bottom nav bar
  late File _scannedReceipt; //Initzld later. Contains receipt image
  //For the 'Welcome USER'
  DatabaseService _databaseService =
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid);
  String dropdownValue = 'Sign Out'; //Dropdown menu

  //Search bar
  void _performSearch(String search) {
    setState(() {
      _searchReceipt = search;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //Get username from firebase
  Future<String> _fetchUserName() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      String userName = userDocument.data()?['name'] ?? 'User';
      return userName;
    }
    return 'User';
  }

  //Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //Remove the back button
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
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

                // If the user confirms, sign out and navigate
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FutureBuilder<String>(
                future: _fetchUserName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return Text(
                      'Welcome ${snapshot.data}!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else {
                    return Text(
                      'Welcome User!',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 1),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextField(
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black, // Text color inside the search bar
                  fontWeight: FontWeight.w600,
                ),
                controller: _searchController,
                decoration: InputDecoration(
                  //labelText: 'Search',
                  labelStyle: TextStyle(color: Colors.black),
                  hintText: 'Search by Merchant or Category',
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.green[950]),
                          //red is too much?
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _searchController.clear());
                            _performSearch('');
                          },
                        )
                      : IconButton(
                          icon: Icon(Icons.search, color: Colors.black),
                          // Search icon color
                          onPressed: () {
                            _performSearch(_searchController.text.trim());
                          },
                        ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    // Border color when it is not in focus
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    // Border color when it is in focus
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    // Border color by default
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                cursorColor: Colors.black,
                // Cursor color
                onChanged: (value) {
                  if (value.isEmpty) {
                    _performSearch('');
                  }
                },
                onSubmitted: (value) {
                  _performSearch(value.trim());
                },
              ),
            ),

            SizedBox(height: 10),

            //Listen to a stream of data and rebuild its widget when new data is emitted
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(_auth.currentUser?.uid)
                  .collection('receipts')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child:
                          Text('You currently do not have any receipts saved'));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;
                if (_searchReceipt.isNotEmpty) {
                  docs = docs.where((DocumentSnapshot doc) {
                    var merchant = doc.get('merchant').toString().toLowerCase();
                    var category = doc.get('category').toString().toLowerCase();
                    return merchant.contains(_searchReceipt.toLowerCase()) ||
                        category.contains(_searchReceipt.toLowerCase());
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(child: Text('No matching receipts.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  physics: const ClampingScrollPhysics(),
                  //Makes sure it scrolls
                  padding: EdgeInsets.only(bottom: 80.0),
                  //The Floating button does not cover the list
                  itemBuilder: (context, index) {
                    var receipt = docs[index].data() as Map<String,
                        dynamic>; // Access the document data as a map.
                    var receiptId = receipt['receiptId'];
                    var merchant = receipt['merchant'];
                    var category = receipt['category'];
                    var date = receipt['date']; //date
                    var totalPrice =
                        receipt['totalPrice'].toString(); // Convert to String
                    var receiptImageUrl =
                        receipt['receiptImageUrl']; // URL of the receipt image

                    return GestureDetector(
                      //Go to the page of that specific receipt.
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReceiptDetails(receiptId: receiptId),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFE8F5ED),
                              Colors.white
                            ], // Gradient colors
                          ),
                          borderRadius: BorderRadius.circular(
                              10.0), // Optional: rounded corners
                        ),
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100, // width
                              height: 105, //height
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    // Shadow color with opacity
                                    spreadRadius: 1,
                                    // Spread radius?
                                    blurRadius: 5,
                                    // Blur
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10),
                                // Rounded corners
                                border: Border.all(
                                  color: Colors.grey,
                                  // Border color. Black or grey?
                                  width: 1, // Border width
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(receiptImageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // Align text to the start
                                children: [
                                  Text(
                                    merchant,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF457D58),
                                    ),
                                  ),
                                  Text(
                                    date,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'RM $totalPrice',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[950]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(bottom: 0.0), //Not sure what this is doing?
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton.icon(
              //its not perfectly center?!
              onPressed: () {
                _addReceiptFromGallery();
              },
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF457D58),
              ),
              label: Text(
                'Add from Gallery',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              //tooltip: 'Add Transaction',
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF457D58), Colors.black],
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.dashboard,
                    color: _selectedIndex == 0 ? Colors.white : Colors.grey),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.add_a_photo, size: 50, color: Colors.white),
              label: '',
            ),
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
              label: '',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              if (index == 1) {
                _scanReceiptAndSave();
              }
            });
          },
        ),
      ),
    );
  }

  //For the scan with camera. The scanned picture and saved and processed
  Future<void> _scanReceiptAndSave() async {
    final ImagePicker _picker = ImagePicker();
    //Open camera
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      //Widget state is updated.
      setState(() {
        _scannedReceipt = File(image.path);
      });
      _processReceipt(); //Called to extract the info from the pic
    }
  }

  Future<void> _addReceiptFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    //Gallery is opened
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _scannedReceipt = File(image.path);
      });
      _processReceipt();
    }
  }

//Processes the receipts. Uses the MLKit(TextRec) to get the information
  Future<void> _processReceipt() async {
    final textRecognizer = TextRecognizer();
    try {
      final inputImage = InputImage.fromFilePath(_scannedReceipt.path);
      //Process the image to extract the text
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      //Stores the extracted text from the receipt
      final String extractedText = recognizedText.text;

      //For the specific information in the receipt
      final String merchant = _extractMerchant(extractedText);
      final String date = _extractDate(extractedText);
      final String totalPrice = _extractTotalPrice(extractedText);
      final String paymentMethod = _extractPaymentMethod(extractedText);

      //Update database with the information from receipt
      await _databaseService.updateReceiptData(
        merchant: merchant,
        date: date,
        totalPriceString: totalPrice,
        paymentMethod: paymentMethod,
        category: 'Uncategorized',
        receiptId: DateTime.now().millisecondsSinceEpoch.toString(),
        receiptImage: _scannedReceipt,
        //items: items,
      );

      //Snack bar to show the success/fail
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receipt processed and saved successfully.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to process receipt: $e'),
          backgroundColor: Colors.red));
    } finally {
      textRecognizer.close();
    }
  }

  //Has worked all the times so far
  String _extractMerchant(String extractedText) {
    var lines = extractedText.split('\n');
    return lines.isNotEmpty
        ? lines.first.trim().toUpperCase()
        : "UNKNOWN MERCHANT";
  }

  //Price. Not working at all so far.
  String _extractTotalPrice(String extractedText) {
    print("Extracted Text: $extractedText");
    RegExp regExp =
        RegExp(r'Total Amt Payable\s*:\s*RM?\s*(\d{1,3}(?:,\d{3})*\.\d{2})',
            //Look for pattern
            multiLine: true,
            caseSensitive: false);

    var matches = regExp.allMatches(extractedText);
    String totalPriceStr = "Unknown Total Price";

    if (matches.isNotEmpty) {
      // Get the last match which should be the total amount payable
      Match lastMatch = matches.last;
      totalPriceStr = lastMatch.group(1) ?? "Unknown Total Price";
      print("Extracted Total Price: $totalPriceStr");
    } else {
      print("No matching total price found.");
    }
    return totalPriceStr;
  }

//Works most of the times
  String _extractPaymentMethod(String extractedText) {
    //sometimes works?
    // Check for various known payment methods. Might need to add more.
    if (extractedText.contains('GRABPAY')) {
      return 'GRABPAY';
    } else if (extractedText.contains('VISA')) {
      return 'VISA';
    } else if (extractedText.contains('MASTERCARD')) {
      return 'MASTERCARD';
    } else if (extractedText.contains('TOUCH N GO')) {
      return 'TOUCH N GO';
    } else if (extractedText.contains('CASH')) {
      return 'CASH';
    }

    // If no known payment method is found, then this
    return 'Payment Method Unknown';
  }

  //If dateunknow, then take the date of scanning as date
  String _extractDate(String extractedText) {
    RegExp regExp =
        RegExp(r'\b(\d{2}/\d{2}/\d{4})\b'); //2 digits 2 digits 4 digits --year
    var match = regExp.firstMatch(extractedText);
    return match?.group(1)?.trim() ??
        DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  void main() {
    runApp(MaterialApp(
      home: HomePage(),
    ));
  }
}
