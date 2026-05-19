import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/usb_key_service.dart';
import 'auth_provider.dart';

class RegisterAdminDialog extends StatefulWidget {
  const RegisterAdminDialog({super.key});

  @override
  State<RegisterAdminDialog> createState() => _RegisterAdminDialogState();
}

class _RegisterAdminDialogState extends State<RegisterAdminDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usbService = UsbKeyService();
  
  bool _isPasswordVisible = false;
  bool _securityKeyValidated = false;
  bool _isScanning = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _scanForKey() async {
    setState(() => _isScanning = true);
    
    // 1. Try automatic Windows drive scan
    String? foundDrive = await _usbService.scanForPhysicalKey();
    
    if (foundDrive != null) {
      _onKeySuccess('Physical Key detected on drive $foundDrive');
      return;
    }

    // 2. Fallback: Manual pick for Web or if auto-scan missed it
    bool success = await _usbService.pickAndValidateKey();
    if (success) {
      _onKeySuccess('Key file verified successfully.');
    } else {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification Failed. Please ensure your USB is plugged in or select the lemon.key file.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onKeySuccess(String message) {
    if (mounted) {
      setState(() {
        _securityKeyValidated = true;
        _isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final errorMessage = context.watch<AuthProvider>().errorMessage;

    return AlertDialog(
      title: const Text('Admin Initial Setup'),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: !_securityKeyValidated
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildSecurityKeyStep(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildRegistrationForm(isLoading, errorMessage),
                  ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: (isLoading || _isScanning) ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (_securityKeyValidated)
          ElevatedButton(
            onPressed: isLoading ? null : _handleRegister,
            child: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Create Admin Account'),
          ),
      ],
    );
  }

  Widget _buildSecurityKeyStep() {
    return Column(
      key: const ValueKey('security_step'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.usb_outlined, size: 64, color: AppTheme.lemonHeader),
        const SizedBox(height: 16),
        const Text(
          'Physical Authentication Required',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Please insert your Physical Admin Key (USB) to unlock the Hard Reset flow.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (_isScanning)
          const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Scanning drives for Lemon Key...', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _scanForKey,
              icon: const Icon(Icons.search),
              label: const Text('Scan for Security Key'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lemonHeader,
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRegistrationForm(bool isLoading, String? errorMessage) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hardware Authenticated.',
                  style: TextStyle(fontSize: 14, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (errorMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
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
            validator: (v) => v != null && v.isNotEmpty ? null : 'Full Name required',
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
              labelText: 'New Admin Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            validator: (v) => (v?.length ?? 0) >= 6 ? null : 'Password must be at least 6 characters',
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isPasswordVisible,
            validator: (v) => v == _passwordController.text ? null : 'Passwords do not match',
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_clock_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
