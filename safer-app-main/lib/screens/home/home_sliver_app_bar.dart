import 'package:flutter/material.dart';
import 'package:safer/models/model.dart';
import 'package:safer/screens/home/home_swiper.dart';

class AppBarHomeSliver extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final List<ImageModel> banners;

  AppBarHomeSliver({
    required this.expandedHeight,
    required this.banners,
  });

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: HomeSwipe(
            images: banners,
            height: expandedHeight,
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 120;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
