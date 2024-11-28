// lib/widgets/services/services_list.dart
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/service_model.dart';
import 'package:happy_deals_pro/services/service_service.dart';

class ServicesList extends StatelessWidget {
  final String professionalId;
  final Function(ServiceModel) onServiceSelected;

  const ServicesList({
    super.key,
    required this.professionalId,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  onPressed: () => onServiceSelected(ServiceModel(
                    id: '',
                    name: '',
                    description: '',
                    price: 0,
                    duration: 30,
                    professionalId: professionalId,
                    images: [],
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  )),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<ServiceModel>>(
              stream:
                  ServiceService().getServicesByProfessional(professionalId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
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
                              child: const Icon(Icons.image_not_supported),
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
                      onTap: () => onServiceSelected(service),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
