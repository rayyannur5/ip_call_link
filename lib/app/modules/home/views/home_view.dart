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
      floatingActionButton: SizedBox(
        width: Get.width - 40,
        child: Obx(() {
          return ElevatedButton.icon(
            onPressed: controller.isConnected.value ? () {} : null,
            icon: Icon(Icons.save),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            label: Text('Save'),
          );
        }),
      ),
      body: Container(
        height: Get.height,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage(ImageConstant.imgBg1), fit: BoxFit.cover)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 80),
              Padding(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: InkWell(
                  onTap: controller.showDeviceScannerSheet,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(150), borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        Obx(() {
                          return Text(controller.isConnected.value ? 'Device' : 'No Connection', style: TextStyle(fontWeight: FontWeight.bold));
                        }),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(color: Colors.grey.withAlpha(150), borderRadius: BorderRadius.circular(5)),
                          child: Obx(() => Text(controller.isConnected.value ? 'Connected' : 'Disconnected')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white.withAlpha(150), borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Obx(() {
                  if (controller.isConnected.value) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('010101 (2W Devices)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Column(
                          children: controller.deviceData.entries.map((entry) {
                            // `entry.key` adalah "IP", "SSID", dll.
                            // `entry.value` adalah "192.168.0.145", "IPCallServer", dll.
                            const keyDisabled = ['IP', 'Mac Addr', 'WiFi Strength', 'Volume', 'Mic Volume'];
                            return _itemCard(
                              entry.key,
                              entry.value,
                              keyDisabled.contains(entry.key)
                                  ? null
                                  : () {
                                // Aksi saat tombol edit ditekan
                                _showEditBottomSheet(entry.key, entry.value);
                              },
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
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                              child: Text('Test Buzzer'),
                            ),
                            FilledButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              child: Text('Test LED'),
                            ),
                            FilledButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              child: Text('Reboot'),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Center(child: Text('No Connection', style: Get.textTheme.headlineMedium));
                  }
                }),
              ),
              SizedBox(height: 40),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (kode untuk handle & title bottom sheet) ...
            Text(key, style: Get.textTheme.headlineSmall),
            SizedBox(height: 15),
            TextField(controller: textController, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Ketik nilai baru')),
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
    );
  }
}
