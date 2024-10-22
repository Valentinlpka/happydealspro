import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoyaltyProgramForm extends StatefulWidget {
  const LoyaltyProgramForm({super.key});

  @override
  _LoyaltyProgramFormState createState() => _LoyaltyProgramFormState();
}

class _LoyaltyProgramFormState extends State<LoyaltyProgramForm> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _programType = 'visits';
  int _targetValue = 0;
  double _rewardValue = 0;
  bool _isPercentage = false;
  final List<Map<String, dynamic>> _tiers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un programme de fidélité')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Type de programme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildProgramTypeRadio(),
              const SizedBox(height: 20),
              if (_programType != 'points') ...[
                _buildTargetValueField(),
                const SizedBox(height: 20),
                _buildRewardField(),
              ],
              if (_programType == 'points') _buildPointTiersSection(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    child: Text('Créer le programme',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramTypeRadio() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Carte de passage'),
          value: 'visits',
          groupValue: _programType,
          onChanged: (value) {
            setState(() {
              _programType = value!;
              _tiers.clear();
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Carte à points'),
          value: 'points',
          groupValue: _programType,
          onChanged: (value) {
            setState(() {
              _programType = value!;
              _tiers.clear();
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Carte à montant'),
          value: 'amount',
          groupValue: _programType,
          onChanged: (value) {
            setState(() {
              _programType = value!;
              _tiers.clear();
            });
          },
        ),
      ],
    );
  }

  Widget _buildTargetValueField() {
    String label = _programType == 'visits'
        ? 'Nombre de passages requis'
        : 'Montant à atteindre (€)';

    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        return null;
      },
      onSaved: (value) {
        _targetValue = int.parse(value!);
      },
    );
  }

  Widget _buildRewardField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Récompense',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Valeur de la récompense',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                },
                onSaved: (value) {
                  _rewardValue = double.parse(value!);
                },
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<bool>(
              value: _isPercentage,
              items: const [
                DropdownMenuItem(value: false, child: Text('€')),
                DropdownMenuItem(value: true, child: Text('%')),
              ],
              onChanged: (value) {
                setState(() {
                  _isPercentage = value!;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPointTiersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Paliers de points',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text(
            'Définissez les paliers de points et leurs récompenses associées'),
        const SizedBox(height: 10),
        ..._tiers.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> tier = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Points', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    initialValue: tier['points'].toString(),
                    onChanged: (value) {
                      setState(() {
                        _tiers[index]['points'] = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Récompense', border: OutlineInputBorder()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                    initialValue: tier['reward'].toString(),
                    onChanged: (value) {
                      setState(() {
                        _tiers[index]['reward'] = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<bool>(
                  value: tier['isPercentage'],
                  items: const [
                    DropdownMenuItem(value: false, child: Text('€')),
                    DropdownMenuItem(value: true, child: Text('%')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tiers[index]['isPercentage'] = value!;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _tiers.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _tiers.add({'points': 0, 'reward': 0.0, 'isPercentage': false});
            });
          },
          child: const Text('Ajouter un palier'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_programType == 'points' && _tiers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Veuillez ajouter au moins un palier pour la carte à points')),
        );
        return;
      }

      try {
        User? currentUser = _auth.currentUser;
        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur: Utilisateur non connecté')),
          );
          return;
        }

        DocumentReference companyRef =
            _firestore.collection('companys').doc(currentUser.uid);
        DocumentSnapshot companySnapshot = await companyRef.get();

        if (!companySnapshot.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Erreur: Profil d\'entreprise non trouvé')),
          );
          return;
        }

        Map<String, dynamic> programData = {
          'companyId': currentUser.uid,
          'type': _programType,
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (_programType == 'points') {
          programData['tiers'] = _tiers;
        } else {
          programData['targetValue'] = _targetValue;
          programData['rewardValue'] = _rewardValue;
          programData['isPercentage'] = _isPercentage;
        }

        DocumentReference loyaltyProgramRef =
            await _firestore.collection('LoyaltyPrograms').add(programData);

        await companyRef.update({
          'loyaltyProgramId': loyaltyProgramRef.id,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Programme de fidélité créé avec succès')),
        );

        Navigator.pop(context);
      } catch (e) {
        print('Erreur lors de la création du programme de fidélité: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Une erreur est survenue lors de la création du programme')),
        );
      }
    }
  }
}
