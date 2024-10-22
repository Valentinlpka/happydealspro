import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/providers/auth_provider.dart';
import 'package:happy_deals_pro/providers/company_provider.dart';
import 'package:happy_deals_pro/screens/add_post_page.dart';
import 'package:happy_deals_pro/screens/company_balance_page.dart';
import 'package:happy_deals_pro/screens/contest_page.dart';
import 'package:happy_deals_pro/screens/conversation_list_page.dart';
import 'package:happy_deals_pro/screens/create_promo_code_page.dart';
import 'package:happy_deals_pro/screens/cvtheque_page.dart';
import 'package:happy_deals_pro/screens/dashboard_page.dart';
import 'package:happy_deals_pro/screens/deal_express_page.dart';
import 'package:happy_deals_pro/screens/detail_loyalty_page.dart';
import 'package:happy_deals_pro/screens/event_page.dart';
import 'package:happy_deals_pro/screens/happy_deals_page.dart';
import 'package:happy_deals_pro/screens/job_offer_page.dart';
import 'package:happy_deals_pro/screens/order_deal_express.dart';
import 'package:happy_deals_pro/screens/order_list_page.dart';
import 'package:happy_deals_pro/screens/pro_referral_page.dart';
import 'package:happy_deals_pro/screens/product_form_page.dart';
import 'package:happy_deals_pro/screens/product_management_page.dart';
import 'package:happy_deals_pro/screens/referral_page.dart';
import 'package:happy_deals_pro/screens/shop_page.dart';
import 'package:happy_deals_pro/widgets/forms/form_company.dart';
import 'package:happy_deals_pro/widgets/notification_bell.dart';
import 'package:provider/provider.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final List<MenuItem>? subItems;
  final Widget page;
  bool isExpanded;

  MenuItem({
    required this.title,
    required this.icon,
    this.subItems,
    required this.page,
    this.isExpanded = false,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

void signOut(BuildContext context) async {
  final authProvider = Provider.of<AuthsProvider>(context, listen: false);
  await authProvider.signOut();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _selectedSubIndex = -1;
  bool _showConversations = false;

  late List<MenuItem> menuItems;
  late String userUid;

  @override
  void initState() {
    super.initState();
    User? userId = FirebaseAuth.instance.currentUser;
    userUid = userId?.uid ?? "";
    menuItems = [
      MenuItem(
          title: 'Dashboard', icon: Icons.dashboard, page: const Dashboard()),
      MenuItem(
          title: 'Ajouter un post',
          icon: Icons.add_outlined,
          page: const AddPost()),
      MenuItem(
          title: 'Programme de fidélité',
          icon: Icons.card_giftcard_outlined,
          page: const LoyaltyDashboard()),
      MenuItem(
        title: 'Boutique',
        icon: Icons.shopping_cart,
        page: const SizedBox(), // Placeholder
        subItems: [
          MenuItem(
              title: 'Ajouter un produit ',
              icon: Icons.shopping_bag_outlined,
              page: const ProductFormScreen()),
          MenuItem(
              title: 'Produits ',
              icon: Icons.shopping_bag_outlined,
              page: const ShopPage()),
          MenuItem(
              title: 'Gestion des produits ',
              icon: Icons.shopping_bag_outlined,
              page: const ProductManagementScreen()),
          MenuItem(
              title: 'Commandes ',
              icon: Icons.inventory,
              page: const EcranListeCommandes()),
          MenuItem(
              title: 'Créer un code promo ',
              icon: Icons.flash_on,
              page: const CreatePromoCodeScreen()),
        ],
      ),
      MenuItem(
        title: 'Deals Express',
        icon: Icons.people,
        page: const SizedBox(),
        subItems: [
          MenuItem(
            title: 'Gestion des deals',
            icon: Icons.flash_on,
            page: const ExpressDealPage(),
          ),
          MenuItem(
            title: 'Gestion des commandes',
            icon: Icons.flash_on,
            page: const DealExpressOrdersPage(),
          ),
        ],
      ),
      MenuItem(
          title: 'Mon portefeuille',
          icon: Icons.inventory,
          page: const CompanyBalancePage()),
      MenuItem(
          title: 'Jeux Concours',
          icon: Icons.inventory,
          page: const ContestPage()),
      MenuItem(
          title: "Offres d'emploi",
          icon: Icons.article,
          page: const JobOfferPage()),
      MenuItem(
          title: 'Happy Deal',
          icon: Icons.local_offer,
          page: const HappyDealsPage()),
      MenuItem(
          title: 'Évènement', icon: Icons.campaign, page: const EventPage()),
      MenuItem(
        title: 'Parrainages',
        icon: Icons.group_add,
        page: const SizedBox(),
        subItems: [
          MenuItem(
              title: 'Mes offres de parrainage ',
              icon: Icons.shopping_bag_outlined,
              page: const ReferralPage()),
          MenuItem(
              title: 'Gestion des parrainages',
              icon: Icons.inventory,
              page: const ProReferralsPage()),
        ],
      ),
      MenuItem(
        title: 'Emploi',
        icon: Icons.group_add,
        page: const SizedBox(),
        subItems: [
          MenuItem(
              title: 'CVthèque ',
              icon: Icons.shopping_bag_outlined,
              page: const CVthequePage()),
          MenuItem(
              title: "Gestion des offres d'emploi",
              icon: Icons.inventory,
              page: const JobOfferPage()),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          VerticalDivider(width: 1, thickness: 1, color: Colors.grey[300]),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset('assets/images/logo.png', height: 100),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return _buildNavItem(menuItems[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTickets() {
    setState(() {
      _selectedIndex =
          menuItems.indexWhere((item) => item.title == 'Mes Tickets');
    });
  }

  void _navigateTo(int index, {int subIndex = -1}) {
    setState(() {
      _showConversations = false;
      _selectedIndex = index;
      _selectedSubIndex = subIndex;
    });
  }

  Widget _buildNavItem(MenuItem item, int index) {
    bool isSelected = _selectedIndex == index && !_showConversations;
    if (item.subItems == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.blue[600] : Colors.transparent,
        ),
        child: ListTile(
          leading: Icon(
            item.icon,
            color: isSelected ? Colors.white : Colors.grey.shade600,
            size: 22,
          ),
          title: Text(
            item.title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          selected: isSelected,
          onTap: () {
            setState(() {
              _showConversations = false;
              _selectedIndex = index;
              _selectedSubIndex = -1;
            });
            _navigateTo(index);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        ),
      );
    } else {
      return ExpansionTile(
        leading: Icon(item.icon, color: Colors.grey.shade600),
        title: Text(
          item.title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
        ),
        children: item.subItems!.asMap().entries.map((entry) {
          int subIndex = entry.key;
          MenuItem subItem = entry.value;
          bool isSubSelected =
              _selectedIndex == index && _selectedSubIndex == subIndex;
          return Container(
            margin: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isSubSelected ? Colors.blue[600] : Colors.transparent,
            ),
            child: ListTile(
              leading: Icon(
                subItem.icon,
                color: isSubSelected ? Colors.white : Colors.grey.shade600,
                size: 20,
              ),
              title: Text(
                subItem.title,
                style: TextStyle(
                  color: isSubSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight:
                      isSubSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                setState(() {
                  _showConversations = false;
                  _selectedIndex = index;
                  _selectedSubIndex = subIndex;
                });
                _navigateTo(index, subIndex: subIndex);
              },
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildHeader() {
    final companyProvider = Provider.of<CompanyProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Spacer(),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          NotificationBell(userId: userUid),
          const SizedBox(width: 16),
          IconButton(
            // Nouvelle icône de messagerie
            icon: const Icon(Icons.message),
            onPressed: () {
              setState(() {
                _showConversations = !_showConversations;
                _selectedIndex = -1;
                _selectedSubIndex = -1;
              });
            },
          ),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            offset: const Offset(0, 56),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit_profile',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Modifier mon profil'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Déconnexion'),
                ),
              ),
            ],
            onSelected: (String value) {
              if (value == 'edit_profile') {
                _navigateToEditCompany(context);
              } else if (value == 'logout') {
                signOut(context);
              }
            },
            child: CircleAvatar(
                radius: 20,
                backgroundImage: companyProvider.companyLogo != ''
                    ? NetworkImage(companyProvider.companyLogo)
                    : null,
                child: companyProvider.companyLogo == ''
                    ? const Icon(Icons.person)
                    : null),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_showConversations) {
      return ConversationsListScreen(currentUserId: userUid);
    } else if (_selectedSubIndex != -1 &&
        menuItems[_selectedIndex].subItems != null) {
      return menuItems[_selectedIndex].subItems![_selectedSubIndex].page;
    } else if (_selectedIndex >= 0) {
      return menuItems[_selectedIndex].page;
    } else {
      return const Center(child: Text('Sélectionnez un élément du menu'));
    }
  }

  void _navigateToEditCompany(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final companyDoc = await FirebaseFirestore.instance
          .collection('companys')
          .doc(user.uid)
          .get();

      if (companyDoc.exists) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CompanyFormPage(),
            fullscreenDialog: true,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aucune entreprise trouvée pour cet utilisateur')),
        );
      }
    }
  }
}

class FormScreen extends StatelessWidget {
  final String formType;

  const FormScreen({required this.formType, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(formType),
      ),
      body: Center(
        child: Text('Formulaire pour $formType'),
      ),
    );
  }
}
