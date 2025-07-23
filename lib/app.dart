import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:safer/blocs/bloc.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/main_navigation.dart';
import 'package:safer/screens/screen.dart';
import 'package:safer/utils/utils.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Routes route = Routes();

  late final ApplicationBloc _applicationBloc;
  late final LanguageBloc _languageBloc;
  late final ThemeBloc _themeBloc;

  @override
  void initState() {
    super.initState();
    _languageBloc = LanguageBloc();
    _themeBloc = ThemeBloc();
    _applicationBloc = ApplicationBloc(
      themeBloc: _themeBloc,
      languageBloc: _languageBloc,
    );
  }

  @override
  void dispose() {
    _applicationBloc.close();
    _languageBloc.close();
    _themeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ApplicationBloc>.value(value: _applicationBloc),
        BlocProvider<LanguageBloc>.value(value: _languageBloc),
        BlocProvider<ThemeBloc>.value(value: _themeBloc),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, lang) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, theme) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                onGenerateRoute: route.generateRoute,
                locale: AppLanguage.defaultLanguage,
                localizationsDelegates: const [
                  Translate.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                supportedLocales: AppLanguage.supportLanguage,
                home: BlocBuilder<ApplicationBloc, ApplicationState>(
                  builder: (context, app) {
                    if (app is ApplicationSetupCompleted ||
                        app is ApplicationIntroView) {
                      return const MainNavigation();
                    }
                    return SplashScreen();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
