import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart' as nb_util;
import 'package:sports/routes/app_routes.dart';
import 'package:sports/utills/api_service.dart';
import 'package:sports/utills/shared_preference.dart';
import 'config/colors.dart';
import 'config/constant.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     statusBarColor: Colors.black,
  //     statusBarIconBrightness: Brightness.light,
  //     statusBarBrightness: Brightness.dark,
  //   ),
  // );
  await SharedPreferenceHelper.init();
  final helper = ApiBaseHelper();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: 'Main Navigator');

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: appTitle,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: primaryColour,
            // scaffoldBackgroundColor: scaffoldDark,
            scaffoldBackgroundColor: scaffoldLight,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColour,
              brightness: Brightness.dark,
              primary: primaryColour,
              secondary: accentGreen,
              surface: cardDark,
              onSurface: textPrimary,
              outlineVariant: borderDark,
            ),
            fontFamily: GoogleFonts.poppins().fontFamily,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColour,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            textTheme: TextTheme(
              bodyLarge: GoogleFonts.montserrat(fontSize: 16.sp, color: textPrimary),
              bodyMedium: GoogleFonts.montserrat(fontSize: 14.sp, color: textSecondary),
              titleLarge: GoogleFonts.montserrat(fontSize: 24.sp, fontWeight: FontWeight.bold, color: textPrimary),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: scaffoldDark,
              foregroundColor: textPrimary,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: cardDark,
              selectedItemColor: accentGreen,
              unselectedItemColor: textSecondary,
              selectedLabelStyle: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),

            inputDecorationTheme: InputDecorationTheme(

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentGreen, width: 1.5),
              ),
              hintStyle: GoogleFonts.poppins(color: textSecondary),
            ),
            cardTheme: CardThemeData(                 // ← Changed here
              color: cardDark,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          initialRoute: AppRoutes.initialRoute,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}