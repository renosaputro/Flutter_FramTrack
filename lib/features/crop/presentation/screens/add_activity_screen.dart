import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/domain/entities.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../injection/service_locator.dart';

class AddActivityScreen extends StatefulWidget {
  final String cropId;
  final String cropNama;
  const AddActivityScreen({super.key, required this.cropId, required this.cropNama});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _firestore = getIt<FirestoreService>();
  ActivityType _tipe = ActivityType.penyiraman;
  final _catatanController = TextEditingController();
  final _tinggiController = TextEditingController();
  final _daunController = TextEditingController();
  final _pupukController = TextEditingController();
  final _dosisController = TextEditingController();
  String? _fotoPath;
  bool _isSaving = false;

  @override
  void dispose() {
    _catatanController.dispose();
    _tinggiController.dispose();
    _daunController.dispose();
    _pupukController.dispose();
    _dosisController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(child: Wrap(children: [
        ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Kamera'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
        ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galeri'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
      ])),
    );
    if (source != null) {
      final img = await picker.pickImage(source: source, maxWidth: 1024);
      if (img != null) setState(() => _fotoPath = img.path);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final log = ActivityLog(
        id: const Uuid().v4(),
        cropId: widget.cropId,
        tipe: _tipe,
        tanggal: DateTime.now(),
        catatan: _catatanController.text.isNotEmpty ? _catatanController.text : null,
        foto: _fotoPath,
        tinggiBatang: _tinggiController.text.isNotEmpty ? double.tryParse(_tinggiController.text) : null,
        jumlahDaun: _daunController.text.isNotEmpty ? int.tryParse(_daunController.text) : null,
        jenisPupuk: _pupukController.text.isNotEmpty ? _pupukController.text : null,
        dosisPupuk: _dosisController.text.isNotEmpty ? double.tryParse(_dosisController.text) : null,
      );
      await _firestore.addActivity(log);
      if (_tinggiController.text.isNotEmpty || _daunController.text.isNotEmpty) {
        final crop = await _firestore.getCrop(widget.cropId);
        if (crop != null) {
          await _firestore.updateCrop(Crop(
            id: crop.id, nama: crop.nama, jenisTanaman: crop.jenisTanaman, varietas: crop.varietas,
            namaLahan: crop.namaLahan, lokasiPlot: crop.lokasiPlot,
            tanggalSemai: crop.tanggalSemai, tanggalTanam: crop.tanggalTanam,
            estimasiPanen: crop.estimasiPanen, durasiHariPanen: crop.durasiHariPanen,
            healthStatus: crop.healthStatus, lifecycleStatus: crop.lifecycleStatus,
            fotoTerakhir: _fotoPath ?? crop.fotoTerakhir,
            tinggiBatang: _tinggiController.text.isNotEmpty ? double.parse(_tinggiController.text) : crop.tinggiBatang,
            jumlahDaun: _daunController.text.isNotEmpty ? int.parse(_daunController.text) : crop.jumlahDaun,
            fotoTimeline: _fotoPath != null ? [...crop.fotoTimeline, _fotoPath!] : crop.fotoTimeline,
            createdAt: crop.createdAt, updatedAt: DateTime.now(),
          ));
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Aktivitas berhasil dicatat'), backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log: ${widget.cropNama}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Tipe aktivitas
          Text('Jenis Aktivitas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: ActivityType.values.map((t) {
            final selected = _tipe == t;
            return ChoiceChip(
              label: Text(_tipeLabel(t)),
              avatar: Icon(_tipeIcon(t), size: 18, color: selected ? Colors.white : AppColors.textSecondary),
              selected: selected,
              onSelected: (_) => setState(() => _tipe = t),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: selected ? Colors.white : null),
            );
          }).toList()),
          const SizedBox(height: 20),
          TextField(controller: _catatanController, decoration: const InputDecoration(labelText: 'Catatan', hintText: 'Apa yang dilakukan?', prefixIcon: Icon(Icons.note_outlined)), maxLines: 3),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickPhoto,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
              ),
              child: _fotoPath != null
                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_fotoPath!), fit: BoxFit.cover, width: double.infinity))
                : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_a_photo_outlined, color: AppColors.primaryLight, size: 32),
                    SizedBox(height: 4),
                    Text('Tambah Foto', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ]),
            ),
          ),
          const SizedBox(height: 20),

          Text('Ukuran Tanaman (opsional)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _tinggiController, decoration: const InputDecoration(labelText: 'Tinggi (cm)', prefixIcon: Icon(Icons.straighten)), keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _daunController, decoration: const InputDecoration(labelText: 'Jumlah Daun', prefixIcon: Icon(Icons.spa)), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 16),

          if (_tipe == ActivityType.pemupukan) ...[
            Text('Detail Pemupukan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(controller: _pupukController, decoration: const InputDecoration(labelText: 'Jenis Pupuk', prefixIcon: Icon(Icons.eco))),
            const SizedBox(height: 12),
            TextField(controller: _dosisController, decoration: const InputDecoration(labelText: 'Dosis (gram)', prefixIcon: Icon(Icons.scale)), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),

          SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check),
            label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Aktivitas'),
          )),
        ]),
      ),
    );
  }

  String _tipeLabel(ActivityType t) {
    switch (t) {
      case ActivityType.penyiraman: return 'Siram';
      case ActivityType.pemupukan: return 'Pupuk';
      case ActivityType.pestisida: return 'Pestisida';
      case ActivityType.penyiangan: return 'Gulma';
      case ActivityType.pemangkasan: return 'Pangkas';
      case ActivityType.lainnya: return 'Lainnya';
    }
  }

  IconData _tipeIcon(ActivityType t) {
    switch (t) {
      case ActivityType.penyiraman: return Icons.water_drop;
      case ActivityType.pemupukan: return Icons.eco;
      case ActivityType.pestisida: return Icons.bug_report;
      case ActivityType.penyiangan: return Icons.grass;
      case ActivityType.pemangkasan: return Icons.content_cut;
      case ActivityType.lainnya: return Icons.more_horiz;
    }
  }
}
