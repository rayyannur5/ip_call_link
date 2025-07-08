import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/setting_controller.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Setting'), actions: [
        Text('Link', style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(width: 20)
      ], centerTitle: true,
      backgroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Connection Type', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Obx(() => Text(controller.connectionType.value)),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Get.bottomSheet(
                Container(
                  padding: EdgeInsets.all(20),
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
                      Text('Connection Type', style: Get.textTheme.headlineSmall),
                      Text('Jenis koneksi yang akan digunakan untuk setting devices', style: Get.textTheme.labelSmall),
                      SizedBox(height: 10),
                      ListTile(
                        title: Text('Bluetooth', style: TextStyle(fontWeight: FontWeight.bold)),
                        leading: Icon(Icons.bluetooth),
                        subtitle: Text('Empty setting devices'),
                        onTap: () {
                          // di klik simpan di local storage sebagai bluetooth
                          controller.saveConnectionType('Bluetooth');
                        },
                      ),
                      Divider(),
                      ListTile(
                        enabled: false,
                        title: Text('WiFi', style: TextStyle(fontWeight: FontWeight.bold)),
                        leading: Icon(Icons.wifi),
                        subtitle: Text('Scan all devices are connected'),
                        onTap: () {
                          // di klik simpan di local storage sebagai wifi
                          controller.saveConnectionType('WiFi');
                        },
                      ),
                      Divider(),
                    ],
                  ),
                ),
                backgroundColor: Colors.white,
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
