import 'package:flutter/material.dart';
import 'package:happy_deals_pro/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class Login extends StatefulWidget {
  final Function()? onTap;
  const Login({
    super.key,
    this.onTap,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _passwordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

// Fonction pour se connecteur a firebase

  void signUserIn() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    try {
      await Provider.of<AuthsProvider>(context, listen: false).signIn(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pop();
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: const Text(
            'Connexion réussi !',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          alignment: Alignment.topRight,
          animationDuration: const Duration(milliseconds: 200),
          icon: const Icon(Icons.check),
          primaryColor: Colors.green,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
          closeButtonShowType: CloseButtonShowType.onHover,
          closeOnClick: false,
          pauseOnHover: true,
          dragToClose: true,
          applyBlurEffect: false,
        );
        // Ferme le dialogue de chargement
        // Affichez un message de succès si nécessaire
      }
    } catch (e) {
      Navigator.of(context).pop();
      // Ferme le dialogue de chargement

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Center(child: Image.asset(height: 80, 'assets/images/logo.png')),
            const SizedBox(
              height: 50,
            ),
            Column(
              children: [
                AutofillGroup(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 70,
                        child: Text(
                          'Connexion',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 500,
                        height: 70,
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(5),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              prefixIcon: const Icon(Icons.alternate_email),
                              hintText: "E-mail"),
                        ),
                      ),
                      SizedBox(
                        width: 500,
                        height: 50,
                        child: TextField(
                          onSubmitted: (_) => signUserIn(),
                          controller: _passwordController,
                          autofillHints: const [AutofillHints.password],
                          obscureText: !_passwordVisible,
                          enableSuggestions: true,
                          autocorrect: false,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(5),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              hintText: "Mot de passe"),
                        ),
                      ),
                      SizedBox(
                        height: 240,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(
                                top: 15,
                                bottom: 15,
                              ),
                              child: Text(
                                'Mot de passe oublié ?',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 55,
                                    width: 350,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[700],
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                      onPressed: signUserIn,
                                      child: const Text(
                                        'Connexion',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 0.3,
                                        width: 100,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.black),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Text('OU'),
                                      ),
                                      SizedBox(
                                        height: 0.3,
                                        width: 100,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.black),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                    " Vous n'avez pas encore de compte ? "),
                                GestureDetector(
                                  onTap: widget.onTap,
                                  child: Text(
                                    "Je m'inscris",
                                    style: TextStyle(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
