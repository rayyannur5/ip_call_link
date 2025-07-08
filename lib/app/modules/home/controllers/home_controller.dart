import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../services/setting_services.dart';
import '../../setting/controllers/setting_controller.dart';


class HomeController extends GetxController {
  final SettingService settingService = Get.find<SettingService>();

  /// real
  // final RxList<ScanResult> scanResults = <ScanResult>[].obs;
  final RxMap<String, String> deviceData = <String, String>{}.obs;

  /// dummy
  final RxList<Map<String, dynamic>> scanResults = <Map<String, dynamic>>[].obs;

  final isScanning = false.obs;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  final Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  final isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        // Setiap kali ada hasil baru, update list kita
        // scanResults.value = results;
      },
      onError: (e) {
        print("Error mendengarkan hasil scan: $e");
      },
    );
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _scanResultsSubscription.cancel();
    _connectionStateSubscription?.cancel();
    super.onClose();
  }

  void scanDevices() {
    if (settingService.connectionType.value == 'Bluetooth') {
      _scanBluetoothDevices();
    } else {
      _scanWiFiDevices();
    }
  }

  _scanBluetoothDevices() async {
    if (isScanning.value) return;

    try {
      isScanning.value = true;
      scanResults.clear();

      /// real
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      /// dummy
      // Jeda 2 detik untuk simulasi proses scan
      await Future.delayed(const Duration(seconds: 2));

      // Buat data dummy dalam bentuk Map
      final dummyData = [
        {'name': 'JBL Speaker', 'id': '0A:1B:2C:3D:4E:5F', 'rssi': -50},
        {'name': 'Mi Band 6', 'id': 'FF:EE:DD:CC:BB:AA', 'rssi': -65},
        {'name': 'NurseCall 2W', 'id': '11:22:33:44:55:66', 'rssi': -80},
      ];

      // Masukkan data dummy ke list reaktif
      scanResults.value = dummyData;

    } catch (e) {
      Get.snackbar("Error", "Gagal memulai scan Bluetooth: $e");
    } finally {
      isScanning.value = false;
    }
  }

  void stopScan() {
    if (settingService.connectionType.value == 'Bluetooth') {
      FlutterBluePlus.stopScan();
      isScanning.value = false;
    } else {
      Get.snackbar("Info", "Fitur Scan WiFi belum diimplementasikan.");
    }
  }

  _scanWiFiDevices() {
    Get.snackbar("Info", "Fitur Scan WiFi belum diimplementasikan.");
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    // Hentikan scan sebelum mencoba konek
    await FlutterBluePlus.stopScan();

    // Mulai dengarkan perubahan status koneksi SEBELUM connect
    _connectionStateSubscription = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.connected) {
        isConnected.value = true;
        connectedDevice.value = device;
        Get.snackbar("Sukses", "Terhubung ke ${device.platformName}");
      } else if (state == BluetoothConnectionState.disconnected) {
        isConnected.value = false;
        connectedDevice.value = null;
        Get.snackbar("Terputus", "Koneksi dengan perangkat terputus", snackPosition: SnackPosition.BOTTOM);
        // Hentikan listener setelah terputus
        _connectionStateSubscription?.cancel();
      }
    });

    // Coba hubungkan ke perangkat
    try {
      await device.connect(timeout: Duration(seconds: 15));
    } catch (e) {
      Get.snackbar("Error", "Gagal terhubung: $e");
      // Jika gagal, batalkan listener
      await _connectionStateSubscription?.cancel();
    }
  }

  /// Method untuk memutus koneksi
  Future<void> disconnectFromDevice() async {
    if (connectedDevice.value != null) {
      await connectedDevice.value!.disconnect();
      // Listener akan otomatis menangani update state menjadi disconnected
    }
  }

  void showDeviceScannerSheet() {
    Get.bottomSheet(
      Container(
        width: Get.width,
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 10,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Get.theme.hoverColor, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),
            Text('Scan Devices', style: Get.textTheme.headlineSmall),
            Text('Klik tombol scan untuk mencari devices yang sedang aktif.', style: Get.textTheme.labelSmall),
            SizedBox(height: 10),
            SizedBox(
              width: Get.width,
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: isScanning.value ? null : scanDevices,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  icon:
                      isScanning.value
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Icon(Icons.search),
                  label: Text(isScanning.value ? 'Scanning...' : 'Scan'),
                ),
              ),
            ),
            SizedBox(height: 10),
            Obx(() => Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: scanResults.length,
                itemBuilder: (context, index) {
                  final device = scanResults[index];
                  return ListTile(
                    title: Text(device['name']),
                    subtitle: Text(device['id']),
                    trailing: Text("${device['rssi']} dBm"),
                    onTap: () {
                      // 1. Langsung tutup BottomSheet terlebih dahulu
                      Get.back();
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (device['device'] != null) {
                          connectToDevice(device['device']!);
                        } else {

                          final dummyDeviceDetails = {
                            "ID": "1234567890",
                            "IP": "192.168.0.145",
                            "IP Current": "192.168.0.145",
                            "Mac Addr": device['id'].toString(), // Ambil dari data scan
                            "SSID": "IPCallServer",
                            "Password": "ipcall123",
                            "WiFi Strength": "80%",
                            "Volume": "100%",
                            "Mic Volume": "90%",
                          };

                          // Masukkan data ke controller
                          deviceData.value = dummyDeviceDetails;
                          // Ubah status menjadi terhubung
                          isConnected.value = true;

                          Get.snackbar(
                            "Info",
                            "Tidak bisa terhubung ke perangkat dummy."
                          );
                        }
                      });
                    },
                  );
                },
              ),
            )),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  void updateDeviceValue(String key, String value) {
    // 1. Langsung update state lokal (RxMap) untuk UI instan
    //    Obx akan otomatis mendeteksi perubahan ini dan me-render ulang UI.
    deviceData[key] = value;

    // // 2. Setelah state lokal terupdate, kirim perintah ke Pi di latar belakang
    // final commandMap = {
    //   "action": "set",
    //   "key": key,
    //   "value": value,
    // };
    // final commandJson = jsonEncode(commandMap);
    //
    // // Panggil method untuk mengirim data tanpa mengganggu UI
    // await writeDataToPi(commandJson);
  }
}
