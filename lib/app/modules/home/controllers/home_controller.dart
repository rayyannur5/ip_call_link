import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../services/setting_services.dart';
import '../../setting/controllers/setting_controller.dart';


class HomeController extends GetxController {
  final SettingService settingService = Get.find<SettingService>();

  /// real
  final RxList<ScanResult> scanResults = <ScanResult>[].obs;
  final RxMap<String, dynamic> deviceData = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> listWiFiDevices = <String, dynamic>{}.obs;

  /// dummy
  // final RxList<Map<String, dynamic>> scanResults = <Map<String, dynamic>>[].obs;

  final isScanning = false.obs;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  final Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  final isConnected = false.obs;

  BluetoothCharacteristic? targetCharacteristic;
  final String SERVICE_UUID = '12345678-1234-5678-1234-56789abcdef0';
  final String CHAR_UUID    = '12345678-1234-5678-1234-56789abcdef1';

  final List<Map<String, String>> deviceTypes = [
    {'label': 'BED', 'value': 'BED'},
    {'label': 'TOILET', 'value': 'TOILET'},
    {'label': 'LAMPP', 'value': 'LAMPP'},
    {'label': 'UNREGISTERED', 'value': ''}, // empty string value
  ];


  @override
  void onInit() {
    super.onInit();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        // Setiap kali ada hasil baru, update list kita
        scanResults.value = results;
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
      // // Jeda 2 detik untuk simulasi proses scan
      // await Future.delayed(const Duration(seconds: 2));
      //
      // // Buat data dummy dalam bentuk Map
      // final dummyData = [
      //   {'name': 'JBL Speaker', 'id': '0A:1B:2C:3D:4E:5F', 'rssi': -50},
      //   {'name': 'Mi Band 6', 'id': 'FF:EE:DD:CC:BB:AA', 'rssi': -65},
      //   {'name': 'NurseCall 2W', 'id': '11:22:33:44:55:66', 'rssi': -80},
      // ];
      //
      // // Masukkan data dummy ke list reaktif
      // scanResults.value = dummyData;

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
    deviceData.clear();

    // Mulai dengarkan perubahan status koneksi SEBELUM connect
    _connectionStateSubscription = device.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.connected) {
        isConnected.value = true;
        connectedDevice.value = device;
        Get.snackbar("Sukses", "Terhubung ke ${device.platformName}");

        try {
          await device.requestMtu(512);
          print("✅ MTU size berhasil diubah ke 512.");
        } catch (e) {
          print("❌ Gagal mengubah MTU size: $e");
        }

        await _discoverAndSetupChannels(device);

      } else if (state == BluetoothConnectionState.disconnected) {
        isConnected.value = false;
        connectedDevice.value = null;
        Get.snackbar("Terputus", "Koneksi dengan perangkat terputus");
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
            Text('Click the scan button to search for active devices.', style: Get.textTheme.labelSmall),
            SizedBox(height: 10),
            SizedBox(
              width: Get.width,
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: isScanning.value ? null : scanDevices,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  icon:
                      isScanning.value
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
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
                    title: Text(device.device.advName),
                    subtitle: Text(device.device.remoteId.str),
                    trailing: Text("${device.rssi} dBm"),
                    onTap: () {
                      // 1. Langsung tutup BottomSheet terlebih dahulu
                      Get.back();
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (device.device != null) {
                          connectToDevice(device.device);
                        } else {

                          final dummyDeviceDetails = {
                            "ID": "1234567890",
                            "IP": "192.168.0.145",
                            "IP Current": "192.168.0.145",
                            "Mac Addr": device.device.advName.toString(), // Ambil dari data scan
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
    String? entryId;
    for (var entry in deviceData.entries) {
      if (entry.value['k'] == key) {
        entryId = entry.key;
        break;
      }
    }

    // Jika entri ditemukan, update nilainya di dalam Map tersebut
    if (entryId != null) {
      deviceData[entryId]!['v'] = value;
      // Panggil refresh() untuk memberitahu GetX agar update UI.
      // Ini penting karena kita mengubah data di dalam nested Map.
      deviceData.refresh();
    }
  }

  Future<void> _discoverAndSetupChannels(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == SERVICE_UUID) {
          for (var char in service.characteristics) {
            if (char.uuid.toString().toLowerCase() == CHAR_UUID) {
              targetCharacteristic = char;

              // **LANGKAH 1: AKTIFKAN NOTIFIKASI**
              // Ini memberitahu Pi bahwa kita mau menerima update.
              await char.setNotifyValue(true);

              // **LANGKAH 2: DENGARKAN STREAM DATA (NOTIFIKASI)**
              // `listen` akan berjalan setiap kali Pi mengirim notifikasi.
              char.value.listen((value) {
                if (value.isEmpty) return; // Abaikan data kosong

                final jsonString = utf8.decode(value);

                if(jsonString == 'scan-wifi') {
                  isScanning.value = false;
                  return;
                }

                try {
                  final decodedData = jsonDecode(jsonString);
                  if(decodedData.containsKey('a')) {
                    return;
                  }

                  if(decodedData.containsKey('wifi')) {
                    listWiFiDevices.value = decodedData;
                    return;
                  }

                  // Update RxMap kita, UI akan otomatis berubah
                  deviceData.addAll(Map<String, dynamic>.from(decodedData));
                  print("🔔 Notifikasi diterima: $decodedData");

                } catch(e) {
                  print("bukan data JSON : $jsonString");
                }

              });

              // **LANGKAH 3: LAKUKAN PEMBACAAN AWAL**
              // Setelah notifikasi aktif, kita minta data state saat ini.
              await char.read();

              return;
            }
          }
        }
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Gagal mencari service/characteristic: $e");
    }
  }

  void save() async {

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.white)),
      barrierDismissible: false,
    );

    try {
      // 2. Loop melalui setiap item di state lokal (deviceData)
      for (var entry in deviceData.entries) {
        final itemData = entry.value as Map<String, dynamic>;
        final bool isWriteable = itemData['w'] ?? false;

        // 3. Hanya proses dan kirim jika item tersebut 'writeable'
        if (isWriteable) {
          final key = itemData['k'];
          final value = itemData['v'];

          // 4. Buat perintah JSON untuk setiap item
          final commandMap = {
            "a": "set",
            "k": key,
            "v": value,
          };
          final commandJson = jsonEncode(commandMap);

          // 5. Kirim perintah ke Pi
          await targetCharacteristic!.write(utf8.encode(commandJson));
          print("✅ Data dikirim: $commandJson");

          // Beri jeda singkat antar perintah untuk stabilitas koneksi BLE
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      // Jika semua berhasil, tutup loading dan beri notifikasi sukses
      Get.back(); // Tutup dialog loading
      Get.snackbar("Sukses", "Semua konfigurasi berhasil disimpan.");

    } catch (e) {
      Get.back(); // Tutup dialog loading jika ada error
      Get.snackbar("Error", "Gagal menyimpan konfigurasi: $e");
      print("❌ Gagal menyimpan data: $e");
    }
  }

  void sendSimpleMessage(message) async {
    try {
      // String diubah menjadi List<int> (bytes) sebelum dikirim
      await targetCharacteristic!.write(utf8.encode(message));
      print("✅ $message berhasil dikirim");
      Get.snackbar("Sukses", "✅ $message berhasil dikirim");
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Gagal mengirim data: $e");
    }
  }

  String get deviceTitle {
    // Jika data masih kosong, tampilkan teks default
    if (deviceData.isEmpty) {
      return "No Device";
    }

    // Ambil nilai ID dari data
    String id = "Unknown ID";
    // Loop untuk mencari item dengan key "ID"
    for (var item in deviceData.values) {
      if (item['k'] == 'ID') {
        id = item['v'];
        break;
      }
    }

    // Cek apakah ada key "Volume" di dalam data
    bool isTwoWayDevice = false;
    for (var item in deviceData.values) {
      if (item['k'] == 'Volume') {
        isTwoWayDevice = true;
        break;
      }
    }

    // Tentukan jenis perangkat
    String deviceType = isTwoWayDevice ? "(2W Devices)" : "(1W Devices)";

    // Gabungkan semuanya
    return "$id $deviceType";
  }

}
