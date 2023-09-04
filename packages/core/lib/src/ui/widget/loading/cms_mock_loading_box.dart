import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';

class CmsMockLoadingBox extends StatelessWidget {
  final double height;
  final double width;
  final EdgeInsets? padding;

  const CmsMockLoadingBox({
    super.key,
    this.height = 6,
    this.width = 60,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Shimmer.fromColors(
        baseColor: context.colors.field,
        highlightColor: context.colors.field.withOpacity(0.2),
        child: Container(
          height: height,
          width: width,
          color: context.colors.canvas,
        ),
      ),
    );
  }
}
