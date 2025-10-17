import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/app_logger.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      AppLogger.warning('Login attempted with empty credentials');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterUsernameAndPassword),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    AppLogger.info('Login attempt for user: ${_usernameController.text}');

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await ref
          .read(authStateProvider.notifier)
          .login(_usernameController.text, _passwordController.text);

      AppLogger.info('Login successful for user: ${_usernameController.text}');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Login failed for user: ${_usernameController.text}',
        e,
        stackTrace,
      );
    } finally {
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(languageProvider);
    final isArabic = locale.languageCode == 'ar';

    // Show loading or error state
    authState.whenOrNull(
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: AppColors.error,
              ),
            );
          }
        });
      },
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language Selector
                  Align(
                    alignment:
                        isArabic ? Alignment.centerLeft : Alignment.centerRight,
                    child: FadeInDown(child: _buildLanguageSelector()),
                  ),
                  const SizedBox(height: 16),

                  // Logo
                  FadeInDown(
                    child: Hero(
                      tag: 'logo',
                      child: Center(
                        child: Image.asset(
                          'assets/logo.svg.png',
                          height: 120,
                          width: 120,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      l10n.welcomeTo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInDown(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      l10n.smartConferenceSystem,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Login Form
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: CustomTextField(
                      label: l10n.username,
                      hint: l10n.enterUsername,
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),

                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: CustomTextField(
                      label: l10n.password,
                      hint: l10n.enterPassword,
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: CustomButton(
                      text: l10n.login,
                      icon: Icons.login,
                      onPressed:
                          _isLoading ? null : () => _handleLogin(context),
                      isLoading: _isLoading,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Demo Credentials Info
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.demoCredentials,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildCredentialRow(l10n.admin, 'admin', 'admin123'),
                          const SizedBox(height: 8),
                          _buildCredentialRow(
                            l10n.member,
                            'member1',
                            'member123',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Text(
                      l10n.secureGovernmentConferenceManagement,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final locale = ref.watch(languageProvider);
    final currentLanguage = locale.languageCode == 'ar' ? 'العربية' : 'English';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () {
          ref.read(languageProvider.notifier).toggleLanguage();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              currentLanguage,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialRow(String role, String username, String password) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$username / $password',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
