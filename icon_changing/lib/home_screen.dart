import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

enum AppIcon {
  purple,
  pink,
  green,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _chestController;
  bool _showImage = false;
  AppIcon? currentIcon;
  AppIcon? nextIcon;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.2),
    ).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.easeOut,
      ),
    );

    FlutterDynamicIcon.getAlternateIconName().then((iconName) {
      setState(() {
        currentIcon = AppIcon.values.byName(iconName ?? 'purple');
        nextIcon = _getNextIcon(currentIcon!);
        _runAnimations();
      });
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _chestController.dispose();
    super.dispose();
  }

  void changeAppIcon() async {
    try {
      if (await FlutterDynamicIcon.supportsAlternateIcons) {
        await FlutterDynamicIcon.setAlternateIconName(nextIcon!.name);
        setState(() {
          currentIcon = nextIcon;
          nextIcon = _getNextIcon(currentIcon!);
          _runAnimations();
        });
      }
    } on PlatformException catch (_) {
      print('Failed to change app icon');
    }
  }

  void _runAnimations() {
    setState(() {
      _showImage = false;
    });

    _chestController.reset();
    _chestController.forward();

    _iconController.reset();
    Future.delayed(const Duration(seconds: 1), () {
      _iconController.forward();
      setState(() {
        _showImage = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Lottie.asset(
                  "assets/animation/chest.json",
                  height: 300,
                  controller: _chestController,
                  onLoaded: (composition) {
                    _chestController.duration = composition.duration;
                    _runAnimations();
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  "You've unlocked the ${nextIcon?.name} icon!",
                  style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: changeAppIcon,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.greenAccent,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        "Tap to change app icon",
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_showImage)
              SlideTransition(
                position: _slideAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    "assets/logos/${nextIcon!.name}.png",
                    height: 100,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  AppIcon _getNextIcon(AppIcon currentIcon) {
    switch (currentIcon) {
      case AppIcon.purple:
        return AppIcon.green;
      case AppIcon.green:
        return AppIcon.pink;
      case AppIcon.pink:
      default:
        return AppIcon.purple;
    }
  }
}
