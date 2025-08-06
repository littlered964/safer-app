import 'package:flutter/material.dart';
import 'package:safer/api/api.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/models/model.dart';
import 'package:safer/models/screen_models/screen_models.dart';
import 'package:safer/screens/home/home_category_item.dart';
import 'package:safer/screens/home/home_sliver_app_bar.dart';
import 'package:safer/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomePageModel? _homePage;
  List<LocationModel> _locationSelected = [];

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void updateLocation(String currentLocation) async {
    UtilPreferences.setString(Preferences.location, currentLocation);
  }

  Future<void> _loadData() async {
    final ResultApiModel result = await Api.getHome();
    if (result.success) {
      setState(() {
        _homePage = HomePageModel.fromJson(result.data);
      });
    }
  }

  void _onTapService(CategoryModel item) {
    switch (item.title) {
      case 'Storm Tracking':
        Navigator.pushNamed(context, Routes.stormTracking, arguments: item.title);
        break;
      case 'Personal Safety':
        Navigator.pushNamed(context, Routes.personalSafety, arguments: item.title);
        break;
      case 'Personal Risk':
        Navigator.pushNamed(context, Routes.personalRisk, arguments: item.title);
        break;
      case 'Property Safety':
        Navigator.pushNamed(context, Routes.propertySafety, arguments: item.title);
        break;
      case 'Property Risk':
        Navigator.pushNamed(context, Routes.propertyRisk, arguments: item.title);
        break;
      case 'Supplies':
        Navigator.pushNamed(context, Routes.supplies, arguments: item.title);
        break;
      case 'Evacuation':
        Navigator.pushNamed(context, Routes.evacuation, arguments: item.title);
        break;
      case 'Stay in Touch':
        Navigator.pushNamed(context, Routes.stayInTouch, arguments: item.title);
        break;
      case 'Power Outage':
        Navigator.pushNamed(context, Routes.powerOutage, arguments: item.title);
        break;
      default:
        break;
    }
  }

  Widget _buildCategory() {
    if (_homePage?.category == null) {
      return Wrap(
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: List.generate(
          8,
          (index) => HomeCategoryItem(
            item: CategoryModel(
              id: index,
              title: 'Loading...',
              icon: Icons.hourglass_empty,
              color: Colors.grey,
              image: '',
              count: 0,
              type: ProductType.more,
            ),
            onPressed: (_) {},
          ),
        ),
      );
    }

    return Wrap(
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: _homePage!.category.map((item) {
        return HomeCategoryItem(
          item: item,
          onPressed: _onTapService,
        );
      }).toList(),
    );
  }

  Future<void> _onNavigateLocation() async {
    final result = await Navigator.pushNamed(
      context,
      Routes.chooseLocation,
      arguments: _locationSelected,
    );
    if (result != null) {
      setState(() {
        _locationSelected = result as List<LocationModel>;
      });
      updateLocation(_locationSelected[0].name);
    }
  }

  String _buildLocationText() {
    return UtilPreferences.getString(Preferences.location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            delegate: AppBarHomeSliver(
              expandedHeight: MediaQuery.of(context).size.height * 0.30,
              banners: _homePage?.banner ?? [],
            ),
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SafeArea(
                top: false,
                bottom: false,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 15, right: 20, left: 20),
                      child: InkWell(
                        onTap: _onNavigateLocation,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    Translate.of(context).translate('location'),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _buildLocationText(),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            RotatedBox(
                              quarterTurns: UtilLanguage.isRTL() ? 2 : 0,
                              child: const Icon(
                                Icons.keyboard_arrow_right,
                                textDirection: TextDirection.ltr,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                      child: _buildCategory(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Dashboard',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Urgent Care and Red Cross Facilities Map',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: GestureDetector(
                              onTap: () {
                                launch(
                                  'https://connecticut.maps.arcgis.com/apps/opsdashboard/index.html#/728b88c606af45dcb3f891ffa20ee7cf',
                                );
                              },
                              child: Image.asset(
                                'assets/images/dashboard.png',
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.89,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '© 2022 Carolyn A. Lin All Rights Reserved',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ]),
          )
        ],
      ),
    );
  }
}
