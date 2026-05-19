import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/student.dart';
import '../../services/student_service.dart';

class AddStudentDialog extends StatefulWidget {
  const AddStudentDialog({super.key});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _uidController = TextEditingController();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController(); // School ID number
  bool _isLoading = false;

  @override
  void dispose() {
    _uidController.dispose();
    _nameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final student = Student(
          uid: _uidController.text.trim(),
          name: _nameController.text.trim(),
          studentId: _studentIdController.text.trim(),
          grades: {}, // Start empty
        );

        await StudentService().addStudent(student);

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding student: $e'),
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
      title: const Text('Add New Student'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
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
                          'Note: Create User in Firebase Console first and copy UID here.',
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
                  controller: _studentIdController,
                  validator: (v) => v?.isNotEmpty == true ? null : 'Student ID is required',
                  decoration: const InputDecoration(
                    labelText: 'Student ID (School ID)',
                    hintText: 'e.g. 2024-001',
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
              : const Text('Add Student'),
        ),
      ],
    );
  }
}
