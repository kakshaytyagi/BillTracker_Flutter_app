import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class DownloadingDialog extends StatefulWidget {
  const DownloadingDialog({Key? key, required this.docURL}) : super(key: key);

  final String docURL;

  @override
  _DownloadingDialogState createState() => _DownloadingDialogState();
}

class _DownloadingDialogState extends State<DownloadingDialog> {
  double? _progress;

  @override
  void initState() {
    super.initState();
    startDownloading();
  }

  Future<void> startDownloading() async {
    try {
      FileDownloader.downloadFile(
        url: widget.docURL,
        onDownloadError: (String error) {
          Navigator.pop(context);
        },
        onDownloadCompleted: (path) {
          setState(() {
            _progress = null;
          });
          Navigator.pop(context); 
        },
        onProgress: (fileName, progress) {
          setState(() {
            _progress = progress;
          });
        },
      );
    } catch (e) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String downloadingProgress = (_progress ?? 0.0 * 100).toInt().toString();

    return AlertDialog(
      backgroundColor: Colors.black,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Downloading: $downloadingProgress%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
