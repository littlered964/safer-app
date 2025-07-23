import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:safer/blocs/language/bloc.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/utils/utils.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(InitialLanguageState()) {
    on<ChangeLanguage>(_onChangeLanguage);
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    if (event.locale == AppLanguage.defaultLanguage) {
      emit(LanguageUpdated());
    } else {
      emit(LanguageUpdating());
      AppLanguage.defaultLanguage = event.locale;

      // Save preference
      UtilPreferences.setString(
        Preferences.language,
        event.locale.languageCode,
      );

      emit(LanguageUpdated());
    }
  }
}
