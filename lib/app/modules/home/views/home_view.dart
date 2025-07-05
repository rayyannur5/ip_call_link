import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ip_call_link/app/core/utils/image_constant.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(ImageConstant.imgLogo),
        backgroundColor: Colors.white,
        actions: [
          Text(
            'Link',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed('setting'),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageConstant.imgBg1),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(150),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('010101 (2W Devices)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 10),
                    _itemCard('ID', '1234567890', () {}),
                    _itemCard('IP', '192.168.0.145', () {}),
                    _itemCard('IP Current', '192.168.0.145', () {}),
                    _itemCard('Mac Addr', '00:1B:44:11:3A:B7', () {}),
                    _itemCard('SSID', 'IPCallServer', () {}),
                    _itemCard('Password', 'ipcall123', () {}),
                    _itemCard('WiFi Strength', '80%', () {}),
                    _itemCard('Volume', '100%', () {}),
                    _itemCard('Mic Volume', '100%', () {}),
                    SizedBox(height: 10),
                    Text('Controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FilledButton(onPressed: () {}, child: Text('Test Buzzer')),
                        FilledButton(onPressed: () {}, child: Text('Test LED'))
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              width: Get.width - 40,
              child: FilledButton(onPressed: () {}, child: Text('Save')),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _itemCard(String label, String value, Function() callback) {
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
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(20)
                ),
                child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(20)
                ),
                child: Text(value),
              ),
            ),
            Container(
              height: 25,
              decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(20)
              ),
              child: IconButton(icon: Icon(Icons.edit, size: 18),  onPressed: (){}),
            )

          ],
        ),
      ),
    );
  }

}
