import 'package:flutter/material.dart';
import 'package:sports/routes/app_routes.dart';

import '../config/colors.dart';
import '../utills/shared_preference.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() {
    final token = SharedPreferenceHelper.getToken();
    final role = SharedPreferenceHelper.getRole();

    print("Splash → token: $token | role: $role");

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        // Token exists → navigate based on saved role
        switch (role) {
          case 'CLUB_ADMIN':
            Navigator.pushReplacementNamed(context, AppRoutes.clubAdmin);
            break;
          case 'COACH':
            Navigator.pushReplacementNamed(context, AppRoutes.coachBar);
            break;
          case 'GUARDIAN':
            Navigator.pushReplacementNamed(context, AppRoutes.guardianBar);
            break;
          case 'MEMBER':
            Navigator.pushReplacementNamed(context, AppRoutes.memberBar);
            break;
          default:
            // Role not saved or unknown → go to login
            Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      } else {
        // No token → go to login
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset("assets/images/squad.png", height: 250),
              ),
              const SizedBox(height: 40),
              Text(
                "SQUAD",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: primaryColour,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Complete Sports Club Management",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
