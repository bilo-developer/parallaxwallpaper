import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/wallpaper_creator.dart';
import 'screens/parallax_creator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WallPers',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/main': (context) => MainScreen(),
        '/create_wallpaper': (context) => WallpaperCreator(),
        '/create_parallax': (context) => ParallaxCreator(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/create_wallpaper' ||
            settings.name == '/create_parallax') {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return settings.name == '/create_wallpaper'
                  ? WallpaperCreator()
                  : ParallaxCreator();
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          );
        }
        return null;
      },
    );
  }
}
