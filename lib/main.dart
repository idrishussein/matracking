import 'package:flutter/material.dart';
import 'customer_side/splash_screen.dart';
import 'customer_side/passenger_auth_screen.dart';
import 'drivers_side/driver_dashboard_screen.dart';
import 'package:matracking/services/notification_service.dart' as notify;
import 'package:matracking/services/location_service.dart' as loc;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🚏 Background Notification: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await notify.NotificationService.init();
  runApp(MatrackingApp());
}

class MatrackingApp extends StatefulWidget {
  @override
  _MatrackingAppState createState() => _MatrackingAppState();
}

class _MatrackingAppState extends State<MatrackingApp> {
  String? selectedBusId;
  DatabaseReference? busStatusRef;
  late FirebaseDatabase database;

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase.instance;
    _requestNotificationPermission();
    _setupFCM();
  }

  void _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );
    print(settings.authorizationStatus == AuthorizationStatus.authorized
        ? "✅ Notification permission granted"
        : "❌ Notification permission denied");
  }

  void _setupFCM() {
    FirebaseMessaging.onMessage.listen((message) {
      notify.NotificationService.showNotification(
        message.notification?.title ?? "Notification",
        message.notification?.body ?? "You have a new message.",
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("📲 Notification clicked! Data: ${message.data}");
    });
  }

  void startTracking(String busId) async {
    if (await loc.LocationService.checkPermission()) {
      setState(() => selectedBusId = busId);
      loc.LocationService.startLocationTracking(busId, (Position position) {
        print("Updated position: ${position.latitude}, ${position.longitude}");
        // Update live tracking data separately (tracking remains in buses node)
        database.ref("buses/$busId/location").set({
          "latitude": position.latitude,
          "longitude": position.longitude,
        });
      });
    } else {
      print("❌ Location permission denied.");
    }
  }

  void listenForBusStatus(String sacco, String bus) {
    busStatusRef = database.ref("buses/$sacco/$bus/status");

    busStatusRef!.onValue.listen((event) {
      String? status = event.snapshot.value as String?;
      if (status == "Arrived") {
        notify.NotificationService.showNotification(
          "Bus Arrived 🚏", "Your bus is at the CBD. Be ready to board!"
        );
      } else if (status == "Departed") {
        notify.NotificationService.showNotification(
          "Bus Departed 🚌", "Your bus has left CBD. Safe journey!"
        );
      }
    });
  }

  @override
  void dispose() {
    busStatusRef?.onValue.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matracking',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      home: SplashScreen(),
      routes: {
        '/passengerAuth': (context) => PassengerAuthScreen(),
        '/driverDashboard': (context) => DriverDashboardScreen(),
      },
    );
  }
}