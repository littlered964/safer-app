import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safer/blocs/bloc.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/utils/language.dart';
import 'package:safer/utils/other.dart';
import 'package:safer/utils/utils.dart';
import 'package:safer/widgets/widget.dart';

class LanguageSetting extends StatefulWidget {
  const LanguageSetting({Key? key}) : super(key: key);

  @override
  _LanguageSettingState createState() => _LanguageSettingState();
}

class _LanguageSettingState extends State<LanguageSetting> {
  late LanguageBloc _languageBloc;
  final _textLanguageController = TextEditingController();
  final _focusNode = FocusNode(); // <-- Added focusNode
  bool _loading = false;

  List<Locale> _listLanguage = AppLanguage.supportLanguage;
  Locale _languageSelected = AppLanguage.defaultLanguage;

  @override
  void initState() {
    _languageBloc = BlocProvider.of<LanguageBloc>(context);
    super.initState();
  }

  void _onFilter(String text) {
    if (text.isEmpty) {
      setState(() {
        _listLanguage = AppLanguage.supportLanguage;
      });
      return;
    }
    setState(() {
      _listLanguage = _listLanguage.where((item) {
        return UtilLanguage.getGlobalLanguageName(item.languageCode)
            .toUpperCase()
            .contains(text.toUpperCase());
      }).toList();
    });
  }

  Future<void> _changeLanguage() async {
    UtilOther.hiddenKeyboard(context);
    setState(() {
      _loading = true;
    });
    _languageBloc.add(ChangeLanguage(_languageSelected));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Translate.of(context).translate('change_language')),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                bottom: 15,
              ),
              child: AppTextInput(
                hintText: Translate.of(context).translate('search'),
                icon: const Icon(Icons.clear),
                controller: _textLanguageController,
                focusNode: _focusNode, // <-- Added focusNode
                onChanged: _onFilter,
                onSubmitted: _onFilter,
                onTapIcon: () async {
                  await Future.delayed(const Duration(milliseconds: 100));
                  _textLanguageController.clear();
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 20, right: 20),
                itemCount: _listLanguage.length,
                itemBuilder: (context, index) {
                  final item = _listLanguage[index];
                  final trailing = item == _languageSelected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).primaryColor,
                        )
                      : const SizedBox.shrink();

                  return AppListTitle(
                    title: UtilLanguage.getGlobalLanguageName(item.languageCode),
                    textStyle: item == _languageSelected
                        ? (Theme.of(context).textTheme.titleMedium ?? const TextStyle())
                            .copyWith(color: Theme.of(context).primaryColor)
                        : const TextStyle(),
                    trailing: trailing,
                    onPressed: () {
                      setState(() {
                        _languageSelected = item;
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                bottom: 15,
              ),
              child: BlocListener<LanguageBloc, LanguageState>(
                listener: (context, state) {
                  if (state is LanguageUpdated) {
                    setState(() {
                      _loading = false;
                    });
                  }
                },
                child: AppButton(
                  onPressed: _changeLanguage,
                  text: Translate.of(context).translate('confirm'),
                  font: Theme.of(context).textTheme.titleMedium, // optional: add font if needed
                  loading: _loading,
                  disableTouchWhenLoading: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
