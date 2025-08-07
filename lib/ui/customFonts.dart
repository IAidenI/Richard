import 'package:flutter/material.dart';
import 'package:richard/assets/constants.dart';

class CustomFonts {
  /*
    Fonts pour le temps du jour
  */
  static TextStyle cityStyle(ColorCode weather, bool isLoaded) {
    return TextStyle(
      fontFamily: 'BebasNeue',
      fontSize: isLoaded ? 25 : 25,
      color: isLoaded
          ? const Color.fromARGB(255, 110, 110, 110)
          : const Color.fromARGB(255, 160, 146, 20),
    );
  }

  static TextStyle weatherStyle(ColorCode weather) {
    TextStyle template = TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 15,
      color: const Color.fromARGB(255, 234, 217, 217),
    );

    // Permet de modifier la couleur en fonction de la météo du jour
    if (weather == ColorCode.CLOUDS) {
      template = template.copyWith(
        color: const Color.fromARGB(255, 240, 236, 236),
      );
    } else if (weather == ColorCode.RAIN) {
      template = template.copyWith(
        color: const Color.fromARGB(255, 240, 236, 236),
      );
    } else if (weather == ColorCode.SNOW) {
      template = template.copyWith(
        color: const Color.fromARGB(255, 240, 236, 236),
      );
    }
    return template;
  }

  static TextStyle temperatureStyle(ColorCode weather) {
    TextStyle template = TextStyle(
      fontFamily: 'Rubik',
      fontWeight: FontWeight.w700,
      fontSize: 75,
      color: Colors.white,
    );

    // Permet de modifier la couleur en fonction de la météo du jour
    if (weather == ColorCode.CLOUDS) {
      template = template.copyWith(
        color: const Color.fromARGB(255, 240, 236, 236),
      );
    } else if (weather == ColorCode.RAIN) {
      template = template.copyWith(
        color: const Color.fromARGB(255, 240, 236, 236),
      );
    }
    return template;
  }

  static TextStyle moreInfosStyle(ColorCode weather) {
    TextStyle template = TextStyle(
      fontFamily: 'Raleway',
      fontWeight: FontWeight.w900,
      fontSize: 11,
      color: const Color.fromARGB(255, 234, 217, 217),
    );

    // Permet de modifier la couleur en fonction de la météo du jour
    if (weather == ColorCode.CLOUDS) {
      template = template.copyWith(
        color: const Color.fromARGB(255, 240, 236, 236),
      );
    } else if (weather == ColorCode.RAIN) {
      template = template.copyWith(
        color: const Color.fromARGB(255, 240, 236, 236),
      );
    } else if (weather == ColorCode.SNOW) {
      template = template.copyWith(
        color: const Color.fromARGB(255, 240, 236, 236),
      );
    }
    return template;
  }

  static TextStyle dateStyle(ColorCode weather) {
    TextStyle template = TextStyle(
      fontFamily: 'OpenSans',
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: const Color.fromARGB(255, 244, 232, 232),
    );

    // Permet de modifier la couleur en fonction de la météo du jour
    if (weather == ColorCode.SNOW) {
      template = template.copyWith(
        color: const Color.fromARGB(255, 184, 184, 184),
      );
    }
    return template;
  }

  /*
    Fonts pour le menu indiquant les précvision météo
  */
  static TextStyle customSwitch(bool on) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: on ? Colors.white : const Color.fromARGB(225, 104, 76, 124),
    );
  }

  static TextStyle weatherCard() {
    return TextStyle(
      fontFamily: 'BebasNeue',
      fontSize: 20,
      color: const Color.fromARGB(255, 233, 228, 228),
    );
  }

  /*
    Fonts pour les informations supplémentaires
  */
  static TextStyle popupTitle(ColorCode weather) {
    TextStyle template = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    // Permet de modifier la couleur en fonction de la météo du jour
    switch (weather) {
      case ColorCode.SUN:
        template = template.copyWith(
          color: const Color.fromARGB(255, 65, 138, 182),
        );
        break;
      case ColorCode.SOME_CLOUDS:
        template = template.copyWith(
          color: const Color.fromARGB(255, 237, 85, 97),
        );
        break;
      case ColorCode.CLOUDS:
        template = template.copyWith(
          color: const Color.fromARGB(255, 34, 141, 125),
        );
        break;
      case ColorCode.RAIN:
        template = template.copyWith(
          color: const Color.fromARGB(255, 34, 141, 125),
        );
        break;
      case ColorCode.SNOW:
        template = template.copyWith(
          color: const Color.fromARGB(255, 30, 40, 138),
        );
        break;
      case ColorCode.THUNDERSTORM:
        template = template.copyWith(
          color: const Color.fromARGB(255, 92, 30, 138),
        );
        break;
      case ColorCode.HAIL:
        template = template.copyWith(
          color: const Color.fromARGB(255, 117, 108, 124),
        );
        break;
      case ColorCode.UNKNOW:
        template = template.copyWith(color: Colors.black);
        break;
    }
    return template;
  }

  static TextStyle popupLabel(ColorCode weather) {
    return TextStyle(
      fontSize: 15,
      color: Colors.black,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle popupVariable(ColorCode weather) {
    return TextStyle(
      fontSize: 15,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle buttonStyle() {
    return TextStyle(
      fontFamily: 'BebasNeue',
      fontSize: 20,
      color: Colors.white,
    );
  }
}

// Permet de selectionner les bonnes couleurs en fonction
// de la météo pour le popup des informations supplémentaires
class PopupColorCode {
  final ColorCode weather;

  TextStyle _styleTitle = CustomFonts.popupTitle(ColorCode.UNKNOW);
  TextStyle _styleLabel = CustomFonts.popupTitle(ColorCode.UNKNOW);
  TextStyle _styleVariable = CustomFonts.popupTitle(ColorCode.UNKNOW);
  Color _frame = Colors.black;
  Color _background = Colors.white;
  Color _colorButton = Colors.white;
  TextStyle _colorButtonText = CustomFonts.buttonStyle();

  PopupColorCode(this.weather) {
    _styleTitle = CustomFonts.popupTitle(weather);
    _styleLabel = CustomFonts.popupLabel(weather);
    _styleVariable = CustomFonts.popupVariable(weather);

    switch (weather) {
      case ColorCode.SUN:
        _frame = Color.fromARGB(255, 32, 84, 116);
        _background = Color.fromARGB(255, 199, 234, 255);
        _colorButton = Color.fromARGB(255, 56, 52, 223);
        break;
      case ColorCode.SOME_CLOUDS:
        _frame = Color.fromARGB(255, 177, 50, 59);
        _background = Color.fromARGB(255, 248, 199, 200);
        _colorButton = Color.fromARGB(255, 225, 93, 99);
        break;
      case ColorCode.CLOUDS:
        _frame = Color.fromARGB(255, 27, 94, 84);
        _background = Color.fromARGB(255, 168, 255, 242);
        _colorButton = Color.fromARGB(255, 62, 198, 210);
        break;
      case ColorCode.RAIN:
        _frame = Color.fromARGB(255, 27, 94, 84);
        _background = Color.fromARGB(255, 168, 255, 242);
        _colorButton = Color.fromARGB(255, 62, 198, 210);
        break;
      case ColorCode.SNOW:
        _frame = Color.fromARGB(255, 0, 54, 125);
        _background = Color.fromARGB(255, 148, 230, 255);
        _colorButton = Color.fromARGB(255, 52, 118, 223);
        break;
      case ColorCode.THUNDERSTORM:
        _frame = Color.fromARGB(255, 92, 30, 138);
        _background = Color.fromARGB(255, 198, 171, 216);
        _colorButton = Color.fromARGB(255, 126, 52, 223);
        break;
      case ColorCode.HAIL:
        _frame = Color.fromARGB(255, 117, 108, 124);
        _background = Color.fromARGB(255, 221, 221, 221);
        _colorButton = Color.fromARGB(255, 145, 145, 158);
        break;
      case ColorCode.UNKNOW:
        break;
    }
  }

  TextStyle get getTitleStyle => _styleTitle;
  TextStyle get getLabelStyle => _styleLabel;
  TextStyle get getVariableStyle => _styleVariable;
  Color get getFrameColor => _frame;
  Color get getBackgroundColor => _background;
  Color get getButtonColor => _colorButton;
  TextStyle get getButtonTextColor => _colorButtonText;
}
