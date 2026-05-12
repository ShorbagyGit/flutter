import 'dart:async';

// Removed direct Firebase usage; backend will proxy Firebase calls.
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
import 'views/marketplace_view.dart';
import 'views/booking_payment_view.dart';
import 'views/register_view.dart';
import 'views/horse_details_view.dart';
import 'views/horse_slots_view.dart';
import 'views/support_view.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KhayalApp());
}

class KhayalApp extends StatelessWidget {
  const KhayalApp({super.key});

  Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(fade);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

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
        initialRoute: Routes.startup,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case Routes.startup:
              return _buildRoute(const _SessionGateView(), settings);

            case Routes.login:
              return _buildRoute(const LoginView(), settings);

            case Routes.register:
              return _buildRoute(const RegisterView(), settings);

            case Routes.mainShell:
              return _buildRoute(const MainShell(), settings);

            case Routes.marketplace:
              return _buildRoute(const MarketplaceView(), settings);

            case Routes.stableDetails:
              final stable = settings.arguments as Stable?;
              if (stable == null) return _errorRoute();
              return _buildRoute(HorseDetailsView(stable: stable), settings);

            case Routes.horseSlots:
              final args = settings.arguments as HorseSlotsArguments?;
              if (args == null) return _errorRoute();
              return _buildRoute(HorseSlotsView(arguments: args), settings);

            case Routes.bookingConfirmation:
              final args = settings.arguments as BookingConfirmationArguments?;
              if (args == null) return _errorRoute();
              return _buildRoute(
                BookingConfirmationView(arguments: args),
                settings,
              );

            case Routes.payment:
              final args = settings.arguments as PaymentArguments?;
              if (args == null) return _errorRoute();
              return _buildRoute(PaymentView(arguments: args), settings);

            case Routes.support:
              return _buildRoute(const SupportView(), settings);

            default:
              return _errorRoute();
          }
        },
      ),
    );
  }

  Route<dynamic> _errorRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) =>
          const Scaffold(body: Center(child: Text('Route not found'))),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}

class _SessionGateView extends StatefulWidget {
  const _SessionGateView();

  @override
  State<_SessionGateView> createState() => _SessionGateViewState();
}

class _SessionGateViewState extends State<_SessionGateView> {
  late final Future<bool> _sessionCheckFuture;

  @override
  void initState() {
    super.initState();
    _sessionCheckFuture = context.read<AuthViewModel>().restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionCheckFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasSession = snapshot.data ?? false;
        if (hasSession) {
          return const MainShell();
        }
        return const LoginView();
      },
    );
  }
}
