import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../injection/service_locator.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = getIt<AuthService>();
  final _firestore = getIt<FirestoreService>();
  late TextEditingController _nameController;
  String? _photoPath;
  bool _isSaving = false;
  String? _dbPhotoUrl;
  Stream<Map<String, dynamic>?>? _profileStream;
  StreamSubscription<Map<String, dynamic>?>? _profileSub;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _auth.displayName);
    // Listen to Firestore user profile so existing DB photoUrl shows immediately
    _profileStream = _firestore.watchUserProfile();
    _profileSub = _profileStream?.listen((data) {
      final photo = data == null ? null : data['photoUrl'] as String?;
      if (photo != _dbPhotoUrl) {
        setState(() => _dbPhotoUrl = photo);
      }
    });
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
    );
    if (img != null) {
      final saved = await _saveImageLocally(img.path);
      setState(() => _photoPath = saved);
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
    );
    if (img != null) {
      final saved = await _saveImageLocally(img.path);
      setState(() => _photoPath = saved);
    }
  }

  Future<String> _saveImageLocally(String tempPath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/profile_photos');
    if (!profileDir.existsSync()) profileDir.createSync(recursive: true);

    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final permanentPath = '${profileDir.path}/$fileName';
    await File(tempPath).copy(permanentPath);
    return permanentPath;
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama tidak boleh kosong'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User tidak ditemukan");
      await user.updateDisplayName(_nameController.text.trim());
      await user.reload();
      String? finalPhotoUrl = _photoPath ?? _dbPhotoUrl ?? user.photoURL;
      await _firestore.saveUserProfile(
        name: _nameController.text.trim(),
        email: _auth.email,
        photoUrl: finalPhotoUrl,
      );
      if (finalPhotoUrl != null && finalPhotoUrl != user.photoURL) {
        try {
          await user.updatePhotoURL(finalPhotoUrl);
          await user.reload();
        } catch (_) {
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil berhasil diperbarui'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  ImageProvider? _buildAvatarImage() {
    if (_photoPath != null) {
      return FileImage(File(_photoPath!));
    }
    final existingPhotoUrl = _dbPhotoUrl ?? _auth.currentUser?.photoURL;
    if (existingPhotoUrl != null && existingPhotoUrl.isNotEmpty) {
      if (existingPhotoUrl.startsWith('http')) {
        return NetworkImage(existingPhotoUrl);
      } else {
        final file = File(existingPhotoUrl);
        if (file.existsSync()) return FileImage(file);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final existingPhotoUrl = _dbPhotoUrl ?? _auth.currentUser?.photoURL;
    // ignore: unused_local_variable
    final hasImage =
        _photoPath != null ||
        (existingPhotoUrl != null && existingPhotoUrl.isNotEmpty);
    final avatarImage = _buildAvatarImage();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: AppColors.primarySurface,
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? const Icon(
                          Icons.person,
                          size: 56,
                          color: AppColors.primaryLight,
                        )
                      : null,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (v) =>
                        v == 'camera' ? _takePhoto() : _pickPhoto(),
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'camera',
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt),
                            SizedBox(width: 8),
                            Text('Kamera'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'gallery',
                        child: Row(
                          children: [
                            Icon(Icons.photo_library),
                            SizedBox(width: 8),
                            Text('Galeri'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person_outlined),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: AppColors.divider.withValues(alpha: 0.3),
              ),
              controller: TextEditingController(text: _auth.email),
            ),
            const SizedBox(height: 8),
            const Text(
              'Email tidak dapat diubah',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
