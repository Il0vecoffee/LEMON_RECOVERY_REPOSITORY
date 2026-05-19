import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/teacher.dart';
import '../../services/teacher_service.dart';

class AddTeacherDialog extends StatefulWidget {
  const AddTeacherDialog({super.key});

  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  final _uidController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _advisoryController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _uidController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subjectsController.dispose();
    _advisoryController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final teacher = Teacher(
          uid: _uidController.text.trim(),
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          subjects: _subjectsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          advisoryClass: _advisoryController.text.trim().isEmpty
              ? null
              : _advisoryController.text.trim(),
        );

        await TeacherService().addTeacher(teacher);

        if (mounted) {
          Navigator.of(context).pop(true); // Return true on success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding teacher: $e'),
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
      title: const Text('Add New Teacher'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500, // Fixed width for desktop
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Note: You must create the User in Firebase Authentication Console first and copy the UID here.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _uidController,
                  validator: (v) => v?.isNotEmpty == true ? null : 'UID is required',
                  decoration: const InputDecoration(
                    labelText: 'Firebase UID',
                    hintText: 'Paste UID from Firebase Console',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  validator: (v) => v?.isNotEmpty == true ? null : 'Name is required',
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  validator: (v) => v?.contains('@') == true ? null : 'Valid email required',
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subjectsController,
                  decoration: const InputDecoration(
                    labelText: 'Subjects (comma separated)',
                    hintText: 'Math, Science, History',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _advisoryController,
                  decoration: const InputDecoration(
                    labelText: 'Advisory Section (Optional)',
                    hintText: 'e.g. 10-A',
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
              : const Text('Add Teacher'),
        ),
      ],
    );
  }
}
