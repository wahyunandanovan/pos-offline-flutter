import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        return await Permission.manageExternalStorage.request().isGranted;
      }
      return status.isGranted;
    }
    return true; // iOS doesn't need this permission
  }

  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (status.isDenied) {
        status = await Permission.manageExternalStorage.status;
      }
      return status.isGranted;
    }
    return true;
  }
}
