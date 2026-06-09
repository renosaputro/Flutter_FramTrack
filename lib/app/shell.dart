import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/domain/entities.dart';
import '../core/services/firestore_service.dart';
import '../core/services/notification_service.dart';
import '../injection/service_locator.dart';
import 'theme/app_colors.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  StreamSubscription<List<FarmReminder>>? _reminderSubscription;

  @override
  void initState() {
    super.initState();
    _startReminderSync();
  }

  void _startReminderSync() {
    final firestore = getIt<FirestoreService>();
    debugPrint('🔔 [AppShell] Memulai sinkronisasi pengingat...');
    _reminderSubscription = firestore.watchActiveReminders().listen((
      reminders,
    ) async {
      debugPrint(
        '🔔 [AppShell] Menerima ${reminders.length} pengingat aktif dari Firestore.',
      );
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifikasi_aktif') ?? true;
      debugPrint(
        '🔔 [AppShell] Status notifikasi diaktifkan: $notificationsEnabled',
      );

      await NotificationService().cancelAll();

      if (!notificationsEnabled) return;

      for (final r in reminders) {
        final now = DateTime.now();
        if (r.waktu.isAfter(now)) {
          debugPrint(
            '🔔 [AppShell] Menjadwalkan pengingat "${r.judul}" pada ${r.waktu}',
          );
          await NotificationService().scheduleReminder(
            id: r.id.hashCode,
            title: r.judul,
            body: r.deskripsi ?? 'Sudah masuk jadwal aktivitas tanaman Anda!',
            scheduledTime: r.waktu,
          );
        } else {
          debugPrint(
            '🔔 [AppShell] Pengingat "${r.judul}" waktunya sudah lewat — tampilkan segera',
          );
          await NotificationService().showNotification(
            id: r.id.hashCode,
            title: r.judul,
            body: r.deskripsi ?? 'Sudah masuk jadwal aktivitas tanaman Anda!',
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _reminderSubscription?.cancel();
    super.dispose();
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/crops')) return 1;
    if (location.startsWith('/reminders')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/crops');
        break;
      case 2:
        context.push('/crop/add');
        break;
      case 3:
        context.go('/reminders');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: widget.child,
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.push('/crop/add'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Beranda',
                  isActive: currentIndex == 0,
                  onTap: () => _onTap(context, 0),
                ),
                _NavItem(
                  icon: Icons.eco_outlined,
                  activeIcon: Icons.eco,
                  label: 'Tanaman',
                  isActive: currentIndex == 1,
                  onTap: () => _onTap(context, 1),
                ),
                const SizedBox(width: 56),
                _NavItem(
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: 'Pengingat',
                  isActive: currentIndex == 3,
                  onTap: () => _onTap(context, 3),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profil',
                  isActive: currentIndex == 4,
                  onTap: () => _onTap(context, 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
