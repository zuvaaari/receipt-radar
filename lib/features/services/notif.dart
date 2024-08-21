import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'database.dart';

class NotificationManager {
  final String uid;

  NotificationManager({required this.uid}) {
    _initializeNotifications();
  }

  //initilaize
  void _initializeNotifications() {
    AwesomeNotifications().initialize(
      'resource://drawable/ic_notification',
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          //scheduled_channel
          channelName: 'Scheduled Notifications',
          channelDescription:
              'Notifications scheduled based on user preferences',
          defaultColor: Color(0xFF457D58),
          //green
          ledColor: Colors.black950, //black
        ),
      ],
    );
  }

  // Configure periodic notifications per the frequency
  Future<void> scheduleNotification(String frequency) async {
    // Determine the interval based on the frequency
    int interval;
    switch (frequency) {
      case 'Daily':
        interval = 60; //for testing set it at 60 //usual one is 24 * 60
        break;
      case 'weekly':
        interval = 24 * 7 * 60;
        break;
      case 'monthly':
        interval = 24 * 30 * 60;
        break;
      default:
        interval = 24 * 60;
    }

    // Schedule the notification
    String timezone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel', //scheduled_channel
        title: '📈 Begin Tracking your Receipts! 💵',
        body:
            'This is your $frequency reminder to add new receipts! 🧾', //$frequency
      ),
      schedule: NotificationInterval(
        interval: interval,
        timeZone: timezone,
        repeats: true, //change to true for testing
      ),
    );
  }

  //Show notification.. Not working as intended?
  Future<void> showNotificationSnackbar(
      BuildContext context, String frequency) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification set for $frequency')),
    );
    // Send the first notification immediately after setting the snackbar. This isnt working? But keep it
    await _showNotification('Notifications Enabled',
        'You will now receive $frequency notifications for Receipt Radar!');

    // Schedule future notifications based on the frequency.
    await scheduleNotification(frequency);

    // Update Firestore with the user's reminder preference.
    DatabaseService(uid: uid).saveReminderData(frequency);
  }


  Future<void> _showNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0, // Unique ID for this notification
        channelKey: 'scheduled_channel',
        title: title,
        body: body,
      ),
    );
  }

  //Cancel notifications when users clicks Cancel Reminders
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
    // Update Firestore to show that the user has turned off reminders
    DatabaseService(uid: uid).saveReminderData('off');
  }
}
