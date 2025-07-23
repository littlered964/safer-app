import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/utils/utils.dart';

class StormTracking extends StatefulWidget {
  final String title;

  const StormTracking({Key? key, required this.title}) : super(key: key);

  @override
  _StormTrackingState createState() => _StormTrackingState();
}

class _StormTrackingState extends State<StormTracking> {
  String location = UtilPreferences.getString(Preferences.location);
  Map<String, String> townAlertNotification = {
    "Bridgeport": "https://veoci.com/veoci/p/form/y9qpadaf4mq9#tab=entryForm",
    "Milford": "https://www.ci.milford.ct.us/sign-up-for-e-alerts",
    "New Haven": "https://www.newhavenct.gov/government/departments-divisions/office-of-emergency-management/new-haven-alerts-login-or-sign-up",
    "New London": "https://portal.ct.gov/CTAlert/Common-Elements/Common-Elements/Sign-up-for-CT-Alerts",
    "Greenwich": "https://www.greenwichct.gov/CivicAlerts.aspx?AID=1925",
    "Stamford": "https://portal.ct.gov/CTAlert/Common-Elements/Common-Elements/Sign-up-for-CT-Alerts",
    "Darien": "https://public.coderedweb.com/CNE/en-US/6AB0EACFCCDD",
    "Westport": "https://www.westportct.gov/government/departments-a-z/fire-department/emergency-notification-system-nixle",
    "Fairfield": "https://fairfieldct.org/service/public_safety/emergency_alerts.php",
    "Stratford": "https://www.stratfordct.gov/StratfordAlerts",
    "West Haven": "https://www.cityofwesthaven.com/AlertCenter.aspx",
    "East Haven": "https://www.easthaven-ct.gov/home/urgent-alerts/residents-sign-town-alerts",
    "Branford": "https://www.branford-ct.gov/departments/emergency-management/CodeRed",
    "Guilford": "https://portal.ct.gov/CTAlert/Common-Elements/Common-Elements/Sign-up-for-CT-Alerts",
    "Madison": "https://www.madisonct.org/1073/Alerts",
    "Clinton": "https://clintonct.org/AlertCenter.aspx",
    "Westbrook": "https://portal.ct.gov/CTAlert/Common-Elements/Common-Elements/Sign-up-for-CT-Alerts",
    "Old Saybrook": "https://portal.ct.gov/CTAlert/Common-Elements/Common-Elements/Sign-up-for-CT-Alerts",
    "Old Lyme": "https://www.oldlyme-ct.gov/AlertCenter.aspx",
    "East Lyme": "https://eltownhall.com/government/departments/emergency-management/alerts/",
    "Waterford": "https://portal.ct.gov/CTAlert/Common-Elements/Common-Elements/Sign-up-for-CT-Alerts",
    "Groton": "https://portal.ct.gov/CTAlert/Common-Elements/Common-Elements/Sign-up-for-CT-Alerts",
    "Stonington": "https://www.stonington-ct.gov/home/pages/stonington-alerts",
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
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          // CT Alert card
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/ct-alert.png'),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.blue.withOpacity(1),
                            fontSize: 16,
                            fontFamily: 'Raleway',
                          ),
                          text: 'Register for CT Alert Notification System',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launch('https://portal.ct.gov/CTAlert/Common-Elements/Common-Elements/Sign-up-for-CT-Alerts');
                            },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The CT Alert website allows Connecticut residents to sign up for emergency alerts to receive timely notifications about public safety incidents, severe weather, and other critical events.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          ),

          // Town Alert card
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/ct-map.png'),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.blue.withOpacity(1),
                        fontSize: 16,
                        fontFamily: 'Raleway',
                      ),
                      text: 'Register for $location Alert Notification',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          final url = townAlertNotification[location];
                          if (url != null) {
                            launch(url);
                          }
                        },
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          ),

          // NHC card
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/nhc.png'),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.blue.withOpacity(1),
                        fontSize: 16,
                        fontFamily: 'Raleway',
                      ),
                      text: 'National Hurricane Center',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch('https://www.nhc.noaa.gov/');
                        },
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          ),

          // Severe weather tracking card
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/storm.png'),
                  ),
                  title: const Text('Severe Weather and Storm Tracker'),
                  subtitle: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.blue.withOpacity(1),
                        fontFamily: 'Raleway',
                        fontSize: 15,
                        height: 2,
                      ),
                      text: '- Weather.com',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch('https://weather.com/');
                        },
                      children: [
                        TextSpan(
                          text: '\n\nNational Weather Service:',
                          style: TextStyle(color: Colors.black.withOpacity(0.6)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launch('https://www.facebook.com/');
                            },
                        ),
                        TextSpan(
                          text: '\n- Weather.gov',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launch('https://www.weather.gov/');
                            },
                        ),
                        TextSpan(
                          text: '\n- Weather Forecast Office',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launch('https://www.weather.gov/okx/');
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          ),

          // TV stations card
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/tv.png'),
                  ),
                  title: const Text('Weather Coverage on Local TV Stations'),
                  subtitle: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.blue.withOpacity(1),
                        fontFamily: 'Raleway',
                        fontSize: 15,
                        height: 2,
                      ),
                      text: '- WTNH (ABC)',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch('https://www.wtnh.com/weather-alerts/');
                        },
                      children: [
                        TextSpan(
                          text: '\n- WFSP (CBS)',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launch('https://www.wfsb.com/weather/');
                            },
                        ),
                        TextSpan(
                          text: '\n- WVIT (NBC)',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launch('https://www.nbcconnecticut.com/weather/');
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
