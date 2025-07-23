import 'package:safer/models/model.dart';

class ProductDetailTabPageModel {
  final ProductModel product;
  final List<TabModel> tab;

  ProductDetailTabPageModel(
    this.product,
    this.tab,
  );

  static List<TabModel> _setTab(dynamic tab) {
    if (tab != null) {
      final Iterable refactorTab = tab;
      return refactorTab.map((item) {
        return TabModel.fromJson(item);
      }).toList();
    }
    return []; // return empty list instead of null
  }

  factory ProductDetailTabPageModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailTabPageModel(
      ProductModel.fromJson(json),
      _setTab(json['tab']),
    );
  }
}
