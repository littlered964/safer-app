import 'package:safer/models/model.dart';

class HotelProductModel extends ProductModel {
  final List<ProductModel> nearly;

  HotelProductModel(
    int id,
    String title,
    String subtitle,
    String image,
    String createDate,
    bool like,
    num rate,
    num numRate,
    String rateText,
    String status,
    bool favorite,
    String address,
    String phone,
    String email,
    String website,
    String hour,
    String description,
    String date,
    String priceRange,
    List<HourModel> hourDetail,
    List<IconModel> service,
    List<ImageModel> photo,
    List<ProductModel> feature,
    List<ProductModel> related,
    LocationModel location,
    UserModel author,
    ProductType type,
    this.nearly,
  ) : super(
          id,
          title,
          subtitle,
          image,
          createDate,
          like,
          rate,
          numRate,
          rateText,
          status,
          favorite,
          address,
          phone,
          email,
          website,
          hour,
          description,
          date,
          priceRange,
          hourDetail,
          service,
          photo,
          feature,
          related,
          location,
          author,
          type,
        );

  static List<HourModel> _setHourDetail(dynamic hour) {
    final Iterable refactor = (hour ?? []) as Iterable;
    return refactor.map((item) => HourModel.fromJson(item)).toList();
  }

  static List<IconModel> _setService(dynamic icon) {
    final Iterable refactor = (icon ?? []) as Iterable;
    return refactor.map((item) => IconModel.fromJson(item)).toList();
  }

  static List<ImageModel> _setPhoto(dynamic photo) {
    final Iterable refactor = (photo ?? []) as Iterable;
    return refactor.map((item) => ImageModel.fromJson(item)).toList();
  }

  static List<ProductModel> _setFeature(dynamic feature) {
    final Iterable refactor = (feature ?? []) as Iterable;
    return refactor.map((item) => ProductModel.fromJson(item)).toList();
  }

  static List<ProductModel> _setNearly(dynamic nearly) {
    final Iterable refactor = (nearly ?? []) as Iterable;
    return refactor.map((item) => ProductModel.fromJson(item)).toList();
  }

  static List<ProductModel> _setRelated(dynamic related) {
    final Iterable refactor = (related ?? []) as Iterable;
    return refactor.map((item) => ProductModel.fromJson(item)).toList();
  }

  static LocationModel _setLocation(Map<String, dynamic>? location) {
    return LocationModel.fromJson(location ?? {});
  }

  static UserModel _setAuthor(Map<String, dynamic>? author) {
    return UserModel.fromJson(author ?? {});
  }

  static ProductType _setType(String? type) {
    switch (type) {
      case 'hotel':
        return ProductType.hotel;
      case 'shop':
        return ProductType.shop;
      case 'drink':
        return ProductType.drink;
      case 'event':
        return ProductType.event;
      case 'estate':
        return ProductType.estate;
      case 'job':
        return ProductType.job;
      case 'restaurant':
        return ProductType.restaurant;
      case 'automotive':
        return ProductType.automotive;
      default:
        return ProductType.place;
    }
  }

  factory HotelProductModel.fromJson(Map<String, dynamic> json) {
    return HotelProductModel(
      json['id'] as int? ?? 0,
      json['title'] as String? ?? 'Unknown',
      json['subtitle'] as String? ?? 'Unknown',
      json['image'] as String? ?? 'Unknown',
      json['created_date'] as String? ?? 'Unknown',
      json['like'] as bool? ?? false,
      json['rate'] as num? ?? 0,
      json['num_rate'] as num? ?? 0,
      json['rate_text'] as String? ?? 'Unknown',
      json['status'] as String? ?? 'Unknown',
      json['favorite'] as bool? ?? false,
      json['address'] as String? ?? 'Unknown',
      json['phone'] as String? ?? 'Unknown',
      json['email'] as String? ?? 'Unknown',
      json['website'] as String? ?? 'Unknown',
      json['hour'] as String? ?? 'Unknown',
      json['description'] as String? ?? 'Unknown',
      json['date'] as String? ?? 'Unknown',
      json['price_range'] as String? ?? 'Unknown',
      _setHourDetail(json['hour_detail']),
      _setService(json['service']),
      _setPhoto(json['photo']),
      _setFeature(json['feature']),
      _setRelated(json['related']),
      _setLocation(json['location']),
      _setAuthor(json['author']),
      _setType(json['type']),
      _setNearly(json['nearly']),
    );
  }
}
