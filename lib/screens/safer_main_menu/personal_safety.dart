import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonalSafety extends StatefulWidget {
  final String? title; // <-- make title nullable

  const PersonalSafety({Key? key, this.title}) : super(key: key);

  @override
  _PersonalSafetyState createState() {
    return _PersonalSafetyState();
  }
}

class _PersonalSafetyState extends State<PersonalSafety> {
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
          widget.title ?? "Personal Safety", // <-- fallback text
        ),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/house.png'),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black.withOpacity(1),
                        fontSize: 15,
                        fontFamily: 'Raleway',
                      ),
                      text: 'Stay home/indoors',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/power.png'),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black.withOpacity(1),
                        fontSize: 14,
                        fontFamily: 'Raleway',
                      ),
                      text: 'Stay away from:\n  - Electrical equipment\n  - Windows/skylights/doors',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/property-risk.png'),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black.withOpacity(1),
                        fontSize: 14,
                        fontFamily: 'Raleway',
                      ),
                      text: 'Stay in lower home level:\n  - Glassless space\n  - Hallway/closet/bathroom',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          ),
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
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black.withOpacity(1),
                        fontSize: 14,
                        fontFamily: 'Raleway',
                      ),
                      text: 'Shut off electricty breaker\n  - Hear thundering\n  - See lightening\n  - If flooding is likely',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/phone.png'),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black.withOpacity(1),
                        fontSize: 14,
                        fontFamily: 'Raleway',
                      ),
                      text: 'Don\'t use:\n  - Phones\n  - Bath/shower',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          ),
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
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black.withOpacity(1),
                        fontSize: 14,
                        fontFamily: 'Raleway',
                      ),
                      text: 'During power loss: \n  - Shut off all appliances:\n    - AC, water heater, etc.\n    - Computer, toaster, etc. \n  - No refrigerator use:\n    - Turn to coldest setting\n    - Keep doors shut',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/home-flooding.png'),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black.withOpacity(1),
                        fontSize: 14,
                        fontFamily: 'Raleway',
                      ),
                      text: 'Don\'t go outside \n  - Eye of the storm passed:\n    - New wind will strike\n    - Lightning can strike\n    - Flying debris can strike',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/beach.png'),
                  ),
                  title: const Text('Beach Safety'),
                  subtitle: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: 'Raleway',
                      ),
                      text: 'National Oceanic and Atmospheric Administration Guidelines',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch('https://www.noaa.gov/stories/story-map-play-it-safe');
                        },
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
