import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../authentication/login.dart';

class ReceiptDetails extends StatefulWidget {
  final String receiptId;

  const ReceiptDetails({Key? key, required this.receiptId}) : super(key: key);

  @override
  _ReceiptDetailsState createState() => _ReceiptDetailsState();
}

class _ReceiptDetailsState extends State<ReceiptDetails> {
  List<String> _categories = [
    '🥗 Food',
    '🛒 Groceries',
    '🏥 Health',
    '💄 Makeup',
    '🧴 Bath and Body',
    '🍶 Skincare',
    '👗 Clothes',
    '🧼 Cleaning',
    '🔪 Kitchen Supplies',
    '🎲 Entertainment',
    '💸 Subscriptions',
    '🎁 Gifts',
    '📱 Electronics',
    '⚙️ Gadgets',
    'Other' //More possible categories?
  ];
  late TextEditingController _merchantController;
  late TextEditingController _categoryController;
  late TextEditingController _dateController;
  late TextEditingController _totalPriceController;
  late TextEditingController _paymentMethodController;
  late TextEditingController _notesController;
  String _selectedCategory = '🥘 Food';
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController();
    _categoryController = TextEditingController();
    _dateController = TextEditingController();
    _totalPriceController = TextEditingController();
    _paymentMethodController = TextEditingController();
    _notesController = TextEditingController();
    _loadReceiptDetails();
  }

  //To retrieve the receipt data from firebase and the info is used to display receipt details.
  Future<void> _loadReceiptDetails() async {
    try {
      //The receipt info to be retrieved based on user id.
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      DocumentSnapshot receiptSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('receipts')
          .doc(widget.receiptId)
          .get();

      if (receiptSnapshot.exists) {
        Map<String, dynamic> receiptData =
            receiptSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _selectedCategory = receiptData['category'] ?? _categories.first;
          if (!_categories.contains(_selectedCategory)) {
            _categories.add(_selectedCategory);
          }

          // Initialize text controllers with the receipt data.
          _merchantController.text = receiptData['merchant'] ?? '';
          _categoryController.text =
              _selectedCategory; // Use the category from the receipt.
          _dateController.text = receiptData['date'] ?? '';
          _totalPriceController.text = receiptData['totalPrice'] != null
              ? receiptData['totalPrice'].toStringAsFixed(2)
              : '';
          _paymentMethodController.text = receiptData['paymentMethod'] ?? '';
          _notesController.text = receiptData['notes'] ?? '';
        });
      } else {}
    } catch (e) {}
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    _totalPriceController.dispose();
    _paymentMethodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  //Updates specific receipts
  Future<void> _updateReceiptDetails() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    Map<String, dynamic> updateData = {};

    // Check each field to make sure it's not empty before updating
    if (_merchantController.text.isNotEmpty) {
      updateData['merchant'] = _merchantController.text;
    }
    if (_categoryController.text.isNotEmpty) {
      updateData['category'] = _categoryController.text;
    }
    if (_dateController.text.isNotEmpty) {
      updateData['date'] = _dateController.text;
    }
    if (_totalPriceController.text.isNotEmpty) {
      // Convert to a number before updating
      double? totalPrice = double.tryParse(_totalPriceController.text);
      if (totalPrice != null) {
        updateData['totalPrice'] = totalPrice;
      }
    }
    if (_paymentMethodController.text.isNotEmpty) {
      updateData['paymentMethod'] = _paymentMethodController.text;
    }
    if (_notesController.text.isNotEmpty) {
      updateData['notes'] = _notesController.text;
    }

    // Only update if there's something to update
    if (updateData.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('receipts')
          .doc(widget.receiptId)
          .update(updateData);
    }
  //Once updated, change the state of UI to exit the edit mode
    setState(() {
      _isEditMode = false;
    });
  }

  //Display the image of the receipt.
  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.network(imageUrl, fit: BoxFit.contain),
      ),
    );
  }

  //handles the deletion of receipt.
  Future<void> _deleteReceipt() async {
    // Confirm deletion with the user before proceeding
    bool confirmDelete = await _confirmDeletionDialog();
    if (!confirmDelete) return;

    // Get the user's UID
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Delete the Firestore document
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('receipts')
        .doc(widget.receiptId)
        .delete();

    // Pop the current screen or show a snackbar if you prefer to stay on the page
    Navigator.pop(context);
  }

  Future<bool> _confirmDeletionDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color(0xFF457D58),
            title: Text(
              'Confirm Deletion',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            content: Text(
              'Are you sure you want to delete this receipt?',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.white54,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text(
                  'Delete',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.redAccent,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false; // If the user cancels, return false
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('', style: TextStyle(color: Colors.white)),
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('receipts')
            .doc(widget.receiptId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Receipt not found.'));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var receiptData =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};
          String receiptImageUrl = receiptData['receiptImageUrl'] ?? '';

          // Initialize text controllers if they haven't been initialized yet
          if (_merchantController.text.isEmpty) {
            _merchantController.text = receiptData['merchant'] ?? '';
            _categoryController.text = receiptData['category'] ?? '';
            _dateController.text = receiptData['date'] ?? '';
            // Ensure to display the number in text format
            _totalPriceController.text = (receiptData['totalPrice'] is num)
                ? (receiptData['totalPrice'] as num).toStringAsFixed(2)
                : '';
            _paymentMethodController.text = receiptData['paymentMethod'] ?? '';
            _notesController.text = receiptData['notes'] ?? '';
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Receipt Details',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black950),
                  ),
                ),
                //SizedBox(height: 0),
                if (receiptImageUrl.isNotEmpty)
                  GestureDetector(
                    onLongPress: () => _showFullImage(receiptImageUrl),
                    child: Container(
                      margin: EdgeInsets.only(top: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white, // Adjust the color as needed
                        border: Border.all(
                          color: Colors.grey.shade300,
                          // Adjust the border color as needed
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black950.withOpacity(0.7),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(
                            4.0), // Adjust the border radius as needed
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        // Match the Container's borderRadius
                        child: Image.network(
                          receiptImageUrl,
                          width: double.infinity,
                          height: 200, // Adjust the height maybe
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                if (receiptImageUrl.isEmpty)
                  Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 100),
                  ),
                Center(
                  //for the receipt id
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black26,
                          fontFamily: 'Eczar',
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Receipt ID: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          TextSpan(
                            text: widget.receiptId,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _isEditMode
                    ? _buildEditableDetails()
                    : _buildDetails(receiptData),
                SizedBox(height: 10),
                if (!_isEditMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditMode = true;
                          });
                        },
                        icon: Icon(Icons.edit, color: Colors.black38),
                        // Specify the icon
                        label: Text(
                          'Edit Receipt',
                          style: TextStyle(
                              color: Colors.black38,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _deleteReceipt,
                        icon: Icon(Icons.delete, color: Colors.white),
                        // Specify the icon
                        label: Text(
                          'Delete',
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red[700], // Use a specific shade of red
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  //Widget to display the details of the receipt inside a container
  Widget _buildDetails(Map<String, dynamic> receiptData) {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(0xFF457D58).withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 1.0),
            child: Center(
              child: Text(
                'RM ${receiptData['totalPrice'] ?? 'Unknown'}',
                style: TextStyle(
                  fontFamily: 'Eczar',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Divider(color: Colors.white70),
          _detailText('Merchant', receiptData['merchant'] ?? 'Unknown'),
          _detailText('Date', receiptData['date'] ?? 'Unknown'),
          _detailText('Category', receiptData['category'] ?? 'Unknown'),
          _detailText(
              'Payment Method', receiptData['paymentMethod'] ?? 'Unknown'),
          _detailText('Notes', receiptData['notes'] ?? 'Unknown'),
        ],
      ),
    );
  }

  //Create a widget which displays some receipt detail with title and a value
  Widget _detailText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
              fontFamily: 'Eczar',
              fontSize: 17,
              color: Colors.white), // Default text style
          children: <TextSpan>[
            TextSpan(
                text: '$title: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
                text: value,
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  //Widget for edit mode
  Widget _buildEditableDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _editableDetailItem('Merchant', _merchantController),
        _editableDetailItem('Date', _dateController),
        _editableDetailItem('Total', _totalPriceController),
        _categoryDropdown(),
        _editableDetailItem('Payment Method', _paymentMethodController),
        _editableDetailItem('Notes', _notesController),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: Icon(
                Icons.cancel,
                color: Colors.white,
              ),
              label: Text('Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  )),
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            ),
            ElevatedButton.icon(
              icon: Icon(
                Icons.save,
                color: Colors.white,
              ),
              label: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onPressed: _updateReceiptDetails,
              style: ElevatedButton.styleFrom(primary: Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  //Function that allow user to select category from dropdown menu
  Widget _categoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(labelText: 'Category'),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue!;
          if (_selectedCategory == 'Other') { //if other is selected, trigger dialog
            _addCustomCategory();
          } else {
            _categoryController.text = _selectedCategory;
          }
        });
      },
      items: _categories.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  //Function to add a custom category
  Future<void> _addCustomCategory() async {
    final TextEditingController _customCategoryController =
        TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create your Category'),
          content: TextFormField(
            controller: _customCategoryController,
            decoration: InputDecoration(hintText: 'Eg. Pets, Hobbies, Travel'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                if (_customCategoryController.text.isNotEmpty) {
                  setState(() {
                    _categoryController.text = _customCategoryController.text;
                    Navigator.of(context).pop();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  //For the edit mode
  //Create editable textfields for the different things in the receipt
  Widget _editableDetailItem(String label, TextEditingController controller,
      {String prefixText = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
        ),
        keyboardType: (label == 'Total Price')
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: (label == 'Total Price')
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
            : [],
      ),
    );
  }
}
