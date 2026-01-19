import 'dart:async';
import 'dart:convert';
import 'package:final_ammonation_project/details_page.dart';
import 'package:final_ammonation_project/privacy_policy.dart';
import 'package:final_ammonation_project/registration_page.dart';
import 'package:final_ammonation_project/notification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'NotificationService/notification_service.dart';
import 'employeelist_page.dart';
import 'model_ammo_project.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ============================================================================
// CONSTANTS & THEME
// ============================================================================
class AppColors {
  static const primary = Color(0xFF2C3E50);
  static const primaryDark = Color(0xFF34495E);
  static const primaryLight = Color(0xFF4A6583);
  static const accent = Color(0xFFE74C3C);
  static const background = Color(0xFFF5F5F5);
  static const cardBackground = Colors.white;

  static const categoryColors = [
    Color(0xFFE74C3C),  // Red
    Color(0xFF2ECC71),  // Green
    Color(0xFF3498DB),  // Blue
    Color(0xFF9B59B6),  // Purple
    Color(0xFF1ABC9C),  // Teal
    Color(0xFFF39C12),  // Orange
    Color(0xFFD35400),  // Dark Orange
    Color(0xFF34495E),  // Dark Blue
  ];
}

class AppConstants {
  static const String appName = "ARMORY PRO";
  static const String helplineNumber = '01726156318';
  static const String apiUrl = "https://raw.githubusercontent.com/ShahedAhmed894/ammunation_project_api/refs/heads/main/ammunition_api_project";
  static const int notificationIntervalMinutes = 3;
  static const int searchDebounceMilliseconds = 300;

  static const double popularSectionHeight = 160.0;
  static const double categorySectionHeight = 110.0;
  static const double categoryIconSize = 70.0;
}

// ============================================================================
// API SERVICE
// ============================================================================
class AmmoApiService {
  Future<Map<String, dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse(AppConstants.apiUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load data: ${response.statusCode}');
    }

    final body = utf8.decode(response.bodyBytes);
    final jsonData = jsonDecode(body);

    List<AmmoItem> products = [];
    List<AmmoItem> popularItems = [];

    if (jsonData is List) {
      products = _parseItemList(jsonData);
    } else if (jsonData is Map<String, dynamic>) {
      if (jsonData['most_popular_categories'] is List) {
        popularItems = _parseItemList(jsonData['most_popular_categories']);
      }

      for (var key in jsonData.keys) {
        if (key != 'most_popular_categories' && jsonData[key] is List) {
          products.addAll(_parseItemList(jsonData[key]));
        }
      }
    }

    return {
      'products': products,
      'popularItems': popularItems,
    };
  }

  List<AmmoItem> _parseItemList(List items) {
    List<AmmoItem> result = [];
    for (var item in items) {
      try {
        if (item is Map<String, dynamic>) {
          result.add(AmmoItem.fromJson(item));
        }
      } catch (e) {
        debugPrint("Error parsing item: $e");
      }
    }
    return result;
  }
}

// ============================================================================
// CATEGORY ITEM MODEL
// ============================================================================
class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int itemCount;

  CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.itemCount,
  });
}

// ============================================================================
// EXTENSIONS
// ============================================================================
extension AmmoItemExtension on AmmoItem {
  String get displayName => name ?? 'Unknown Product';
  String get displayCategory => category ?? 'Category';
  String get displayCaliber => caliber ?? 'N/A';
  String get displayPrice => '${(price ?? 0).toStringAsFixed(0)} ${currency ?? 'BDT'}';
  int get displayStock => stockQuantity ?? 0;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}

// ============================================================================
// MAIN WIDGET
// ============================================================================
class Api_ammunation_project extends StatefulWidget {
  final User? user;
  final AmmoApiService? apiService;

  const Api_ammunation_project({
    super.key,
    this.user,
    this.apiService,
  });

  @override
  State<Api_ammunation_project> createState() => _Api_ammunation_projectState();
}

class _Api_ammunation_projectState extends State<Api_ammunation_project> {
  late final AmmoApiService _apiService;

  List<AmmoItem> data = [];
  List<AmmoItem> filteredData = [];
  List<AmmoItem> popularItems = [];
  List<CategoryItem> categories = [];
  String selectedCategory = "All Products";

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  Timer? _notificationTimer;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? AmmoApiService();
    fetchData();
    _startRecurringNotifications();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _notificationTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // DATA FETCHING
  // ==========================================================================
  Future<void> fetchData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await _apiService.fetchProducts();

      setState(() {
        data = result['products'] ?? [];
        filteredData = List.from(data);
        popularItems = result['popularItems'] ?? [];
      });

      await _buildCategories();

      debugPrint("Data loaded: ${data.length} items, ${popularItems.length} popular items");
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() {
        errorMessage = "Failed to load data. Please check your connection.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _buildCategories() async {
    Set<String> categorySet = {};
    for (var item in data) {
      if (item.category != null && item.category!.isNotEmpty) {
        categorySet.add(item.category!);
      }
    }

    List<CategoryItem> tempCategories = [
      CategoryItem(
        id: "all",
        name: "All Products",
        icon: Icons.all_inclusive,
        color: AppColors.primary,
        itemCount: data.length,
      ),
    ];

    Map<String, IconData> categoryIcons = {
      'Handgun Ammo': Icons.security,
      'Sniper Ammo': Icons.remove_red_eye,
      'Rifle Ammo': Icons.architecture,
      'Rimfire Ammo': Icons.flash_on,
      'Shotgun Shell': Icons.bolt,
      'Pistol Ammo': Icons.precision_manufacturing,
      'Handgun/Rifle Ammo': Icons.swap_horiz,
    };

    int colorIndex = 0;
    for (var category in categorySet) {
      final itemCount = data.where((item) => item.category == category).length;
      tempCategories.add(
        CategoryItem(
          id: category.toLowerCase().replaceAll(' ', '_'),
          name: category,
          icon: categoryIcons[category] ?? Icons.category,
          color: AppColors.categoryColors[colorIndex % AppColors.categoryColors.length],
          itemCount: itemCount,
        ),
      );
      colorIndex++;
    }

    setState(() {
      categories = tempCategories;
    });
  }

  // ==========================================================================
  // FILTERING & SEARCH
  // ==========================================================================
  void filterData(String query, String category) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(
      Duration(milliseconds: AppConstants.searchDebounceMilliseconds),
          () {
        setState(() {
          filteredData = data.where((item) {
            final matchesSearch = query.isEmpty ||
                item.displayName.toLowerCase().contains(query.toLowerCase()) ||
                item.displayCategory.toLowerCase().contains(query.toLowerCase()) ||
                (item.description ?? '').toLowerCase().contains(query.toLowerCase());

            final matchesCategory = category == "All Products" ||
                item.displayCategory == category;

            return matchesSearch && matchesCategory;
          }).toList();
        });
      },
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      selectedCategory = "All Products";
      filteredData = List.from(data);
    });
  }

  // ==========================================================================
  // NOTIFICATIONS
  // ==========================================================================
  void _startRecurringNotifications() {
    // Send first notification after 3 minutes
    Future.delayed(Duration(minutes: AppConstants.notificationIntervalMinutes), () {
      _sendNotification();
    });

    // Then send recurring notifications every 3 minutes
    _notificationTimer = Timer.periodic(
      Duration(minutes: AppConstants.notificationIntervalMinutes),
          (timer) {
        _sendNotification();
      },
    );

    debugPrint("✅ Recurring notifications scheduled for every ${AppConstants.notificationIntervalMinutes} minutes");
  }

  Future<void> _sendNotification() async {
    await NotificationService.scheduleNotification(
      title: "Armory Pro Alert 🎯",
      body: "Check out our latest ammunition deals!",
      seconds: 0,
    );
  }

  // ==========================================================================
  // UI BUILDERS
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      drawer: _buildDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 4,
      centerTitle: true,
      title: Text(
        AppConstants.appName,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.white),
          onPressed: fetchData,
          tooltip: 'Refresh',
        ),
        if (categories.isNotEmpty)
          IconButton(
            icon: Icon(Icons.filter_alt, color: Colors.white),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingScreen();
    }

    if (errorMessage != null) {
      return _buildErrorScreen();
    }

    if (data.isEmpty) {
      return _buildEmptyScreen();
    }

    return RefreshIndicator(
      onRefresh: fetchData,
      color: AppColors.accent,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            if (popularItems.isNotEmpty) _buildMostPopularSection(),
            if (categories.length > 1) _buildCategoriesSection(),
            _buildProductsHeader(),
            _buildProductsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            "Loading Armory...",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Securing your arsenal",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.accent,
            ),
            SizedBox(height: 20),
            Text(
              "Connection Error",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              errorMessage ?? "Failed to load data",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(
                "Retry",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Text(
              "No Products Available",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Check back later or refresh",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Icon(Icons.search, color: AppColors.accent),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search weapons, ammunition...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
                onChanged: (value) {
                  filterData(value, selectedCategory);
                },
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: AppColors.accent),
                onPressed: () {
                  _searchController.clear();
                  filterData('', selectedCategory);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostPopularSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MOST POPULAR",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "TRENDING",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: AppConstants.popularSectionHeight,
          padding: EdgeInsets.only(left: 16, bottom: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popularItems.length,
            itemBuilder: (context, index) {
              return _buildPopularCard(popularItems[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularCard(AmmoItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Details_page(output: item),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  color: Colors.black.withOpacity(0.1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: item.hasImage
                      ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image,
                          color: Colors.white.withOpacity(0.3), size: 40);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    },
                  )
                      : Icon(Icons.image, color: Colors.white.withOpacity(0.3), size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "POPULAR",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        item.displayCategory,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.displayPrice,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colors.white,
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
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            "CATEGORIES",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          height: AppConstants.categorySectionHeight,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              bool isSelected = selectedCategory == category.name;

              return Container(
                margin: EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category.name;
                        });
                        filterData(_searchController.text, selectedCategory);
                      },
                      child: Container(
                        width: AppConstants.categoryIconSize,
                        height: AppConstants.categoryIconSize,
                        decoration: BoxDecoration(
                          color: isSelected ? category.color : category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? category.color : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: category.color.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category.icon,
                              color: isSelected ? Colors.white : category.color,
                              size: 24,
                            ),
                            SizedBox(height: 6),
                            if (category.itemCount > 0)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : category.color,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${category.itemCount}",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? category.color : Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: AppConstants.categoryIconSize,
                      child: Text(
                        category.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? category.color : AppColors.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "ALL PRODUCTS",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
          Text(
            "${filteredData.length} items",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (filteredData.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
            SizedBox(height: 20),
            Text(
              "No products found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Try different search terms or categories",
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(
                "Clear Filters",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      padding: EdgeInsets.all(16),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        return _buildProductCard(filteredData[index]);
      },
    );
  }

  Widget _buildProductCard(AmmoItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Details_page(output: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey[50]!,
                      Colors.grey[100]!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: item.hasImage
                            ? Image.network(
                          item.imageUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accent,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                              size: 40,
                            );
                          },
                        )
                            : Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      ),
                    ),
                    if (item.category != null && item.category!.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.displayCategory,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Caliber: ${item.displayCaliber}",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                        ),
                        child: Text(
                          item.displayPrice,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${item.displayStock}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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
  }

  // ==========================================================================
  // DIALOGS
  // ==========================================================================
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Filter Products",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                bool isSelected = selectedCategory == category.name;

                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: AppColors.accent, width: 2) : null,
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${category.itemCount}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: category.color,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedCategory = category.name;
                      });
                      filterData(_searchController.text, selectedCategory);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearFilters();
                Navigator.pop(context);
              },
              child: Text(
                "Reset",
                style: TextStyle(color: AppColors.accent),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Close",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================================
  // DRAWER
  // ==========================================================================
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: ListView(
          children: [
            _buildDrawerHeader(),
            SizedBox(height: 16),
            ..._buildDrawerItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.accent.withOpacity(0.8),
            AppColors.primary,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.grey[300]!,
                ],
              ),
            ),
            child: Icon(
              Icons.security,
              size: 40,
              color: AppColors.accent,
            ),
          ),
          SizedBox(height: 16),
          Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Secure | Reliable | Professional",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems() {
    return [
      _buildDrawerItem(
        icon: Icons.home,
        title: "Home",
        isSelected: true,
        onTap: () {
          Navigator.pop(context);
        },
      ),
      _buildDrawerItem(
        icon: Icons.notifications_active,
        title: "Notifications",
        subtitle: "Manage alerts",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationPage()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.call,
        title: "Helpline",
        subtitle: AppConstants.helplineNumber,
        onTap: () async {
          final Uri url = Uri.parse('tel:${AppConstants.helplineNumber}');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch phone dialer')),
            );
          }
        },
      ),
      _buildDrawerItem(
        icon: Icons.people,
        title: "Employee List",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => employeelist_page()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.privacy_tip,
        title: "Privacy Policy",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => privacy_page()),
          );
        },
      ),
    ];
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppColors.accent) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.accent : Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white.withOpacity(0.5),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}