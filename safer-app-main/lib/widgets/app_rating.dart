import 'package:flutter/material.dart';
import 'package:safer/models/model.dart';
import 'package:safer/utils/utils.dart';

class AppRating extends StatelessWidget {
  final RateModel rate;

  const AppRating({
    super.key,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Column(
            children: <Widget>[
              Text(
                "${rate.avg}",
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(color: Theme.of(context).primaryColor),
              ),
              Text(
                "${Translate.of(context).translate('out_of')} ${rate.range}",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: List.generate(5, (index) {
              int starLevel = 5 - index;
              double barValue;
              switch (starLevel) {
                case 5:
                  barValue = rate.five;
                  break;
                case 4:
                  barValue = rate.four;
                  break;
                case 3:
                  barValue = rate.three;
                  break;
                case 2:
                  barValue = rate.two;
                  break;
                default:
                  barValue = rate.one;
              }

              return Row(
                children: <Widget>[
                  Container(
                    width: 60,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: List.generate(starLevel, (i) {
                        return Icon(Icons.star, size: 12);
                      }),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 10),
                      height: 3,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: barValue,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            })
              ..add(
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "${rate.total} ${Translate.of(context).translate('rating')}",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ),
        )
      ],
    );
  }
}
