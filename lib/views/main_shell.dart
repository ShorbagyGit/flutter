import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/booking_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'bookings_view.dart';
import 'home_view.dart';
import 'marketplace_view.dart';
import 'profile_view.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    HomeView(),
    MarketplaceView(),
    BookingsView(),
    ProfileView(),
  ];
  final List<String> _titles = [
    'Discover',
    'Marketplace',
    'Bookings',
    'Profile',
  ];
  bool _didInitialLoad = false;

  static const int _bookingsTabIndex = 2;

  Future<void> _loadBookingsForCurrentUser({bool showLoading = true}) async {
    final bookingViewModel = context.read<BookingViewModel>();
    final currentUser = context.read<AuthViewModel>().currentUser;

    if (currentUser != null && currentUser.id.isNotEmpty) {
      await bookingViewModel.fetchBookingsForUser(
        currentUser.id,
        showLoading: showLoading,
      );
      return;
    }

    bookingViewModel.clearBookings();
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentIndex = index);

    if (index == _bookingsTabIndex) {
      _loadBookingsForCurrentUser();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialLoad) return;
    _didInitialLoad = true;
    _loadBookingsForCurrentUser(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Text(
            _titles[_currentIndex],
            key: ValueKey(_titles[_currentIndex]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0.02, 0),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        onTap: _onBottomNavTap,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
