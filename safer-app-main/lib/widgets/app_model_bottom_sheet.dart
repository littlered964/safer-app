import 'package:flutter/material.dart';
import 'package:safer/models/model.dart';
import 'package:safer/utils/utils.dart';
import 'package:safer/widgets/widget.dart';

class AppModelBottomSheet extends StatefulWidget {
  final SortModel selected;
  final List<SortModel> option;
  final ValueChanged<SortModel> onChange;

  const AppModelBottomSheet({
    super.key,
    required this.selected,
    required this.option,
    required this.onChange,
  });

  @override
  _AppModelBottomSheetState createState() => _AppModelBottomSheetState();
}

class _AppModelBottomSheetState extends State<AppModelBottomSheet> {
  late SortModel _currentSort;

  @override
  void initState() {
    _currentSort = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: IntrinsicHeight(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(10),
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  Column(
                    children: widget.option.map((item) {
                      return AppListTitle(
                        title: Translate.of(context).translate(item.name),
                        textStyle: item.code == _currentSort.code
                            ? Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Theme.of(context).primaryColor)
                            : null,
                        trailing: item.code == _currentSort.code
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).primaryColor,
                              )
                            : const SizedBox.shrink(),
                        onPressed: () {
                          setState(() {
                            _currentSort = item;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: AppButton(
                      onPressed: () {
                        widget.onChange(_currentSort);
                        Navigator.pop(context);
                      },
                      text: Translate.of(context).translate('apply'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
