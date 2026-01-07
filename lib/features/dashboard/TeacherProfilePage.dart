import 'dart:io';
import 'package:ams_try2/core/navigation/slide_page_route.dart';
import 'package:ams_try2/features/auth/presentation/pages/login_page.dart';
import 'package:ams_try2/features/auth/presentation/providers/auth_provider.dart';
import 'package:ams_try2/features/common/pdf_preview_page.dart';
import 'package:ams_try2/features/teacher/presentation/providers/attendance_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TProfilePage extends ConsumerWidget {
  static Route<void> route() => SlidePageRoute(
    child: const TProfilePage(),
    direction: AxisDirection.left,
  );

  const TProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider.select((s) => s.auth?.user));
    final filesAsync = ref.watch(attendanceFilesProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Hi ${user.name}!',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          /// 🔽 VIEW ATTENDANCE (PDFs)
          Container(
            color: Colors.white,
            child: ExpansionTile(
              leading: const Icon(Icons.assignment),
              title: const Text(
                'View Attendance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Preview attendance sheets',
                style: TextStyle(fontSize: 13),
              ),
              children: [
                /// 🧹 CLEAR ALL PDFs
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text(
                        'Clear All',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Clear Attendance PDFs'),
                            content: const Text(
                              'This will permanently delete all attendance PDF files. Continue?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (ok == true) {
                          await AttendanceFileUtils.clearAll(ref);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All attendance PDFs deleted'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),

                /// 📂 PDF FILE LIST
                filesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Failed to load attendance files',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  data: (List<File> files) {
                    if (files.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No attendance PDFs available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return Column(
                      children: files.map((file) {
                        final name = file.path.split('/').last;

                        return ListTile(
                          leading: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                          ),
                          title: Text(name),
                          subtitle: const Text('Tap to preview'),
                          trailing: const Icon(Icons.visibility),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PdfPreviewPage(file: file),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          /// 🔹 REPORT COMPLAINT
          _ProfileTile(
            icon: Icons.report_problem_outlined,
            title: 'Report a Complaint',
            subtitle: 'Raise an issue or concern',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature coming soon')),
              );
            },
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'ACCOUNT',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          /// 🔹 LOGOUT
          _ProfileTile(
            icon: Icons.logout,
            iconColor: Colors.red,
            title: 'Logout',
            subtitle: 'Sign out from this account',
            onTap: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              Navigator.pushAndRemoveUntil(
                context,
                LoginPage.route(),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.black),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
