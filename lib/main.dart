import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'app/services/setting_services.dart';

void main() async {

  // Inisialisasi dependency lain
  await GetStorage.init();

  // Daftarkan service Anda di sini agar selalu tersedia
  await Get.putAsync(() => SettingService().init());

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
