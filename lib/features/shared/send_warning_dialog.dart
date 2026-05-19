import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SendWarningDialog extends StatefulWidget {
  final String targetName;
  final String? currentWarning;

  const SendWarningDialog({
    super.key,
    required this.targetName,
    this.currentWarning,
  });

  @override
  State<SendWarningDialog> createState() => _SendWarningDialogState();
}

class _SendWarningDialogState extends State<SendWarningDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentWarning);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 8),
          Text('Warn ${widget.targetName}'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'The message will be visible to the user on their home screen.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter violation details (e.g., Dress code violation, Late for class)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.orange, width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (widget.currentWarning != null && widget.currentWarning!.isNotEmpty)
          TextButton(
            onPressed: () => Navigator.pop(context, ""), // Send empty string to clear
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Clear Warning'),
          ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Send Warning'),
        ),
      ],
    );
  }
}
