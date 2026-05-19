import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/student.dart';
import '../../services/student_service.dart';
import '../../services/fcm_service.dart';
import 'add_student_dialog.dart';
import '../shared/send_warning_dialog.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final StudentService _studentService = StudentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        backgroundColor: AppTheme.white,
        centerTitle: true,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Student'),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => const AddStudentDialog(),
              );
              
              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Student added successfully'),
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
      body: StreamBuilder<List<Student>>(
        stream: _studentService.getStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return const Center(child: Text('No students found'));
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
                  DataColumn(label: Center(child: Text('Actions'))),
                ],
                rows: students.map((student) {
                  return DataRow(cells: [
                    DataCell(Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.lemonYellow,
                            backgroundImage: student.profileImageUrl != null
                                ? NetworkImage(student.profileImageUrl!)
                                : null,
                            child: student.profileImageUrl == null
                                ? Text(
                                    student.name.trim().isNotEmpty
                                        ? student.name.trim().characters.first.toUpperCase()
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
                                Text(student.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: student.isSuspended ? TextDecoration.lineThrough : null,
                                      color: student.isSuspended ? Colors.grey : null,
                                    )),
                                if (student.isSuspended)
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
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Student',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
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
                                targetName: student.name,
                                currentWarning: student.warning,
                              ),
                            );

                            if (message != null) {
                              try {
                                await _studentService.updateWarning(student.uid, message.isEmpty ? null : message);
                                
                                // Send push notification for warning
                                if (message.isNotEmpty) {
                                  await FCMService.sendNotification(
                                    recipientUid: student.uid,
                                    title: 'Account Warning',
                                    body: message,
                                    data: {'type': 'account_warning'},
                                  );
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message.isEmpty ? 'Warning cleared' : 'Warning sent to ${student.name}'),
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
                          tooltip: 'Warn Student',
                        ),
                        IconButton(
                          icon: Icon(
                            student.isSuspended ? Icons.play_arrow_outlined : Icons.block_flipped,
                            color: student.isSuspended ? AppTheme.primaryGreen : AppTheme.errorRed,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(student.isSuspended ? 'Unsuspend Student' : 'Suspend Student'),
                                content: Text('Are you sure you want to ${student.isSuspended ? 'unsuspend' : 'suspend'} ${student.name}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: student.isSuspended ? AppTheme.primaryGreen : AppTheme.errorRed,
                                    ),
                                    child: Text(student.isSuspended ? 'Unsuspend' : 'Suspend'),
                                  ),
                                ],
                              ),
                            );
 
                            if (confirm == true) {
                              try {
                                final wasSuspended = student.isSuspended;
                                await _studentService.toggleSuspension(student.uid, wasSuspended);
                                
                                // Send push notification for suspension change
                                await FCMService.sendNotification(
                                  recipientUid: student.uid,
                                  title: wasSuspended ? 'Account Unsuspended' : 'Account Suspended',
                                  body: wasSuspended 
                                      ? 'Your account has been unsuspended. You can now access LIME.' 
                                      : 'Your account has been suspended by the Lemon Administrator.',
                                  data: {'type': wasSuspended ? 'account_unsuspended' : 'account_suspended'},
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Student ${wasSuspended ? 'unsuspended' : 'suspended'}')),
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
                          tooltip: student.isSuspended ? 'Unsuspend' : 'Suspend',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                          onPressed: () {},
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Student'),
                                content: Text('Are you sure you want to delete ${student.name}?'),
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
                                await _studentService.deleteStudent(student.uid);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Student deleted')),
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
                        ),
                      ],
                    ))),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
