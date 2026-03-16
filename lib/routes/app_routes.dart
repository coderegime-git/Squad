import 'package:flutter/material.dart';
import 'package:sports/Pages/Coach/coach_bottom_nav.dart';
import 'package:sports/Pages/Guardian/bottom_bar_guardian.dart';
import 'package:sports/Pages/Guardian/notification.dart';
import 'package:sports/Pages/Guardian/sign_up.dart';
import 'package:sports/Pages/dashboard.dart';
import 'package:sports/Pages/landing_screen.dart';
import 'package:sports/Pages/login.dart';
import 'package:sports/Pages/role_selection.dart';
import 'package:sports/Pages/signup.dart';

import '../Pages/Club_admin/club_admin_bottomnavigation.dart';
import '../Pages/Member/member_bottom_nav.dart';
import '../Pages/splash.dart';


class AppRoutes {
  static const String splash = '/';
  static const String dashboard = '/home';
  static const String login = '/login';
  static const String signup = '/sign_up';
  static const String initialRoute = splash;
  static const String landing = '/landing';
  static const String guardianBar = '/guarian_bar';
  static const String guardianNotifications = '/guarian_notifications';
  static const String roleSelection = '/role_selection';
  static const String parentSignup = '/parent_signup';
  static const String memberBar = '/member_bar';
  static const String coachBar = '/coach_bar';
  static const String clubAdmin = '/club_admin';




  static Route<dynamic> generateRoute(RouteSettings settings) {
    Map args = (settings.arguments ?? {}) as Map;

    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (context) => const Splash());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (context) => const AccountActivationScreen());
      case dashboard:
        return MaterialPageRoute(builder: (context) => const DashboardScreen());
      case landing:
        return MaterialPageRoute(builder: (context) => const LandingScreen());
      case guardianBar:
         return MaterialPageRoute(builder: (context)=>GuardianBottomNav());
      case guardianNotifications:
        return MaterialPageRoute(builder: (context)=>GuardianNotificationsScreen());
      case roleSelection:
        return MaterialPageRoute(builder: (context)=>RoleSelectionScreen());
      case parentSignup:
        return MaterialPageRoute(builder: (context)=>ParentOnboardingScreen());
      case memberBar:
        return MaterialPageRoute(builder: (context)=>MemberBottomNav());
      case coachBar:
        return MaterialPageRoute(builder: (context)=>CoachBottomNav());
      case clubAdmin:
        return MaterialPageRoute(builder: (context)=>ClubAdminBottomNav());


      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
