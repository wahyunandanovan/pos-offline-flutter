import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 500 : double.infinity,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLarge),
                        boxShadow: AppTheme.shadowMedium,
                      ),
                      child: const Icon(
                        Icons.shopping_cart_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Title
                  Text(
                    'Selamat Datang',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacing8),

                  Text(
                    'Masuk ke akun Anda untuk melanjutkan',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacing48),

                  // Login Form Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Username Field
                          CustomTextField(
                            controller: controller.usernameController,
                            label: 'Username',
                            hintText: 'Masukkan username',
                            prefixIcon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppTheme.spacing16),

                          // Password Field
                          Obx(() => CustomTextField(
                                controller: controller.passwordController,
                                label: 'Password',
                                hintText: 'Masukkan password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: controller.obscurePassword.value,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.obscurePassword.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed:
                                      controller.togglePasswordVisibility,
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => controller.login(),
                              )),
                          const SizedBox(height: AppTheme.spacing16),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(() => Row(
                                    children: [
                                      Checkbox(
                                        value: controller.rememberMe.value,
                                        onChanged: (value) {
                                          controller.rememberMe.value =
                                              value ?? false;
                                        },
                                      ),
                                      const Text('Ingat Saya'),
                                    ],
                                  )),
                              TextButton(
                                onPressed: () {
                                  _showForgotPasswordDialog(context);
                                },
                                child: const Text('Lupa Password?'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing24),

                          // Login Button
                          Obx(() => CustomButton(
                                text: 'Masuk',
                                onPressed: controller.login,
                                isLoading: controller.isLoading.value,
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing32),

                  // Quick Login Hints (untuk testing)
                  _buildQuickLoginHints(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLoginHints(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.info.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.info,
                size: 20,
              ),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                'Akun Testing',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.info,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing8),
          _buildLoginHint(context, 'Admin', 'admin / admin123'),
          _buildLoginHint(context, 'Kasir', 'kasir1 / kasir123'),
        ],
      ),
    );
  }

  Widget _buildLoginHint(
      BuildContext context, String role, String credentials) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.info,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.spacing8),
          Text(
            '$role: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            credentials,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final usernameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Lupa Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Masukkan username Anda untuk reset password (offline simulation)',
            ),
            const SizedBox(height: AppTheme.spacing16),
            CustomTextField(
              controller: usernameController,
              label: 'Username',
              hintText: 'Masukkan username',
              prefixIcon: Icons.person_outline,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.forgotPassword(usernameController.text);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
