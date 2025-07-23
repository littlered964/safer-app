import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safer/widgets/widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class PersonalRisk extends StatefulWidget {
  final String title;

  PersonalRisk({super.key, required this.title});

  @override
  _PersonalRiskState createState() {
    return _PersonalRiskState();
  }
}

class _PersonalRiskState extends State<PersonalRisk> {
  bool _loading = false;

  List<String> _specialNeeds = [];
  List<String> _priorFlooding = [];
  List<String> _priorDamages = [];
  List<String> _priorDangers = [];
  List<String> _priorOutage = [];
  List<String> _safePlace = [];
  List<String> _doYouHave = [];

  Map<String, int> _riskScore = {
    "specialNeeds": 0,
    "priorFlooding": 0,
    "priorDamages": 0,
    "priorDangers": 0,
    "priorOutage": 0,
    "safePlace": 0,
    "doYouHave": 0,
  };

  final Map<String, List<String>> _headingData = {
    "specialNeeds": [
      "Medication",
      "Walking",
      "Bathing",
      "Wheelchair",
      "Breathing",
      "Feeding",
      "Cooking",
      "Cleaning",
      "Young Children",
      "Pets",
    ],
    "priorFlooding": [
      "Front/Back Yard",
      "Ground Floor",
      "Basement",
      "Street",
      "Neighborhood",
    ],
    "priorDamages": [
      "Roof",
      "Gutters",
      "Window(s)",
      "Door(s)",
      "Garage(s)",
      "House Foundation",
      "Out Buildings",
    ],
    "priorDangers": [
      "Fallen Trees near Houses",
      "Carbon Monoxide Leak",
      "Propane Tank Leak",
      "Sewage Overflow",
      "Mudslide Nearby",
      "Sinkhole Nearby",
      "Electrical Pole Fire",
      "Fallen Electrical Wires",
    ],
    "priorOutage": [
      "Water Outage",
      "Sanitation System Outage",
      "Electrical Power Outage",
      "Air Conditioning Outage",
      "Heating System Outage",
    ],
    "safePlace": [
      "Windowless Hallway",
      "Windowless Closet",
      "Bathtub in Windowless Room",
      "Underground Shelter",
      "Neighbor's House",
      "Friend's House",
      "Relative's House",
    ],
    "doYouHave": [
      "Functional Car",
      "Functional Smartphone",
      "Functional Fixed-line Phone",
      "Operable Radio with Batteries",
      "Electrical Generator",
      "Evacuation Plan",
      "Disaster Kit",
    ]
  };

  @override
  void initState() {
    super.initState();
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor ?? "unknown-ios-id";
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id ?? "unknown-android-id"; // updated here
    }
    return "unknown-device-id"; // fallback
  }



  void senddata() async {
    setState(() {
      _loading = true;
    });
    await http.post(
      Uri.parse("https://stormassistance.research.uconn.edu/personal_risk.php"),
      body: {
        "phoneID": await _getId(),
        "specialNeeds": _specialNeeds.join(", "),
        "priorFlooding": _priorFlooding.join(", "),
        "priorDamages": _priorDamages.join(", "),
        "priorDangers": _priorDangers.join(", "),
        "priorOutage": _priorOutage.join(", "),
        "safePlaces": _safePlace.join(", "),
        "resAvailable": _doYouHave.join(", "),
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
                    leading: CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/safety.png')),
                    title: Text('Personal Risk in a Storm'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.black.withOpacity(1),
                            fontFamily: 'Raleway'),
                        text: 'Select your risk factors below:',
                        children: <TextSpan>[
                          TextSpan(
                            text: '\n\nScoring Range: 0 - 49',
                          )
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
                    left: 15,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Raleway'),
                    text: 'Special Needs Care',
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: (_headingData["specialNeeds"] ?? []).map((item) {
                      final bool selected = _specialNeeds.contains(item);
                      return SizedBox(
                        height: 32,
                        child: FilterChip(
                          selected: selected,
                          label: Text(item, style: TextStyle(fontFamily: 'Fonto')),
                          backgroundColor: Color.fromARGB(255, 130, 200, 21),
                          onSelected: (value) {
                            selected ? _specialNeeds.remove(item) : _specialNeeds.add(item);
                            setState(() {
                              _specialNeeds = _specialNeeds;
                              _riskScore["specialNeeds"] = _specialNeeds.length;
                            });
                          },
                        ),
                      );
                    }).toList(),
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
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Raleway'),
                    text: 'Prior Flooding',
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: (_headingData["priorFlooding"] ?? []).map((item) {
                      final bool selected = _priorFlooding.contains(item);
                      return SizedBox(
                        height: 32,
                        child: FilterChip(
                          selected: selected,
                          label: Text(item, style: TextStyle(fontFamily: 'Fonto')),
                          backgroundColor: Color.fromARGB(255, 130, 200, 21),
                          onSelected: (value) {
                            selected ? _priorFlooding.remove(item) : _priorFlooding.add(item);
                            setState(() {
                              _priorFlooding = _priorFlooding;
                              _riskScore["priorFlooding"] = _priorFlooding.length;
                            });
                          },
                        ),
                      );
                    }).toList(),

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
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Raleway'),
                    text: 'Prior Damages',
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: (_headingData["priorDamages"] ?? []).map((item) {
                      final bool selected = _priorDamages.contains(item);
                      return SizedBox(
                        height: 32,
                        child: FilterChip(
                          selected: selected,
                          label: Text(item, style: TextStyle(fontFamily: 'Fonto')),
                          backgroundColor: Color.fromARGB(255, 130, 200, 21),
                          onSelected: (value) {
                            selected ? _priorDamages.remove(item) : _priorDamages.add(item);
                            setState(() {
                              _priorDamages = _priorDamages;
                              _riskScore["priorDamages"] = _priorDamages.length;
                            });
                          },
                        ),
                      );
                    }).toList(),

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
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Raleway'),
                    text: 'Prior Dangers',
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: (_headingData["priorDangers"] ?? []).map((item) {
                      final bool selected = _priorDangers.contains(item);
                      return SizedBox(
                        height: 32,
                        child: FilterChip(
                          selected: selected,
                          label: Text(item, style: TextStyle(fontFamily: 'Fonto')),
                          backgroundColor: Color.fromARGB(255, 130, 200, 21),
                          onSelected: (value) {
                            selected ? _priorDangers.remove(item) : _priorDangers.add(item);
                            setState(() {
                              _priorDangers = _priorDangers;
                              _riskScore["priorDangers"] = _priorDangers.length;
                            });
                          },
                        ),
                      );
                    }).toList(),
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
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Raleway'),
                    text: 'Prior Outage',
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: (_headingData["priorOutage"] ?? []).map((item) {
                      final bool selected = _priorOutage.contains(item);
                      return SizedBox(
                        height: 32,
                        child: FilterChip(
                          selected: selected,
                          label: Text(item, style: TextStyle(fontFamily: 'Fonto')),
                          backgroundColor: Color.fromARGB(255, 130, 200, 21),
                          onSelected: (value) {
                            selected ? _priorOutage.remove(item) : _priorOutage.add(item);
                            setState(() {
                              _priorOutage = _priorOutage;
                              _riskScore["priorOutage"] = _priorOutage.length;
                            });
                          },
                        ),
                      );
                    }).toList(),
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
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Raleway'),
                    text: 'Lack a Safe Place Below to Hide',
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: (_headingData["safePlace"] ?? []).map((item) {
                      final bool selected = _safePlace.contains(item);
                      return SizedBox(
                        height: 32,
                        child: FilterChip(
                          selected: selected,
                          label: Text(item, style: TextStyle(fontFamily: 'Fonto')),
                          backgroundColor: Color.fromARGB(255, 130, 200, 21),
                          onSelected: (value) {
                            selected ? _safePlace.remove(item) : _safePlace.add(item);
                            setState(() {
                              _safePlace = _safePlace;
                              _riskScore["safePlace"] = _safePlace.length;
                            });
                          },
                        ),
                      );
                    }).toList(),
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
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Raleway'),
                    text: 'Lack Access to the Item(s) below',
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: (_headingData["doYouHave"] ?? []).map((item) {
                      final bool selected = _doYouHave.contains(item);
                      return SizedBox(
                        height: 32,
                        child: FilterChip(
                          selected: selected,
                          label: Text(item, style: TextStyle(fontFamily: 'Fonto')),
                          backgroundColor: Color.fromARGB(255, 130, 200, 21),
                          onSelected: (value) {
                            selected ? _doYouHave.remove(item) : _doYouHave.add(item);
                            setState(() {
                              _doYouHave = _doYouHave;
                              _riskScore["doYouHave"] = _doYouHave.length;
                            });
                          },
                        ),
                      );
                    }).toList(),
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
