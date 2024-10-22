import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/ticket.dart';
import 'package:happy_deals_pro/classes/user.dart';
import 'package:happy_deals_pro/screens/ticket_detail_page.dart';
import 'package:happy_deals_pro/widgets/create_ticket.dart';
import 'package:happy_deals_pro/widgets/ticket_service.dart';
import 'package:provider/provider.dart';

class MyTicketsPage extends StatelessWidget {
  const MyTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketService = Provider.of<TicketService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Tickets')),
      body: StreamBuilder<List<Ticket>>(
        stream: ticketService.getUserTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun ticket trouvé'));
          }

          final tickets = snapshot.data!;
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(ticket.title),
                  subtitle: Text(
                    '${ticket.description}\nStatut: ${ticket.status.toString().split('.').last}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TicketDetailPage(
                                ticketId: ticket.id,
                              )),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTicketPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTicketDetails(BuildContext context, Ticket ticket, Users user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ticket.title),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Description: ${ticket.description}'),
            const SizedBox(height: 8),
            Text('Statut: ${ticket.status.toString().split('.').last}'),
            const SizedBox(height: 8),
            Text('Date de création: ${ticket.createdAt.toLocal()}'),
          ],
        ),
        actions: [
          if (user.type == UserType.admin)
            PopupMenuButton<TicketStatus>(
              onSelected: (TicketStatus result) {
                Provider.of<TicketService>(context, listen: false)
                    .updateTicketStatus(ticket.id, result);
                Navigator.of(context).pop();
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<TicketStatus>>[
                const PopupMenuItem<TicketStatus>(
                  value: TicketStatus.open,
                  child: Text('Ouvert'),
                ),
                const PopupMenuItem<TicketStatus>(
                  value: TicketStatus.inProgress,
                  child: Text('En cours'),
                ),
                const PopupMenuItem<TicketStatus>(
                  value: TicketStatus.completed,
                  child: Text('Terminé'),
                ),
                const PopupMenuItem<TicketStatus>(
                  value: TicketStatus.cancelled,
                  child: Text('Annulé'),
                ),
              ],
              child: const Text('Changer le statut'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
