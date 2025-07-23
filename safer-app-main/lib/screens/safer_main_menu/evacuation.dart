import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/utils/utils.dart';
import 'package:safer/widgets/widget.dart';

class Evacuation extends StatefulWidget {
  final String title;

  const Evacuation({super.key, required this.title});

  @override
  _EvacuationState createState() => _EvacuationState();
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
    "New Haven": "https://www.newhavenct.gov/gov/depts/emergency_info/default.htm",
    "New London": "http://newlondonct.org/content/8251/13617/default.aspx",
    "Norwalk": "https://www.norwalkct.org/324/Emergency-Management",
  };

  Map<String, String> evacuationRoutes = {
    "Bridgeport": "https://www.redcross.org/get-help/disaster-relief-and-recovery-services/find-an-open-shelter.html",
    "Milford": "https://www.redcross.org/get-help/disaster-relief-and-recovery-services/find-an-open-shelter.html",
    "New Haven": "https://www.redcross.org/get-help/disaster-relief-and-recovery-services/find-an-open-shelter.html",
    "New London": "https://www.redcross.org/get-help/disaster-relief-and-recovery-services/find-an-open-shelter.html",
    "Norwalk": "https://www.norwalkct.org/FAQ.aspx?QID=226",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          _buildInfoCard(),
          _buildScoreCard(),
          _buildSectionCard(
            title: 'Alerted for Evacuation',
            image: 'assets/images/property-risk.png',
            description: [
              '- Before Leaving:',
              '- Load emergency supplies in a car',
              '- Secure pets/livestock with food/water for 5 days',
              '- Disconnect all electrical appliances',
              '- Shut off electricity, gas, water',
              '- Secure people in car',
              '- Secure pets in carrier/crate in car, if pet shelter open',
              '',
              '- While en route',
              '- Follow the evacuation routes given',
              '- Expect heavy traffic',
              '- Monitor route change',
              '- Avoid creeks/flooded roads',
              '- If stranded, call emergency assistance or search alternative routes (see below)',
            ],
            scoreKey: "alerted",
            tappablePhrases: {
              'Load emergency supplies in a car': () {
                Navigator.pushNamed(context, Routes.supplies,
                    arguments: Translate.of(context).translate('Supplies'));
              }
            },
          ),
          _buildSectionCard(
            title: 'Evacuation Routes/Shelters',
            image: 'assets/images/medical.png',
            description: [
              '- Local emergency service: City of $location',
              '- Evacuation routes/shelter location: City of $location',
              '- Alternative evacuation shelter locator:',
              '  - American Red Cross',
              '  - American Red Cross, CT Chapter',
            ],
            scoreKey: "evacuation_routes",
            tappablePhrases: {
              'City of $location': () {
                final url1 = emergencyService[location];
                final url2 = evacuationRoutes[location];
                if (url1 != null) launch(url1);
                if (url2 != null) launch(url2);
              },
              'American Red Cross': () {
                launch('http://www.redcross.org/find-help/shelter');
              },
              'American Red Cross, CT Chapter': () {
                launch('http://www.redcross.org/ct/');
              }
            },
          ),
          _buildSimpleSection(
            title: 'Evacuation Transport',
            image: 'assets/images/vehicle.png',
            text:
                '- Prepare household to evacuate in car\n- Prepare to evacuate to shelter or others\' home\n- Arrange for transport, if lacking car access\n- Arrange for transport, if unable to drive',
            scoreKey: "evacuation_transport",
          ),
          _buildSimpleSection(
            title: 'Evacuation Items in Car',
            image: 'assets/images/burger.png',
            text:
                'Waterproof items below, as needed\n- Full-tank of gasoline in car(s)\n- Fully-charged cell phone(s)\n- A first aid kit\n- Sleeping bags, blankets\n- Emergency food, water, medicine\n- Flashlights and flares\n- Booster cables and maps\n- Rubber boots, sturdy shoes, waterproof gloves',
            scoreKey: "evacuation_items",
          ),
          _buildSectionCard(
            title: 'Not Yet Alerted for Evacuation',
            image: 'assets/images/tv.png',
            description: [
              '- Monitor changing conditions',
              '- Prepare for Emergency Needs',
              '- Prepare for disruption of power, utility service, communication, transportation',
              '- Secure your property safely',
              '- Be evacuation-ready in car or to other\'s home',
            ],
            scoreKey: "not_yet_alerted",
            tappablePhrases: {
              'Prepare for Emergency Needs': () {
                Navigator.pushNamed(context, Routes.supplies,
                    arguments: Translate.of(context).translate('Supplies'));
              },
              'disruption of power': () {
                launch('https://www.ready.gov/power-outages');
              },
              'Secure your property safely': () {
                Navigator.pushNamed(context, Routes.propertySafety,
                    arguments: Translate.of(context)
                        .translate('Property Safety'));
              }
            },
          ),
          _buildScoreCard(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: AppButton(
              onPressed: () {
                // sendData();
              },
              text: 'Submit',
              font: Theme.of(context).textTheme.titleMedium,
              loading: _loading,
              disableTouchWhenLoading: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/green-check.png'),
        ),
        title: const Text('Readiness for Emergency'),
        subtitle: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontFamily: 'Raleway'),
            text: 'Score the items below:\n\nScoring Range: 0 - 50',
            children: const [
              TextSpan(
                  text:
                      '\n0 = not ready   1 = unsure how to prepare\n2 = have a plan   3 = getting ready\n4 = mostly ready   5 = totally ready'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(
          'Your Readiness Score: ${_evacuationScore.values.reduce((sum, element) => sum + element)}',
          style: const TextStyle(fontSize: 18, fontFamily: 'Raleway'),
        ),
      ),
    );
  }

  Widget _buildSimpleSection({
    required String title,
    required String image,
    required String text,
    required String scoreKey,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(backgroundImage: AssetImage(image)),
            title: Text(
              title,
              style: const TextStyle(fontSize: 20, fontFamily: 'Raleway'),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(text, style: const TextStyle(fontSize: 15)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: SpinBox(
              min: 0,
              max: 1,
              value: _evacuationScore[scoreKey]!.toDouble(),
              decoration: const InputDecoration(border: InputBorder.none),
              validator: (text) => text?.isEmpty == true ? 'Invalid' : null,
              onChanged: (value) =>
                  setState(() => _evacuationScore[scoreKey] = value.toInt()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String image,
    required List<String> description,
    required String scoreKey,
    Map<String, VoidCallback>? tappablePhrases,
  }) {
    final spans = <InlineSpan>[];
    for (var line in description) {
      bool matched = false;
      if (tappablePhrases != null) {
        tappablePhrases.forEach((key, callback) {
          if (line.contains(key)) {
            spans.add(TextSpan(
              text: line + '\n',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue.withOpacity(1),
                  fontFamily: 'Raleway'),
              recognizer: TapGestureRecognizer()..onTap = callback,
            ));
            matched = true;
          }
        });
      }
      if (!matched) {
        spans.add(TextSpan(
          text: line + '\n',
          style: const TextStyle(fontSize: 15, color: Colors.black),
        ));
      }
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(backgroundImage: AssetImage(image)),
            title: Text(
              title,
              style: const TextStyle(fontSize: 20, fontFamily: 'Raleway'),
            ),
            subtitle: RichText(text: TextSpan(children: spans)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: SpinBox(
              min: 0,
              max: 1,
              value: _evacuationScore[scoreKey]!.toDouble(),
              decoration: const InputDecoration(border: InputBorder.none),
              validator: (text) => text?.isEmpty == true ? 'Invalid' : null,
              onChanged: (value) =>
                  setState(() => _evacuationScore[scoreKey] = value.toInt()),
            ),
          ),
        ],
      ),
    );
  }
}
