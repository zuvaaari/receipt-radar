/*
* receipt details page the editable stuff
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReceiptDetails extends StatefulWidget {
  final String receiptId;

  const ReceiptDetails({Key? key, required this.receiptId}) : super(key: key);

  @override
  _ReceiptDetailsState createState() => _ReceiptDetailsState();
}

class _ReceiptDetailsState extends State<ReceiptDetails> {
  late TextEditingController _merchantController;
  late TextEditingController _categoryController;
  late TextEditingController _dateController;
  late TextEditingController _totalPriceController;
  late TextEditingController _paymentMethodController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController();
    _categoryController = TextEditingController();
    _dateController = TextEditingController();
    _totalPriceController = TextEditingController();
    _paymentMethodController = TextEditingController();
    _notesController = TextEditingController();
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

  Future<void> _updateReceiptDetails() async {
    // Get the user's UID
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Update the Firestore document
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('receipts')
        .doc(widget.receiptId)
        .update({
      'merchant': _merchantController.text,
      'category': _categoryController.text,
      'date': _dateController.text,
      'totalPrice': _totalPriceController.text,
      'paymentMethod': _paymentMethodController.text,
      'notes': _notesController.text,
    });
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Receipt Details'),
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
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {},
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
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Receipt not found.'));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var receiptData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          _merchantController.text = receiptData['merchant'] ?? '';
          _categoryController.text = receiptData['category'] ?? '';
          _dateController.text = receiptData['date'] ?? '';
          _totalPriceController.text = receiptData['totalPrice'] ?? '';
          _paymentMethodController.text = receiptData['paymentMethod'] ?? '';
          _notesController.text = receiptData['notes'] ?? '';

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _showFullImage(receiptData['receiptImageUrl'] ?? ''),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(receiptData['receiptImageUrl'] ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Divider(),
                _editableDetailItem('Merchant', _merchantController),
                _editableDetailItem('Date', _dateController),
                _editableDetailItem('Total', _totalPriceController),
                _editableDetailItem('Category', _categoryController),
                _editableDetailItem('Payment Method', _paymentMethodController),
                _editableDetailItem('Notes', _notesController),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.save, color: Colors.white,),
                      label: Text('Save',
                          style: TextStyle(color: Colors.white)),
                      onPressed: _updateReceiptDetails,
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.delete, color: Colors.white,),
                      label: Text('Delete',
                        style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        // Implement delete functionality
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.red),
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

  Widget _editableDetailItem(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

*
* */