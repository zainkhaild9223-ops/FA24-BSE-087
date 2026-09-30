import 'package:flutter/material.dart';

void main() {
  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus ID',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A4D8F)),
        scaffoldBackgroundColor: const Color(0xFFF3F6FB),
      ),
      home: const DashboardScreen(),
    );
  }
}

class Course {
  final String code;
  final String name;
  final int creditHours;
  const Course(this.code, this.name, this.creditHours);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _noteController = TextEditingController();

  static const String studentName = 'Muhammad Zain Khalid';
  static const String rollNo = 'FA24-BSE-087';
  static const String department = 'Computer Science';
  static const String semester = '5th';
  static const String profileImageUrl = 'lib/profile_pic.png';

  final List<Course> _courses = const [
    Course('CS-301', 'Mobile Application Development', 3),
    Course('CS-302', 'Assembly Language', 3),
    Course('CS-303', 'Operating Systems', 3),
    Course('CS-304', 'Multi-variable calculas', 3),
    Course('MT-305', 'Web Technologies', 3),
    Course('HU-306', 'Technical Writing', 2),
    Course('CS-307', 'Software Design and Architecture', 3),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitNote() {
    final text = _noteController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Note saved: $text')),
    );
    _noteController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus ID'),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search tapped')),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(scheme),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIdCard(scheme),
              const SizedBox(height: 24),
              _sectionTitle('Enrolled Courses'),
              const SizedBox(height: 8),
              _buildCourseList(scheme),
              const SizedBox(height: 24),
              _sectionTitle('Quick Notes'),
              const SizedBox(height: 8),
              _buildNoteInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDrawer(ColorScheme scheme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: scheme.primary),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.network(
                  profileImageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.person,
                      size: 40, color: scheme.primary),
                ),
              ),
            ),
            accountName: const Text(studentName),
            accountEmail: const Text('abdulrehman@campus.edu.pk'),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('My Profile'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Digital ID Card'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('My Courses'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.assessment_outlined),
            title: const Text('Results'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildIdCard(ColorScheme scheme) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary, const Color(0xFF3D7BD9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'UNIVERSITY STUDENT ID',
                style: TextStyle(
                  color: Colors.white70,
                  letterSpacing: 1.5,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildAvatarWithDot(scheme),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            CircleAvatar(
                                radius: 4, backgroundColor: Colors.green),
                            SizedBox(width: 6),
                            Text('Active',
                                style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWithDot(ColorScheme scheme) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: Image.network(
              profileImageUrl,
              width: 88,
              height: 88,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.person, size: 52, color: scheme.primary),
            ),
          ),
        ),
        Positioned(
          right: 4,
          bottom: 4,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          children: [
            _InfoRow(label: 'Name', value: studentName),
            SizedBox(height: 10),
            _InfoRow(label: 'Roll No', value: rollNo),
            SizedBox(height: 10),
            _InfoRow(label: 'Department', value: department),
            SizedBox(height: 10),
            _InfoRow(label: 'Semester', value: semester),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList(ColorScheme scheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 260,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _courses.length,
          itemBuilder: (context, index) {
            final course = _courses[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(course.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(course.code),
              trailing: Text(
                '${course.creditHours} CH',
                style: TextStyle(
                    color: scheme.primary, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoteInput() {
    return Column(
      children: [
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Write a quick note...',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.edit_note),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _submitNote,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Submit'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.black54, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}