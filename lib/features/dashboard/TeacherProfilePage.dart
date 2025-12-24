import 'package:ams_try2/core/navigation/slide_page_route.dart';
import 'package:ams_try2/features/auth/presentation/pages/login_page.dart';
import 'package:ams_try2/features/auth/presentation/providers/auth_provider.dart';
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

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 🔹 Dummy excel list (later comes from API)
    final excelFiles = [
      'CSE2101 - 19 Dec.xlsx',
      'CSE2102 - 20 Dec.xlsx',
      'CSE2103 - 21 Dec.xlsx',
    ];

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

          /// 🔽 VIEW ATTENDANCE DROPDOWN
          Container(
            color: Colors.white,
            child: ExpansionTile(
              leading: const Icon(Icons.assignment),
              title: const Text(
                'View Attendance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Download attendance sheets',
                style: TextStyle(fontSize: 13),
              ),
              children: excelFiles.map((file) {
                return ListTile(
                  leading: const Icon(Icons.file_present, color: Colors.green),
                  title: Text(file),
                  onTap: () {
                    print('Clicked file: $file');
                  },
                );
              }).toList(),
            ),
          ),

          /// 🔹 REPORT COMPLAINT
          _ProfileTile(
            icon: Icons.report_problem_outlined,
            title: 'Report a Complaint',
            subtitle: 'Raise an issue or concern',
            onTap: () {
              print('Report Complaint');
            },
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'ACCOUNT',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          _ProfileTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out from this account',
            iconColor: Colors.red,
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
