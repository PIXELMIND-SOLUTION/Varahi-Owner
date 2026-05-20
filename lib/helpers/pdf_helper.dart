import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class PdfDownloadHelper {
  static Future<void> downloadAndOpenPdf(String pdfUrl, String fileName) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        await Permission.storage.request();
      }

      // Check if URL is full URL or needs base URL
      String fullUrl = pdfUrl;
      if (!pdfUrl.startsWith('http://') && !pdfUrl.startsWith('https://')) {
        // Add your base URL here - replace with your actual base URL
        const String baseUrl = 'https://varahibackend.varahiselfdrivecars.com';
        fullUrl = baseUrl + pdfUrl;
      }

      // Get directory to save file
      Directory directory;
      if (Platform.isAndroid) {
        directory = (await getExternalStorageDirectory())!;
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String savePath = '${directory.path}/$fileName';

      // Download file
      Dio dio = Dio();
      await dio.download(fullUrl, savePath);

      // Open the downloaded file
      await OpenFile.open(savePath);
    } catch (e) {
      throw Exception('Failed to download PDF: $e');
    }
  }
}
