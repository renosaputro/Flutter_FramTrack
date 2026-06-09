import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang FarmTrack')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: theme.colorScheme.primary.withOpacity(0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.eco, size: 54, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'FarmTrack',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kelola Pertanian Cerdas',
              style: TextStyle(
                // ignore: deprecated_member_use
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.85),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Versi 0.1.0',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tentang Aplikasi',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FarmTrack adalah aplikasi manajemen pertanian yang dirancang untuk membantu petani dan pehobi urban farming mengelola tanaman mereka secara efisien.\n\n'
                    'Fitur utama:\n'
                    '• Kelola tanaman dari semai hingga panen\n'
                    '• Catat aktivitas harian (siram, pupuk, dll)\n'
                    '• Foto timeline pertumbuhan\n'
                    '• Analisis hasil panen\n'
                    '• Pengingat otomatis\n'
                    '• Mode offline',
                    style: TextStyle(
                      // ignore: deprecated_member_use
                      color: theme.textTheme.bodySmall?.color?.withOpacity(
                        0.85,
                      ),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _infoTile(
              context,
              Icons.code,
              'Dibuat dengan',
              'Flutter + Firebase',
            ),
            _infoTile(
              context,
              Icons.school,
              'Tugas Kuliah',
              'Mobile Programming',
            ),
            _infoTile(context, Icons.calendar_today, 'Tahun', '2026'),
            _infoTile(context, Icons.favorite, 'Made with', 'Arijaya'),

            const SizedBox(height: 24),
            Text(
              '© 2026 FarmTrack. All rights reserved.',
              style: TextStyle(
                // ignore: deprecated_member_use
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              // ignore: deprecated_member_use
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.85),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
