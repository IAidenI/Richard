import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:richard/ui/theme.dart';

class InitialData {
  static Position? gpsPosition;
}

/*
  Crée un menu déroulant personalisé
*/

class FloatingMenu extends StatefulWidget {
  final AppTheme theme;
  const FloatingMenu(this.theme, {super.key});

  @override
  State<FloatingMenu> createState() => _FloatingMenuState();
}

class _FloatingMenuState extends State<FloatingMenu> {
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(widget.theme.getSecondary),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: WidgetStateProperty.all(6),
      ),
      onOpen: () => setState(() => _menuOpen = true),
      onClose: () => setState(() => _menuOpen = false),
      alignmentOffset: const Offset(-110, -20),
      builder: (context, controller, child) {
        return TextButton(
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: Container(
            decoration: BoxDecoration(
              color: widget.theme.getButtonColor,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              _menuOpen ? Icons.close : Icons.menu,
              size: 30,
              color: widget.theme.getButtonTextColor,
            ),
          ),
        );
      },
      menuChildren: <Widget>[
        // Bloc "Général"
        MenuItemButton(
          leadingIcon: const Icon(Icons.home_rounded),
          child: const Text('Accueil'),
          onPressed: () => _go(context, '/'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.wb_sunny_rounded),
          child: const Text('Météo'),
          onPressed: () => _go(context, '/weather'),
        ),

        // Bloc "Jeux"
        SubmenuButton(
          leadingIcon: const Icon(Icons.sports_esports_rounded),
          menuChildren: <Widget>[
            MenuItemButton(
              leadingIcon: const Icon(Icons.grid_on_rounded),
              child: const Text('Jeu de la vie'),
              onPressed: () => _go(context, '/game/life'),
            ),
          ],
          child: const Text('Jeux'),
        ),
      ],
    );
  }
}

void _go(BuildContext context, String route) {
  Navigator.of(context).pushNamed(route);
}

/*
  Crée une snackbar personalisable
*/
class InfoDisplayer {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
  buildInfoDisplayer(
    BuildContext context,
    String data, {
    SnackBarAction? action,
    EdgeInsets? margin,
    Duration? duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar(); // Supprime l'ancien popup si existant

    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: action,
        content: GestureDetector(
          behavior: HitTestBehavior.opaque, // prend toute la surface
          onTap: () {
            messenger.hideCurrentSnackBar();
          },
          child: Center(child: Text(data)),
        ),
        duration: duration ?? const Duration(seconds: 1),
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}

/*
  Permet d'obtenir un popup générique personalisable
*/
class StyledText {
  final String text;
  final TextStyle? style;
  final VoidCallback? onTap;

  StyledText(this.text, {this.style, this.onTap});
}

class PopupGeneric extends StatefulWidget {
  final String title;
  final List<StyledText> content;
  final AppTheme theme;
  final bool scroll;
  final String? uri;

  const PopupGeneric({
    super.key,
    required this.title,
    required this.content,
    required this.theme,
    this.scroll = false,
    this.uri,
  });

  @override
  State<PopupGeneric> createState() => _PopupGenericState();
}

class _PopupGenericState extends State<PopupGeneric> {
  Widget _buildContentAsRichText() {
    return RichText(
      text: TextSpan(
        children: [
          for (var entry in widget.content) ...[
            TextSpan(
              text: entry.text,
              style: entry.style,
              recognizer: entry.onTap != null
                  ? (TapGestureRecognizer()..onTap = entry.onTap)
                  : null,
            ),
          ],
          const WidgetSpan(child: SizedBox(height: 15)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.theme.getPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Crée un cadre et place à l'interieur les données passé en paramètre
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 15),
                  Text(widget.title, style: widget.theme.getPopupGenericTitle),
                  const SizedBox(height: 16),

                  widget.scroll
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: _buildContentAsRichText(),
                          ),
                        )
                      : _buildContentAsRichText(),
                ],
              ),

              const SizedBox(height: 16),

              // Crée un bouton personalisé qui prend la même largeur que le cadre
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.theme.getButtonColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Center(
                      child: Text(
                        "OK",
                        style: widget.theme.getPupGenericTextButton,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
