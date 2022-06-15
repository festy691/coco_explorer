import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ItemLoadingView extends StatelessWidget {
  const ItemLoadingView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.3),
      highlightColor: Colors.white,
      child: Container(
        height: 200,
        color: Colors.white,
        alignment: Alignment.center,
      ),
    );
  }
}