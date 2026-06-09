import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/domain/entities.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../injection/service_locator.dart';

class HarvestScreen extends StatefulWidget {
  final String cropId;
  const HarvestScreen({super.key, required this.cropId});

  @override
  State<HarvestScreen> createState() => _HarvestScreenState();
}

class _HarvestScreenState extends State<HarvestScreen> {
  final _firestore = getIt<FirestoreService>();
  final _beratController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _hargaController = TextEditingController();
  final _catatanController = TextEditingController();
  String _kualitas = 'Bagus';
  int _rating = 4;
  bool _saved = false;
  bool _isSaving = false;

  @override
  void dispose() { _beratController.dispose(); _jumlahController.dispose(); _hargaController.dispose(); _catatanController.dispose(); super.dispose(); }

  Future<void> _saveHarvest() async {
    if (_beratController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan berat panen'), backgroundColor: AppColors.danger));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final harvest = HarvestResult(
        id: const Uuid().v4(),
        cropId: widget.cropId,
        tanggalPanen: DateTime.now(),
        beratKg: double.parse(_beratController.text),
        jumlahBuah: _jumlahController.text.isNotEmpty ? int.parse(_jumlahController.text) : null,
        kualitas: _kualitas,
        hargaJualPerKg: _hargaController.text.isNotEmpty ? double.parse(_hargaController.text) : null,
        catatan: _catatanController.text.isNotEmpty ? _catatanController.text : null,
        rating: _rating,
      );
      await _firestore.addHarvest(harvest);
      await _firestore.markCropHarvested(widget.cropId);
      if (mounted) setState(() => _saved = true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_saved) {
      return Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎊', style: TextStyle(fontSize: 80)), const SizedBox(height: 20),
        Text('Panen Berhasil!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8), Text('Data panen telah disimpan ke Firestore', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        const SizedBox(height: 32), ElevatedButton(onPressed: () => context.go('/dashboard'), child: const Text('Kembali ke Dashboard')),
      ])));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Selesai Panen')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: AppColors.sunsetGradient, borderRadius: BorderRadius.circular(16)),
          child: const Column(children: [
            Text('🎉', style: TextStyle(fontSize: 48)), SizedBox(height: 8),
            Text('Selamat Panen!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            SizedBox(height: 4), Text('Masukkan data hasil panen', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ])),
        const SizedBox(height: 24),
        Text('Hasil Panen', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: _beratController, decoration: const InputDecoration(labelText: 'Berat (Kg)', prefixIcon: Icon(Icons.scale)), keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _jumlahController, decoration: const InputDecoration(labelText: 'Jumlah Buah', prefixIcon: Icon(Icons.tag)), keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 20),
        Text('Kualitas', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 12),
        Row(children: ['Bagus', 'Sedang', 'Buruk'].map((k) {
          final selected = _kualitas == k;
          return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(label: SizedBox(width: double.infinity, child: Center(child: Text(k))), selected: selected, onSelected: (_) => setState(() => _kualitas = k),
              selectedColor: k == 'Bagus' ? const Color(0xFFE8F5E9) : k == 'Sedang' ? const Color(0xFFFFF8E1) : const Color(0xFFFFEBEE))));
        }).toList()),
        const SizedBox(height: 20),
        TextField(controller: _hargaController, decoration: const InputDecoration(labelText: 'Harga Jual/Kg (opsional)', prefixIcon: Icon(Icons.payments_outlined), prefixText: 'Rp '), keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        Text('Rating Pengalaman', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(
          icon: Icon(i < _rating ? Icons.star : Icons.star_border, color: AppColors.secondary, size: 36), onPressed: () => setState(() => _rating = i + 1)))),
        const SizedBox(height: 16),
        TextField(controller: _catatanController, decoration: const InputDecoration(labelText: 'Catatan Evaluasi', hintText: 'Apa yang bisa diperbaiki?', prefixIcon: Icon(Icons.note_outlined)), maxLines: 3),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveHarvest,
          icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check),
          label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Hasil Panen'),
        )),
      ])),
    );
  }
}
