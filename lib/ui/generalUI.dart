/*
  Crée un menu déroulant personalisé
*/
import 'package:flutter/material.dart';
import 'package:richard/ui/theme.dart';

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
      alignmentOffset: const Offset(-80, 0),
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
              color: Colors.white,
            ),
          ),
        );
      },
      menuChildren: <Widget>[
        MenuItemButton(
          leadingIcon: const Icon(Icons.person),
          child: const Text("Météo"),
          onPressed: () {},
        ),

        MenuItemButton(
          leadingIcon: const Icon(Icons.person),
          child: const Text("Rapel"),
          onPressed: () {},
        ),

        MenuItemButton(
          leadingIcon: const Icon(Icons.person),
          child: const Text("Liste course"),
          onPressed: () {},
        ),
      ],
    );
  }
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
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: action,
        content: GestureDetector(
          behavior: HitTestBehavior.opaque, // prend toute la surface
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
class PopupGeneric extends StatefulWidget {
  final String title;
  final List<String> content;
  final AppTheme theme;

  const PopupGeneric({
    super.key,
    required this.title,
    required this.content,
    required this.theme,
  });

  @override
  State<PopupGeneric> createState() => _PopupGenericState();
}

class _PopupGenericState extends State<PopupGeneric> {
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
                  Column(
                    children: [
                      for (var data in widget.content)
                        Text(data, style: widget.theme.getPopupGenericLabel),
                      const SizedBox(height: 15),
                    ],
                  ),
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
