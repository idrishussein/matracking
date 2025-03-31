import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

// Background message handler (required for notifications when app is terminated)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🚏 Background Notification: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set background notification handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MatrackingApp());
}

class MatrackingApp extends StatefulWidget {
  @override
  _MatrackingAppState createState() => _MatrackingAppState();
}

class _MatrackingAppState extends State<MatrackingApp> {
  String? selectedBusId; // Set when driver selects a bus
  DatabaseReference? busStatusRef;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _setupFCM();
    if (selectedBusId != null) {
      _startTracking();
    }
  }

  // Request notification permissions from user
  void _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ User granted notification permission");
    } else {
      print("❌ User denied notification permission");
    }
  }

  // Setup Firebase Cloud Messaging listeners
  void _setupFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🚏 Foreground Notification: ${message.notification?.title}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 Notification clicked! Data: ${message.data}");
    });
  }

  void _startTracking() async {
    bool hasPermission = await LocationService.checkPermission();
    if (hasPermission && selectedBusId != null) {
      LocationService.startLocationTracking(selectedBusId!);
    } else {
      print("❌ Location permission denied or no bus selected.");
    }
  }

  void _listenForBusStatus(String sacco, String bus) {
    busStatusRef = FirebaseDatabase.instance.ref("buses/$sacco/$bus/status");

    busStatusRef!.onValue.listen((event) {
      String? status = event.snapshot.value as String?;
      if (status == "Arrived") {
        NotificationService.showNotification("Bus Arrived 🚏", "Your bus is at the CBD. Be ready to board!");
      } else if (status == "Departed") {
        NotificationService.showNotification("Bus Departed 🚌", "Your bus has left CBD. Safe journey!");
      }
    });
  }

  @override
  void dispose() {
    busStatusRef?.onDisconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matracking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: SplashScreen(),
    );
  }
}
