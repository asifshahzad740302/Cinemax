import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Screens/DownloadScreen.dart';

class TrailerController extends GetxController {
  var downloadedFiles = <FileSystemEntity>[].obs;
  var progress = 0.0.obs;
  var isDownloading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDownloads();
  }

  Future<void> loadDownloads() async {
    final dir = await getApplicationDocumentsDirectory();
    final directory = Directory(dir.path);
    List<FileSystemEntity> files = directory.listSync()
        .where((file) => file.path.endsWith('.mp4'))
        .toList();

    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    downloadedFiles.assignAll(files);
  }


  Future<void> deleteTrailer(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        await loadDownloads();
        Get.snackbar("Deleted", "Trailer removed from downloads",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not delete file");
    }
  }



  Future<void> startDownload(String ytUrl, String movieId) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/$movieId.mp4";

    if (File(filePath).existsSync()) {
      Get.snackbar("Info", "Trailer already downloaded!");
      return;
    }

    // 2. Start Download Flow
    try {
      isDownloading.value = true;
      Get.to(() => DownloadsScreen()); // Move to download screen

      var yt = YoutubeExplode();
      var manifest = await yt.videos.streamsClient.getManifest(ytUrl);
      var streamInfo = manifest.muxed.withHighestBitrate();

      await Dio().download(
        streamInfo.url.toString(),
        filePath,
        onReceiveProgress: (count, total) {
          progress.value = count / total;
        },
      );

      yt.close();
      isDownloading.value = false;
      await loadDownloads();
    } catch (e) {
      isDownloading.value = false;
      Get.snackbar("Error", "Download failed");
    }
  }
}