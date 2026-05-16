import 'package:flutter/material.dart';
import 'package:quran_a_day/app/theme.dart';

class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key, this.width = 60});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: width,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                context.goldColor,
                Colors.transparent,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.star, size: 10, color: context.goldColor),
          //  TODO?:            Icon(Icons.star_four_points, size: 10, color: context.goldColor),
        ),
        Container(
          width: width,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                context.goldColor,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
