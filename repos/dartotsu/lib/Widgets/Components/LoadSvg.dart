import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget loadSvg(String iconPath, {double? width, double? height, Color? color}) {
  return SvgPicture.asset(
    iconPath,
    width: width,
    height: height,
    colorFilter: color == null
        ? null
        : ColorFilter.mode(color, BlendMode.srcIn),
  );
}

Widget assetIcon(String path, {required double size}) {
  if (path.endsWith('.svg')) {
    return SvgPicture.asset(path, width: size, height: size, fit: BoxFit.cover);
  }
  return Image.asset(path, width: size, height: size, fit: BoxFit.cover);
}
