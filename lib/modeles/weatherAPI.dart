import 'dart:convert';
import '../assets/constants.dart';
import 'package:http/http.dart' as http;
/*
// Donnée du actuelle
curl "https://api.meteo-concept.com/api/forecast/nextHours?token=${TOKEN}&insee=31395" | jq '{name: .city.name} + (.forecast[0] | {datetime, temp2m, rh2m, wind10m, weather})'

// Données pour les 12 prochaines heures (de 00h à 11h ou 12h à 23h en fonction de l'heure actuelle)
curl "https://api.meteo-concept.com/api/forecast/nextHours?token=${TOKEN}&insee=31395&hourly=true" | jq '.forecast[] | {datetime, temp2m, rh2m, weather, wind10m, gust10m, rr10}'

// Données pour les 14 prochaines jours
curl "https://api.meteo-concept.com/api/forecast/daily?token=${TOKEN}&insee=31395" | jq '.forecast[] | {datetime, day, tmin, tmax, probarain, weather, wind10m, gust10m}'
*/

class Weatherapi {
  // Données pour la connexion à l'api
  static const String _token =
      "fd59e845bda91b5102cd99cf81c99783a28cfcff98d683dc1f9f44c7c60e3c33";
  String _insee = "63113"; // Toulouse : 31555 ; Paris : 75056 ; Muret : 31395
  static const String _url = "https://api.meteo-concept.com/api";
  static const Map<When, String> _endpoints = {
    When.NOW: "/forecast/nextHours",
    When.HOURLY: "/forecast/nextHours",
    When.DAILY: "/forecast/daily",
  };

  String get getCodeInsee => _insee;
  set setCodeInsee(String insee) => _insee = insee;

  String _cityName = "";

  // Données pour le stockage de la météo actuelle
  int _currentTemp = -100;
  int _currentWind = -1;
  int _currentHumidity = -1;
  int _currentWeather = -1;

  // Pour les informations supplémentaires
  int _gustWind = -1;
  int _probaRain = -1;
  int _probaFrost = -1;
  int _probaFog = -1;

  // Données pour les 12 prochaines heures
  List<HourlyData> _hourlyData = [
    HourlyData(hour: -2, temp: -100, weather: -1),
    HourlyData(hour: -2, temp: -100, weather: -1),
    HourlyData(hour: -2, temp: -100, weather: -1),
  ];

  // Données pour les 7 prochains jours
  List<DailyData> _dailyData = [
    DailyData(day: -1, tempMax: -100, tempMin: -100, weather: -1),
    DailyData(day: -1, tempMax: -100, tempMin: -100, weather: -1),
    DailyData(day: -1, tempMax: -100, tempMin: -100, weather: -1),
  ];

  // Appelle l'api
  Future<void> fetchWeather() async {
    print("[ DEBUG ] Fetching data...");
    await fetchWeatherHourly();
    await fetchWeatherDaily();
    print("[ OK ] Data feched.");
    print("");
  }

  /*
    Permet d'appeler l'api et de récuperer les informations de la journée
    Permet donc également de récupèrer les informations actuelle
  */
  Future<void> fetchWeatherHourly() async {
    String url =
        "$_url${_endpoints[When.HOURLY]}?token=$_token&insee=$_insee&hourly=true";

    // Appele de l'api
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      _cityName = json['city']['name'];

      final List forecasts = json['forecast'];

      // Formatte la date actuelle
      final now = DateTime.now();
      final DateTime currentDate = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
      );
      _hourlyData = [];

      // Récupère tout les informations sur les 12 prochaines heures
      for (var forecast in forecasts) {
        String dateStr = forecast['datetime'];

        // Récupère et formatte la date reçue
        DateTime date = DateTime.parse(
          dateStr.replaceFirstMapped(RegExp(r'(\+|-)(\d{2})(\d{2})$'), (m) {
            return '${m[1]}${m[2]}:${m[3]}';
          }),
        ).toLocal();

        // Récupère les données actuelle
        if (date == currentDate) {
          // Stock les infos du jour
          _currentTemp = forecast['temp2m'];
          _currentWind = forecast['wind10m'];
          _currentHumidity = forecast['rh2m'];
          _currentWeather = forecast['weather'];

          // Stock les infos supplémentaires
          _gustWind = forecast['gust10m'];
          _probaRain = forecast['probarain'];
          _probaFrost = forecast['probafrost'];
          _probaFog = forecast['probafog'];

          // Change la valeur actuelle pour que la regex casse
          // et pouvoir afficher NOW pour la date actuelle
          dateStr = "X";
        }

        // Filtre pour supprimé les prévisions passées
        if (!date.isBefore(currentDate)) {
          // Récupère les données pour les 12 prochaines heures
          final match = RegExp(r'T(\d{2}):').firstMatch(dateStr);
          _hourlyData.add(
            HourlyData(
              hour: match != null ? int.parse(match.group(1)!) : -1,
              temp: forecast['temp2m'],
              weather: forecast['weather'],
            ),
          );
        }
      }
    } else {
      throw Exception("Failed to load weather");
    }
  }

  /*
    Permet d'appeler l'api et de récuperer les informations sur les 7 prochains jours
  */
  Future<void> fetchWeatherDaily() async {
    String url = "$_url${_endpoints[When.DAILY]}?token=$_token&insee=$_insee";

    // Appele de l'api
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List forecasts = json['forecast'];

      // Converti le jour actuelle en un nombre (ex Lundi: 1, Mardi: 2...)
      final now = DateTime.now();
      final int dayNumber = now.weekday;
      _dailyData = [];

      // Récupère les données pour les 7 prochains jours
      for (var forecast in forecasts) {
        // Day == 1 correspond au jour actuelle donc on ignore
        if (forecast['day'] == 0) {
          continue;
        }

        // Ajoute au jour actuelle le jour reçue (ex on est mardi donc Mardi: 2, on reçoit 3,
        // donc pour déterminer de quel jour il s'agit, il faut faire 2 + 3 = 5 = Vendredi)
        int dayIndex = ((dayNumber - 1 + (forecast['day'] as int)) % 7) + 1;

        // Stock les informations reçue
        _dailyData.add(
          DailyData(
            day: dayIndex,
            tempMax: forecast['tmax'],
            tempMin: forecast['tmin'],
            weather: forecast['weather'],
          ),
        );

        // L'api va jusqu'à 14 jours donc à 7 on arrête
        if (forecast['day'] == 7) {
          break;
        }
      }
    } else {
      throw Exception("Failed to load weather");
    }
  }

  void printData() {
    print("=== WEATHER DATA ===");
    print("City       : $_cityName");
    print(
      "Now        : $_currentTemp°C, $_currentHumidity% hum, $_currentWind km/h wind, weather code $_currentWeather",
    );

    print("---------------------");

    for (final h in _hourlyData) {
      final hourStr = h.hour.toString().padLeft(2, '0');
      print("$hourStr h : ${h.temp}°C | weather code: ${h.weather}");
    }

    print("---------------------");

    for (final h in _dailyData) {
      final hourStr = dayTable[h.day];
      print(
        "$hourStr : ${h.tempMin}°C - ${h.tempMax}°C | weather code: ${h.weather}",
      );
    }

    print("=====================");
    print("");
  }

  // Getters

  // Temps actuelle
  String get getCityName => _cityName.toUpperCase();
  String get getTemperature => "$_currentTemp°";
  int get getWeather => _currentWeather;
  String get getWeatherDescription =>
      weatherDescriptions[_currentWeather] ?? "Inconnu";
  String get getHumidity => "$_currentHumidity%";
  String get getWind => "${_currentWind}km/h";

  // Infos supplémentaires
  String get getGustWind => "${_gustWind}km/h";
  String get getProbaRain => "$_probaRain%";
  String get getProbaFrost => "$_probaFrost%";
  String get getProbaFog => "$_probaFog%";

  // Les 12 prochaines heures
  List<HourlyData> get getHourlyData => _hourlyData;

  // Les 7 prochains jours
  List<DailyData> get getDailyData => _dailyData;
}

abstract class WeatherEntry {
  String formattedTime();
  String get formattedTemp;
  int get weather;
}

// Permet de stocker les données pour les 12 prochaines heures
class HourlyData implements WeatherEntry {
  final int hour;
  final int temp;
  final int _weather;

  HourlyData({required this.hour, required this.temp, required int weather})
    : _weather = weather;

  @override
  int get weather => _weather;

  @override
  String get formattedTemp => temp == -100 ? '--°' : '$temp°';

  @override
  String formattedTime() {
    String data;
    if (hour == -2) {
      data = "XXX";
    } else if (hour == -1) {
      data = "NOW";
    } else {
      data = "${hour}h";
    }
    return data;
  }
}

// Permet de stocker les données pour les 7 prochains jours
class DailyData implements WeatherEntry {
  final int day;
  final int tempMax;
  final int tempMin;
  final int _weather;

  DailyData({
    required this.day,
    required this.tempMax,
    required this.tempMin,
    required int weather,
  }) : _weather = weather;

  @override
  int get weather => _weather;

  @override
  String get formattedTemp =>
      tempMax == -100 || tempMin == -100 ? '--°/--°' : '$tempMin°/$tempMax°';

  @override
  String formattedTime() {
    return day == -1 ? "XXX" : "${dayTable[day]}";
  }
}

// Permet d'identifier une ville comme étant un nom et un code insee
// De cette manière il est possible d'afficher le nom dans l'autocompletion
// à partir du code insee
class City<T> {
  final String name;
  final T codeInsee;

  City({required this.name, required this.codeInsee});

  String get getName => name;
  T get getCodeInsee => codeInsee;

  void printData() {
    print("=== CITY DATA | name : $name - insee : $codeInsee ===");
  }
}
