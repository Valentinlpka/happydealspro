import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/event.dart';
import 'package:happy_deals_pro/providers/company_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EvenementCard extends StatelessWidget {
  final Event event;

  const EvenementCard({
    required this.event,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final companyProvider = Provider.of<CompanyProvider>(context);

    final formattedDate =
        DateFormat('dd/MM/yyyy à HH:mm').format(event.eventDate);
    return SizedBox(
      width: 350,
      child: Column(
        children: [
          Card(
            shadowColor: Colors.grey,
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: InkWell(
              onTap: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      image: DecorationImage(
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                        image: NetworkImage(event.photo),
                      ),
                    ),
                    height: 123,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color.fromARGB(115, 0, 0, 0),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      Text(
                                        'Evènement',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    height: 120,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  (event.title),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 15,
                                ),
                                const SizedBox(
                                  height: 5,
                                  width: 5,
                                ),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 85, 85, 85),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.grey[300],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue,
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundImage: NetworkImage(
                                        companyProvider.companyLogo),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                  width: 5,
                                ),
                                Text(
                                  (companyProvider.companyName),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
