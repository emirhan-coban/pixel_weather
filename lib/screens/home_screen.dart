import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pixel_weather/models/weather_model.dart';
import 'package:pixel_weather/models/location_model.dart';
import 'package:pixel_weather/services/weather_background.dart';
import 'package:pixel_weather/widgets/rain_animation.dart';
import 'package:pixel_weather/widgets/snow_animation.dart';
import 'package:pixel_weather/widgets/is_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rainController;
  late AnimationController _snowController;
  bool _isRainPlaying = false;
  bool _isSnowPlaying = false;

  @override
  void initState() {
    super.initState();
    // Yanıp sönen animasyon
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _rainController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _snowController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    // Build sonrası konumu al (Provider state değişikliğini önlemek için)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeather();
    });
  }

  Future<void> _loadWeather() async {
    final locationModel = Provider.of<LocationModel>(context, listen: false);
    await locationModel.fetchCurrentLocation();

    if (locationModel.cityName != null) {
      Provider.of<WeatherModel>(
        context,
        listen: false,
      ).fetchWeather(locationModel.cityName!);
    } else {
      Provider.of<WeatherModel>(
        context,
        listen: false,
      ).fetchWeather('Istanbul');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rainController.dispose();
    _snowController.dispose();
    super.dispose();
  }

  void _syncRainAnimation(bool shouldPlay) {
    if (shouldPlay && !_isRainPlaying) {
      _rainController.repeat();
      _isRainPlaying = true;
    } else if (!shouldPlay && _isRainPlaying) {
      _rainController.stop();
      _rainController.reset();
      _isRainPlaying = false;
    }
  }

  void _syncSnowAnimation(bool shouldPlay) {
    if (shouldPlay && !_isSnowPlaying) {
      _snowController.repeat();
      _isSnowPlaying = true;
    } else if (!shouldPlay && _isSnowPlaying) {
      _snowController.stop();
      _snowController.reset();
      _isSnowPlaying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherModel>(
      builder: (context, weatherModel, child) {
        // Hava durumuna göre background seç
        String? weatherMain = weatherModel.weatherData?['weather']?[0]?['main'];
        int? sunrise = weatherModel.sunrise;
        int? sunset = weatherModel.sunset;
        final shouldShowRain = WeatherBackground.shouldShowRainAnimation(
          weatherMain,
        );
        final shouldShowSnow = WeatherBackground.shouldShowSnowAnimation(
          weatherMain,
        );

        _syncRainAnimation(shouldShowRain);
        _syncSnowAnimation(shouldShowSnow);

        // Debug: Console'a hava durumunu yazdır
        debugPrint('Weather Data: ${weatherModel.weatherData}');
        debugPrint('Weather Main: $weatherMain');
        debugPrint('Sunrise: $sunrise, Sunset: $sunset');
        debugPrint('Is Loading: ${weatherModel.isLoading}');
        debugPrint('Error: ${weatherModel.error}');
        return Scaffold(
          body: Stack(
            children: [
              // Background en arkada (sunrise/sunset'e göre gece kontrolü)
              WeatherBackground.getBackgroundWidget(
                weatherMain,
                sunrise,
                sunset,
              ),

              if (shouldShowRain)
                Positioned.fill(
                  child: RainAnimation(animation: _rainController),
                ),

              if (shouldShowSnow)
                Positioned.fill(
                  child: SnowAnimation(animation: _snowController),
                ),

              // Yükleniyor ve Hata Overlay en önde
              LoadingOverlay(
                animationController: _animationController,
                isLoading: weatherModel.isLoading,
                error: weatherModel.error,
              ),

              // Şehir adı
              Center(
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1,
                    left: MediaQuery.of(context).size.height * 0.02,
                    right: MediaQuery.of(context).size.height * 0.02,
                  ),
                  child: Column(
                    children: [
                      Text(
                        weatherModel.weatherData?['name'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Text(
                        weatherModel.weatherData?['weather']?[0]?['description']
                                ?.toString()
                                .toUpperCase() ??
                            '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      // derece
                      Text(
                        weatherModel.weatherData?['main']?['temp'] != null
                            ? '${weatherModel.weatherData!['main']['temp'].round()}°C'
                            : '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.06,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      // max min derece
                      Text(
                        weatherModel.weatherData?['main']?['temp_min'] !=
                                    null &&
                                weatherModel
                                        .weatherData?['main']?['temp_max'] !=
                                    null
                            ? 'Min:${weatherModel.weatherData!['main']['temp_min'].round()}°C | Max:${weatherModel.weatherData!['main']['temp_max'].round()}°C'
                            : '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.017,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
