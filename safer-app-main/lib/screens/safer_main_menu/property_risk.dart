import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:safer/widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class PropertyRisk extends StatefulWidget {
  final String title;

  PropertyRisk({super.key, required this.title});

  @override
  _PropertyRiskState createState() {
    return _PropertyRiskState();
  }
}

class _PropertyRiskState extends State<PropertyRisk> {
  bool _loading = false;

  Map<String, int> _riskScore = {
    "buildingStructure": 0,
    "roofAge": 0,
    "elevation": 0,
    "flooding": 0,
    "drainage": 0,
    "waterDamage": 0,
    "window": 0,
    "sewage": 0,
    "waterSupply": 0,
    "fuelSupply": 0,
    "itemSecurity": 0,
    "treeFalling": 0,
  };

  String homeType = "";
  String buildingAge = "";

  @override
  void initState() {
    super.initState();
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor ?? "unknown-ios-id"; // provide fallback
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id ?? "unknown-android-id"; // provide fallback
    }
    return "unknown-device-id"; // fallback if neither
  }


  void senddata() async {
    setState(() {
      _loading = true;
    });
    await http.post(
      Uri.parse("https://stormassistance.research.uconn.edu/property_risk.php"),
      body: {
        "phoneID": await _getId(),
        "homeType": homeType.isEmpty ? "" : homeType,
        "buildingAge": buildingAge.isEmpty ? "" : buildingAge,
        "buildingStructure": _riskScore["buildingStructure"].toString(),
        "roofAge": _riskScore["roofAge"].toString(),
        "elevation": _riskScore["elevation"].toString(),
        "flooding": _riskScore["flooding"].toString(),
        "drainage": _riskScore["drainage"].toString(),
        "waterDamage": _riskScore["waterDamage"].toString(),
        "window": _riskScore["window"].toString(),
        "sewage": _riskScore["sewage"].toString(),
        "waterSupply": _riskScore["waterSupply"].toString(),
        "fuelSupply": _riskScore["fuelSupply"].toString(),
        "itemSecurity": _riskScore["itemSecurity"].toString(),
        "treeFalling": _riskScore["treeFalling"].toString(),
        "riskScore": "${_riskScore.values.reduce((sum, element) => sum + element)}",
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
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/house.png'),
                  ),
                  title: Container(
                    child: DropdownButton<String>(
                      value: homeType.isNotEmpty ? homeType : null,
                      hint: const Text('Home Type'),
                      isExpanded: true,
                      iconSize: 40.0,
                      items: ['Single Family Home', 'Multiple Dwelling Unit'].map((val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          homeType = val ?? "";
                        });
                      },
                    ),
                  ),
                  subtitle: Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Building Age',
                        suffixText: 'years',
                        contentPadding: EdgeInsets.only(left: 1),
                      ),
                      onChanged: (val) {
                        setState(() {
                          buildingAge = val;
                        });
                      },
                    ),
                  ),
                ),
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
                            AssetImage('assets/images/property-risk.png')),
                    title: Text('Property Risk in a Storm'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.black.withOpacity(1),
                            fontFamily: 'Raleway'),
                        text: 'Score the items below:',
                        children: <TextSpan>[
                          TextSpan(
                            text: '\n\nScoring Range: 0 - 60',
                          ),
                          TextSpan(
                            text:
                                '\n0 = no risk \t\t\t\t\t  1 = minimal risk \n2 = low risk \t\t\t  3 = medium risk\n4 = high risk \t\t\t 5 = very high risk',
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
                      color: Colors.black, fontSize: 20, fontFamily: 'Raleway'),
                  text:
                      'Your Risk Score: ${_riskScore.values.reduce((sum, element) => sum + element)}',
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
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 25,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Raleway'),
                    text: 'Building Structure',
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_riskScore["buildingStructure"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) => setState(
                      () => _riskScore["buildingStructure"] = value.toInt(),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 25,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Raleway'),
                    text: 'Age of the Roof',
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_riskScore["roofAge"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _riskScore["roofAge"] = value.toInt()),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 25,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Raleway'),
                    text: 'Property Elevation Level',
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_riskScore["elevation"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _riskScore["elevation"] = value.toInt()),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 25,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Raleway'),
                    text: 'Potential Flooding via Nearby River/Lake',
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_riskScore["flooding"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _riskScore["flooding"] = value.toInt()),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 25,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Raleway'),
                    text: 'Drainage System Functions',
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_riskScore["drainage"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _riskScore["drainage"] = value.toInt()),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 25,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Raleway'),
                    text: 'Potential Water Damage on Property',
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_riskScore["waterDamage"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _riskScore["waterDamage"] = value.toInt()),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 25,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Raleway'),
                    text: 'Window Protection from Storm',
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_riskScore["window"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _riskScore["window"] = value.toInt()),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 25,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Raleway'),
                    text: 'Sewage System',
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_riskScore["sewage"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _riskScore["sewage"] = value.toInt()),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 25,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Raleway'),
                    text: 'Water Supply',
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_riskScore["waterSupply"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _riskScore["waterSupply"] = value.toInt()),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 25,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Raleway'),
                    text: 'Heating/Cooking Fuel Supply',
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_riskScore["fuelSupply"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _riskScore["fuelSupply"] = value.toInt()),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 25,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Raleway'),
                    text: 'Boat/Outdoor Item Security',
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_riskScore["itemSecurity"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _riskScore["itemSecurity"] = value.toInt()),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 25,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Raleway'),
                    text: 'Tree Falling on House',
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SpinBox(
                    min: 0,
                    max: 5,
                    value: (_riskScore["treeFalling"] ?? 0).toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => (text == null || text.isEmpty) ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _riskScore["treeFalling"] = value.toInt()),
                  ),
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
                      color: Colors.black, fontSize: 20, fontFamily: 'Raleway'),
                  text:
                      'Your Risk Score: ${_riskScore.values.reduce((sum, element) => sum + element)}',
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
