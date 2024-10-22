import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/ticket.dart';
import 'package:happy_deals_pro/widgets/ticket_service.dart';
import 'package:provider/provider.dart';

class TicketDetailPage extends StatelessWidget {
  final String ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    final ticketService = Provider.of<TicketService>(context);
    final TextEditingController messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Détails du ticket')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<TicketMessage>>(
              stream: ticketService.getTicketMessages(ticketId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucun message'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final message = snapshot.data![index];
                    return ListTile(
                      title: Text(message.content),
                      subtitle:
                          Text('${message.senderId} - ${message.createdAt}'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration:
                        const InputDecoration(hintText: 'Entrez votre message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      ticketService.addMessageToTicket(
                          ticketId, messageController.text);
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
