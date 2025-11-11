import 'package:flutter/material.dart';
import 'screens/add_habitat_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Earthy color palette
    const Color lightBeige = Color(0xFFDAD7CD);
    const Color sageGreen = Color(0xFFA3B18A);
    const Color mediumGreen = Color(0xFF588157);
    const Color darkGreen = Color(0xFF3A5A40);
    const Color veryDarkGreen = Color(0xFF344E41);

    return MaterialApp(
      title: 'Habitat App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: mediumGreen,
          onPrimary: Colors.white,
          secondary: sageGreen,
          onSecondary: veryDarkGreen,
          tertiary: darkGreen,
          onTertiary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: veryDarkGreen,
          surfaceVariant: sageGreen.withOpacity(0.3),
          onSurfaceVariant: darkGreen,
          outline: darkGreen,
          shadow: veryDarkGreen.withOpacity(0.3),
          inverseSurface: veryDarkGreen,
          onInverseSurface: lightBeige,
          inversePrimary: sageGreen,
          primaryContainer: sageGreen.withOpacity(0.3),
          onPrimaryContainer: darkGreen,
          secondaryContainer: lightBeige,
          onSecondaryContainer: veryDarkGreen,
          tertiaryContainer: mediumGreen.withOpacity(0.3),
          onTertiaryContainer: veryDarkGreen,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HabitatHomePage(),
    );
  }
}

