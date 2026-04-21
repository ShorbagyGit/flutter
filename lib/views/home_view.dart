import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_routes.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/stable_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadStables();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<HomeViewModel>().search(_searchController.text);
  }

  Future<void> _onRefresh(HomeViewModel viewModel) async {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      await viewModel.search(query);
      return;
    }

    await viewModel.loadStables();
  }

  Widget _fadeUp({required Widget child, int delayMs = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: RefreshIndicator(
                color: const Color(0xFF1B5E20),
                onRefresh: () => _onRefresh(viewModel),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      _fadeUp(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Find your ride',
                                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Welcome back, Rider',
                                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.notifications, color: Color(0xFF2E7D32)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _fadeUp(
                        delayMs: 80,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Where to?',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    height: 42,
                                    width: 42,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.place, color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _searchController,
                                onSubmitted: (_) => _onSearch(),
                                decoration: InputDecoration(
                                  hintText: 'Location, court, or club',
                                  prefixIcon: const Icon(Icons.search, color: Color(0xFF4B5563)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _fadeUp(
                        delayMs: 140,
                        child: const Text(
                          'Recommended stables',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : viewModel.stables.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No featured courts available',
                                      style: TextStyle(color: Color(0xFF6B7280)),
                                    ),
                                  )
                                : ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: viewModel.stables.length.clamp(0, 5),
                                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                                    itemBuilder: (context, index) {
                                      final stable = viewModel.stables[index];
                                      return TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0, end: 1),
                                        duration: Duration(milliseconds: 360 + (index * 70)),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, child) {
                                          return Opacity(
                                            opacity: value,
                                            child: Transform.translate(
                                              offset: Offset(0, (1 - value) * 18),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: GestureDetector(
                                          onTap: () => Navigator.pushNamed(
                                            context,
                                            Routes.stableDetails,
                                            arguments: stable,
                                          ),
                                          child: Container(
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color: theme.cardColor,
                                              borderRadius: BorderRadius.circular(24),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.08),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                                  child: SizedBox(
                                                    height: 85,
                                                    width: double.infinity,
                                                    child: Image.network(
                                                      stable.image,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => Container(
                                                        color: theme.colorScheme.surfaceContainerHighest,
                                                        child: const Icon(Icons.sports_soccer, size: 40, color: Colors.grey),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          stable.name,
                                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            Icon(Icons.location_on, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                                            const SizedBox(width: 4),
                                                            Expanded(
                                                              child: Text(
                                                                stable.location,
                                                                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                      const SizedBox(height: 22),
                      viewModel.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : viewModel.error != null
                              ? Center(
                                  child: Text(
                                    viewModel.error!,
                                    style: TextStyle(color: theme.colorScheme.error),
                                  ),
                                )
                              : viewModel.stables.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No courts found.',
                                        style: TextStyle(color: Color(0xFF6B7280)),
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                                      itemCount: viewModel.stables.length,
                                      itemBuilder: (context, index) {
                                        final stable = viewModel.stables[index];
                                        return TweenAnimationBuilder<double>(
                                          tween: Tween(begin: 0, end: 1),
                                          duration: Duration(milliseconds: 380 + (index * 60)),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, value, child) {
                                            return Opacity(
                                              opacity: value,
                                              child: Transform.translate(
                                                offset: Offset(0, (1 - value) * 16),
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: StableCard(
                                            stable: stable,
                                            onTap: () => Navigator.pushNamed(
                                              context,
                                              Routes.stableDetails,
                                              arguments: stable,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                      const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
