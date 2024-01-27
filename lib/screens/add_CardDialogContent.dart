import 'package:Billtracker/api/api_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCardDialogContent extends StatefulWidget {
  final VoidCallback?
      onCardAdded; // Callback to be triggered after adding a card

  const AddCardDialogContent({Key? key, this.onCardAdded}) : super(key: key);

  @override
  _AddCardDialogContentState createState() => _AddCardDialogContentState();
}

class _AddCardDialogContentState extends State<AddCardDialogContent> {
  TextEditingController _cardTitleController = TextEditingController();
  String selectedImage = ''; // Variable to store the selected image URL
  final CollectionReference cardsCollection =
      FirebaseFirestore.instance.collection('cards');

  FirebaseApi firebaseApi = FirebaseApi();

  final List<String> availableImages = [
    'assets/Elements/RMC.png',
    'assets/Elements/cement.jpg',
    'assets/Elements/hardware.jpg',
    'assets/Elements/Plumbing.jpg',
    'assets/Elements/sanataory.jpg',
    'assets/Elements/others.jpg',
    // Add more image URLs as needed
  ];

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.black;

    return Theme(
      data: Theme.of(context), // Use the current theme
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Title',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _cardTitleController,
                    style: TextStyle(
                      color: textColor, // Set the text color
                    ),
                    decoration: InputDecoration(
                      labelText: 'Add Title',
                      labelStyle: TextStyle(
                        color: textColor, // Set the label color
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Choose an Logo:',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor, // Set the text color
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 100, // Set the height according to your needs
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableImages.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedImage = availableImages[index];
                            });
                          },
                          child: Container(
                            width: 80, // Set the width according to your needs
                            height:
                                80, // Set the height according to your needs
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedImage == availableImages[index]
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage(availableImages[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_cardTitleController.text.isNotEmpty &&
                          selectedImage.isNotEmpty) {
                        await addCardToFirestore();

                        firebaseApi.fetchDataFromFirebase().then((_) {
                          widget.onCardAdded!(); // Corrected code
                        });

                        _cardTitleController.clear();
                        selectedImage = '';
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addCardToFirestore() async {
    String secretCode = 'SHIVAT${_cardTitleController.text.toUpperCase()}';

    // Add card to Firestore with document ID as the entered title
    await cardsCollection.doc(_cardTitleController.text.toUpperCase()).set({
      'title': _cardTitleController.text.toUpperCase(),
      'image': selectedImage,
      'isPinned': false,
    });

    await FirebaseFirestore.instance
        .collection('secretCodes')
        .doc(_cardTitleController.text.toUpperCase())
        .set({
      'secretCode': secretCode,
    });

    // Fetch data from Firebase and update UI
    await firebaseApi.fetchDataFromFirebase();
  }

  @override
  void dispose() {
    _cardTitleController.dispose();
    super.dispose();
  }
}
