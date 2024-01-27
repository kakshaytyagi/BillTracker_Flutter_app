import 'dart:io';
import 'package:Billtracker/screens/PdfViewerScreen.dart';
import 'package:Billtracker/widgets/DownloadingDialog.dart';
import 'package:flutter/material.dart';
import 'package:Billtracker/api/api_request.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class DataReviewPage extends StatelessWidget {
  final Map<String?, dynamic> cardDetails;
  final String title;

  DataReviewPage({required this.cardDetails, required this.title});

  FirebaseApi firebaseApi = FirebaseApi();
  File? selectedImage;
  File? selectedPdf;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String?, dynamic>>(
      future: firebaseApi.fetchAllDetails(title, cardDetails["id"].toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          Map<String?, dynamic> cardDetails = snapshot.data!;
          return buildDetailsPage(context, cardDetails);
        } else {
          return const Scaffold(body: Center(child: Text('No data available')));
        }
      },
    );
  }

  Widget buildDetailsPage(
      BuildContext context, Map<String?, dynamic> cardDetails) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        centerTitle: true,
        backgroundColor: Colors.blue, // Set your desired color
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _showShareDetailsDialog(context, cardDetails);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  DetailCard(label: 'ID:', value: cardDetails["id"].toString()),
                  DetailCard(
                      label: 'Date of Billing:',
                      value: cardDetails["billingDate"].toString()),
                  DetailCard(
                      label: 'Task Name:',
                      value: cardDetails["taskName"] ?? "N/A"),
                  DetailCard(
                      label: 'Quantity:',
                      value: cardDetails["quantity"] ?? "N/A"),
                  if (title == 'RMC')
                    DetailCard(
                        label: 'Grade:', value: cardDetails["grade"] ?? "N/A"),
                  if (title == 'RMC')
                    DetailCard(
                        label: 'Trucks:',
                        value: cardDetails["trucks"] ?? "N/A"),
                  if (title == 'CEMENT')
                    DetailCard(
                        label: 'material:',
                        value: cardDetails["material"] ?? "N/A"),
                  if (title == 'CEMENT')
                    DetailCard(
                        label: 'No. of Packets:',
                        value: cardDetails["packets"] ?? "N/A"),
                  if (title != 'RMC' && title != 'CEMENT')
                    DetailCard(
                        label: 'Material:',
                        value: cardDetails["material"] ?? "N/A"),
                  DetailCard(
                      label: 'Money:', value: cardDetails["money"] ?? "N/A"),
                  DetailCard(
                      label: 'Date:', value: cardDetails["date"].toString()),
                  DetailCard(
                      label: 'Payment Status:',
                      value: cardDetails["paymentStatus"] ?? "N/A"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (cardDetails['imageUrl'] == null ||
                        cardDetails['imageUrl'].toString().isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('File Not Available'),
                          content: Center(
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
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      if (await isPdf(cardDetails['imageUrl'])) {
                        _previewPdf(context, cardDetails['imageUrl']);
                      } else {
                        _previewImage(context, cardDetails['imageUrl']);
                      }
                    }
                  },
                  child: const Text('Preview'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (cardDetails['imageUrl'] == null ||
                        cardDetails['imageUrl'].toString().isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('File Not Available'),
                          content: Center(
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
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => DownloadingDialog(
                          docURL: cardDetails['imageUrl'].toString().trim(),
                        ),
                      );
                    }
                  },
                  child: const Text('Download'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShareDetailsDialog(
      BuildContext context, Map<String?, dynamic> cardDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID:', cardDetails["id"]),
                _buildDetailRow('Date of Billing:', cardDetails["billingDate"]),
                _buildDetailRow('Task Name:', cardDetails["taskName"] ?? "N/A"),
                _buildDetailRow('Quantity:', cardDetails["quantity"] ?? "N/A"),
                if (title == 'RMC')
                  _buildDetailRow('Grade:', cardDetails["grade"] ?? "N/A"),
                if (title == 'RMC')
                  _buildDetailRow('Trucks:', cardDetails["trucks"] ?? "N/A"),
                if (title == 'CEMENT')
                  _buildDetailRow(
                      'Material:', cardDetails["material"] ?? "N/A"),
                if (title == 'CEMENT')
                  _buildDetailRow(
                      'No. of Packets:', cardDetails["packets"] ?? "N/A"),
                if (title != 'RMC' && title != 'CEMENT')
                  _buildDetailRow(
                      'Material:', cardDetails["material"] ?? "N/A"),
                _buildDetailRow('Money:', cardDetails["money"] ?? "N/A"),
                _buildDetailRow('Date:', cardDetails["date"]),
                _buildDetailRow(
                    'Payment Status:', cardDetails["paymentStatus"] ?? "N/A"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                _shareDetails(context, cardDetails);
                Navigator.pop(context);
              },
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value?.toString() ?? "N/A"),
        ],
      ),
    );
  }

  void _shareDetails(
      BuildContext context, Map<String?, dynamic> cardDetails) async {
    String fileLink = cardDetails['imageUrl'];
    String detailsText = "Details:\n"
        "ID: ${cardDetails["id"]}\n"
        "Date of Billing: ${cardDetails["billingDate"]}\n"
        "Task Name: ${cardDetails["taskName"] ?? "N/A"}\n"
        "Quantity: ${cardDetails["quantity"] ?? "N/A"}\n";

    if (title == 'RMC') {
      detailsText += "Grade: ${cardDetails["grade"] ?? "N/A"}\n";
      detailsText += "Trucks: ${cardDetails["trucks"] ?? "N/A"}\n";
    } else if (title == 'CEMENT') {
      detailsText += "Material: ${cardDetails["material"] ?? "N/A"}\n";
      detailsText += "No. of Packets: ${cardDetails["packets"] ?? "N/A"}\n";
    } else {
      detailsText += "Material: ${cardDetails["material"] ?? "N/A"}\n";
    }

    detailsText += "Money: ${cardDetails["money"] ?? "N/A"}\n"
        "Date: ${cardDetails["date"]}\n"
        "Payment Status: ${cardDetails["paymentStatus"] ?? "N/A"}\n"
        "File Link: $fileLink";

    final RenderBox box = context.findRenderObject() as RenderBox;

    await Share.share(
      detailsText,
      subject: 'Details',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<bool> isPdf(String url) async {
    String? contentType = await getFileContentType(url);
    return contentType != null &&
        contentType.toLowerCase().contains('application/pdf');
  }

  Future<String?> getFileContentType(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      final contentType = response.headers['content-type'];
      return contentType;
    } catch (e) {
      return null;
    }
  }
}

void _previewPdf(BuildContext context, String pdfUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PdfViewerScreen(pdfUrl: pdfUrl),
    ),
  );
}

void _previewImage(BuildContext context, String imageUrl) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Error loading image');
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Close Preview',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DetailCard extends StatelessWidget {
  final String label;
  final dynamic value;

  DetailCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value?.toString() ?? "N/A",
                style: TextStyle(
                  fontSize: 16,
                  color: textColor, // Use the determined text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
