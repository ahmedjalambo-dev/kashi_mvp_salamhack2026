import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum KashiLogoType {
  /// The full wordmark logo (English and Arabic)
  wordmark,
  
  /// The standalone tatreez star mark
  mark,
}

/// Renders the Kashi brand logo or mark.
/// 
/// Automatically loaded from local assets. 
class KashiLogo extends StatelessWidget {
  const KashiLogo({
    super.key,
    this.type = KashiLogoType.wordmark,
    this.height = 32,
    this.width,
  });

  final KashiLogoType type;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final assetPath = switch (type) {
      KashiLogoType.wordmark => 'assets/images/kashi-logo.svg',
      KashiLogoType.mark => 'assets/images/kashi-mark.svg',
    };

    return SvgPicture.asset(
      assetPath,
      height: height,
      width: width,
      fit: BoxFit.contain,
    );
  }
}
