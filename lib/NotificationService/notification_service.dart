import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class NotificationService {
  static Timer? _recurringTimer;
  static int _notificationCounter = 0;

  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'armory_channel',
          channelName: 'Armory Notifications',
          channelDescription: 'Notification channel for Armory Pro',
          defaultColor: Color(0xFFE74C3C),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'promo_channel',
          channelName: 'Promotional Notifications',
          channelDescription: 'Channel for promotional offers',
          defaultColor: Color(0xFF2ECC71),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Start recurring notifications every 3 minutes
    startRecurringNotifications();
  }

  // Start recurring notifications every 3 minutes
  static void startRecurringNotifications() {
    // Cancel any existing timer
    _recurringTimer?.cancel();

    // Create a timer that fires every 3 minutes (180 seconds)
    _recurringTimer = Timer.periodic(Duration(minutes: 2), (timer) async {
      _notificationCounter++;

      // Rotate between different notification messages
      final messages = [
        {
          'title': 'Armory Pro Alert 🎯',
          'body': 'Check out our latest ammunition deals!',
        },
        {
          'title': 'New Arrivals! 🆕',
          'body': 'Fresh stock just added to our inventory',
        },
        {
          'title': 'Special Offer 🔥',
          'body': 'Limited time discounts on selected items',
        },
        {
          'title': 'Armory Update 📦',
          'body': 'Explore our wide range of products',
        },
      ];

      final message = messages[_notificationCounter % messages.length];

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'armory_channel',
          title: message['title']!,
          body: message['body']!,
          notificationLayout: NotificationLayout.Default,
          color: Color(0xFFE74C3C),
          badge: _notificationCounter,
        ),
      );

      print("🔔 Recurring notification sent (Count: $_notificationCounter)");
    });

    print("✅ Recurring notifications started - will fire every 3 minutes");
  }

  // Stop recurring notifications
  static void stopRecurringNotifications() {
    _recurringTimer?.cancel();
    _recurringTimer = null;
    print("🛑 Recurring notifications stopped");
  }

  static Future<void> showWelcomeNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'armory_channel',
        title: 'Welcome to Armory Pro! 🎯',
        body: 'Explore our wide range of ammunition and weapons',
        notificationLayout: NotificationLayout.Default,
        color: Color(0xFFE74C3C),
      ),
    );
  }

  static Future<void> showNewProductNotification(String productName) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'armory_channel',
        title: 'New Product Available! 🎉',
        body: '$productName just added to our inventory',
        notificationLayout: NotificationLayout.Default,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  static Future<void> showPromoNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'promo_channel',
        title: 'Special Offer! 🔥',
        body: 'Get 20% off on selected ammunition. Limited time only!',
        notificationLayout: NotificationLayout.Default,
        color: Color(0xFF2ECC71),
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'view_offer',
          label: 'View Offer',
          color: Color(0xFF2ECC71),
          actionType: ActionType.SilentAction,
        ),
      ],
    );
  }

  static Future<void> showStockAlertNotification(String productName, int stock) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'armory_channel',
        title: 'Low Stock Alert! ⚠️',
        body: '$productName - Only $stock items left in stock',
        notificationLayout: NotificationLayout.Default,
        color: Color(0xFFF39C12),
      ),
    );
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required int seconds,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'armory_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        color: Color(0xFFE74C3C),
      ),
      schedule: NotificationInterval(
        interval: Duration(seconds: 60),
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
        repeats: false,
      ),
    );
  }

  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // Dispose method to clean up timer
  static void dispose() {
    _recurringTimer?.cancel();
  }
}