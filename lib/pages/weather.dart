import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:richard/ui/generalUI.dart';
import 'package:richard/ui/theme.dart';
import 'package:richard/modeles/weatherAPI.dart';
import 'package:richard/assets/constants.dart';
import 'package:richard/ui/weatherUI.dart';

class Weather extends StatefulWidget {
  const Weather({super.key});

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  late final String _date;

  WeatherTheme theme = WeatherTheme(ColorCode.UNKNOW);

  final Weatherapi _weather = Weatherapi();
  ColorCode _currentWeather = ColorCode.UNKNOW;

  int _reposition = 0;

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
    _init();
  }

  Future<void> _init() async {
    await _weather.initAPI();
    await _loadWeather();
  }

  Future<void> _loadWeather() async {
    await _weather.fetchWeather();
    setState(() {
      _currentWeather = weatherCode[_weather.getWeather] ?? ColorCode.UNKNOW;
      theme = WeatherTheme(_currentWeather);
      _isLoaded = _weather.isDataOk;
      _reposition++; // Rebuild l'autocomplete
    });
    _weather.printData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
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
                    image: DecorationImage(
                      image: theme.getBackground,
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Affichage du nom de la ville
                      Positioned(
                        top: 60,
                        left: 0,
                        right: 0,

                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: _isLoaded ? 165 : 295,
                              child: CustomPaint(
                                painter: FrameTitle(
                                  padding: 16.0,
                                  theme: theme,
                                ),
                                child: Center(
                                  // Si les données sont chargé affichage du nom de la ville
                                  // sinon affichage d'un message d'information
                                  child: _isLoaded
                                      ? CityAutoComplete(
                                          key: ValueKey(_reposition),
                                          currentData: _weather.getCodeInsee,
                                          dataList: cityTable,
                                          style: theme.cityStyle(_isLoaded),
                                          onSelected: (City selectedCity) {
                                            if (_weather.getCodeInsee !=
                                                selectedCity.getCodeInsee) {
                                              _weather.setCodeInsee =
                                                  selectedCity.getCodeInsee;
                                              _weather.disableGPS;
                                              _loadWeather();
                                            }
                                          },
                                        )
                                      : Text(
                                          "Vérifiez votre connexion internet",
                                          style: theme.cityStyle(_isLoaded),
                                        ),
                                ),
                              ),
                            ),

                            // Place un bouton à droite de l'autocomplete avec un offset de 70
                            Positioned(
                              right:
                                  MediaQuery.of(context).size.width / 2 -
                                  (_isLoaded ? 165 : 295) / 2 -
                                  70,
                              child: Material(
                                color: PopupColorCode(theme).getButtonColor,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () {
                                    final CodeErrorAPI ret = _weather.flag;
                                    // Vérifie si c'est pas déjà sur la position gps
                                    if (!_weather.isPositionGPS &&
                                        ret == CodeErrorAPI.GEOLOC_OK) {
                                      _weather.enableGPS;
                                      _loadWeather();

                                      // Affiche un message pour indiqué la le repositionnement
                                      InfoDisplayer.buildInfoDisplayer(
                                        context,
                                        "Position GPS",
                                      );
                                      // Sinon affiche un message
                                    } else {
                                      switch (ret) {
                                        case CodeErrorAPI
                                            .GEOLOC_SERVICE_DISABLE:
                                          InfoDisplayer.buildInfoDisplayer(
                                            context,
                                            "Service désactiver",
                                          );
                                          break;
                                        case CodeErrorAPI
                                            .GEOLOC_PERMISSION_DENIED:
                                          InfoDisplayer.buildInfoDisplayer(
                                            context,
                                            "Permissons refusé",
                                            action: SnackBarAction(
                                              label: 'Settings',
                                              onPressed: () {
                                                Geolocator.openAppSettings();
                                              },
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 50,
                                              vertical: 20,
                                            ),
                                            duration: const Duration(
                                              seconds: 3,
                                            ),
                                          );
                                          break;
                                        case CodeErrorAPI.GEOLOC_FOREVER_DENIED:
                                          InfoDisplayer.buildInfoDisplayer(
                                            context,
                                            "Permission refusé pour toujours",
                                            action: SnackBarAction(
                                              label: 'Settings',
                                              onPressed: () {
                                                Geolocator.openAppSettings();
                                              },
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 50,
                                              vertical: 20,
                                            ),
                                            duration: const Duration(
                                              seconds: 3,
                                            ),
                                          );
                                          break;
                                        case CodeErrorAPI.GEOLOC_OK:
                                          InfoDisplayer.buildInfoDisplayer(
                                            context,
                                            "Déjà sur la position GPS",
                                          );
                                          break;
                                        case CodeErrorAPI.DEFAULT:
                                          InfoDisplayer.buildInfoDisplayer(
                                            context,
                                            "ERROR",
                                          );
                                          break;
                                      }
                                    }
                                  },
                                  // Affiche l'icon de gps
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.gps_fixed,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Affichage du cercle
                      Center(
                        child: SizedBox(
                          width: 200,
                          height: 200,

                          child: CustomPaint(
                            painter: WeatherCircle(theme),
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
                                    style: theme.weatherStyle(),
                                  ),
                                  // Température
                                  Text(
                                    _isLoaded ? _weather.getTemperature : "--°",
                                    style: theme.temperatureStyle(),
                                  ),
                                  // Humidité + Vent
                                  Text(
                                    _isLoaded
                                        ? "H : ${_weather.getHumidity} - V : ${_weather.getWind}"
                                        : "H : --% - V : --km/h",
                                    style: theme.moreInfosStyle(),
                                  ),
                                ],
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
                          child: Text(_date, style: theme.dateStyle()),
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
                      image: theme.getBackgroundMenu,
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Affiche le switch DAY/WEEK
                      SwitchLine(
                        theme: theme,
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
                                weather:
                                    weatherCode[h.getWeather] ??
                                    ColorCode.UNKNOW,
                                theme: theme,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => PopupDisplayInfos(
                                      title: "Plus d'informations",
                                      content: {
                                        "Raffales de vents : ": dayChoice
                                            ? _weather
                                                  .getHourlyData[index]
                                                  .getFormattedGustWind
                                            : _weather
                                                  .getDailyData[index]
                                                  .getFormattedGustWind,
                                        "Probabilité de pluie : ": dayChoice
                                            ? _weather
                                                  .getHourlyData[index]
                                                  .getFormattedProbaRain
                                            : _weather
                                                  .getDailyData[index]
                                                  .getFormattedProbaRain,
                                        "Probabilité de gel : ": dayChoice
                                            ? _weather
                                                  .getHourlyData[index]
                                                  .getFormattedProbaFrost
                                            : _weather
                                                  .getDailyData[index]
                                                  .getFormattedProbaFrost,
                                        "Probabilité de brouillard : ":
                                            dayChoice
                                            ? _weather
                                                  .getHourlyData[index]
                                                  .getFormattedProbaFog
                                            : _weather
                                                  .getDailyData[index]
                                                  .getFormattedProbaFog,
                                      },
                                      style: PopupColorCode(theme),
                                    ),
                                  );
                                },
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

          Align(alignment: Alignment.bottomRight, child: FloatingMenu(theme)),

          // Affichage d'un widget d'attente
          _weather.isReady
              ? const SizedBox.shrink()
              : Stack(
                  key: const ValueKey('loading'),
                  children: const [
                    ModalBarrier(
                      dismissible: false,
                      color: Color.fromARGB(100, 0, 0, 0),
                    ),
                    // Ton popup centré et à taille fixe
                    Center(child: LoadingScreen()),
                  ],
                ),
        ],
      ),
    );
  }
}
