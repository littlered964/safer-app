import 'package:flutter/material.dart';
import 'package:safer/screens/profile/profile.dart';
import 'package:safer/screens/screen.dart';
import 'package:safer/utils/utils.dart';

class MainNavigation extends StatefulWidget {
  MainNavigation({Key key}) : super(key: key);

  @override
  _MainNavigationState createState() {
    return _MainNavigationState();
  }
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  // On change tab bottom menu
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // List bottom menu
  List<BottomNavigationBarItem> _bottomBarItem(BuildContext context) {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: Translate.of(context).translate('home'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
        label: Translate.of(context).translate('pref'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          Home(),
          Profile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomBarItem(context),
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
        selectedItemColor: Theme.of(context).primaryColor,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
