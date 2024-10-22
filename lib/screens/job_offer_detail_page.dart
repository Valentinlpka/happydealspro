import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/job_offer.dart';
import 'package:url_launcher/url_launcher.dart';

class JobOfferDetailPage extends StatelessWidget {
  final JobOffer jobOffer;

  const JobOfferDetailPage({super.key, required this.jobOffer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(jobOffer.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJobOfferDetails(),
              const SizedBox(height: 24),
              _buildStatistics(),
              const SizedBox(height: 24),
              _buildApplicantsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobOfferDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(jobOffer.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(jobOffer.description),
            const SizedBox(height: 16),
            Text('Date de publication: ${jobOffer.timestamp.toString()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('jobOfferId', isEqualTo: jobOffer.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        int applicationsCount = snapshot.data?.docs.length ?? 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard('Likes', jobOffer.likes.toString()),
            _buildStatCard('Candidatures', applicationsCount.toString()),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('jobOfferId', isEqualTo: jobOffer.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('Aucun candidat pour le moment.');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var application = snapshot.data!.docs[index];
            return _buildApplicantCard(application);
          },
        );
      },
    );
  }

  Widget _buildApplicantCard(DocumentSnapshot application) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('${application['name']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${application['email']}'),
            Text('Téléphone: ${application['phone']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (application['cvUrl'] != null) const Text('CV'),
            if (application['cvUrl'] != null)
              IconButton(
                icon: const Icon(Icons.description),
                onPressed: () => _launchURL(application['cvUrl']),
              ),
            if (application['coverLetterUrl'] != null)
              const Text('Lettre de motivation'),
            if (application['coverLetterUrl'] != null)
              IconButton(
                icon: const Icon(Icons.article),
                onPressed: () => _launchURL(application['coverLetterUrl']),
              ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}
