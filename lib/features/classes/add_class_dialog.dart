import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/section.dart';
import '../../services/section_service.dart';

class AddSectionDialog extends StatefulWidget {
  const AddSectionDialog({super.key});

  @override
  State<AddSectionDialog> createState() => _AddSectionDialogState();
}

class _AddSectionDialogState extends State<AddSectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); // E.g. "10-Newton"
  final _adviserUidController = TextEditingController();
  final _gradeLevelController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _adviserUidController.dispose();
    _gradeLevelController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final sectionName = _nameController.text.trim();
        final section = Section(
          id: sectionName,
          name: sectionName,
          adviserUid: _adviserUidController.text.trim().isEmpty ? null : _adviserUidController.text.trim(),
          gradeLevel: int.tryParse(_gradeLevelController.text.trim()) ?? 0,
          teacherUids: [], // Add teachers later via edit
          studentUids: [], // Add students later
        );

        await SectionService().addSection(section, sectionName);

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding section: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Section'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  validator: (v) => v?.isNotEmpty == true ? null : 'Section Name is required',
                  decoration: const InputDecoration(
                    labelText: 'Section Name (e.g. 10-Newton)',
                    hintText: 'Unique Identifier',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gradeLevelController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Grade Level',
                    hintText: 'e.g. 10',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _adviserUidController,
                  decoration: const InputDecoration(
                    labelText: 'Adviser UID (Optional)',
                    hintText: 'Copy from Teachers list',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? _handleSubmit : null,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Add Section'),
        ),
      ],
    );
  }
}
