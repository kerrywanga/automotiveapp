import 'package:automotiveapp/constants/colors.dart';
import 'package:automotiveapp/firebase/storage_service.dart';
import 'package:automotiveapp/usecase/firebasestorage_apis.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  late Future<List<FirebaseFile>> servicesFromFirebaseStorage;

  @override
  void initState() {
    super.initState();
    servicesFromFirebaseStorage =
        FirebaseStorageApis.fetchAllrentalServicesImages();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseStorageApis().fetchAllServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }
          if (snapshot.hasData) {
            final serviceDocs = snapshot.data!.docs;

            return GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 3 / 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: List.generate(serviceDocs.length, (index) {
                  final service = serviceDocs[index];
                  return Stack(children: [
                    Container(
                      margin: const EdgeInsets.only(left: 5, top: 10, right: 5),
                      decoration: BoxDecoration(
                          color: blackfade,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 110,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                image: DecorationImage(
                                    image: NetworkImage(service['url']),
                                    fit: BoxFit.fill)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: orange),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle, color: white),
                                  child: const Center(
                                    child: Icon(Icons.settings),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go("/PartDetails"),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text("Repair"),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                           Text(
                            service['name'],
                            style:  const TextStyle(
                                color: white,
                                fontFamily: "Roboto",
                                fontSize: 19),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Icon(
                                LineIcons.headphones,
                                color: white.withOpacity(0.6),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                "24/7",
                                style: TextStyle(
                                    color: white,
                                    fontFamily: "Roboto",
                                    fontSize: 19),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    // Container(
                    //   margin: const EdgeInsets.only(left: 4, top: 9, right: 5),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(20),
                    //     gradient: LinearGradient(colors: [
                    //       white.withOpacity(0.4),
                    //       white.withOpacity(0.3),
                    //       white.withOpacity(0.2),
                    //       white.withOpacity(0.1),
                    //     ])
                    //   ),
                    // )
                  ]);
                }));
          }

          return const Center(
            child: Text(
              "Something went wrong while fetching the data",
              style: TextStyle(
                  color: Colors.red, fontSize: 20, fontWeight: FontWeight.w600),
            ),
          );
        });
  }
}
