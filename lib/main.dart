import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'model.dart';
import 'fields.dart';
import 'ui.dart';
import 'auth.dart';
import 'workflow.dart';
import 'media.dart';
import 'services.dart';

void main() => runApp(TamweelyApp());
class TamweelyApp extends StatelessWidget {
  TamweelyApp({super.key, DemoState? state}) : state = state ?? DemoState();
  final DemoState state;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'تمويلي | التقييم الذكي', debugShowCheckedModeBanner: false,
    locale: const Locale('ar'), supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: navy, primary: navy, secondary: gold, surface: Colors.white),
      scaffoldBackgroundColor: navy, appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white, centerTitle: false),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)), contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16)),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white, side: const BorderSide(color: gold), minimumSize: const Size(0, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.94), foregroundColor: navy, side: const BorderSide(color: gold), minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
    ), initialRoute: '/login',
    routes: {
      '/login': (_) => AuthPage(state: state, kind: AuthKind.login),
      '/register': (_) => AuthPage(state: state, kind: AuthKind.register),
      '/reset': (_) => AuthPage(state: state, kind: AuthKind.reset),
      '/dashboard': (_) => Dashboard(state),
      '/profile': (_) => ProfilePage(state),
      for (final spec in forms) spec.route: (_) => DataPage(state, spec),
      '/location': (_) => LocationPage(state),
      '/documents': (_) => AttachmentPage(state, photos: false),
      '/photos': (_) => AttachmentPage(state, photos: true),
      '/review': (_) => ReviewPage(state),
      '/tracking': (_) => TrackingPage(state),
      '/notifications': (_) => NotificationsPage(state),
      '/support': (_) => SupportPage(state),
    },
  );
}
