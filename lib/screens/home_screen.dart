import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pixel_weather/models/weather_model.dart';
import 'package:pixel_weather/models/location_model.dart';
import 'package:pixel_weather/services/weather_background.dart';
import 'package:pixel_weather/widgets/rain_animation.dart';
import 'package:pixel_weather/widgets/snow_animation.dart';
import 'package:pixel_weather/widgets/weather_details_grid.dart';
import 'package:pixel_weather/widgets/forecast_item.dart';
import 'package:pixel_weather/widgets/clothing_suggestion.dart';
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
  late ScrollController _forecastScrollController;

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
    _forecastScrollController = ScrollController();

    // Build sonrası konumu al (Provider state değişikliğini önlemek için)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeather();
    });
  }

  Future<void> _loadWeather() async {
    final locationModel = Provider.of<LocationModel>(context, listen: false);
    await locationModel.fetchCurrentLocation();

    if (locationModel.cityName != null && locationModel.cityName!.isNotEmpty) {
      Provider.of<WeatherModel>(
        context,
        listen: false,
      ).fetchWeather(locationModel.cityName!);
    } else {
      // Konum alınamazsa fallback şehir
      debugPrint('Location not available: ${locationModel.error}');
      Provider.of<WeatherModel>(context, listen: false).fetchWeather('Ankara');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rainController.dispose();
    _snowController.dispose();
    _forecastScrollController.dispose();
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

  List<dynamic> _getDailyForecast(List<dynamic> list) {
    final Map<String, dynamic> dailyMap = {};
    for (var item in list) {
      final dateStr = item['dt_txt'].toString().split(' ')[0];
      // Eğer o gün için henüz kayıt yoksa veya bu kayıt öğlen 12'ye daha yakınsa (tercihen)
      // Basitlik için: İlk kaydı alıyoruz, sonra 12:00'ye yakın olanı güncelliyoruz.
      if (!dailyMap.containsKey(dateStr)) {
        dailyMap[dateStr] = item;
      } else {
        // Mevcut kaydın saati
        final currentItemTime = DateTime.parse(dailyMap[dateStr]['dt_txt']);
        final newItemTime = DateTime.parse(item['dt_txt']);

        // Öğle saatine (12:00) yakınlık kontrolü
        if ((newItemTime.hour - 12).abs() < (currentItemTime.hour - 12).abs()) {
          dailyMap[dateStr] = item;
        }
      }
    }
    return dailyMap.values.toList();
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
              SingleChildScrollView(
                child: Center(
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.08,
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
                            // stroke
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 6.0,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Text(
                          weatherModel
                                  .weatherData?['weather']?[0]?['description']
                                  ?.toString()
                                  .toUpperCase() ??
                              '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 4.0,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
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
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 6.0,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
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
                            fontSize:
                                MediaQuery.of(context).size.height * 0.017,
                            color: Theme.of(context).primaryColor,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 6.0,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.12,
                        ),

                        // 5 günlük tahmin kartları
                        if (weatherModel.weatherData != null) ...[
                          ClothingSuggestion(
                            temp:
                                (weatherModel.weatherData!['main']['temp']
                                        as num)
                                    .toDouble(),
                            weatherMain:
                                weatherModel
                                    .weatherData?['weather']?[0]?['main'] ??
                                '',
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                        ],

                        if (weatherModel.forecastData != null) ...[
                          Container(
                            height:
                                140, // Increased height to accommodate scrollbar
                            margin: const EdgeInsets.only(top: 10, bottom: 20),
                            child: RawScrollbar(
                              controller: _forecastScrollController,
                              thumbColor: Colors.white.withOpacity(0.4),
                              radius: const Radius.circular(10),
                              thickness: 4,
                              thumbVisibility: true,
                              // Barı ortalamak ve küçültmek için kenarlardan boşluk bırakıyoruz
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.25,
                                vertical: 2, // Biraz aşağıdan boşluk
                              ),
                              child: ListView.builder(
                                controller: _forecastScrollController,
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  bottom: 20, // Bar için yer
                                ),
                                itemCount: _getDailyForecast(
                                  weatherModel.forecastData!['list'],
                                ).length,
                                itemBuilder: (context, index) {
                                  final dailyList = _getDailyForecast(
                                    weatherModel.forecastData!['list'],
                                  );
                                  final item = dailyList[index];
                                  final date = DateTime.parse(item['dt_txt']);
                                  final dayStr = switch (date.weekday) {
                                    1 => 'Pzt',
                                    2 => 'Sal',
                                    3 => 'Çar',
                                    4 => 'Per',
                                    5 => 'Cum',
                                    6 => 'Cmt',
                                    7 => 'Paz',
                                    _ => '',
                                  };
                                  final temp = (item['main']['temp'] as num)
                                      .round();
                                  final icon = item['weather'][0]['icon'];

                                  return ForecastItem(
                                    time: dayStr,
                                    iconCode: icon,
                                    temp: temp,
                                  );
                                },
                              ),
                            ),
                          ),

                          // Detaylar en alta taşındı
                          if (weatherModel.weatherData != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 40.0,
                                top: 10.0,
                              ),
                              child: WeatherDetailsGrid(
                                humidity:
                                    weatherModel
                                        .weatherData!['main']['humidity'] ??
                                    0,
                                windSpeed:
                                    (weatherModel
                                                .weatherData!['wind']['speed'] ??
                                            0)
                                        .toDouble(),
                              ),
                            ),
                        ],
                      ],
                    ),
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
