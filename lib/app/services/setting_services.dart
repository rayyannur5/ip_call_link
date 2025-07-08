import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingService extends GetxService {
  final _storage = GetStorage();
  final _key = 'connection_type';

  // Variabel reaktif untuk tipe koneksi
  final connectionType = 'Bluetooth'.obs;

  // Method ini bisa dipanggil di main.dart untuk inisialisasi
  Future<SettingService> init() async {
    // Membaca nilai terakhir dari local storage saat aplikasi dimulai
    connectionType.value = _storage.read(_key) ?? 'Bluetooth';
    return this;
  }

  // Method untuk menyimpan data
  void saveConnectionType(String type) {
    connectionType.value = type;
    _storage.write(_key, type);
  }
}