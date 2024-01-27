import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Billtracker/models/card_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final firebaseApiProvider = Provider<FirebaseApi>((ref) => FirebaseApi());

class FirebaseApi {
  final CollectionReference cardsCollection =
      FirebaseFirestore.instance.collection('cards');

  Future<void> fetchDataFromFirebase() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('cards').get();

      List<CardData> allCards = querySnapshot.docs.map((DocumentSnapshot doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return CardData(
          image: data['image'] ?? '',
          text: data['title'] ?? '',
          isPinned: data['isPinned'] ?? false,
        );
      }).toList();
      List<CardData> pinnedCards =
          allCards.where((card) => card.isPinned).toList();
      List<CardData> unpinnedCards =
          allCards.where((card) => !card.isPinned).toList();

      pinnedCards.sort((a, b) => a.text.compareTo(b.text));
      unpinnedCards.sort((a, b) => a.text.compareTo(b.text));

      cardList = [...pinnedCards, ...unpinnedCards];
    } catch (e) {
    }
  }

  Future<List<Map<String, dynamic>>> fetchDetailsForCard(String cardId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection(cardId.toUpperCase())
              .get();
      return querySnapshot.docs.map((DocumentSnapshot doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime date = doc['date'].toDate();
        String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
        return {
          'id': int.tryParse(doc.id) ?? 0,
          'date': formattedDate,
          'work': data['taskName'],
          'paymentStatus': data['paymentStatus'],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String?, dynamic>> fetchAllDetails(
      String title, String cardId) async {
    try {
      DocumentSnapshot<Map<String?, dynamic>> docSnapshot =
          await FirebaseFirestore.instance
              .collection(title) // collection name
              .doc(cardId) // document ID
              .get();

      if (docSnapshot.exists) {
        Map<String?, dynamic> data = docSnapshot.data()!;

        DateTime date = data['date'].toDate();
        DateTime billingD = data['billingDate'].toDate();
        String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
        String billingDate = DateFormat('dd/MM/yyyy').format(billingD);

        return {
          'id': int.tryParse(docSnapshot.id) ?? 0,
          'date': formattedDate,
          'billingDate': billingDate,
          'work': data['taskName'],
          'taskName': data['taskName'],
          'quantity': data['quantity'],
          'selectedValue': data['selectedValue'],
          'packets': data['packets'],
          'grade': data['grade'],
          'trucks': data['trucks'],
          'material': data['material'],
          'money': data['money'],
          'paymentStatus': data['paymentStatus'],
          'imageUrl': data['imageUrl'],
        };
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  void filterCards(String searchQuery, List<CardData> allCards) {
    if (searchQuery.isEmpty) {
      cardList = List.from(allCards);
    } else {
      cardList = allCards
          .where((card) =>
              card.text.toUpperCase().contains(searchQuery.toUpperCase()))
          .toList();
    }
  }

  Future<String?> getSecretCode(String cardTitle) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await FirebaseFirestore.instance
              .collection('secretCodes')
              .doc(cardTitle.toUpperCase())
              .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data()!;
        return data['secretCode'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> handleDelete(String title) async {
    try {
      await cardsCollection.doc(title.toUpperCase()).delete();
      await FirebaseFirestore.instance
          .collection('secretCodes')
          .doc(title.toUpperCase())
          .delete();
    } catch (e) {
    }
  }

  Future<void> handleTileDelete(String title, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection(title.toUpperCase())
          .doc(id)
          .delete();
          
    } catch (e) {
    }
  }

  Future<void> handleUpdatePaymentStatus(
      String cardId, String title, bool isPaid) async {
    try {
      await FirebaseFirestore.instance
          .collection(title.toUpperCase()) // collection name
          .doc(cardId)
          .update({'paymentStatus': isPaid ? 'Unpaid' : 'Paid'});
    } catch (e) {
    }
  }
}
