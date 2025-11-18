import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ip_call_link/app/core/utils/image_constant.dart';
import 'package:ip_call_link/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Image.asset(ImageConstant.imgLogo),
        elevation: 0,
        backgroundColor: Colors.white.withAlpha(150),
        actions: [
          Text('Link', style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => Get.toNamed(Routes.SETTING), icon: Icon(Icons.settings)),
        ],
      ),
      body: Container(
        height: Get.height,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage(ImageConstant.imgBg1), fit: BoxFit.cover)),
        child: RefreshIndicator(
          onRefresh: () async => controller.sendSimpleMessage('get'),
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: InkWell(
                  onTap: controller.showDeviceScannerSheet,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(150),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Obx(() {
                          if (controller.isConnected.value) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(controller.connectedDevice.value!.advName, style: Get.textTheme.labelLarge),
                                Text(controller.connectedDevice.value!.remoteId.str, style: Get.textTheme.labelSmall),
                              ],
                            );
                          } else {
                            return Text('Disconnected', style: TextStyle(fontWeight: FontWeight.bold));
                          }
                        }),
                        Spacer(),
                        Obx(() {
                          if (controller.isConnected.value) {
                            return Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(20),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text('Connected', style: TextStyle(color: Colors.green)),
                            );
                          } else {
                            return Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.grey.withAlpha(150),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text('Disconnected'),
                            );
                          }
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(150),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Obx(() {
                  final sortedEntries =
                      controller.deviceData.entries.toList()
                        ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
                  if (controller.isConnected.value) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(controller.deviceTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children:
                              sortedEntries.map((entry) {
                                final Map<String, dynamic> itemData = entry.value;

                                final String label = itemData['k'] ?? 'N/A';
                                final String value = itemData['v'] ?? '-';
                                final bool isWriteable = itemData['w'] ?? false;

                                return _itemCard(
                                  label,
                                  value,
                                  isWriteable
                                      ? () {
                                        // Aksi saat tombol edit ditekan
                                        _showEditBottomSheet(label, value);
                                      }
                                      : null,
                                );
                              }).toList(),
                        ),
                        SizedBox(height: 10),
                        Text('Controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FilledButton(
                              onPressed: () => controller.sendSimpleMessage('buzzer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Test Buzzer'),
                            ),
                            FilledButton(
                              onPressed: () => controller.sendSimpleMessage('led'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Test LED'),
                            ),
                            FilledButton(
                              onPressed: () => controller.sendSimpleMessage('reboot'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Reboot'),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                      ],
                    );
                  } else {
                    return Center(child: Text('No Connection', style: Get.textTheme.headlineMedium));
                  }
                }),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: Get.width,
                child: Obx( () {
                    return ElevatedButton.icon(
                      onPressed: controller.isConnected.value ? controller.save : null,
                      icon: Icon(Icons.save),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      label: Text('Save'),
                    );
                  }
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemCard(String label, String value, Function()? callback) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey.withAlpha(20)),
                child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey.withAlpha(20)),
                child: Text(value),
              ),
            ),
            Container(
              height: 25,
              decoration: BoxDecoration(color: Colors.grey.withAlpha(20)),
              child: IconButton(icon: Icon(Icons.edit, size: 18), onPressed: callback),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBottomSheet(String key, String currentValue) {
    final textController = TextEditingController(text: currentValue);
    Get.bottomSheet(
      backgroundColor: Colors.white,
      Container(
        width: Get.width,
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(key, style: Get.textTheme.headlineSmall),
              key == 'SSID'
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final List<dynamic> wifiList = controller.listWiFiDevices['wifi'] as List? ?? [];
                        return Column(
                          children:
                              wifiList.map((item) {
                                final String ssid = item.keys.first;
                                final String strength = item.values.first;

                                // 4. Buat ListTile dengan data yang benar.
                                return ListTile(
                                  leading: const Icon(Icons.wifi),
                                  title: Text(ssid),
                                  trailing: Text("$strength %"), // Strength sudah dalam format "80%"
                                  onTap: () {
                                    controller.updateDeviceValue("SSID", ssid);
                                    Get.back();
                                  },
                                );
                              }).toList(),
                        );
                      }),
                      SizedBox(height: 10),
                      SizedBox(
                        width: Get.width,
                        child: Obx(() {
                            return ElevatedButton.icon(
                              onPressed: controller.isScanning.value ? null : () {
                                controller.isScanning.value = true;
                                controller.sendSimpleMessage('scan-wifi');
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                              icon: controller.isScanning.value ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : Icon(Icons.search),
                              label: Text(controller.isScanning.value ? 'Scanning...' : 'Scan'),
                            );
                          }
                        ),
                      ),
                      Divider()
                    ],
                  )
                  : SizedBox(),
              SizedBox(height: 15),
              key == 'Device Type' ?
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: controller.deviceTypes.map((item) => ListTile(title: Text(item['label']!), onTap: () {
                    controller.updateDeviceValue("Device Type", item['value'] ?? "");
                    Get.back();
                  },)).toList(),
                )
                  : SizedBox(),
              key == 'Audio' || key == 'Device Type' ?
                  Row(
                    children: [],
                  )
              :
              TextField(
                controller: textController,
                keyboardType: key == 'ID' || key == 'IP' ? TextInputType.number : TextInputType.text,
                decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Ketik nilai baru', prefix: key == 'IP' ? Text('192.168.0.') : null),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: Get.width,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Panggil method update di controller
                    controller.updateDeviceValue(key, textController.text);
                    Get.back(); // Tutup bottom sheet
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  icon: Icon(Icons.save),
                  label: Text('Save'),
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
