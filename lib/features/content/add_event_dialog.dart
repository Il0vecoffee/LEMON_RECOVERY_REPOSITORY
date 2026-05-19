import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';

class AddEventDialog extends StatefulWidget {
  final Event? event;

  const AddEventDialog({super.key, this.event});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _linkController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _imageFile;
  String? _currentImageUrl; // Can be a base64 data URI or a network URL
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descController.text = widget.event!.desc;
      _selectedDate = widget.event!.date;
      _currentImageUrl = widget.event!.imageUrl;
      if (widget.event!.externalLink != null) {
        _linkController.text = widget.event!.externalLink!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _imageFile = File(result.files.single.path!);
        });
        debugPrint('Image picked: ${_imageFile!.path}');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppTheme.forestEspresso,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String? imageData = _currentImageUrl;

        // Upload new image to Firebase Storage
        if (_imageFile != null) {
          imageData = await EventService().uploadImage(_imageFile!);
          if (imageData == null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Warning: Image upload failed. Posting without image.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }

        final eventService = EventService();
        final event = Event(
          id: widget.event?.id ?? '',
          title: _titleController.text.trim(),
          desc: _descController.text.trim(),
          date: _selectedDate,
          imageUrl: imageData,
          externalLink: _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
        );

        if (widget.event != null) {
          await eventService.updateEvent(event);
        } else {
          await eventService.addEvent(event);
        }

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving event: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  /// Build the image preview widget (handles base64 data URIs, network URLs, and local files)
  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity, height: 100),
      );
    }
    if (_currentImageUrl != null) {
      if (_currentImageUrl!.startsWith('data:')) {
        // Base64 data URI
        final base64Str = _currentImageUrl!.split(',').last;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(base64Decode(base64Str), fit: BoxFit.cover, width: double.infinity, height: 100),
        );
      } else {
        // Network URL (legacy)
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(_currentImageUrl!, fit: BoxFit.cover, width: double.infinity, height: 100),
        );
      }
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, color: AppTheme.primaryGreen, size: 32),
        SizedBox(height: 4),
        Text(
          'Add/Change Picture',
          style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFFF1F4ED),
      child: Container(
        width: 550,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event != null ? 'Edit News/Event' : 'Add News/Event',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.forestEspresso,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    validator: (v) => v?.isNotEmpty == true ? null : 'Title is required',
                    decoration: AppTheme.inputDecoration(
                      labelText: 'Event Title',
                      hintText: 'Enter title...',
                    ).copyWith(fillColor: Colors.white, filled: true),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: AppTheme.inputDecoration(
                      labelText: 'Description',
                      hintText: 'Add some details...',
                    ).copyWith(fillColor: Colors.white, filled: true),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: AppTheme.inputDecoration(labelText: 'Event Date').copyWith(
                        fillColor: Colors.white,
                        filled: true,
                        suffixIcon: const Icon(Icons.calendar_month, color: AppTheme.forestEspresso),
                      ),
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                        style: const TextStyle(color: AppTheme.forestEspresso),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _linkController,
                    decoration: AppTheme.inputDecoration(
                      labelText: 'External Link (Optional)',
                      hintText: 'https://example.com',
                    ).copyWith(
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: const Icon(Icons.link, color: AppTheme.forestEspresso),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: _buildImagePreview(),
                          ),
                        ),
                      ),
                      if (_imageFile != null || _currentImageUrl != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => setState(() {
                            _imageFile = null;
                            _currentImageUrl = null;
                          }),
                          icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                          tooltip: 'Remove Picture',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen.withAlpha(50),
                    foregroundColor: AppTheme.forestEspresso.withAlpha(150),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: AppTheme.primaryGreen, strokeWidth: 2),
                        )
                      : Text(widget.event != null ? 'Update Event' : 'Post Event',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
