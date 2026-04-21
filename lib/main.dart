import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/stable.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';
import 'viewmodels/booking_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/marketplace_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/booking_confirmation_view.dart';
import 'views/login_view.dart';
import 'views/main_shell.dart';
import 'views/splash_view.dart';
import 'views/marketplace_view.dart';
import 'views/payment_view.dart';
import 'views/register_view.dart';
import 'views/stable_details_view.dart';
import 'views/support_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KhayalApp());
}

class KhayalApp extends StatelessWidget {
  const KhayalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => BookingViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MarketplaceViewModel()),
      ],
      child: MaterialApp(
        title: 'Khayal Booking',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.splash,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case Routes.splash:
              return MaterialPageRoute(builder: (_) => const SplashView());

            case Routes.login:
              return MaterialPageRoute(builder: (_) => const LoginView());

            case Routes.register:
              return MaterialPageRoute(builder: (_) => const RegisterView());

            case Routes.mainShell:
              return MaterialPageRoute(builder: (_) => const MainShell());

            case Routes.marketplace:
              return MaterialPageRoute(builder: (_) => const MarketplaceView());

            case Routes.stableDetails:
              final stable = settings.arguments as Stable?;
              if (stable == null) return _errorRoute();
              return MaterialPageRoute(
                builder: (_) => StableDetailsView(stable: stable),
              );

            case Routes.bookingConfirmation:
              final args =
                  settings.arguments as BookingConfirmationArguments?;
              if (args == null) return _errorRoute();
              return MaterialPageRoute(
                builder: (_) =>
                    BookingConfirmationView(arguments: args),
              );

            case Routes.payment:
              final args = settings.arguments as PaymentArguments?;
              if (args == null) return _errorRoute();
              return MaterialPageRoute(
                builder: (_) => PaymentView(arguments: args),
              );

            case Routes.support:
              return MaterialPageRoute(builder: (_) => const SupportView());

            default:
              return _errorRoute();
          }
        },
      ),
    );
  }

  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Route not found')),
      ),
    );
  }
}