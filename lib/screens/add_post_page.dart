import 'package:flutter/material.dart';
import 'package:happy_deals_pro/screens/product_form_page.dart';
import 'package:happy_deals_pro/widgets/forms/form_contest.dart';
import 'package:happy_deals_pro/widgets/forms/form_deal_express.dart';
import 'package:happy_deals_pro/widgets/forms/form_event.dart';
import 'package:happy_deals_pro/widgets/forms/form_happy_deal.dart';
import 'package:happy_deals_pro/widgets/forms/form_job_offer.dart';
import 'package:happy_deals_pro/widgets/forms/form_news.dart';
import 'package:happy_deals_pro/widgets/forms/form_promo_code.dart';
import 'package:happy_deals_pro/widgets/forms/form_referral.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  Widget? _currentForm;
  String _selectedOption = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120, // Ajustez cette hauteur selon vos besoins
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildOption(
                  icon: Icons.add_business_outlined,
                  title: 'Post',
                  isSelected: _selectedOption == 'Post',
                  onTap: () {
                    setState(() {
                      _selectedOption = 'Post';
                      _currentForm = const FormNews();
                    });
                  },
                ),
                _buildOption(
                  icon: Icons.add_business_outlined,
                  title: 'Produit',
                  isSelected: _selectedOption == 'Produit',
                  onTap: () {
                    setState(() {
                      _selectedOption = 'Produit';
                      _currentForm = const ProductFormScreen();
                    });
                  },
                ),
                _buildOption(
                  icon: Icons.add_business_outlined,
                  title: 'Code Promo',
                  isSelected: _selectedOption == 'Code Promo',
                  onTap: () {
                    setState(() {
                      _selectedOption = 'Code Promo';
                      _currentForm = const PromoCodeForm();
                    });
                  },
                ),
                _buildOption(
                  icon: Icons.event,
                  title: 'Evènement',
                  isSelected: _selectedOption == 'Evènement',
                  onTap: () {
                    setState(() {
                      _selectedOption = 'Evènement';
                      _currentForm = const FormEvent();
                    });
                  },
                ),
                _buildOption(
                  icon: Icons.local_offer,
                  title: 'Happy Deals',
                  isSelected: _selectedOption == 'Happy Deals',
                  onTap: () {
                    setState(() {
                      _selectedOption = 'Happy Deals';
                      _currentForm = const HappyDealForm();
                    });
                  },
                ),
                _buildOption(
                  icon: Icons.flash_on,
                  title: 'Deals Express',
                  isSelected: _selectedOption == 'Deals Express',
                  onTap: () {
                    setState(() {
                      _selectedOption = 'Deals Express';
                      _currentForm = const FormExpressDeal();
                    });
                  },
                ),
                _buildOption(
                  icon: Icons.people,
                  title: 'Parrainage',
                  isSelected: _selectedOption == 'Parrainage',
                  onTap: () {
                    setState(() {
                      _selectedOption = 'Parrainage';
                      _currentForm = const FormReferral();
                    });
                  },
                ),
                _buildOption(
                  icon: Icons.casino,
                  title: 'Jeux concours',
                  isSelected: _selectedOption == 'Jeux concours',
                  onTap: () {
                    setState(() {
                      _selectedOption = 'Jeux concours';
                      _currentForm = const FormContest();
                    });
                  },
                ),
                _buildOption(
                  icon: Icons.work,
                  title: "Offres d'emploi",
                  isSelected: _selectedOption == "Offres d'emploi",
                  onTap: () {
                    setState(() {
                      _selectedOption = "Offres d'emploi";
                      _currentForm = const JobOfferForm();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _currentForm ??
              const Center(
                  child: Text('Sélectionnez une option pour ajouter un post')),
        ),
      ],
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white,
            border: Border.all(
                color: isSelected
                    ? Colors.blue
                    : const Color.fromARGB(166, 232, 232, 232),
                width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          height: 100,
          width:
              150, // Réduit la largeur pour mieux s'adapter au défilement horizontal
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 30, color: isSelected ? Colors.white : Colors.black),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 14, // Réduit légèrement la taille de la police
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
