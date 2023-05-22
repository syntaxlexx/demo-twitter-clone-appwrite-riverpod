import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../contants/constants.dart';
import '../core/providers.dart';

final storageAPIProvider = Provider(
  (ref) => StorageAPI(
    storage: ref.watch(appwriteStorageProvider),
  ),
);

class StorageAPI {
  final Storage _storage;
  var logger = Logger();

  StorageAPI({required Storage storage}) : _storage = storage;

  Future<List<String>> uploadImages(List<File> files) async {
    List<String> imageLinks = [];

    try {
      for (final file in files) {
        final uploadedImage = await _storage.createFile(
          bucketId: AppwriteConstants.imagesBucket,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: file.path),
        );

        imageLinks.add(AppwriteConstants.imageUrl(uploadedImage.$id));
      }
    } catch (e) {
      logger.e(e);
    }

    return imageLinks;
  }
}
