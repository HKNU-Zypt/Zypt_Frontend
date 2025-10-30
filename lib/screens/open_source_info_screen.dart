import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:focused_study_time_tracker/oss_licenses.dart' as oss;

class OpenSourceInfoScreen extends StatefulWidget {
  const OpenSourceInfoScreen({super.key});

  @override
  State<OpenSourceInfoScreen> createState() => _OpenSourceInfoScreenState();
}

class _OpenSourceInfoScreenState extends State<OpenSourceInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      appBar: AppBar(
        title: Text(
          "오픈소스 정보",
          style: TextStyle(
            fontFamily: 'SOYO Maple Bold',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.go('/mypage');
          },
          // 1. 내부 여백을 제거합니다.
          padding: EdgeInsets.zero,
          // 2. 정렬을 중앙으로 명시합니다.
          alignment: Alignment.center,
          icon: Icon(
            Icons.arrow_left_rounded,
            color: Color(0xFFF95C3B),
            size: 60,
          ),
        ),
      ),
      child: ListView.separated(
        itemCount: oss.dependencies.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final pkg = oss.dependencies[index];
          return ListTile(
            title: Text(pkg.name),
            subtitle: Text(pkg.version),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OpenSourceLicenseDetailScreen(package: pkg),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class OpenSourceLicenseDetailScreen extends StatelessWidget {
  final oss.Package package;
  const OpenSourceLicenseDetailScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      appBar: AppBar(
        title: Text(
          package.name,
          style: TextStyle(
            fontFamily: 'SOYO Maple Bold',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          icon: Icon(
            Icons.arrow_left_rounded,
            color: Color(0xFFF95C3B),
            size: 60,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (package.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  package.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  package.license ?? 'No license information available.',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
