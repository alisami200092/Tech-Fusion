import 'package:flutter/material.dart';
import 'package:flutter_techfusion_project/profile_page_settings/notification_settings_page.dart';
import 'package:flutter_techfusion_project/search_product_page.dart';
import 'package:flutter_techfusion_project/shoppingCart/deals.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_page.dart';
import 'profile_page_settings/profile_settings_page.dart';
import 'authentication/auth_service.dart';
import 'shoppingCart/cart_provider.dart';
import 'shoppingCart/view_cart_page.dart';
import 'shoppingCart/checkout_page.dart';
import 'shoppingCart/wishlist_provider.dart';
import 'shoppingCart/wishlist_page.dart';
import 'shoppingCart/shopping_cart_product_provider.dart';
import 'shoppingCart/manage_products.dart';
import 'slider.dart';
import 'products/category_products_page.dart';
import 'products/product_details_page.dart';

class MyTechFusion extends StatelessWidget {
  final String firstName;
  final String lastName;

  const MyTechFusion(
      {required this.firstName, required this.lastName, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => WishlistProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor:
              Colors.white, // Forces white background globally
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
        ),
        routes: {
          '/profile': (context) => const ProfilePage(),
          '/profile_settings': (context) => const ProfileSettingsPage(),
          '/view_cart': (context) => const ViewCartPage(),
          '/checkout': (context) => const CheckoutPage(),
          '/wishlist': (context) => const WishlistPage(),
          '/manage': (context) => ManageProductsPage(),
        },
        home: HomeScreen(firstName: firstName, lastName: lastName),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String firstName;
  final String lastName;

  const HomeScreen(
      {required this.firstName, required this.lastName, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool isLoggedIn = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  void _logout(BuildContext context) async {
    await AuthService().signOut(context);

    if (!context.mounted) return;

    setState(() {
      isLoggedIn = false;
    });
    Navigator.pushReplacementNamed(context, '/');
  }

  void _launchWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/923458441469');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Could not open WhatsApp. Please ensure it is installed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Could not launch chat.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeDashboard(),
      _buildCategoriesTab(),
      const ViewCartPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 60, bottom: 20, left: 16, right: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF000033),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('images/techfusion-logo-text.png',
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.computer,
                          color: Colors.white,
                          size: 40)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Color(0xFF000033)),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${widget.firstName} ${widget.lastName}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('My Orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer_outlined),
              title: const Text('Deals'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const DealsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile_settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF000033),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category),
              label: 'Categories'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchWhatsApp,
        backgroundColor: Colors.transparent,
        elevation: 0,
        tooltip: 'Chat on WhatsApp',
        child: Image.asset('images/whatsapp_icon.png'),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final List<Map<String, dynamic>> categoryData = [
      {
        'title': 'Cases',
        'image': 'assets/banners/gaming-casing.png',
        'color': const Color(0xFFE0F7FA)
      },
      {
        'title': 'Monitor',
        'image': 'assets/banners/monitor.png',
        'color': const Color(0xFFC8E6C9)
      },
      {
        'title': 'Console',
        'image': 'assets/banners/console.png',
        'color': const Color(0xFFFFF9C4)
      },
      {
        'title': 'Headphones',
        'image': 'assets/banners/headphones.png',
        'color': const Color(0xFFFCE4EC)
      },
      {
        'title': 'Keyboard',
        'image': 'assets/banners/keyboard.png',
        'color': const Color(0xFFF3E5F5)
      },
      {
        'title': 'Mouse',
        'image': 'assets/banners/mouse.png',
        'color': const Color(0xFFE8F5E9)
      },
      {
        'title': 'Chair',
        'image': 'assets/banners/gaming-chair.png',
        'color': const Color(0xFFFFE0B2)
      },
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'All Categories',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000033)),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categoryData.length,
              itemBuilder: (context, index) {
                final cat = categoryData[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryProductsPage(categoryName: cat['title']),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: cat['color'],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4))
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(cat['image'],
                            height: 80, fit: BoxFit.contain),
                        const SizedBox(height: 16),
                        Text(cat['title'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF000033))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeDashboard() {
    return SafeArea(
      // Adjusted top padding slightly to bring things tighter
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Custom Header
            // 1. Custom Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black, size: 28),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                // Logo is now back to height 100, no Transform used.
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Image.asset(
                    'images/techFusion-logo-text-drawer.png',
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                        'TechFusion',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                ),
                const Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none,
                          color: Colors.black, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificationsPage()),
                        );
                      },
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Text(
                          '2',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                    icon:
                        const Icon(Icons.favorite_border, color: Colors.black),
                    onPressed: () => Navigator.pushNamed(context, '/wishlist')),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined,
                          color: Colors.black),
                      onPressed: () => setState(() => _currentIndex = 2),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Consumer<CartProvider>(
                        builder: (context, cart, child) {
                          if (cart.itemCount == 0) return const SizedBox();
                          return Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Text(
                              cart.itemCount.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Search Bar
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchProductsPage()),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      'Search for products',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.tune, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Your Custom Product Carousel
            const SizedBox(
              height: 200,
              child: ProductCarousel(),
            ),
            const SizedBox(height: 24),

            // 4. Categories Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Categories',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                  child: Text('View all',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryItem(
                      context,
                      'Cases',
                      'assets/banners/gaming-casing.png',
                      const Color(0xFFE0F7FA)),
                  _buildCategoryItem(
                      context,
                      'Monitor',
                      'assets/banners/monitor.png',
                      const Color.fromARGB(190, 135, 251, 156)),
                  _buildCategoryItem(context, 'Console',
                      'assets/banners/console.png', const Color(0xFFFFF9C4)),
                  _buildCategoryItem(context, 'Headphones',
                      'assets/banners/headphones.png', const Color(0xFFFCE4EC)),
                  _buildCategoryItem(context, 'Keyboard',
                      'assets/banners/keyboard.png', const Color(0xFFF3E5F5)),
                  _buildCategoryItem(context, 'Mouse',
                      'assets/banners/mouse.png', const Color(0xFFE8F5E9)),
                  _buildCategoryItem(
                      context,
                      'Chair',
                      'assets/banners/gaming-chair.png',
                      const Color(0xFFFFE0B2)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 5. HOT DEALS SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        color: Colors.red, size: 22),
                    SizedBox(width: 4),
                    Text('Hot Deals',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DealsPage()));
                  },
                  child: Text('View all',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  final dealProducts =
                      productProvider.newArrivals.reversed.take(6).toList();

                  if (dealProducts.isEmpty) {
                    return Center(
                        child: Text("Loading deals...",
                            style: TextStyle(color: Colors.grey.shade500)));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dealProducts.length,
                    itemBuilder: (context, index) {
                      final product = dealProducts[index];
                      final discountedPrice = product.price * 0.80;

                      // ==== DYNAMIC MATH FOR DISCOUNT ====
                      int discountPercentage =
                          ((product.price - discountedPrice) /
                                  product.price *
                                  100)
                              .round();

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailsPage(product: product)));
                        },
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(
                              right: 16, bottom: 8, top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                                width: 1),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                  ),
                                  // ==== FIXED: Image wrapped in a Stack for the badge ====
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(16)),
                                        child: Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey),
                                        ),
                                      ),
                                      // The sleek discount badge
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade600,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.local_offer,
                                                  color: Colors.white,
                                                  size: 12),
                                              const SizedBox(width: 4),
                                              Text(
                                                '-$discountPercentage%',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF000033)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${discountedPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.red),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Provider.of<CartProvider>(context,
                                                    listen: false)
                                                .addItem(product);
                                            final sm =
                                                ScaffoldMessenger.of(context);
                                            sm.hideCurrentSnackBar();
                                            sm.showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    '🔥 Deal added to cart!'),
                                                backgroundColor: Colors.red,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF000033),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(Icons.add,
                                                color: Colors.white, size: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // 6. TRENDING ARRIVALS SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Trending Arrivals',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchProductsPage()));
                  },
                  child: Text('View all',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  final trendingProducts =
                      productProvider.newArrivals.take(12).toList();

                  if (trendingProducts.isEmpty) {
                    return Center(
                      child: Text("Loading products...",
                          style: TextStyle(color: Colors.grey.shade500)),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: trendingProducts.length,
                    itemBuilder: (context, index) {
                      final product = trendingProducts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsPage(product: product),
                            ),
                          );
                        },
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(
                              right: 16, bottom: 8, top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          const Icon(Icons.image_not_supported,
                                              color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF000033)),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.green),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Provider.of<CartProvider>(context,
                                                    listen: false)
                                                .addItem(product);
                                            final sm =
                                                ScaffoldMessenger.of(context);
                                            sm.hideCurrentSnackBar();
                                            sm.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    '✅ ${product.title} added to cart!'),
                                                backgroundColor: Colors.green,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                duration:
                                                    const Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF000033),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(Icons.add,
                                                color: Colors.white, size: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, String title, String imagePath, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(35),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryProductsPage(categoryName: title),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 8),
            Text(title,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
