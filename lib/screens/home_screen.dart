import 'dart:ui';

import 'package:Billtracker/api/api_request.dart';
import 'package:Billtracker/main.dart';
import 'package:Billtracker/models/card_data.dart';
import 'package:Billtracker/screens/add_CardDialogContent.dart';
import 'package:Billtracker/screens/custom_detailPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(themeNotifierProvider);
    Color textColor =
        notifier.themeMode == ThemeMode.light ? Colors.black : Colors.white;
    Color hintColor =
        notifier.themeMode == ThemeMode.light ? Colors.white : Colors.white;

    TextEditingController _searchController = TextEditingController();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/background/home_bg.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          notifier.themeMode == ThemeMode.light
                              ? Icons.brightness_6
                              : Icons.brightness_3,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          notifier.setTheme(
                            notifier.themeMode == ThemeMode.light
                                ? ThemeMode.dark
                                : ThemeMode.light,
                          );
                        },
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hello, Shiva ",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Director",
                            style: TextStyle(fontSize: 18, color: hintColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        ref
                            .read(firebaseApiProvider)
                            .filterCards(value, cardList);
                      },
                      decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search, color: textColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: notifier.themeMode == ThemeMode.light
                            ? Colors.white
                            : const Color(0xFF242248).withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 7),
                          child: Text(
                            'HIRNOT GROUP',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 116, 108, 252),
                                    Colors.blue
                                  ],
                                ).createShader(
                                    const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await ref
                              .read(firebaseApiProvider)
                              .fetchDataFromFirebase();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future:
                          ref.read(firebaseApiProvider).fetchDataFromFirebase(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20.0,
                            crossAxisSpacing: 20.0,
                            childAspectRatio: 0.75,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  _showAddCardDialog(context, ref);
                                },
                                child: Card(
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const ListTile(
                                    title: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          size: 100,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "Add Info",
                                          style: TextStyle(fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Display the list of added cards
                              ...cardList.map((cardData) =>
                                  buildCard(context, ref, cardData)),
                            ],
                          );
                        }
                      },
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

  Widget buildCard(BuildContext context, WidgetRef ref, CardData cardData) {
    String pinButtonText = cardData.isPinned ? 'Unpin' : 'Pin';

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          _handleCardTap(context, cardData);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: AssetImage(cardData.image),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 5,
                child: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      showSecretCodeDialog(context, cardData.text);
                    } else if (value == 'pin') {
                      bool isActionSuccessful =
                          await handlePinAction(context, ref, cardData);

                      if (isActionSuccessful) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'pin',
                      child: ListTile(
                        leading: const Icon(Icons.push_pin),
                        title: Text(pinButtonText),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 13,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardData.text.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (cardData.isPinned)
                      const SizedBox(
                        height: 8,
                      ),
                    if (cardData.isPinned)
                      const Chip(
                        label: Text(
                          'Pinned',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: Colors.orange,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> handlePinAction(
      BuildContext context, WidgetRef ref, CardData cardData) async {
    FirebaseApi firebaseApi = FirebaseApi();

    final CollectionReference<Map<String, dynamic>> cardsCollection =
        FirebaseFirestore.instance.collection('cards');

    try {
      await cardsCollection.doc(cardData.text.toUpperCase()).update({
        'isPinned': !cardData.isPinned,
      });

      await firebaseApi.fetchDataFromFirebase();
      await ref.read(firebaseApiProvider).fetchDataFromFirebase();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cardData.isPinned ? 'Card Pinned' : 'Card Unpinned'),
          duration: const Duration(seconds: 1),
        ),
      );

      return true;
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error toggling pin status'),
          duration: Duration(seconds: 1),
        ),
      );

      return false; // Return false indicating failure
    }
  }

  void _showAddCardDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: AddCardDialogContent(
            onCardAdded: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        );
      },
    );
  }

  void _handleCardTap(BuildContext context, CardData cardData) {
    String cardTitle = cardData.text;
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomDetailPage(cardId: cardTitle),
      ),
    );
  }

  Future<void> showSecretCodeDialog(BuildContext context, String title) async {
    String enteredCode = '';
    FirebaseApi firebaseApi = FirebaseApi();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Secret Code'),
          content: TextField(
            onChanged: (value) {
              enteredCode = value;
            },
            decoration: const InputDecoration(labelText: 'Secret Code'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Retrieve the secret code from Firebase
                String? secretCode = await firebaseApi.getSecretCode(title);

                // Validate the entered code
                if (secretCode != null && enteredCode == secretCode) {
                  handleDelete(title);
                  Navigator.pop(context); // Close the dialog
                } else {
                  // Display an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid Secret Code'),
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void handleDelete(String title) {
    FirebaseApi firebaseApi = FirebaseApi();
    firebaseApi.handleDelete(title);
  }
}
