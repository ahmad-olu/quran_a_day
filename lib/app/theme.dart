import 'package:flutter/material.dart';

// class AppColors {
//   static const lightBrown = Color(0xFFB59379);
//   static const mediumBrown = Color(0xFF8B5E3C);
//   static const darkBrown = Color(0xFF4E2A1F);
//   static const backgroundLight = Color(0xFFF6F1E7);
//   static const backgroundDark = Color(0xFF1E1E1E);
// }

// class AppTextStyles {
//   static const headline1 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
//   static const bodyText1 =
//       TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
//   static const caption = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
// }

// ThemeData lightTheme = ThemeData.light().copyWith(
//   brightness: Brightness.light,
//   primaryColor: AppColors.mediumBrown,
//   scaffoldBackgroundColor: AppColors.backgroundLight,
//   textTheme: const TextTheme(
//     displayLarge: AppTextStyles.headline1,
//     bodyMedium: AppTextStyles.bodyText1,
//     bodySmall: AppTextStyles.caption,
//   ).apply(
//     bodyColor: AppColors.darkBrown,
//     displayColor: AppColors.darkBrown,
//   ),
//   appBarTheme: AppBarTheme(
//     backgroundColor: AppColors.lightBrown,
//     titleTextStyle:
//         AppTextStyles.headline1.copyWith(color: AppColors.darkBrown),
//   ),
//   // elevatedButtonTheme: ElevatedButtonThemeData(
//   //   style: ElevatedButton.styleFrom(primary: AppColors.mediumBrown),
//   // ),
// );

// ThemeData darkTheme = ThemeData.dark().copyWith(
//   brightness: Brightness.dark,
//   primaryColor: AppColors.darkBrown,
//   scaffoldBackgroundColor: AppColors.backgroundDark,
//   textTheme: const TextTheme(
//     displayLarge: AppTextStyles.headline1,
//     bodyMedium: AppTextStyles.bodyText1,
//     bodySmall: AppTextStyles.caption,
//   ).apply(
//     bodyColor: Colors.white,
//     displayColor: Colors.white,
//   ),
//   appBarTheme: AppBarTheme(
//     backgroundColor: AppColors.darkBrown,
//     titleTextStyle: AppTextStyles.headline1.copyWith(color: Colors.white),
//   ),
//   // elevatedButtonTheme: ElevatedButtonThemeData(
//   //   style: ElevatedButton.styleFrom(primary: AppColors.lightBrown),
//   // ),
// );

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextStyle get headline1 => theme.textTheme.displayLarge!;
  TextStyle get bodyText1 => theme.textTheme.bodyMedium!;
  TextStyle get caption => theme.textTheme.bodySmall!;

  Color get textColor =>
      theme.brightness == Brightness.light ? Colors.black : Colors.white;
}
