import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/theme.dart';
import '../../services/usb_key_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final _usbService = UsbKeyService();
  bool _isProvisioning = false;

  Future<void> _provisionKey() async {
    // Show a confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.usb, color: AppTheme.lemonHeader),
            SizedBox(width: 12),
            Text('Provision Security Key', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: kIsWeb
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Please follow these steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text('1️⃣  Plug in your USB drive now.'),
                SizedBox(height: 6),
                Text('2️⃣  Click CONFIRM — a "lemon.key" file will download to your browser\'s Downloads folder.'),
                SizedBox(height: 6),
                Text('3️⃣  Move that file to the ROOT of your USB drive (e.g. E:\\lemon.key)'),
                SizedBox(height: 6),
                Text('4️⃣  Your USB is now a Physical Admin Key! ✅'),
                SizedBox(height: 12),
                Text(
                  'Note: Browsers cannot save directly to USB drives — the file must be moved manually.',
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            )
          : const Text('Select a folder on your USB drive when prompted. The app will write the "lemon.key" file to it.\n\nMake sure your USB drive is plugged in before continuing.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lemonHeader,
              foregroundColor: Colors.white,
            ),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProvisioning = true);
    try {
      bool success = await _usbService.provisionUsbKey();
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                kIsWeb
                  ? '✅ lemon.key downloaded! Now move it from Downloads to the ROOT of your USB drive.'
                  : '✅ USB Provisioned Successfully! This drive can now be used as a Physical Admin Key.',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 8),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Provisioning canceled or failed. Please try again.'),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isProvisioning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hintText = kIsWeb
      ? 'On Web: Clicking Provision will download a "lemon.key" file. Copy it to the ROOT of your USB drive to use it as a Physical Admin Key.'
      : 'Plug in a generic USB drive and click the button above. The app will create a "lemon.key" signature file on the root of the drive.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('VAULT - Security Key Management'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: AppTheme.lemonBackground,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.enhanced_encryption_outlined, size: 80, color: AppTheme.lemonHeader),
                const SizedBox(height: 24),
                Text(
                  'Physical Admin Keys',
                  style: AppTheme.serifTitle.copyWith(fontSize: 28, color: AppTheme.lemonHeader),
                ),
                const SizedBox(height: 16),
                const Text(
                  'From this Vault, you can create physical security keys that are required to perform critical administrative actions like system hard resets.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                ),
                if (kIsWeb) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.web, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Web Mode: Provisioning will download the key file to your browser.',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 32),
                _isProvisioning
                    ? const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Preparing your security key...', style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton.icon(
                              onPressed: _provisionKey,
                              icon: Icon(kIsWeb ? Icons.download : Icons.usb, size: 28),
                              label: const Text('PROVISION NEW SECURITY KEY', style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.lemonHeader,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  hintText,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
