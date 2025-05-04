import 'package:aide_client/providers/chat_provider.dart';
import 'package:aide_client/providers/login_provider.dart';
import 'package:aide_client/providers/navigation_provider.dart';
import 'package:aide_client/providers/user_sidebar_provider.dart';
import 'package:aide_client/utils/token_checker.dart';
import 'package:aide_client/views/pages/login_page.dart';
import 'package:aide_client/views/pages/admin_wrapper.dart';
import 'package:aide_client/views/pages/user_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );


  bool expired = await isAccessTokenExpired();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? role = prefs.getString('role');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => UserSidebarProvider()),
        ChangeNotifierProvider(create: (_) => UserChatProvider()),

      ],
      child: MyApp(
        child: expired
            ? const LoginPage()
            : role == 'admin'? const AdminWrapperPage(): const UserWrapper(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: child,
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorSchemeSeed: Colors.deepOrange,
      ),
    );
  }
}
