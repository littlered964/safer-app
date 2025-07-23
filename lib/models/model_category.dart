import 'package:flutter/cupertino.dart';
import 'package:safer/models/model.dart';
import 'package:safer/utils/utils.dart';

class CategoryModel {
  final int id;
  final String title;
  final int count;
  final String image;
  final IconData icon;
  final Color color;
  final ProductType type;

  CategoryModel({
    required this.id,
    required this.title,
    required this.count,
    required this.image,
    required this.icon,
    required this.color,
    required this.type,
  });

  static ProductType _setType(String type) {
    switch (type) {
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
      case 'hotel':
        return ProductType.hotel;
      default:
        return ProductType.more;
    }
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final icon = UtilIcon.getIconData(json['icon'] ?? "Unknown");
    final color = UtilColor.getColorFromHex(json['color'] ?? "#ff8a65");

    return CategoryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      count: json['count'] ?? 0,
      image: json['image'] ?? 'Unknown',
      icon: icon,
      color: color,
      type: _setType(json['type'] ?? "Unknown"),
    );
  }
}
