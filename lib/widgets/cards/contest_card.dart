import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/contest.dart';
import 'package:happy_deals_pro/providers/company_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConcoursCard extends StatelessWidget {
  final Contest contest;
  const ConcoursCard({
    super.key,
    required this.contest,
  });

  @override
  Widget build(BuildContext context) {
    final companyProvider = Provider.of<CompanyProvider>(context);
    String formatDateTime(DateTime dateTime) {
      return DateFormat('d MMMM yyyy', 'fr_FR').format(dateTime);
    }

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
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.50), BlendMode.darken),
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                        image: NetworkImage(contest.giftPhoto),
                      ),
                    ),
                    height: 110,
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
                                padding: const EdgeInsets.only(
                                    top: 3, bottom: 3, right: 7, left: 5),
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(70, 0, 0, 0),
                                ),
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.event_note_outlined,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 5, width: 5),
                                    Text(
                                      'Jeux Concours',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
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
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  (contest.title),
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
                                const SizedBox(height: 5, width: 5),
                                Text(
                                  "${formatDateTime(contest.startDate)} -${formatDateTime(contest.endDate)}",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 85, 85, 85)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10, width: 10),
                            Text(
                              contest.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
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
                                const SizedBox(height: 10, width: 10),
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
