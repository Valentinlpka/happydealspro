import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  final Function()? onTap;
  const Register({
    super.key,
    this.onTap,
  });

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _passwordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Fonction pour inscrire l'utilisateur avec Firebase
  void signUserUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          content: Text('Les mots de passe ne correspondent pas.'),
        ),
      );
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    try {
      await Provider.of<AuthsProvider>(context, listen: false).signUp(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pop(); // Ferme le dialogue de chargement
        // Naviguez vers la page de création d'entreprise ou affichez un message de succès
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'status': 'new',
            'email': user.email,
            'type': 'company',
            // Ajoutez d'autres champs d'utilisateur si nécessaire
          });
        }
      }
    } catch (e) {
      Navigator.of(context).pop(); // Ferme le dialogue de chargement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Image.asset(height: 80, 'assets/images/logo.png'),
              const SizedBox(
                height: 50,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 70,
                    child: Text(
                      'Inscription',
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
                    height: 70,
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      enableSuggestions: false,
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
                    width: 500,
                    height: 70,
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_passwordVisible,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.lock),
                          hintText: "Confirmer le mot de passe"),
                    ),
                  ),
                  SizedBox(
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                                  onPressed: signUserUp,
                                  child: const Text(
                                    'S\'inscrire',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.0),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Vous avez déjà un compte ? "),
                              GestureDetector(
                                onTap: widget.onTap,
                                child: Text(
                                  "Se connecter",
                                  style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
