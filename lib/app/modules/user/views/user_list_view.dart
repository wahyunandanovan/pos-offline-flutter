import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../routes/app_routes.dart';
import '../user_controller.dart';

class UserListView extends GetView<UserController> {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: CustomTextField(
              hintText: 'Cari user...',
              prefixIcon: Icons.search,
              onChanged: controller.searchUsers,
            ),
          ),

          // User List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredUsers.isEmpty) {
                return EmptyState(
                  icon: Icons.people_outline,
                  title: 'Tidak ada user',
                  message: controller.searchQuery.value.isEmpty
                      ? 'Belum ada user yang terdaftar'
                      : 'User tidak ditemukan',
                  actionText: controller.searchQuery.value.isEmpty
                      ? 'Tambah User'
                      : null,
                  onAction: controller.searchQuery.value.isEmpty
                      ? () {
                          controller.prepareCreate();
                          Get.toNamed(AppRoutes.USER_FORM);
                        }
                      : null,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                itemCount: controller.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.filteredUsers[index];
                  return _buildUserCard(context, user);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.prepareCreate();
          Get.toNamed(AppRoutes.USER_FORM);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah User'),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, user) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryLight,
          child: Text(
            user.fullName[0].toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${user.username}'),
            if (user.email != null) Text(user.email!),
            const SizedBox(height: AppTheme.spacing4),
            Row(
              children: [
                CustomBadge(
                  text: user.role.toUpperCase(),
                  backgroundColor: user.isAdmin
                      ? AppTheme.error.withOpacity(0.1)
                      : AppTheme.info.withOpacity(0.1),
                  textColor: user.isAdmin ? AppTheme.error : AppTheme.info,
                ),
                const SizedBox(width: AppTheme.spacing8),
                CustomBadge(
                  text: user.isActive ? 'Aktif' : 'Nonaktif',
                  backgroundColor: user.isActive
                      ? AppTheme.success.withOpacity(0.1)
                      : AppTheme.warning.withOpacity(0.1),
                  textColor:
                      user.isActive ? AppTheme.success : AppTheme.warning,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(user.isActive ? Icons.block : Icons.check_circle),
                  const SizedBox(width: 8),
                  Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                controller.prepareEdit(user);
                Get.toNamed(AppRoutes.USER_FORM);
                break;
              case 'toggle':
                controller.toggleUserStatus(user);
                break;
              case 'delete':
                final confirm = await ConfirmDialog.show(
                  context: context,
                  title: 'Hapus User',
                  message:
                      'Apakah Anda yakin ingin menghapus user ${user.fullName}?',
                  isDanger: true,
                );
                if (confirm == true) {
                  controller.deleteUser(user);
                }
                break;
            }
          },
        ),
      ),
    );
  }
}
