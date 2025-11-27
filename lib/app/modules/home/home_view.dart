import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_offline/app/modules/reports/views/reports_view.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';
import '../pos/views/pos_view.dart';
import '../product/views/product_list_view.dart';
import '../pos/views/transaction_history_view.dart';
import '../user/views/user_list_view.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser.value;

      if (user == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final size = MediaQuery.of(context).size;
      final isDesktop = size.width > 800;

      return isDesktop ? _buildDesktopLayout(user) : _buildMobileLayout(user);
    });
  }

  Widget _buildDesktopLayout(user) {
    final pages = _getPages(user);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: controller.changePage,
            leading: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryLight,
                    child: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  const Text(
                    'POS Offline',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    user.fullName,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            destinations: pages.map((page) {
              return NavigationRailDestination(
                icon: Icon(page['icon'] as IconData),
                label: Text(page['label'] as String),
              );
            }).toList(),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Profil'),
                        onTap: () => Get.toNamed(AppRoutes.PROFILE),
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Pengaturan'),
                        onTap: () => Get.toNamed(AppRoutes.SETTINGS),
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                        onTap: () => _showLogoutDialog(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Obx(
                () => pages[controller.currentIndex.value]['page'] as Widget),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(user) {
    final pages = _getPages(user);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() =>
            Text(pages[controller.currentIndex.value]['label'] as String)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(AppRoutes.SETTINGS),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
              accountName: Text(user.fullName),
              accountEmail: Text(user.email ?? '@${user.username}'),
            ),
            ...pages.asMap().entries.map((entry) {
              final index = entry.key;
              final page = entry.value;
              return Obx(() => ListTile(
                    leading: Icon(page['icon'] as IconData),
                    title: Text(page['label'] as String),
                    selected: controller.currentIndex.value == index,
                    onTap: () {
                      controller.changePage(index);
                      Get.back();
                    },
                  ));
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.PROFILE);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.SETTINGS);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Get.back();
                _showLogoutDialog();
              },
            ),
          ],
        ),
      ),
      body: Obx(() => pages[controller.currentIndex.value]['page'] as Widget),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryLight,
            items: pages.map((page) {
              return BottomNavigationBarItem(
                icon: Icon(page['icon'] as IconData),
                label: page['label'] as String,
              );
            }).toList(),
          )),
    );
  }

  List<Map<String, dynamic>> _getPages(user) {
    final pages = <Map<String, dynamic>>[
      {
        'icon': Icons.point_of_sale,
        'label': 'POS',
        'page': const PosView(),
      },
      {
        'icon': Icons.receipt_long,
        'label': 'Transaksi',
        'page': const TransactionHistoryView(),
      },
      {
        'icon': Icons.inventory_2,
        'label': 'Produk',
        'page': const ProductListView(),
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Laporan',
        'page': const ReportsView(),
      },
    ];

    // Only show User Management for admin
    if (user.isAdmin) {
      pages.add({
        'icon': Icons.people,
        'label': 'User',
        'page': const UserListView(),
      });
    }

    return pages;
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.find<AuthController>().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
