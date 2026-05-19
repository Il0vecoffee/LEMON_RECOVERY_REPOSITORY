import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../auth/auth_provider.dart';
import '../teachers/teachers_screen.dart';
import '../students/students_screen.dart';
import '../classes/classes_screen.dart';
import '../content/events_screen.dart';
import '../../services/teacher_service.dart';
import '../../services/student_service.dart';
import '../../services/section_service.dart';
import '../../models/teacher.dart';
import '../../models/student.dart';
import '../../models/section.dart';
import '../admins/admins_screen.dart';
import '../vault/vault_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _OverviewScreen(),
    TeachersScreen(),
    StudentsScreen(),
    ClassesScreen(),
    EventsScreen(),
    AdminsScreen(),
    VaultScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppTheme.white,
            selectedIconTheme: const IconThemeData(color: AppTheme.primaryGreen),
            selectedLabelTextStyle: const TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
            unselectedIconTheme: const IconThemeData(color: AppTheme.forestEspresso),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: CircleAvatar(
                backgroundColor: AppTheme.lemonYellow,
                child: Icon(Icons.eco, color: AppTheme.primaryGreen),
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: AppTheme.errorRed),
                    onPressed: () {
                       context.read<AuthProvider>().logout();
                    },
                    tooltip: 'Logout',
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Teachers'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school),
                label: Text('Students'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.class_outlined),
                selectedIcon: Icon(Icons.class_),
                label: Text('Sections'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.event_outlined),
                selectedIcon: Icon(Icons.event),
                label: Text('News/Events'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings),
                label: Text('Admins'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.lock_outline),
                selectedIcon: Icon(Icons.lock),
                label: Text('VAULT'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class _OverviewScreen extends StatelessWidget {
  const _OverviewScreen();

  @override
  Widget build(BuildContext context) {
    final teacherService = TeacherService();
    final studentService = StudentService();
    final sectionService = SectionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
        backgroundColor: AppTheme.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            StreamBuilder<List<Student>>(
              stream: studentService.getStudents(),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return _StatCard(
                  title: "Total Students",
                  value: count.toString(),
                  icon: Icons.school,
                  color: Colors.blue.shade100,
                  textColor: Colors.blue.shade900,
                );
              },
            ),
            StreamBuilder<List<Teacher>>(
              stream: teacherService.getTeachers(),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return _StatCard(
                  title: "Total Teachers",
                  value: count.toString(),
                  icon: Icons.people,
                  color: Colors.orange.shade100,
                  textColor: Colors.orange.shade900,
                );
              },
            ),
            StreamBuilder<List<Section>>(
              stream: sectionService.getSections(),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return _StatCard(
                  title: "Active Sections",
                  value: count.toString(),
                  icon: Icons.class_,
                  color: Colors.green.shade100,
                  textColor: Colors.green.shade900,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color textColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.forestEspresso,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}
