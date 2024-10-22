import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileDetailDialog extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileDetailDialog({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userData['image_profile'] ??
                      'https://via.placeholder.com/150'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${userData['firstName']} ${userData['lastName']}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userData['desiredPosition'] ?? '',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData['industrySector'] ?? '',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Description:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(userData['description'] ?? ''),
            const SizedBox(height: 16),
            Text('Disponibilité: ${userData['availability'] ?? ''}'),
            Text(
                'Type de contrat: ${(userData['contractTypes'] as List<dynamic>?)?.join(', ') ?? ''}'),
            Text('Horaires: ${userData['workingHours'] ?? ''}'),
            const SizedBox(height: 16),
            if (userData['showEmail'] == true && userData['email'] != null)
              TextButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Contacter par email'),
                onPressed: () => _launchEmail(userData['email']),
              ),
            if (userData['showPhone'] == true && userData['phone'] != null)
              TextButton.icon(
                icon: const Icon(Icons.phone),
                label: const Text('Contacter par téléphone'),
                onPressed: () => _launchPhone(userData['phone']),
              ),
            if (userData['cvUrl'] != null)
              TextButton.icon(
                icon: const Icon(Icons.description),
                label: const Text('Voir le CV'),
                onPressed: () => _launchURL(userData['cvUrl']),
              ),
            const SizedBox(height: 16),
            Text(
              'Profil mis à jour le ${DateFormat('dd/MM/yyyy').format((userData['timestampProfile'] as Timestamp).toDate())}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      print('Could not launch $emailLaunchUri');
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunch(phoneLaunchUri.toString())) {
      await launch(phoneLaunchUri.toString());
    } else {
      print('Could not launch $phoneLaunchUri');
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}
