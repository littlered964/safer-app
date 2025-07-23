import 'package:flutter/material.dart';
import 'package:safer/models/model.dart';

class HomeCategoryItem extends StatelessWidget {
  final CategoryModel item;
  final ValueChanged<CategoryModel> onPressed;

  const HomeCategoryItem({
    super.key,
    required this.item,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.26,
      child: GestureDetector(
        onTap: () => onPressed(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.color,
              ),
              child: Icon(
                item.icon,
                size: 18,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 3, left: 2, right: 2),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
