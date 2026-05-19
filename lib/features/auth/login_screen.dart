import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets/responsive_centered_layout.dart';
import '../auth/auth_provider.dart';
import 'register_admin_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        if (mounted) context.go('/');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Login failed'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return ResponsiveCenteredLayout(
      maxWidth: 420,
      backgroundColor: AppTheme.lemonBackground,
      builder: (context, constraints, isNarrow) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        final isShort = cardHeight < 600;
        
        // Fluid scaling factors
        final scaleFactor = (cardWidth / 420).clamp(0.7, 1.0);
        
        final titleFontSize = (32 * scaleFactor).clamp(24.0, 32.0);
        final welcomeFontSize = (28 * scaleFactor).clamp(20.0, 28.0);
        
        // Adjust logo based on height
        final logoHeight = (isShort ? 120.0 : (isNarrow ? 180.0 : 240.0)) * scaleFactor;
        final lemonScale = (isShort ? 0.8 : (isNarrow ? 1.0 : 1.2)) * scaleFactor;
        
        final innerPadding = (isNarrow ? 24.0 : 32.0) * scaleFactor;

        return Container(
          decoration: isNarrow 
            ? null 
            : BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                color: AppTheme.lemonHeader,
                padding: EdgeInsets.symmetric(vertical: (isShort || isNarrow) ? 12 : 24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Sign In',
                      style: AppTheme.serifTitle.copyWith(
                        color: Colors.white,
                        fontSize: titleFontSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              
              if (isNarrow) const SizedBox(height: 16),

              // Logo (Responsive sizing based on width AND height)
              if (cardHeight > 450)
                SizedBox(
                  height: logoHeight, 
                  child: OverflowBox(
                    maxHeight: 600,
                    maxWidth: 600,
                    child: Transform.translate(
                      offset: Offset(0, isNarrow ? 0 : 10), 
                      child: Transform.scale(
                        scale: lemonScale,
                        child: Center(
                          child: Image.asset(
                            'assets/icon/icon.png',
                            height: isNarrow ? 280 : 320,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 16),
              
              Padding(
                padding: EdgeInsets.fromLTRB(innerPadding, 0, innerPadding, innerPadding * 1.25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Welcome Text
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Welcome Back!',
                          style: AppTheme.serifTitle.copyWith(
                            fontSize: welcomeFontSize,
                            color: AppTheme.lemonHeader,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to your Lemon Account',
                        style: TextStyle(
                          color: AppTheme.lemonHeader.withValues(alpha: 0.7),
                          fontSize: (16 * scaleFactor).clamp(13.0, 16.0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: AppTheme.lemonText),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Please enter email' : null,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Icon(Icons.mail_outline, color: AppTheme.lemonHeader),
                          filled: true,
                          fillColor: AppTheme.lemonCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(color: AppTheme.lemonText),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Please enter password' : null,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.lemonHeader),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.lemonHeader,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          filled: true,
                          fillColor: AppTheme.lemonCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: isNarrow ? 50 : 54,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.lemonButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: isNarrow ? 0 : 2,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => context.push('/admin-setup/initial'),
                        child: Text(
                          'Admin Hard Reset / Initial Setup',
                          style: TextStyle(
                            color: AppTheme.lemonHeader.withValues(alpha: 0.5),
                            fontSize: isNarrow ? 11 : 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

  }
}
