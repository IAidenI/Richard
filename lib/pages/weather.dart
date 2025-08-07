import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:richard/ui/customFonts.dart';
import '../modeles/weatherAPI.dart';
import '../assets/constants.dart';
import '../ui/customUI.dart';

class Weather extends StatefulWidget {
  const Weather({super.key});

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  late final String _date;

  final Weatherapi _weather = Weatherapi();
  ColorCode _currentWeather = ColorCode.UNKNOW;

  AssetImage _background = AssetImage("assets/background/no_signal.png");
  AssetImage _backgroundMenu = AssetImage("assets/menu/no_signal.png");

  bool _isLoaded = false;
  bool dayChoice = true;

  String getCurrentDate() {
    // Formate la date sous le bon format
    DateTime now = DateTime.now();
    String day = DateFormat("EEEE").format(now);
    String month = DateFormat("MMMM").format(now);
    String number = DateFormat("d").format(now);
    String year = DateFormat("yyyy").format(now);
    return "${DAY[day]} $number ${MONTH[month]} $year";
  }

  @override
  void initState() {
    super.initState();
    _date = getCurrentDate();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    await _weather.fetchWeather();
    setState(() {
      _currentWeather = weatherCode[_weather.getWeather] ?? ColorCode.UNKNOW;
      switch (_currentWeather) {
        case ColorCode.SUN:
          _background = AssetImage("assets/background/sun.png");
          _backgroundMenu = AssetImage("assets/menu/sun.png");
          break;
        case ColorCode.SOME_CLOUDS:
          _background = AssetImage("assets/background/some_clouds.png");
          _backgroundMenu = AssetImage("assets/menu/some_clouds.png");

          break;
        case ColorCode.CLOUDS:
          _background = AssetImage("assets/background/clouds.png");
          _backgroundMenu = AssetImage("assets/menu/clouds.png");

          break;
        case ColorCode.RAIN:
          _background = AssetImage("assets/background/rain.png");
          _backgroundMenu = AssetImage("assets/menu/rain.png");

          break;
        case ColorCode.SNOW:
          _background = AssetImage("assets/background/snow.png");
          _backgroundMenu = AssetImage("assets/menu/snow.png");

          break;
        case ColorCode.THUNDERSTORM:
          _background = AssetImage("assets/background/thunderstorm.png");
          _backgroundMenu = AssetImage("assets/menu/thunderstorm.png");

          break;
        case ColorCode.HAIL:
          _background = AssetImage("assets/background/hail.png");
          _backgroundMenu = AssetImage("assets/menu/hail.png");

          break;
        case ColorCode.UNKNOW:
          _background = AssetImage("assets/background/no_signal.png");
          _backgroundMenu = AssetImage("assets/menu/no_signal.png");

          break;
      }
      _isLoaded = true;
    });
    _weather.printData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sépare l'écran en deux,
          // Partie du bas : 60%
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              // Affichage de l'image de fond
              decoration: BoxDecoration(
                image: DecorationImage(image: _background, fit: BoxFit.fill),
              ),
              child: Stack(
                children: [
                  // Affichage du nom de la ville
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        width: _isLoaded ? 165 : 295,
                        child: CustomPaint(
                          painter: FrameTitle(
                            padding: 16.0,
                            weather: _currentWeather,
                          ),
                          child: Center(
                            // Si les données sont chargé affichage du nom de la ville
                            // sinon affichage d'un message d'information
                            child: _isLoaded
                                ? CityAutoComplete(
                                    currentData: _weather.getCodeInsee,
                                    dataList: cityTable,
                                    style: CustomFonts.cityStyle(
                                      _currentWeather,
                                      _isLoaded,
                                    ),
                                    onSelected: (City selectedCity) {
                                      if (_weather.getCodeInsee !=
                                          selectedCity.getCodeInsee) {
                                        _weather.setCodeInsee =
                                            selectedCity.getCodeInsee;
                                        _loadWeather();
                                      }
                                    },
                                  )
                                : Text(
                                    "Vérifiez votre connexion internet",
                                    style: CustomFonts.cityStyle(
                                      _currentWeather,
                                      _isLoaded,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Affichage du cercle
                  GestureDetector(
                    onTap: () {
                      if (_isLoaded) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => PopupDisplayInfos(
                            title: "Plus d'informations",
                            content: {
                              "Raffales de vents : ": _weather.getGustWind,
                              "Probabilité de pluie : ": _weather.getProbaRain,
                              "Probabilité de gel : ": _weather.getProbaFrost,
                              "Probabilité de brouillard : ":
                                  _weather.getProbaFog,
                            },
                            style: PopupColorCode(_currentWeather),
                          ),
                        );
                      }
                    },

                    child: Center(
                      child: SizedBox(
                        width: 200,
                        height: 200,

                        child: CustomPaint(
                          painter: WeatherCircle(_currentWeather),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Météo
                                Text(
                                  _isLoaded
                                      ? _weather.getWeatherDescription
                                      : "Inconnu",
                                  style: CustomFonts.weatherStyle(
                                    _currentWeather,
                                  ),
                                ),
                                // Température
                                Text(
                                  _isLoaded ? _weather.getTemperature : "--°",
                                  style: CustomFonts.temperatureStyle(
                                    _currentWeather,
                                  ),
                                ),
                                // Humidité + Vent
                                Text(
                                  _isLoaded
                                      ? "H : ${_weather.getHumidity} - V : ${_weather.getWind}"
                                      : "H : --% - V : --km/h",
                                  style: CustomFonts.moreInfosStyle(
                                    _currentWeather,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Affichage de la date
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        _date,
                        style: CustomFonts.dateStyle(_currentWeather),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Partie du bas : 40%
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              // Affichage de l'image de fond
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _backgroundMenu,
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                children: [
                  // Affiche le switch DAY/WEEK
                  SwitchLine(
                    width: 200,
                    day: dayChoice,
                    onTap: () {
                      setState(() {
                        dayChoice = !dayChoice;
                      });
                    },
                  ),

                  const SizedBox(height: 40),

                  // Affiche le carousel
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dayChoice
                          ? _weather.getHourlyData.length
                          : _weather.getDailyData.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      itemBuilder: (context, index) {
                        final h = dayChoice
                            ? _weather.getHourlyData[index]
                            : _weather.getDailyData[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: WeatherCard(
                            title: h.formattedTime(),
                            temperature: h.formattedTemp,
                            weather: weatherCode[h.weather] ?? ColorCode.UNKNOW,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
