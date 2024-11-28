// lib/pages/services/service_management_page.dart
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/service_model.dart';
import 'package:happy_deals_pro/widgets/forms/form_service.dart';

import '../../services/service_service.dart';

class ServiceManagementPage extends StatefulWidget {
  final String professionalId;

  const ServiceManagementPage({
    super.key,
    required this.professionalId,
  });

  @override
  _ServiceManagementPageState createState() => _ServiceManagementPageState();
}

class _ServiceManagementPageState extends State<ServiceManagementPage> {
  ServiceModel? selectedService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Liste des services (1/3 de l'écran)
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mes Services',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Nouveau Service'),
                          onPressed: () {
                            setState(() {
                              selectedService = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: StreamBuilder<List<ServiceModel>>(
                      stream: ServiceService()
                          .getServicesByProfessional(widget.professionalId),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return Center(
                              child: Text('Erreur: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final services = snapshot.data!;
                        if (services.isEmpty) {
                          return const Center(
                            child: Text('Aucun service créé pour le moment'),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: services.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final service = services[index];
                            return ListTile(
                              leading: service.images.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        service.images.first,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child:
                                          const Icon(Icons.image_not_supported),
                                    ),
                              title: Text(service.name),
                              subtitle: Text(
                                '${service.price.toStringAsFixed(2)}€ - ${service.duration}min',
                              ),
                              trailing: Switch(
                                value: service.isActive,
                                onChanged: (value) async {
                                  await ServiceService()
                                      .toggleServiceStatus(service.id, value);
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  selectedService = service;
                                });
                              },
                              selected: selectedService?.id == service.id,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Formulaire de service (2/3 de l'écran)
          Expanded(
            flex: 2,
            child: ServiceFormScreen(
              service: selectedService,
              professionalId: widget.professionalId, // Ajoutez cette prop
              onServiceSaved: () {
                // Ajoutez cette prop
                setState(() {
                  selectedService = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
