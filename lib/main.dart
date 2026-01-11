import 'package:flutter/material.dart';
import 'package:pixel_weather/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:pixel_weather/models/weather_model.dart';
import 'package:pixel_weather/models/location_model.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherModel()),
        ChangeNotifierProvider(create: (context) => LocationModel()),
      ],
      child: MaterialApp(
        title: 'Pixel Weather',
        debugShowCheckedModeBanner: false,
        theme: darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
