import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/job_offer.dart';
import 'package:happy_deals_pro/providers/company_provider.dart';
import 'package:happy_deals_pro/screens/job_offer_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class JobOfferCard extends StatelessWidget {
  final JobOffer post;

  const JobOfferCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final companyProvider = Provider.of<CompanyProvider>(context);

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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobOfferDetailPage(jobOffer: post),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
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
                                      "Offre d'emploi",
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
                    height: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.blue,
                                      child: CircleAvatar(
                                        radius: 28,
                                        backgroundImage: NetworkImage(
                                            'https://media.licdn.com/dms/image/C4D0BAQF1LJrX1nhcyA/company-logo_200_200/0/1630523580358/be_happy_services_logo?e=2147483647&v=beta&t=XH4UBtLR0ulhQvd1XKnpRgg-BrU0JrWZhcsAZf7c15I'),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                      width: 20,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (post.title),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                            '${(companyProvider.companyName)} - ${post.city}')
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 10, width: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: post.keywords
                                  .map(
                                    (keyword) => Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.blue[600],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15.0, vertical: 6),
                                            child: Text(
                                              keyword,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                          width: 10,
                                        )
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 5, width: 5),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(timeago.format(post.timestamp, locale: 'fr')),
                          ],
                        )
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
