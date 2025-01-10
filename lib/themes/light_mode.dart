import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.grey.shade300,
    background: const Color(0xFFF6F6F6),
    inversePrimary: Colors.grey.shade900,
  ),
);




// import 'package:flutter/material.dart';

// ThemeData lightMode = ThemeData(
//   colorScheme: const ColorScheme.light(
//     primary: Color(0xFFF6F6F6),
//     secondary: Color(0xFFE65125),
//     surface: Color(0xFFF6F6F6),
//     background: Color(0xFFF6F6F6),
//     error: Color(0xFFE65125),
//     onPrimary: Color(0xFFE65125),
//     onSecondary: Color(0xFFF6F6F6),
//     onSurface: Color(0xFF1E1E1E),
//     onBackground: Color(0xFFE65125),
//     onError: Color(0xFF000000),
//     errorContainer: Color(0xFFCF6679),
//     outline: Color(0xFFE65125),
//     scrim: Color(0xFF1E1E1E),
//   ),
//   brightness: Brightness.light,
//   fontFamily: 'Poppins',
//   textSelectionTheme: const TextSelectionThemeData(
//     cursorColor: Color(0xFFE65125),
//     selectionColor: Color.fromARGB(255, 238, 195, 172),
//     selectionHandleColor: Color.fromARGB(255, 238, 195, 172),
//   ),
//   disabledColor: Color(0xFFF0F0F0),
//   elevatedButtonTheme: ElevatedButtonThemeData(
//     style: ButtonStyle(
//       backgroundColor: MaterialStateProperty.resolveWith<Color?>(
//         (Set<MaterialState> states) {
//           if (states.contains(MaterialState.disabled)) {
//             return Color(
//                 0xFFF0F0F0); // Custom background color for disabled state
//           }
//           return null; // Use default color for other states
//         },
//       ),
//       foregroundColor: MaterialStateProperty.resolveWith<Color?>(
//         (Set<MaterialState> states) {
//           if (states.contains(MaterialState.disabled)) {
//             return Colors.grey[400]; // Custom text color for disabled state
//           }
//           return null; // Use default color for other states
//         },
//       ),
//     ),
//   ),
// );
