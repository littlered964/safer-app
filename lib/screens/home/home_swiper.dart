import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:safer/models/model.dart';
import 'package:shimmer/shimmer.dart';

class HomeSwipe extends StatelessWidget {
  final List<ImageModel> images;
  final double? height;

  const HomeSwipe({
    super.key,
    required this.images,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isNotEmpty) {
      return SizedBox(
        height: height ?? 200,
        child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            return Image.asset(
              images[index].image,
              fit: BoxFit.cover,
            );
          },
          autoplayDelay: 3000,
          autoplayDisableOnInteraction: false,
          autoplay: true,
          itemCount: images.length,
          pagination: SwiperPagination(
            alignment: Alignment.bottomCenter,
            builder: SwiperPagination.dots,
          ),
        ),
      );
    }

    return SizedBox(
      height: height ?? 200,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).hoverColor,
        highlightColor: Theme.of(context).highlightColor,
        enabled: true,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }
}
