// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc_template/core/theme/app_themes.dart';
import 'package:flutter_bloc_template/data/auth/bloc/verify/verify_bloc.dart';
import 'package:flutter_bloc_template/page/home.dart';
import 'package:flutter_bloc_template/page/item_detail_page.dart';
import 'package:flutter_bloc_template/page/login.dart';
import 'package:flutter_bloc_template/page/splash_screen.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VerifyBloc>(
      create: (_) => VerifyBloc()..add(VerifyRequested()),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        onGenerateRoute: createRoute,
        locale: const Locale('id', 'ID'),
        theme: AppTheme.light(),
        themeMode: ThemeMode.light,
        supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: BlocListener<VerifyBloc, VerifyState>(
          listener: (context, state) {
            if (state is VerifySuccess) {
              navigatorKey.currentState?.pushReplacementNamed('/home');
            } else if (state is VerifyFailure) {
              navigatorKey.currentState?.pushReplacementNamed('/login');
            }
          },
          child: const SplashScreen(),
        ),
      ),
    );
  }
}

Route<dynamic> createRoute(RouteSettings settings) {
  final Widget page;
  switch (settings.name) {
    case '/home':
      page = const HomePage();
    case '/item_detail':
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      page = ItemDetailPage(itemId: (args['id'] as num?)?.toInt() ?? 0);
    case '/login':
      page = const LoginPage();
    default:
      page = const SplashScreen();
  }
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) {
      final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.ease));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
