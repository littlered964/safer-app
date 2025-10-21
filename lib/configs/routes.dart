import 'package:flutter/material.dart';
import 'package:safer/screens/choose_location/choose_location.dart';
import 'package:safer/screens/screen.dart';
import 'package:safer/models/model.dart';

class Routes {
  static const String signIn = "/signIn";
  static const String signUp = "/signUp";
  static const String forgotPassword = "/forgotPassword";
  static const String productDetail = "/productDetail";
  static const String productDetailTab = "ProductDetailTab";
  static const String searchHistory = "/searchHistory";
  static const String category = "/category";
  static const String editProfile = "/editProfile";
  static const String changePassword = "/changePassword";
  static const String changeLanguage = "/changeLanguage";
  static const String contactUs = "/contactUs";
  static const String chat = "/chat";
  static const String aboutUs = "/aboutUs";
  static const String gallery = "/gallery";
  static const String photoPreview = "/photoPreview";
  static const String themeSetting = "/themeSetting";
  static const String listProduct = "/listProduct";
  static const String filter = "/filter";
  static const String review = "/review";
  static const String writeReview = "/writeReview";
  static const String location = "/location";
  static const String setting = "/setting";
  static const String fontSetting = "/fontSetting";
  static const String chooseLocation = "/chooseLocation";

  static const String stormTracking = "/stormTracking";
  static const String personalSafety = "/personalSafety";
  static const String personalRisk = "/personalRisk";
  static const String propertySafety = "/propertySafety";
  static const String propertyRisk = "/propertyRisk";
  static const String supplies = "/supplies";
  static const String evacuation = "/evacuation";
  static const String stayInTouch = "/stayInTouch";
  static const String powerOutage = "/powerOutage";
  static const beforeOutageQuiz = '/beforeOutageQuiz';
  static const duringOutageSort = '/duringOutageSort';
  static const String afterOutageGame = '/afterOutageGamePage';

  static const String termsOfUse = "/termsOfUse";

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case termsOfUse:
        final category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => TermsOfUse(title: category ?? ''),
        );

      case chooseLocation:
        final location = settings.arguments as List<LocationModel>;
        return MaterialPageRoute(
          builder: (context) => ChooseLocation(location: location),
        );

      case stormTracking:
        final category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => StormTracking(title: category ?? ''),
        );

      case personalSafety:
        final category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => PersonalSafety(title: category ?? ''),
        );

      case personalRisk:
        final category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => PersonalRisk(title: category ?? ''),
        );

      case propertySafety:
        final category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => PropertySafety(title: category ?? ''),
        );

      case propertyRisk:
        final category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => PropertyRisk(title: category ?? ''),
        );

      case supplies:
        final category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => Supplies(title: category ?? ''),
        );

      case evacuation:
        final category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => Evacuation(title: category ?? ''),
        );

      case stayInTouch:
        final category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => StayInTouch(title: category ?? ''),
        );

      case powerOutage:
        final category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => PowerOutage(title: category ?? ''),
        );

      case changeLanguage:
        return MaterialPageRoute(
          builder: (context) => LanguageSetting(),
        );

      case themeSetting:
        return MaterialPageRoute(
          builder: (context) => ThemeSetting(),
        );

      case fontSetting:
        return MaterialPageRoute(
          builder: (context) => FontSetting(),
        );

      case Routes.beforeOutageQuiz:
        return MaterialPageRoute(
          builder: (context) => const BeforeOutageQuizPage(),
        );

      case Routes.duringOutageSort:
        return MaterialPageRoute(
          builder: (context) => const DuringOutageSortingPage(),
        );

      case Routes.afterOutageGame:
        return MaterialPageRoute(
          builder: (context) => const AfterOutageGamePage(),
        );


      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text("Not Found")),
            body: Center(child: Text('No path for ${settings.name}')),
          ),
        );
    }
  }

  // Singleton factory
  static final Routes _instance = Routes._internal();

  factory Routes() => _instance;

  Routes._internal();
}
