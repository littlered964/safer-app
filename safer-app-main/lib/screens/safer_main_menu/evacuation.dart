import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/utils/utils.dart';
import 'package:safer/widgets/widget.dart';

class Evacuation extends StatefulWidget {
  final String title;

  Evacuation({Key key, this.title}) : super(key: key);

  @override
  _EvacuationState createState() {
    return _EvacuationState();
  }
}

class _EvacuationState extends State<Evacuation> {
  String location = UtilPreferences.getString(Preferences.location);

  bool _loading = false;

  Map<String, int> _evacuationScore = {
    "alerted": 0,
    "evacuation_routes": 0,
    "evacuation_transport": 0,
    "evacuation_items": 0,
    "not_yet_alerted": 0,
  };

  Map<String, String> emergencyService = {
    "Bridgeport": "https://www.bridgeportct.gov/emergencymgmt",
    "Milford": "https://www.ci.milford.ct.us/emergency-management-services",
    "New Haven":
        "https://www.newhavenct.gov/gov/depts/emergency_info/default.htm",
    "New London": "http://newlondonct.org/content/8251/13617/default.aspx",
    "Norwalk": "https://www.norwalkct.org/324/Emergency-Management",
  };

  Map<String, String> evacuationRoutes = {
    "Bridgeport":
        "https://www.redcross.org/get-help/disaster-relief-and-recovery-services/find-an-open-shelter.html",
    "Milford":
        "https://www.redcross.org/get-help/disaster-relief-and-recovery-services/find-an-open-shelter.html",
    "New Haven":
        "https://www.redcross.org/get-help/disaster-relief-and-recovery-services/find-an-open-shelter.html",
    "New London":
        "https://www.redcross.org/get-help/disaster-relief-and-recovery-services/find-an-open-shelter.html",
    "Norwalk": "https://www.norwalkct.org/FAQ.aspx?QID=226",
  };

  @override
  void initState() {
    super.initState();
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
                      'Your Readiness Score: ${_evacuationScore.values.reduce((sum, element) => sum + element)}',
                      // 'Your Readiness Score: ',
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
                      backgroundImage: AssetImage('assets/images/property-risk.png')),
                  title: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Raleway'),
                    text: 'Alerted for Evacuation',
                    children: <TextSpan>[
                      TextSpan(
                          text: '\n\n- Before Leaving:',
                          style: TextStyle(fontSize: 15)),
                      TextSpan(
                        style: TextStyle(
                            fontSize: 15, color: Colors.blue.withOpacity(1)),
                        text: '\n  - Load emergency supplies in a car',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, Routes.supplies,
                                arguments: Translate.of(context)
                                    .translate('Supplies'));
                          },
                      ),
                      TextSpan(
                          text:
                              '\n  - Secure pets/livestock with food/water for 5 days\n  - Disconnect all electrical appliances\n  - Shut off electricity, gas, water\n  - Secure people in car\n  - Secure pets in carrier/crate in car, if pet shelter open',
                          style: TextStyle(fontSize: 15)),
                      TextSpan(
                          text: '\n\n- While en route',
                          style: TextStyle(fontSize: 15)),
                      TextSpan(
                          text:
                              '\n  - Follow the evacuation routes given\n  - Expect heavy traffic\n  - Monitor route change\n  - Avoid creeks/flooded roads\n  - If stranded, call emergency assistance or search alternative routes (see below)',
                          style: TextStyle(fontSize: 15)),
                    ],
                  )),
                ),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 1,
                    value: _evacuationScore["alerted"].toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => text.isEmpty ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _evacuationScore["alerted"] = value.toInt()),
                  ),
                  padding: EdgeInsets.only(left: 10),
                  // padding: const EdgeInsets.all(8),
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
                      backgroundImage: AssetImage('assets/images/medical.png')),
                  title: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Raleway'),
                    text: 'Evacuation Routes/Shelters',
                    children: <TextSpan>[
                      TextSpan(
                          text: '\n\n- Local emergency service: ',
                          style: TextStyle(fontSize: 15)),
                      TextSpan(
                        style: TextStyle(
                            fontSize: 15, color: Colors.blue.withOpacity(1)),
                        text: 'City of $location',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch(emergencyService[location]);
                          },
                      ),
                      TextSpan(
                          text: '\n- Evacuation routes/shelter location: ',
                          style: TextStyle(fontSize: 15)),
                      TextSpan(
                        style: TextStyle(
                            fontSize: 15, color: Colors.blue.withOpacity(1)),
                        text: 'City of $location',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch(evacuationRoutes[location]);
                          },
                      ),
                      TextSpan(
                          text: '\n- Alternative evacuation shelter locator:',
                          style: TextStyle(fontSize: 15)),
                      TextSpan(
                        style: TextStyle(
                            fontSize: 15, color: Colors.blue.withOpacity(1)),
                        text: '\n  - American Red Cross',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch('http://www.redcross.org/find-help/shelter');
                          },
                      ),
                      TextSpan(
                        style: TextStyle(
                            fontSize: 15, color: Colors.blue.withOpacity(1)),
                        text: '\n  - American Red Cross, CT Chapter',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch('http://www.redcross.org/ct/');
                          },
                      ),
                    ],
                  )),
                ),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 1,
                    value: _evacuationScore["evacuation_routes"].toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => text.isEmpty ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _evacuationScore["evacuation_routes"] = value.toInt()),
                  ),
                  padding: EdgeInsets.only(left: 10),
                  // padding: const EdgeInsets.all(8),
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
                      backgroundImage: AssetImage('assets/images/vehicle.png')),
                  title: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Raleway'),
                    text: 'Evacuation Transport',
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              '\n\n- Prepare household to evacuate in car\n- Prepare to evacuate to shelter or others\' home\n- Arrange for transport, if lacking car access\n- Arrange for transport, if unable to drive',
                          style: TextStyle(fontSize: 15)),
                    ],
                  )),
                ),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 1,
                    value: _evacuationScore["evacuation_transport"].toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => text.isEmpty ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _evacuationScore["evacuation_transport"] = value.toInt()),
                  ),
                  padding: EdgeInsets.only(left: 10),
                  // padding: const EdgeInsets.all(8),
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
                      backgroundImage: AssetImage('assets/images/burger.png')),
                  title: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Raleway'),
                    text: 'Evacuation Items in Car',
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              '\n\nWaterproof items below, as needed\n- Full-tank of gasoline in car(s)\n- Fully-charged cell phone(s)\n- A first aid kit\n- Sleeping bags, blankets\n- Emergency food, water, medicine\n- Flashlights and flares\n- Booster cables and maps\n- Rubber boots, sturdy shoes, waterproof gloves',
                          style: TextStyle(fontSize: 15)),
                    ],
                  )),
                ),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 1,
                    value: _evacuationScore["evacuation_items"].toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => text.isEmpty ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _evacuationScore["evacuation_items"] = value.toInt()),
                  ),
                  padding: EdgeInsets.only(left: 10),
                  // padding: const EdgeInsets.all(8),
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
                      backgroundImage: AssetImage('assets/images/tv.png')),
                  title: RichText(
                      text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Raleway'),
                    text: 'Not Yet Alerted for Evacuation',
                    children: <TextSpan>[
                      TextSpan(
                          text: '\n\n- Monitor changing conditions',
                          style: TextStyle(fontSize: 15)),
                      TextSpan(
                        style: TextStyle(
                            fontSize: 15, color: Colors.blue.withOpacity(1)),
                        text: '\n- Prepare for Emergency Needs',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, Routes.supplies,
                                arguments: Translate.of(context)
                                    .translate('Supplies'));
                          },
                      ),
                      TextSpan(
                        style: TextStyle(
                            fontSize: 15, color: Colors.blue.withOpacity(1)),
                        text:
                            '\n- Prepare for disruption of power, utility service, communication, transportation',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch('https://www.ready.gov/power-outages');
                          },
                      ),
                      TextSpan(
                        style: TextStyle(
                            fontSize: 15, color: Colors.blue.withOpacity(1)),
                        text: '\n- Secure your property safely',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, Routes.propertySafety,
                                arguments: Translate.of(context)
                                    .translate('Property Safety'));
                          },
                      ),
                      TextSpan(
                          text:
                              '\n- Be evacuation-ready in car or to other\'s home',
                          style: TextStyle(fontSize: 15)),
                    ],
                  )),
                ),
                Padding(
                  child: SpinBox(
                    min: 0,
                    max: 1,
                    value: _evacuationScore["not_yet_alerted"].toDouble(),
                    decoration: InputDecoration(border: InputBorder.none),
                    validator: (text) => text.isEmpty ? 'Invalid' : null,
                    onChanged: (value) =>
                        setState(() => _evacuationScore["not_yet_alerted"] = value.toInt()),
                  ),
                  padding: EdgeInsets.only(left: 10),
                  // padding: const EdgeInsets.all(8),
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
                      'Your Readiness Score: ${_evacuationScore.values.reduce((sum, element) => sum + element)}',
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
                // senddata();
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
