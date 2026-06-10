import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gym_master/config/theme.dart';
import 'package:gym_master/providers/auth_provider.dart';
import 'package:gym_master/widgets/common_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _contactController = TextEditingController();
  final _cityController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _contactController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _clearAuthError() {
    final auth = context.read<AuthProvider>();
    if (auth.error != null) auth.clearError();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim().toLowerCase(),
      'password': _passwordController.text,
      'contact': _contactController.text.trim(),
      'city': _cityController.text.trim(),
    });

    if (!mounted) return;

    if (success) {
      showAppSnackBar(context, 'Registration successful! Please login.');
      context.go('/login');
    } else {
      showAppSnackBar(
        context,
        auth.error ?? 'Registration failed. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return LoadingOverlay(
              isLoading: auth.isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Join GymMaster',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create your account to get started',
                        style: TextStyle(
                            fontSize: 16, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        enabled: !auth.isLoading,
                        onChanged: (_) => _clearAuthError(),
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outlined),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Name is required';
                          if (!RegExp(r'^[A-Za-z ]+$').hasMatch(value)) {
                            return 'Name must contain only letters and spaces';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        enabled: !auth.isLoading,
                        onChanged: (_) => _clearAuthError(),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Email is required';
                          if (!RegExp(
                                  r'^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$',
                                  caseSensitive: false)
                              .hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        enabled: !auth.isLoading,
                        onChanged: (_) => _clearAuthError(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          helperText:
                              'Min 8 chars with upper, lower & a number',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: auth.isLoading
                                ? null
                                : () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          final value = v ?? '';
                          if (value.isEmpty) return 'Password is required';
                          if (!RegExp(
                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$')
                              .hasMatch(value)) {
                            return 'Min 8 chars with upper, lower & a number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        textInputAction: TextInputAction.next,
                        enabled: !auth.isLoading,
                        onChanged: (_) => _clearAuthError(),
                        decoration: const InputDecoration(
                          labelText: 'Contact Number',
                          counterText: '',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Contact is required';
                          if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                            return 'Enter a 10-digit number starting with 6-9';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cityController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        enabled: !auth.isLoading,
                        onChanged: (_) => _clearAuthError(),
                        onFieldSubmitted: (_) => _handleRegister(),
                        decoration: const InputDecoration(
                          labelText: 'City',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'City is required';
                          if (!RegExp(r'^[A-Za-z ]+$').hasMatch(value)) {
                            return 'City must contain only letters and spaces';
                          }
                          return null;
                        },
                      ),
                      // Inline error banner
                      if (auth.error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.08),
                            border: Border.all(
                                color: AppColors.danger.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.danger, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  auth.error!,
                                  style: const TextStyle(
                                      color: AppColors.danger, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleRegister,
                          child: auth.isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Creating account...'),
                                  ],
                                )
                              : const Text('Create Account'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ',
                              style:
                                  TextStyle(color: AppColors.textSecondary)),
                          TextButton(
                            onPressed: auth.isLoading
                                ? null
                                : () => context.go('/login'),
                            child: const Text('Sign In',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
