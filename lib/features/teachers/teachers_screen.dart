import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/teacher.dart';
import '../../models/section.dart';
import '../../services/teacher_service.dart';
import '../../services/section_service.dart';
import 'add_teacher_dialog.dart';
import '../shared/send_warning_dialog.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final TeacherService _teacherService = TeacherService();
  final SectionService _sectionService = SectionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Teachers'),
        backgroundColor: AppTheme.white,
        centerTitle: true,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Teacher'),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => const AddTeacherDialog(),
              );
              
              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Teacher added successfully'),
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
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 48),
                  const SizedBox(height: 16),
                  Text('Error loading teachers: ${snapshot.error}'),
                ],
              ),
            );
          }

          final teachers = snapshot.data ?? [];

          if (teachers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined,
                      size: 64, color: AppTheme.forestEspresso.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No teachers found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.forestEspresso.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<List<Section>>(
            stream: _sectionService.getSections(),
            builder: (context, sectionSnapshot) {
              final sections = sectionSnapshot.data ?? [];
              final Map<String, String> adviserMap = {};
              for (var s in sections) {
                if (s.adviserUid != null) {
                  adviserMap[s.adviserUid!] = s.id;
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DataTable(
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    columnSpacing: 24,
                    horizontalMargin: 12,
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Account Type')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Advisory')),
                      DataColumn(label: Center(child: Text('Actions'))),
                    ],
                    rows: teachers.map((teacher) {
                      final advisoryFromSections = adviserMap[teacher.uid];
                      final isAdviser = advisoryFromSections != null || (teacher.advisoryClass != null && teacher.advisoryClass!.isNotEmpty);
                      final displayedAdvisory = advisoryFromSections ?? (teacher.advisoryClass ?? '-');

                      return DataRow(cells: [
                        DataCell(Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.lemonYellow,
                                backgroundImage: teacher.profileImageUrl != null
                                    ? NetworkImage(teacher.profileImageUrl!)
                                    : null,
                                child: teacher.profileImageUrl == null
                                    ? Text(
                                        teacher.name.isNotEmpty
                                            ? teacher.name.substring(0, 1).toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            color: AppTheme.forestEspresso, fontWeight: FontWeight.bold))
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(teacher.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration: teacher.isSuspended ? TextDecoration.lineThrough : null,
                                          color: teacher.isSuspended ? Colors.grey : null,
                                        )),
                                    if (teacher.isSuspended)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.errorRed.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'SUSPENDED',
                                          style: TextStyle(
                                            color: AppTheme.errorRed,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAdviser ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAdviser ? 'Adviser' : 'Subject Teacher',
                            style: TextStyle(
                              color: isAdviser ? AppTheme.primaryGreen : Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                        DataCell(Text(teacher.email)),
                        DataCell(Text(displayedAdvisory)),
                        DataCell(Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.bolt, color: Colors.orange),
                              onPressed: () async {
                                final message = await showDialog<String>(
                                  context: context,
                                  builder: (context) => SendWarningDialog(
                                    targetName: teacher.name,
                                    currentWarning: teacher.warning,
                                  ),
                                );

                                if (message != null) {
                                  try {
                                    await _teacherService.updateWarning(teacher.uid, message.isEmpty ? null : message);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(message.isEmpty ? 'Warning cleared' : 'Warning sent to ${teacher.name}'),
                                          backgroundColor: message.isEmpty ? AppTheme.forestEspresso : Colors.orange,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
                                      );
                                    }
                                  }
                                }
                              },
                              tooltip: 'Warn Teacher',
                            ),
                            IconButton(
                              icon: Icon(
                                teacher.isSuspended ? Icons.play_arrow_outlined : Icons.block_flipped,
                                color: teacher.isSuspended ? AppTheme.primaryGreen : AppTheme.errorRed,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(teacher.isSuspended ? 'Unsuspend Teacher' : 'Suspend Teacher'),
                                    content: Text('Are you sure you want to ${teacher.isSuspended ? 'unsuspend' : 'suspend'} ${teacher.name}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: teacher.isSuspended ? AppTheme.primaryGreen : AppTheme.errorRed,
                                        ),
                                        child: Text(teacher.isSuspended ? 'Unsuspend' : 'Suspend'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  try {
                                    await _teacherService.toggleSuspension(teacher.uid, teacher.isSuspended);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Teacher ${teacher.isSuspended ? 'unsuspended' : 'suspended'}')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
                                      );
                                    }
                                  }
                                }
                              },
                              tooltip: teacher.isSuspended ? 'Unsuspend' : 'Suspend',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                              onPressed: () {
                                // TODO: Edit Teacher
                              },
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Teacher'),
                                    content: Text('Are you sure you want to delete ${teacher.name}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  try {
                                    await _teacherService.deleteTeacher(teacher.uid);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Teacher deleted')),
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
                              },
                              tooltip: 'Delete',
                            ),
                          ],
                        ))),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
