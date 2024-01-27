import 'package:Billtracker/api/api_request.dart';
import 'package:Billtracker/screens/data_review.dart';
import 'package:Billtracker/screens/home_screen.dart';
import 'package:Billtracker/screens/task_screen.dart';
import 'package:Billtracker/widgets/CustomListTile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDetailPage extends StatefulWidget {
  final String cardId;

  CustomDetailPage({required this.cardId});

  @override
  _CustomDetailPageState createState() => _CustomDetailPageState();
}

class _CustomDetailPageState extends State<CustomDetailPage> {
  List<Map<String, dynamic>> cardDetails = [];
  List<Map<String, dynamic>> filteredCardDetails = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    fetchData();
  }

  FirebaseApi firebaseApi = FirebaseApi();

  void fetchData() async {
    cardDetails = await firebaseApi.fetchDetailsForCard(widget.cardId);
    setState(() {
      filteredCardDetails = List.from(cardDetails);
    });
  }

  void filterCardDetails(String searchQuery) {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredCardDetails = List.from(cardDetails);
      } else {
        filteredCardDetails = cardDetails
            .where((detail) => detail["work"]
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  List<Map<String, dynamic>> categorizeItems(String category) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    switch (category) {
      case 'Weekly':
        return cardDetails
            .where((item) =>
                today.difference(_parseDate(item['date'])).inDays <= 7)
            .toList();
      case 'Monthly':
        return cardDetails
            .where((item) =>
                today.difference(_parseDate(item['date'])).inDays <= 30)
            .toList();
      default:
        return cardDetails;
    }
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        title: Text(
          widget.cardId.toUpperCase(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      onChanged: filterCardDetails,
                      decoration: const InputDecoration(
                        hintText: "Search...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      filterCardDetails(_searchController.text);
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OptionButton(
                  "All",
                  onTap: () {
                    setState(() {
                      filteredCardDetails = cardDetails;
                    });
                  },
                ),
                OptionButton(
                  "Weekly",
                  onTap: () {
                    setState(() {
                      filteredCardDetails = categorizeItems('Weekly');
                    });
                  },
                ),
                OptionButton(
                  "Monthly",
                  onTap: () {
                    setState(() {
                      filteredCardDetails = categorizeItems('Monthly');
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredCardDetails.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/Elements/nodata.png',
                            height: 320,
                            width: 320,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Data available!',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredCardDetails.length,
                      itemBuilder: (context, index) {
                        return CustomListTile(
                          id: filteredCardDetails.reversed.toList()[index]
                              ["id"],
                          date: filteredCardDetails.reversed.toList()[index]
                              ["date"],
                          work: filteredCardDetails.reversed.toList()[index]
                              ["work"],
                          isPaid: filteredCardDetails.reversed.toList()[index]
                              ["paymentStatus"],
                          onEdit: () {
                            // Handle edit
                          },
                          onDelete: () async {
                            String id = filteredCardDetails.reversed
                                .toList()[index]["id"]
                                .toString();

                            bool isCodeCorrect = await showSecretCodeDialog(
                                context, id, widget.cardId);

                            if (isCodeCorrect) {
                              setState(() {
                                filteredCardDetails.removeAt(index);
                              });
                            }
                          },
                          onTogglePaid: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm Payment Status"),
                                  content: const Text(
                                      "Are you sure you want to update the payment status?"),
                                  actions: [
                                    ElevatedButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                    ),
                                    ElevatedButton(
                                      child: const Text("Confirm"),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        String id = filteredCardDetails.reversed
                                            .toList()[index]["id"]
                                            .toString();
                                        bool isPaid = filteredCardDetails
                                                        .reversed
                                                        .toList()[index]
                                                    ["paymentStatus"] ==
                                                'Unpaid'
                                            ? false
                                            : true;
                                        firebaseApi.handleUpdatePaymentStatus(
                                            id, widget.cardId, isPaid);
                                        fetchData();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DataReviewPage(
                                title: widget.cardId.toUpperCase(),
                                cardDetails: filteredCardDetails.reversed
                                    .toList()[index],
                              ),
                            ));
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTask(
                title: widget.cardId.toUpperCase(),
              ),
            ),
          );

          if (result == true) {
            fetchData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<bool> showSecretCodeDialog(
    BuildContext context, String id, String title) async {
  String enteredCode = '';
  FirebaseApi firebaseApi = FirebaseApi();

  bool? result = await showDialog<bool>(
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
              Navigator.pop(context, false); // Close the dialog with false
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String? secretCode = await firebaseApi.getSecretCode(title);
              if (secretCode != null && enteredCode == secretCode) {
                handleDelete(title, id);
                Navigator.pop(context, true); // Close the dialog with true
              } else {
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

  // Return false if result is null (dialog was cancelled)
  return result ?? false;
}

void handleDelete(String title, String id) {
  FirebaseApi firebaseApi = FirebaseApi();
  firebaseApi.handleTileDelete(title, id);
}

class OptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  OptionButton(this.text, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(text),
    );
  }
}
