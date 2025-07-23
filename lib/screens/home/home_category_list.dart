import 'package:flutter/material.dart';
import 'package:safer/models/model.dart';
import 'package:safer/screens/home/home_category_item.dart';
import 'package:safer/utils/utils.dart';

class HomeCategoryList extends StatelessWidget {
  final List<CategoryModel> category;
  final Function(CategoryModel) onPress;
  final VoidCallback onOpenList;

  const HomeCategoryList({
    super.key,
    required this.category,
    required this.onPress,
    required this.onOpenList,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: IntrinsicHeight(
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Translate.of(context).translate('more_options'),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    GestureDetector(
                      onTap: onOpenList,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Icon(Icons.list),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Wrap(
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: category.map(
                      (item) {
                        return HomeCategoryItem(
                          item: item,
                          onPressed: onPress,
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
