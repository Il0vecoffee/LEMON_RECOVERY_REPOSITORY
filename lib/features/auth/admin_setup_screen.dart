import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/responsive_centered_layout.dart';
import '../../models/invitation.dart';
import '../../services/admin_service.dart';
import 'auth_provider.dart';

class AdminSetupScreen extends StatefulWidget {
  final String token;
  const AdminSetupScreen({super.key, required this.token});

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AdminService _adminService = AdminService();
  
  AdminInvitation? _invitation;
  bool _isValidating = true;
  String? _error;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _validateToken();
  }

  Future<void> _validateToken() async {
    try {
      final invite = await _adminService.getInvitation(widget.token);
      if (invite == null || invite.isUsed) {
        setState(() {
          _error = 'This invitation link is invalid or has already been used.';
          _isValidating = false;
        });
        return;
      }
      setState(() {
        _invitation = invite;
        _isValidating = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error validating invitation: $e';
        _isValidating = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSetup() async {
    if (_formKey.currentState!.validate() && _invitation != null) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        invitationToken: widget.token,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account setup successful! logging in...')),
        );
        // AuthProvider will automatically redirect to dashboard on state change
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidating) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final isLoading = context.watch<AuthProvider>().isLoading;
    final errorMessage = context.watch<AuthProvider>().errorMessage;

    return ResponsiveCenteredLayout(
      backgroundColor: AppTheme.creamSilk,
      builder: (context, constraints, isNarrow) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        final isShort = cardHeight < 600;
        
        final scaleFactor = (cardWidth / 450).clamp(0.8, 1.0);
        final titleFontSize = (24 * scaleFactor).clamp(18.0, 24.0);
        final innerPadding = (isNarrow ? 24.0 : 40.0) * scaleFactor;

        Widget content = Padding(
          padding: EdgeInsets.all(innerPadding),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (cardHeight > 550)
                  Center(
                    child: Icon(Icons.admin_panel_settings,
                        size: (64 * scaleFactor).clamp(40.0, 64.0),
                        color: AppTheme.primaryGreen),
                  ),
                SizedBox(height: isShort ? 8 : (isNarrow ? 16 : 24)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isShort ? 'Admin Setup' : 'Administrator Setup',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.forestEspresso,
                          fontSize: titleFontSize,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                if (!isShort)
                  Text(
                    'Set up your administrator account to join the team',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: (14 * scaleFactor).clamp(11.0, 14.0),
                    ),
                  ),
                SizedBox(height: isShort ? 16 : (isNarrow ? 24 : 32)),
                if (errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
                    ),
                  ),
                TextFormField(
                  controller: _nameController,
                  validator: (v) => (v?.length ?? 0) >= 2 ? null : 'Full name required',
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  validator: (v) => v?.contains('@') == true ? null : 'Valid email required',
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  validator: (v) => (v?.length ?? 0) >= 6 ? null : 'Minimum 6 characters',
                  decoration: InputDecoration(
                    labelText: 'Create Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isPasswordVisible,
                  validator: (v) =>
                      v == _passwordController.text ? null : 'Passwords do not match',
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_clock_outlined),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _handleSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isNarrow ? 12 : 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Complete Setup & Join',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );

        if (isNarrow) {
          return Container(
            color: Theme.of(context).cardColor,
            child: content,
          );
        }

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 4,
          child: content,
        );
      },
    );

  }
}
