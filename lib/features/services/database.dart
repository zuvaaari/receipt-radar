import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  // Collection reference for user data
  final CollectionReference userData =
      FirebaseFirestore.instance.collection('users');

  // Collection reference for receipts
  CollectionReference getReceiptsCollection() {
    return userData.doc(uid).collection('receipts');
  }

  // Collection reference for reminders
  CollectionReference getRemindersCollection() {
    return userData.doc(uid).collection('reminders');
  }

  Future updateUserdata(String userName, String email) async {
    return await userData.doc(uid).set({
      'name': userName,
      // Preserving the email update functionality, if necessary
      'email': email,
    });
  }

  Future<String> uploadReceiptImage(File imageFile) async {
    try {
      String receiptId = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(uid)
          .child('receipts')
          .child('$uid-receipt_$receiptId.jpg');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading receipt image: $e');
      return '';
    }
  }

  Future<void> updateReceiptData({
    required String merchant,
    required String category,
    required String date,
    required String totalPriceString,
    required String paymentMethod,
    required String receiptId,
    required File receiptImage,
  }) async {
    double totalPrice = double.tryParse(totalPriceString) ?? 0.0;

    String receiptImageUrl = await uploadReceiptImage(receiptImage);
    await getReceiptsCollection().doc(receiptId).set({
      'merchant': merchant,
      'category': category,
      'date': date,
      'totalPrice': totalPrice, // Save as a number
      'paymentMethod': paymentMethod,
      'receiptId': receiptId,
      'receiptImageUrl': receiptImageUrl,
      //'items': items, // Save items along with other receipt details
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Method to save reminder data to Firestore
  Future<void> saveReminderData(String reminderFrequency) async {
    try {
      await getRemindersCollection().doc('reminderSettings').set({
        'frequency': reminderFrequency,
        'status': reminderFrequency == 'off' ? 'Disabled' : 'Enabled',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving reminder data: $e');
    }
  }

  // Method to retrieve reminder data
  Future<Map<String, dynamic>?> getReminderData() async {
    try {
      DocumentSnapshot documentSnapshot =
          await getRemindersCollection().doc('reminderSettings').get();
      if (documentSnapshot.exists) {
        return documentSnapshot.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error retrieving reminder data: $e');
      return null;
    }
  }

  //Fetch expense
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

  //Method for expense related stuff.
  Future<Map<String, int>> getExpenseCategoryFrequencies() async {
    Map<String, int> categoryFrequencies = {};

    try {
      QuerySnapshot querySnapshot = await getReceiptsCollection().get();
      for (var doc in querySnapshot.docs) {
        String category = doc.get('category') ?? 'Uncategorized';
        categoryFrequencies[category] =
            (categoryFrequencies[category] ?? 0) + 1;
      }
    } catch (e) {
      print('Error fetching category frequencies: $e');
    }

    return categoryFrequencies;
  }
}
