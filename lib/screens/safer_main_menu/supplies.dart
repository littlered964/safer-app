import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safer/widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class Supplies extends StatefulWidget {
  final String title;

  Supplies({super.key, required this.title});

  @override
  _SuppliesState createState() {
    return _SuppliesState();
  }
}

class _SuppliesState extends State<Supplies> {
  bool _loading = false;

  Map<String, int> _readinessScore = {
    "necessities": 0,
    "food": 0,
    "water": 0,
    "safety": 0,
    "medical": 0,
    "care": 0,
    "tools": 0,
    "communication": 0,
    "documents": 0,
    "power": 0,
  };

  @override
  void initState() {
    super.initState();
  }

  Future<String> _getId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor ?? "unknown-ios-id";
    } else if (Platform.isAndroid) {
      final androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id ?? "unknown-android-id";
    }
    return "unknown-device-id"; // fallback for other platforms
  }


  void senddata() async {
    setState(() {
      _loading = true;
    });
    await http.post(
      Uri.parse("https://stormassistance.research.uconn.edu/supplies.php"),
      body: {
        "phoneID": await _getId(),
        "necessities": _readinessScore["necessities"].toString(),
        "food": _readinessScore["food"].toString(),
        "water": _readinessScore["water"].toString(),
        "safety": _readinessScore["safety"].toString(),
        "medical": _readinessScore["medical"].toString(),
        "care": _readinessScore["care"].toString(),
        "tools": _readinessScore["tools"].toString(),
        "communication": _readinessScore["communication"].toString(),
        "documents": _readinessScore["documents"].toString(),
        "power": _readinessScore["power"].toString(),
        "readinessScore":
            "${_readinessScore.values.reduce((sum, element) => sum + element)}",
      },
    );
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
        ),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                ListTile(
                    leading: CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/green-check.png')),
                    title: const Text('Readiness for Emergency'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.black.withOpacity(1),
                            fontFamily: 'Raleway'),
                        text: 'Score the items below:',
                        children: <TextSpan>[
                          TextSpan(
                            text: '\n\nScoring Range: 0 - 50',
                          ),
                          TextSpan(
                            text:
                                '\n0 = not ready \t\t\t\t\t  1 = unsure how to prepare \n2 = have a plan\t\t\t  3 = getting ready\n4 = mostly ready \t\t\t 5 = totally ready',
                          ),
                        ],
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                ListTile(
                    title: RichText(
                        text: TextSpan(
                  style: TextStyle(
                      color: Colors.black, fontSize: 18, fontFamily: 'Raleway'),
                  text:
                      'Your Readiness Score: ${_readinessScore.values.reduce((sum, element) => sum + element)}',
                ))),
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                ListTile(
                    leading: CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/burger.png')),
                    title: const Text('Access to Emergency Necessities'),
                    subtitle: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              color: Colors.blue.withOpacity(1),
                              fontFamily: 'Raleway'),
                          text: 'Register Here',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launch(
                                  'https://biznet.ct.gov/cp-openclosewebservice/index.html');
                            }),
                    )),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_readinessScore["necessities"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) => setState(
                        () => _readinessScore["necessities"] = value.toInt()),
                  ),
                  padding: EdgeInsets.only(left: 10),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                ListTile(
                    leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/images/food.png')),
                    title: const Text('Food 3-5 Day Supply'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.black.withOpacity(1),
                            fontFamily: 'Raleway'),
                        text: '\n- Ready-to-eat Food',
                        children: <TextSpan>[
                          TextSpan(
                            text: '\n- Baby Food, if needed',
                          ),
                          TextSpan(
                            text: '\n- Special Diet Food, if needed',
                          ),
                          TextSpan(
                            text: '\n- Pet Food, if needed',
                          ),
                        ],
                      ),
                    )),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_readinessScore["food"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _readinessScore["food"] = value.toInt()),
                  ),
                  padding: EdgeInsets.only(left: 10),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                ListTile(
                    leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/images/water.png')),
                    title: const Text('Drinking Water: 3-5 Day Supply'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.black.withOpacity(1),
                            fontFamily: 'Raleway'),
                        text: '\n- Stock up Bottled Water',
                        children: <TextSpan>[
                          TextSpan(
                            text: '\n- 5 Gallons of Water each Person',
                          ),
                          TextSpan(
                            text: '\n- 5 Gallons of Water each Pet, if needed',
                          ),
                          TextSpan(
                            text: '\n- Collect water in Rain Barrels',
                          ),
                          TextSpan(
                            text: '\n- Fill up the Bathtub, if possible',
                          ),
                          TextSpan(
                            text: '\n- Fill Pots & Pans with Water',
                          ),
                        ],
                      ),
                    )),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_readinessScore["water"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) => setState(
                        () => _readinessScore["water"] = value.toInt()),
                  ),
                  padding: EdgeInsets.only(left: 10),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                ListTile(
                    leading: CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/safety.png')),
                    title: const Text('Personal Safety'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.black.withOpacity(1),
                            fontFamily: 'Raleway'),
                        text: '\n- First Aid Kit/Manual',
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                '\n- Insect Repellent (with DEET or Picaridin)',
                          ),
                          TextSpan(
                            text:
                                '\n- Long-sleeved/Legged Clothing Against Mosquito Bites',
                          ),
                        ],
                      ),
                    )),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_readinessScore["safety"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) => setState(
                        () => _readinessScore["safety"] = value.toInt()),
                  ),
                  padding: EdgeInsets.only(left: 10),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                ListTile(
                    leading: CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/medical.png')),
                    title: const Text('Medical Supply'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.black.withOpacity(1),
                            fontFamily: 'Raleway'),
                        text: '\n- Over-the-counter Medicine',
                        children: <TextSpan>[
                          TextSpan(
                            text: '\n- Prescription Medicines',
                          ),
                          TextSpan(
                            text: '\n- Medical Devices, if needed',
                          ),
                        ],
                      ),
                    )),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_readinessScore["medical"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _readinessScore["medical"] = value.toInt()),
                  ),
                  padding: EdgeInsets.only(left: 10),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                ListTile(
                    leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/images/care.png')),
                    title: const Text('Personal Care'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.black.withOpacity(1),
                            fontFamily: 'Raleway'),
                        text:
                            '\n- Personal Hygiene (Soap, Shampoo, Toothpaste, Sanitary Napkins, etc.)',
                        children: <TextSpan>[
                          TextSpan(
                            text: '\n- Sleeping Bags or Blankets',
                          ),
                          TextSpan(
                            text:
                                '\n- Disposable Cleaning Supplies (Baby Wipes, Dry Shampoos, etc.)',
                          ),
                        ],
                      ),
                    )),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_readinessScore["care"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _readinessScore["care"] = value.toInt()),
                  ),
                  padding: EdgeInsets.only(left: 10),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                ListTile(
                    leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/images/tools.png')),
                    title: const Text('Handy Tools'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.black.withOpacity(1),
                            fontFamily: 'Raleway'),
                        text: '\n- Manual Can Opener',
                        children: <TextSpan>[
                          TextSpan(
                            text: '\n- Flashlights',
                          ),
                          TextSpan(
                            text: '\n- Batteries',
                          ),
                        ],
                      ),
                    )),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_readinessScore["tools"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _readinessScore["tools"] = value.toInt()),
                  ),
                  padding: EdgeInsets.only(left: 10),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                ListTile(
                    leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/images/phone.png')),
                    title: const Text('Communication Devices'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.black.withOpacity(1),
                            fontFamily: 'Raleway'),
                        text: '\n- Fully-charged Cellular Phone',
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                '\n- Battery-powered Radio and Extra Batteries',
                          ),
                          TextSpan(
                            text: '\n- Special Diet Food, if needed',
                          ),
                          TextSpan(
                            text: '\n- Pet Food, if needed',
                          ),
                        ],
                      ),
                    )),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_readinessScore["communication"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) => setState(
                      () => _readinessScore["communication"] = value.toInt(),
                    ),
                  ),
                  padding: EdgeInsets.only(left: 10),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                ListTile(
                    leading: CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/documents.png')),
                    title: const Text('Important Documents'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.black.withOpacity(1),
                            fontFamily: 'Raleway'),
                        text: '\n- Waterproofed Insurance/ID Cards',
                        children: <TextSpan>[
                          TextSpan(
                            text: '\n- Waterproofed Medical Records, if needed',
                          ),
                        ],
                      ),
                    )),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_readinessScore["documents"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) => setState(
                      () => _readinessScore["documents"] = value.toInt(),
                    ),
                  ),
                  padding: EdgeInsets.only(left: 10),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                ListTile(
                    leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/images/power.png')),
                    title: const Text('Power Supply'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.black.withOpacity(1),
                            fontFamily: 'Raleway'),
                        text: '\n- Power Generator',
                        children: <TextSpan>[
                          TextSpan(
                            text: '\n- Gasoline in Cans',
                          ),
                        ],
                      ),
                    )),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_readinessScore["power"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) => setState(
                      () => _readinessScore["power"] = value.toInt(),
                    ),
                  ),
                  padding: EdgeInsets.only(left: 10),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                ListTile(
                    title: RichText(
                        text: TextSpan(
                  style: TextStyle(
                      color: Colors.black, fontSize: 18, fontFamily: 'Raleway'),
                  text:
                      'Your Readiness Score: ${_readinessScore.values.reduce((sum, element) => sum + element)}',
                ))),
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 15,
              bottom: 15,
            ),
            child: AppButton(
              onPressed: () {
                senddata();
              },
              loading: _loading,
              disableTouchWhenLoading: true,
              text: 'Submit',
            ),
          )
        ],
      ),
    );
  }
}
