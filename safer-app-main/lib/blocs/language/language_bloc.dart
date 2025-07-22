import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:safer/blocs/language/bloc.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/utils/utils.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  @override
  LanguageState get initialState => InitialLanguageState();

  @override
  Stream<LanguageState> mapEventToState(event) async* {
    if (event is ChangeLanguage) {
      if (event.locale == AppLanguage.defaultLanguage) {
        yield LanguageUpdated();
      } else {
        yield LanguageUpdating();
        AppLanguage.defaultLanguage = event.locale;

        // Preference save
        UtilPreferences.setString(
          Preferences.language,
          event.locale.languageCode,
        );

        yield LanguageUpdated();
      }
    }
  }
}
