import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/section.dart';
import '../../models/teacher.dart';
import '../../services/section_service.dart';
import '../../services/teacher_service.dart';
import 'add_class_dialog.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final SectionService _sectionService = SectionService();
  final TeacherService _teacherService = TeacherService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Sections'),
        backgroundColor: AppTheme.white,
        centerTitle: true,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Section'),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => const AddSectionDialog(),
              );
              
              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Section added successfully'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: AppTheme.white,
              elevation: 0,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<List<Teacher>>(
        stream: _teacherService.getTeachers(),
        builder: (context, teacherSnapshot) {
          final teacherMap = <String, String>{
            for (var teacher in teacherSnapshot.data ?? [])
              teacher.uid: teacher.name
          };

          return StreamBuilder<List<Section>>(
            stream: _sectionService.getSections(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final sections = snapshot.data ?? [];

              if (sections.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.class_outlined,
                          size: 64, color: AppTheme.forestEspresso.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const Text('No sections found'),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: sections
                      .map((section) => _buildSectionCard(context, section, teacherMap))
                      .toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(
      BuildContext context, Section section, Map<String, String> teacherMap) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  section.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style: TextStyle(color: AppTheme.errorRed))),
                ],
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Section'),
                        content:
                            Text('Are you sure you want to delete ${section.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                                foregroundColor: AppTheme.errorRed),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        await _sectionService.deleteSection(section.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Section deleted')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: AppTheme.errorRed,
                            ),
                          );
                        }
                      }
                    }
                  } else if (value == 'edit') {
                    // TODO: Implement Edit
                  }
                },
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.person,
              'Adviser: ${teacherMap[section.adviserUid] ?? "Unassigned"}'),
          const SizedBox(height: 4),
          _buildInfoRow(Icons.people, 'Students: ${section.studentUids.length}'),
          const SizedBox(height: 4),
          _buildInfoRow(Icons.grade, 'Grade Level: ${section.gradeLevel}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey))),
      ],
    );
  }
}
