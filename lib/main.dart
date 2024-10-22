import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happy_deals_pro/firebase_options.dart';
import 'package:happy_deals_pro/providers/auth_provider.dart';
import 'package:happy_deals_pro/providers/company_provider.dart';
import 'package:happy_deals_pro/providers/conversation_provider.dart';
import 'package:happy_deals_pro/screens/auth/login_or_register.dart';
import 'package:happy_deals_pro/screens/home_page.dart';
import 'package:happy_deals_pro/widgets/forms/form_company.dart';
import 'package:happy_deals_pro/widgets/ticket_service.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/timeago.dart' as timeago_fr;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  timeago.setLocaleMessages('fr', timeago_fr.FrMessages());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthsProvider()),
        ChangeNotifierProvider(create: (_) => TicketService()),
        ChangeNotifierProvider(create: (_) => CompanyProvider()),
        ChangeNotifierProvider(create: (_) => ConversationService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Happy Deals Pro',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthsProvider>(
      builder: (context, authProvider, _) {
        switch (authProvider.status) {
          case AuthStatus.authenticated:
            return const DashboardScreen();
          case AuthStatus.unauthenticated:
            return const LoginOrRegisterPage();
          case AuthStatus.newUser:
            return const CompanyFormPage(isNewUser: true);
          case AuthStatus.unknown:
          default:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
        }
      },
    );
  }
}
