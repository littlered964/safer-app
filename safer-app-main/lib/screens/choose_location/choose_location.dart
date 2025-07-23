import 'package:flutter/material.dart';
import 'package:safer/api/api.dart';
import 'package:safer/models/model.dart';
import 'package:safer/utils/other.dart';
import 'package:safer/utils/utils.dart';
import 'package:safer/widgets/widget.dart';

class ChooseLocation extends StatefulWidget {
  final List<LocationModel> location;

  const ChooseLocation({required this.location, super.key});

  @override
  _ChooseLocationState createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  final _textLanguageController = TextEditingController();
  bool _loading = false;

  late List<LocationModel> _location;
  late List<LocationModel> _locationBackup;
  late List<LocationModel> _locationSelected;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  // Fetch API
  Future<void> _loadData() async {
    final ResultApiModel result = await Api.getLocationList();
    if (result.success) {
      final Iterable data = result.data['location'] ?? [];
      setState(() {
        _location = data.map((item) => LocationModel.fromJson(item)).toList();
        _location.sort((a, b) => a.name.compareTo(b.name));
        _locationBackup = _location;
        _locationSelected = widget.location;
      });
    }
  }

  // On filter location
  void _onFilter(String text) {
    setState(() {
      _location = text.isEmpty
          ? _locationBackup
          : _locationBackup
              .where((item) =>
                  item.name.toUpperCase().contains(text.toUpperCase()))
              .toList();
    });
  }

  // On Select Location
  void _onSelect(LocationModel item) {
    setState(() {
      if (_locationSelected.contains(item)) {
        _locationSelected.remove(item);
      } else {
        _locationSelected = [item];
      }
    });
  }

  // Build List location
  Widget _buildContent() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _location.length,
      itemBuilder: (context, index) {
        final item = _location[index];
        final selected = _locationSelected.contains(item);
        return AppListTitle(
          title: item.name,
          textStyle: selected
              ? Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).primaryColor)
              : null,
          trailing: selected
              ? Icon(Icons.check, color: Theme.of(context).primaryColor)
              : null,
          onPressed: () => _onSelect(item),
        );
      },
    );
  }

  // On change language
  Future<void> _onChange() async {
    UtilOther.hiddenKeyboard(context);
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pop(context, _locationSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Translate.of(context).translate('location')),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: AppTextInput(
                hintText: Translate.of(context).translate('search'),
                icon: const Icon(Icons.clear),
                controller: _textLanguageController,
                focusNode: FocusNode(), // Required fix
                onChanged: _onFilter,
                onSubmitted: _onFilter,
                onTapIcon: () async {
                  await Future.delayed(const Duration(milliseconds: 100));
                  _textLanguageController.clear();
                },
              ),
            ),
            Expanded(child: _buildContent()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: AppButton(
                onPressed: _onChange,
                text: Translate.of(context).translate('apply'),
                loading: _loading,
                disableTouchWhenLoading: true,
              ),
            )
          ],
        ),
      ),
    );
  }
}
