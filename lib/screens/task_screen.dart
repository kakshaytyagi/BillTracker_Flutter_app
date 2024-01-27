import 'dart:io';

import 'package:Billtracker/screens/PdfViewerScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BorderlessTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  BorderlessTextField({
    required this.hintText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return TextField(
      controller: controller,
      style: TextStyle(color: theme.textTheme.bodyLarge!.color),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: theme.hintColor),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
    );
  }
}

class BorderTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  BorderTextField({
    required this.hintText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
          color: Colors.white), // Set permanent white text color
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
            color: Colors.white), // Set permanent white hint text color
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}

class AddTask extends StatefulWidget {
  final String title;

  AddTask({
    required this.title,
  });

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  String? selectedValue;
  String? paymentStatus = 'Unpaid';
  bool hasSelectedImage = false;
  late File selectedImage;
  String? selectedFileType;
  String? imageUrl;
  double uploadProgress = 0.0;
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  } // Added for tracking upload progress

  TextEditingController taskNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController gradeController = TextEditingController();
  TextEditingController trucksController = TextEditingController();
  TextEditingController packetController = TextEditingController();
  TextEditingController materialController = TextEditingController();
  TextEditingController moneyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 45, vertical: 5),
                  child: Text(
                    'Create new task',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 45, vertical: 5),
                  child: Text(
                    'Task Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 45, vertical: 1),
                  child: BorderTextField(
                    hintText: 'Enter task name',
                    controller: taskNameController,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Additional Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        readOnly: true,
                                        onTap: () => _selectDate(context),
                                        controller: TextEditingController(
                                          text: selectedDate != null
                                              ? DateFormat('yyyy-MM-dd')
                                                  .format(selectedDate!)
                                              : 'Select Date',
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: 'Select Date',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.calendar_today),
                                      onPressed: () => _selectDate(context),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          BorderlessTextField(
                            hintText: 'Quantity',
                            controller: quantityController,
                          ),
                          const SizedBox(height: 18),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: const Text('RMC'),
                                      value: 'RMC',
                                      groupValue: selectedValue,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedValue = value;
                                        });
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: const Text('Cement'),
                                      value: 'CEMENT',
                                      groupValue: selectedValue,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedValue = value;
                                        });
                                      },
                                      controlAffinity: ListTileControlAffinity
                                          .leading, // This places the tick box to the leading side
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: const Text('Sanitory'),
                                      value: 'SANITORY',
                                      groupValue: selectedValue,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedValue = value;
                                        });
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: const Text('Others'),
                                      value: 'Others',
                                      groupValue: selectedValue,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedValue = value;
                                        });
                                      },
                                      controlAffinity: ListTileControlAffinity
                                          .leading, // This places the tick box to the leading side
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (selectedValue == "RMC")
                            Row(
                              children: [
                                Expanded(
                                  child: BorderlessTextField(
                                    hintText: 'Grade (RMC)',
                                    controller: gradeController,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: BorderlessTextField(
                                    hintText: 'No. of Trucks',
                                    controller: trucksController,
                                  ),
                                ),
                              ],
                            )
                          else if (selectedValue == "CEMENT")
                            Row(
                              children: [
                                Expanded(
                                  child: BorderlessTextField(
                                    hintText: 'Material',
                                    controller: materialController,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: BorderlessTextField(
                                    hintText: 'No. of Packets',
                                    controller: packetController,
                                  ),
                                ),
                              ],
                            )
                          else if (selectedValue == "Others" ||
                              selectedValue == "SANITORY")
                            BorderlessTextField(
                              hintText: 'Material (Sanitory or Hardware)',
                              controller: materialController,
                            ),
                          const SizedBox(height: 18),
                          // Common fields
                          BorderlessTextField(
                            hintText: 'Money',
                            controller: moneyController,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButton<String>(
                                  value: paymentStatus,
                                  onChanged: (value) {
                                    setState(() {
                                      paymentStatus = value;
                                    });
                                  },
                                  items: ['Paid', 'Unpaid'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(width: 23),
                              GestureDetector(
                                onTap: () {
                                  _previewImage();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.grey,
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              GestureDetector(
                                onTap: () {
                                  _showImageSourceModal(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors
                                        .grey, // Adjust the color based on your design
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 17),
                          ElevatedButton(
                            onPressed: () {
                              _submitTask();
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue, // Text color
                              elevation: 8, // Elevation (shadow)
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Rounded corners
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10), // Vertical padding
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            height: hasSelectedImage ? 50 : 0,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                LinearProgressIndicator(
                                  minHeight: 20,
                                  value: uploadProgress,
                                  backgroundColor: Colors.blueGrey[200]!,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(255, 125, 240, 105),
                                  ),
                                ),
                                if (uploadProgress <
                                    1.0) // Only show text when not fully loaded
                                  const Text(
                                    'Uploading...',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Storage'),
                onTap: () async {
                  Navigator.pop(context);
                  final FilePickerResult? pickedFile =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                  );

                  if (pickedFile != null) {
                    setState(() {
                      hasSelectedImage = true;
                      selectedImage = File(pickedFile.files.single.path!);
                      String fileExtension =
                          pickedFile.files.single.extension!.toLowerCase();
                      if (fileExtension == 'jpg' ||
                          fileExtension == 'jpeg' ||
                          fileExtension == 'png') {
                        selectedFileType = 'image';
                      } else if (fileExtension == 'pdf') {
                        selectedFileType = 'pdf';
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Invalid File Type'),
                              content: const Text(
                                  '(jpg, jpeg, png, PDF) files are allowed.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    });
                  } else {}
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _previewImage() {
    if (selectedFileType == 'pdf') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('PDF Preview'),
            content: const Text('Sorry! PDF preview Not Available'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    } else if (hasSelectedImage && selectedImage != null) {
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
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.contain,
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
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
                    'Please Select a File!',
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
          );
        },
      );
    }
  }

  Future<void> _uploadFile(String title, String cardId) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference referenceRoot = storage.ref();
      Reference referenceDirFiles = referenceRoot.child('bills/$title');
      String uniqueFileName = title + cardId;
      Reference referenceFileToUpload = referenceDirFiles.child(uniqueFileName);

      UploadTask uploadTask = referenceFileToUpload.putFile(
        File(selectedImage.path),
        SettableMetadata(
          contentType:
              selectedFileType == 'image' ? 'image/jpeg' : 'application/pdf',
        ),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setState(() {
          uploadProgress = progress;
        });
      });

      await uploadTask;
      imageUrl = await referenceFileToUpload.getDownloadURL();
      setState(() {
        uploadProgress = 1.0;
      });
    } catch (error) {}
  }

  Future<void> _submitTask() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot<Map<String, dynamic>> counterSnapshot = await firestore
          .collection('counters')
          .doc(widget.title.toUpperCase())
          .get();

      int currentCount = counterSnapshot.data()?['count'] ?? 0;

      int nextCount = currentCount + 1;
      String documentId = nextCount.toString();

      await firestore
          .collection('counters')
          .doc(widget.title.toUpperCase())
          .set({
        'count': nextCount,
      });

      if (hasSelectedImage) {
        await _uploadFile(widget.title, nextCount.toString());
      }

      await firestore
          .collection(widget.title.toUpperCase())
          .doc(documentId)
          .set({
        'taskName': taskNameController.text,
        'quantity': quantityController.text,
        'selectedValue': selectedValue,
        'grade': gradeController.text,
        'trucks': trucksController.text,
        'packets': packetController.text,
        'material': materialController.text,
        'money': moneyController.text,
        'paymentStatus': paymentStatus,
        'billingDate': selectedDate,
        'date': DateTime.now(),
        'imageUrl': imageUrl,
      });

      Navigator.pop(context, true);
    } catch (e) {}
  }
}
