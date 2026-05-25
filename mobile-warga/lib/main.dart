import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
// TODO: Uncomment import di bawah saat Firebase sudah dikonfigurasi
// import 'package:firebase_core/firebase_core.dart';

import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/pickup_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/pickup_request_screen.dart';
import 'screens/history_screen.dart';
import 'screens/notification_screen.dart';

/// ============================================================
/// main.dart — Entry Point Aplikasi Bank Sampah Digital
/// ============================================================
///
/// CATATAN PENTING:
/// 1. Firebase HARUS diinisialisasi sebelum runApp().
///    Pastikan file konfigurasi sudah ada:
///    - Android: android/app/google-services.json
///    - iOS: ios/Runner/GoogleService-Info.plist
///
/// 2. Jika menggunakan FlutterFire CLI, jalankan:
///    ```
///    dart pub global activate flutterfire_cli
///    flutterfire configure
///    ```
///    Ini akan otomatis generate file firebase_options.dart.
///
/// 3. Jika belum setup Firebase, COMMENT OUT baris
///    `await Firebase.initializeApp()` agar app tetap bisa jalan
///    (fitur Firestore tidak akan berfungsi).

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ----------------------------------------------------------
  // INISIALISASI FIREBASE
  // ----------------------------------------------------------
  // TODO: Uncomment baris di bawah setelah konfigurasi Firebase selesai.
  //
  // Opsi 1: Tanpa FlutterFire CLI (manual google-services.json)
  // await Firebase.initializeApp();
  //
  // Opsi 2: Dengan FlutterFire CLI (recommended)
  // import 'firebase_options.dart';
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // ----------------------------------------------------------

  runApp(const BankSampahApp());
}

class BankSampahApp extends StatelessWidget {
  const BankSampahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => PickupProvider()),
      ],
      child: MaterialApp(
        title: 'Bank Sampah Digital',
        debugShowCheckedModeBanner: false,

        // ============================================
        // TEMA MATERIAL DESIGN 3
        // ============================================
        // Menggunakan warna hijau sebagai primary (tema
        // "lingkungan" / "daur ulang"). Bisa disesuaikan.
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32), // Green 800
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        // ============================================
        // DARK THEME (opsional)
        // ============================================
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF66BB6A), // Green 400
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        // ============================================
        // ROUTING
        // ============================================
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/pickup-request': (context) => const PickupRequestScreen(),
          '/history': (context) => const HistoryScreen(),
          '/notifications_screen': (context) => const NotificationScreen(),
        },
      ),
    );
  }
}
