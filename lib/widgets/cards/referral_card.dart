import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/referral.dart';
import 'package:happy_deals_pro/providers/company_provider.dart';
import 'package:happy_deals_pro/widgets/forms/form_referral.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReferralCard extends StatelessWidget {
  final Referral post;

  const ReferralCard({
    required this.post,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final companyProvider = Provider.of<CompanyProvider>(context);

    String formatDateTime(DateTime dateTime) {
      return DateFormat('dd/MM/yyyy')
          .format(dateTime); // Format comme "2024-06-13"
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormReferral(
                      referral: post,
                    ),
                  ),
                );
              },
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
                          Colors.black.withOpacity(0.30),
                          BlendMode.hue,
                        ),
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                        image: NetworkImage(post.image),
                      ),
                    ),
                    height: 80,
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
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.pink, Colors.blue],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.only(
                                      top: 3, bottom: 3, right: 7, left: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Parrainage',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
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
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              textAlign: TextAlign.left,
                              softWrap: true,
                              (post.title),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                          width: 5,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 15),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "jusqu'au ${formatDateTime(post.dateFinal)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 85, 85, 85),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                          width: 5,
                        ),
                        Text(
                          post.description,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
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
                                  width: 10,
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
