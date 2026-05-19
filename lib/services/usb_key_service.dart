import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'web_download_stub.dart'
    if (dart.library.html) 'web_download_html.dart';

class UsbKeyService {
  static const String keyFileName = 'lemon.key';
  static const String keyContent = 'LEMON-ADMIN-SECURE-HANDSHAKE-2026';

  /// Scans for the lemon.key file on any connected drive (Windows only).
  /// Returns null on Web or non-Windows platforms.
  Future<String?> scanForPhysicalKey() async {
    if (kIsWeb) return null;

    try {
      if (Platform.isWindows) {
        for (var charCode = 'D'.codeUnitAt(0);
            charCode <= 'Z'.codeUnitAt(0);
            charCode++) {
          final driveLetter = String.fromCharCode(charCode);
          final drivePath = '$driveLetter:\\';
          final keyFile = File('$drivePath$keyFileName');

          try {
            if (await keyFile.exists()) {
              final content = await keyFile.readAsString();
              if (content.trim() == keyContent) {
                return drivePath;
              }
            }
          } catch (_) {
            // Drive might not be ready or accessible
            continue;
          }
        }
      }
    } catch (e) {
      debugPrint('Scanning error: $e');
    }

    return null;
  }

  /// Allows the user to manually pick the key file (fallback for Web/other).
  Future<bool> pickAndValidateKey() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.single.name == keyFileName) {
        final content = String.fromCharCodes(result.files.single.bytes!);
        return content.trim() == keyContent;
      }
    } catch (e) {
      debugPrint('Error picking key: $e');
    }
    return false;
  }

  /// Provisions a new USB security key.
  /// On Web: triggers a browser download of lemon.key.
  /// On Desktop: writes the key file to a user-selected directory.
  Future<bool> provisionUsbKey() async {
    if (kIsWeb) {
      return await downloadKeyFile(keyFileName, keyContent);
    }

    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select your USB drive root',
      );

      if (selectedDirectory != null) {
        final pathSeparator = Platform.isWindows ? '\\' : '/';
        final file = File('$selectedDirectory$pathSeparator$keyFileName');
        await file.writeAsString(keyContent);
        return true;
      }
    } catch (e) {
      debugPrint('Error provisioning USB: $e');
    }
    return false;
  }
}
