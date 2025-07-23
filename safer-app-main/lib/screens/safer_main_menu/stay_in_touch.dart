import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/utils/utils.dart';

class StayInTouch extends StatefulWidget {
  final String title;

  StayInTouch({Key? key, required this.title}) : super(key: key);

  @override
  _StayInTouchState createState() {
    return _StayInTouchState();
  }
}

class _StayInTouchState extends State<StayInTouch> {
  String location = UtilPreferences.getString(Preferences.location);
  Map<String, String> townEmergencyLink = {
    "Bridgeport":
        "https://www.bridgeportct.gov/content/341307/341425/342901/342995.aspx",
    "Milford": "https://www.ci.milford.ct.us/emergency-management-services",
    "New Haven":
        "https://www.newhavenct.gov/government/departments-divisions/office-of-emergency-management/resources-information-links",
    "New London":
        "https://newlondonct.org/content/8251/13617/default.aspx",
    "Norwalk": "https://www.norwalkct.org/461/Important-Numbers",
    "Greenwich": "https://www.greenwichct.gov/435/Emergency-Management",
    "Stamford": "https://www.stamfordct.gov/government/public-safety-health-welfare/storm-emergency-information",
    "Darien": "https://www.darienct.gov/159/Emergency-Management",
    "Norwalk": "https://www.norwalkct.gov/324/Emergency-Management",
    "Westport": "https://www.westportct.gov/residents/emergency-information-alerts",
    "Fairfield": "https://fairfieldct.org/service/public_safety/storm_information.php",
    "Stratford": "https://www.stratfordct.gov/content/39832/39846/39911/40363.aspx",
    "West Haven": "https://www.cityofwesthaven.com/182/Emergency-Management",
    "East Haven": "https://www.easthaven-ct.gov/town-engineer/pages/natural-disaster-information", //Not that good
    "Branford": "https://www.branford-ct.gov/departments/emergency-management",
    "Guilford": "",
    "Madison": "https://www.madisonct.org/247/Emergency-Management",
    "Clinton": "https://clintonct.org/160/Emergency-Management", //Not that good
    "Westbrook": "https://westbrookct.us/407/Emergency-Management---About-Us",
    "Old Saybrook": "https://www.oldsaybrookct.gov/emergency-management", //Not that good
    "Old Lyme": "https://www.oldlyme-ct.gov/186/Emergency-Management",
    "East Lyme": "https://eltownhall.com/government/departments/emergency-management/",
    "Waterford": "https://waterfordct.org/213/Emergency-Management",
    "Groton": "https://www.groton-ct.gov/departments/emergency_management/index.php",
    "Stonington": "https://www.stonington-ct.gov/emergency-management",
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
                            AssetImage('assets/images/social_media.png')),
                    title: const Text('Social Media'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.blue.withOpacity(1),
                            fontFamily: 'Raleway',
                            height: 1.5),
                        text: 'Facebook',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch('https://www.facebook.com');
                          },
                        children: [
                          TextSpan(
                            text: '\nTwitter',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch('https://www.twitter.com');
                              },
                          ),
                          TextSpan(
                            text: '\nInstagram',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch('https://www.instagram.com');
                              },
                          ),
                          TextSpan(
                            text: '\nReddit',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch('https://www.reddit.com');
                              },
                          ),
                          TextSpan(
                            text: '\nTikTok',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch('https://www.tiktok.com');
                              },
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
                  leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/police.png')),
                  title: const Text('Police, Fire, and Medical Emergency:'),
                  subtitle: Text(
                    'Call 911',
                    style: TextStyle(
                        color: Colors.blue.withOpacity(1),
                        fontFamily: 'Raleway'),
                  ),
                  onTap: () {
                    launch('tel://911');
                  },
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
                          AssetImage('assets/images/emergency.png')),
                  title: const Text('Emergency Needs'),
                  subtitle: Text(
                    'Call 211',
                    style: TextStyle(
                        color: Colors.blue.withOpacity(1),
                        fontFamily: 'Raleway'),
                  ),
                  onTap: () {
                      launch('http://www.211ct.org/');
                      },
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
                      backgroundImage: AssetImage('assets/images/emergency-service.png')),
                  title: const Text('Emergency Service Center'),
                  subtitle: RichText(
                    text: TextSpan(
                      style: TextStyle(
                          color: Colors.blue.withOpacity(1),
                          fontFamily: 'Raleway'),
                      text: 'City of $location',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          final url = townEmergencyLink[location];
                          if (url != null && url.isNotEmpty) {
                            launch(url);
                          }
                        },
                    ),
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
                    leading: CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/resources.png')),
                    title: const Text('Resources'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.blue.withOpacity(1),
                            fontFamily: 'Raleway',
                            height: 1.5),
                        text: 'Get in Contact with FEMA',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch('https://www.fema.gov/about/contact');
                          },
                        children: [
                          TextSpan(
                            text: '\nRed Cross Relief',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch(
                                    'https://www.redcross.org/get-help/disaster-relief-and-recovery-services.html');
                              },
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
        ],
      ),
    );
  }
}
