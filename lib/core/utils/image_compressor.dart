import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressor {
  static Future<String> compressImage(String filePath) async {
    final dir = await getTemporaryDirectory();

    final targetPath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${path.basename(filePath)}';

    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 60, // adjust 50–70 if needed
    );

    return result!.path;
  }

  static Future<List<String>> compressImages(List<String> paths) async {
    List<String> compressedPaths = [];

    for (final p in paths) {
      final compressed = await compressImage(p);
      compressedPaths.add(compressed);
    }

    return compressedPaths;
  }
}
