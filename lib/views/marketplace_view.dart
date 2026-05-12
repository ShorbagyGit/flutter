import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/marketplace_viewmodel.dart';
import 'marketplace_product_view.dart';
import '../widgets/primary_button.dart';

class MarketplaceView extends StatefulWidget {
  const MarketplaceView({super.key});

  @override
  State<MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends State<MarketplaceView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _searchController = TextEditingController();
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialLoad) return;
    _didInitialLoad = true;
    context.read<MarketplaceViewModel>().loadProducts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submit(MarketplaceViewModel marketplaceViewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final currentUser = authViewModel.currentUser;

    // Validate user is logged in
    if (currentUser == null || currentUser.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in first to add a product'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = currentUser.id;

    final description = _descriptionController.text.trim();
    final category = _categoryController.text.trim();
    final location = _locationController.text.trim();

    final success = await marketplaceViewModel.addProduct(
      title: _titleController.text.trim(),
      description: description.isEmpty ? 'No description provided' : description,
      price: double.parse(_priceController.text.trim()),
      phone: _phoneController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      category: category.isEmpty ? 'General' : category,
      location: location.isEmpty ? 'Unknown' : location,
      userId: userId,
    );

    if (!mounted) return;

    if (success) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      _formKey.currentState?.reset();
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _phoneController.clear();
      _imageUrlController.clear();
      _categoryController.clear();
      _locationController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );
      return;
    }

    final message = marketplaceViewModel.error ?? 'Failed to add product';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openAddProductSheet() async {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _phoneController.clear();
    _imageUrlController.clear();
    _categoryController.clear();
    _locationController.clear();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Consumer<MarketplaceViewModel>(
          builder: (context, marketplaceViewModel, _) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 56,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Add Product',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Only title, price, image, and phone are required.',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _titleController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          prefixIcon: Icon(Icons.shopping_bag_outlined),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) return 'Price is required';
                          final parsed = double.tryParse(text);
                          if (parsed == null || parsed <= 0) return 'Enter a valid price';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _imageUrlController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty ? 'Image URL is required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty ? 'Phone is required' : null,
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.notes_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _categoryController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _locationController,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: marketplaceViewModel.isSubmitting ? 'Adding...' : 'Publish Product',
                        onPressed: marketplaceViewModel.isSubmitting ? () {} : () => _submit(marketplaceViewModel),
                        disabled: marketplaceViewModel.isSubmitting,
                        fullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product, int index) {
    final imageUrl = ApiService.resolveMediaUrl(product.imageUrl);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 28),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MarketplaceProductView(product: product),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 1.25,
                      child: imageUrl.isEmpty
                          ? Container(
                              color: Colors.grey.shade200,
                              child: const Center(child: Icon(Icons.image_not_supported, size: 42)),
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(child: Icon(Icons.broken_image, size: 42)),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoChip(label: 'EGP ${product.price.toStringAsFixed(0)}', icon: Icons.sell_outlined),
                      _InfoChip(label: product.category.isEmpty ? 'Category' : product.category, icon: Icons.category_outlined),
                      _InfoChip(label: product.location.isEmpty ? 'Location' : product.location, icon: Icons.location_on_outlined),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 19, color: Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          product.phone,
                          style: TextStyle(color: Colors.grey.shade700),
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
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by title',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: () => _searchController.clear(),
                  icon: const Icon(Icons.close),
                ),
          filled: true,
          fillColor: const Color(0xFFF7F9F4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketplaceViewModel>(
      builder: (context, marketplaceViewModel, _) {
        final authViewModel = context.read<AuthViewModel>();
        final user = authViewModel.currentUser;
        final isUserLoggedIn = user != null && user.id.isNotEmpty;
        final searchQuery = _searchController.text.trim().toLowerCase();
        final filteredProducts = searchQuery.isEmpty
            ? marketplaceViewModel.products
            : marketplaceViewModel.products.where((product) {
                return product.title.toLowerCase().contains(searchQuery);
              }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F3),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: isUserLoggedIn ? _openAddProductSheet : null,
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
          ),
          body: RefreshIndicator(
            onRefresh: marketplaceViewModel.loadProducts,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              children: [
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                    children: [
                      TextSpan(
                        text: 'Find Your\n',
                        style: TextStyle(color: Color(0xFF111111)),
                      ),
                      TextSpan(
                        text: '    Perfect Match',
                        style: TextStyle(color: Color(0xFF1B5E20)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _buildSearchBar(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Latest Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: marketplaceViewModel.loadProducts,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOut,
                  child: marketplaceViewModel.isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : marketplaceViewModel.error != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Text(
                                marketplaceViewModel.error!,
                                style: TextStyle(color: Theme.of(context).colorScheme.error),
                              ),
                            )
                          : marketplaceViewModel.products.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 18),
                                  child: Text('No products found yet.'),
                                )
                              : filteredProducts.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 18),
                                      child: Text('No products match your search.'),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: filteredProducts.length,
                                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                                      itemBuilder: (context, index) {
                                        return _buildProductCard(filteredProducts[index], index);
                                      },
                                    ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
