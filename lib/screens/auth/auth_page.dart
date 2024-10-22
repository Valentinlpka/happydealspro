import 'package:flutter/material.dart';
import 'package:happy_deals_pro/providers/auth_provider.dart';
import 'package:happy_deals_pro/screens/auth/login_or_register.dart';
import 'package:happy_deals_pro/screens/home_page.dart';
import 'package:happy_deals_pro/widgets/forms/form_company.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthsProvider>(
      builder: (context, authProvider, _) {
        switch (authProvider.status) {
          case AuthStatus.authenticated:
            return const DashboardScreen();
          case AuthStatus.newUser:
            return const CompanyFormPage(
              isNewUser: true,
            );
          case AuthStatus.unauthenticated:
            return const LoginOrRegisterPage();
          case AuthStatus.unknown:
          default:
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
