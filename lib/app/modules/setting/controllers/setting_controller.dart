import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../services/setting_services.dart';

class SettingController extends GetxController {

  final SettingService settingService = Get.find<SettingService>();

  @override
  void onInit() {
    super.onInit();
  }
  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  RxString get connectionType => settingService.connectionType;

  // 3. Method ini sekarang hanya meneruskan perintah ke service
  void saveConnectionType(String type) {
    settingService.saveConnectionType(type);
    Get.back(); // Tutup bottom sheet
  }
}
