import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:samar_farming/core/widgets/ft_card.dart';
import 'package:uuid/uuid.dart';
import 'package:samar_farming/l10n/app_localizations.dart';
import '../../../../core/constants/crop_database.dart';
import '../../../../core/domain/entities.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../injection/service_locator.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _firestore = getIt<FirestoreService>();
  int _step = 0;
  final _namaController = TextEditingController();
  final _varietasController = TextEditingController();
  String? _selectedKategori;
  CropType? _selectedCrop;
  DateTime _tanggalSemai = DateTime.now();
  String? _selectedLahan;
  bool _isSaving = false;
  List<FarmField> _lahanOptions = [];
  String? _selectedLahanId;
  StreamSubscription<List<FarmField>>? _fieldsSub;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    _fieldsSub = _firestore.watchFields().listen((fields) {
      if (mounted) {
        setState(() {
          _lahanOptions = fields;
        });
      }
    });
  }

  @override
  void dispose() {
    _fieldsSub?.cancel();
    _namaController.dispose();
    _varietasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          [
            AppLocalizations.of(context)!.infoCrop,
            AppLocalizations.of(context)!.schedule,
            AppLocalizations.of(context)!.location,
          ][_step],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: List.generate(3, (i) {
                final active = i <= _step;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: active
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: [_buildStep1(), _buildStep2(), _buildStep3()][_step],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        child: Text(
                          AppLocalizations.of(context)!.back,
                        ),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : (_step < 2
                                ? () => setState(() => _step++)
                                : _saveCrop),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _step < 2
                                  ? AppLocalizations.of(context)!.next
                                  : AppLocalizations.of(context)!.saveCrop,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    final kategoris = CropDatabase.kategoriList;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.choosePlantType,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kategoris.map((k) {
            final selected = _selectedKategori == k;
            return ChoiceChip(
              label: Text(k),
              selected: selected,
              onSelected: (v) => setState(() {
                _selectedKategori = v ? k : null;
                _selectedCrop = null;
              }),
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.primary,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (_selectedKategori != null)
          ...CropDatabase.byKategori(_selectedKategori!).map((crop) {
            final selected = _selectedCrop?.nama == crop.nama;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.primaryContainer
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                  width: selected ? 2 : 0.5,
                ),
              ),
              child: ListTile(
                leading: Text(crop.emoji, style: const TextStyle(fontSize: 28)),
                title: Text(crop.nama),
                subtitle: Text(
                  '${crop.durasiPanenHari} ${AppLocalizations.of(context)!.days ?? 'hari'}',
                ),
                trailing: selected
                    ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                    : null,
                onTap: () => setState(() => _selectedCrop = crop),
              ),
            );
          }),
        const SizedBox(height: 16),
        TextField(
          controller: _namaController,
          decoration: InputDecoration(
            labelText:
                AppLocalizations.of(context)!.customNameLabel,
            hintText:
                AppLocalizations.of(context)!.customNameHint,
            prefixIcon: const Icon(Icons.label_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _varietasController,
          decoration: InputDecoration(
            labelText:
                AppLocalizations.of(context)!.varietasLabel,
            hintText:
                AppLocalizations.of(context)!.customNameHint,
            prefixIcon: const Icon(Icons.category_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final theme = Theme.of(context);
    final estimasi = _selectedCrop != null
        ? _tanggalSemai.add(Duration(days: _selectedCrop!.durasiPanenHari))
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.schedule,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _tanggalSemai,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) setState(() => _tanggalSemai = date);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  '${_tanggalSemai.day}/${_tanggalSemai.month}/${_tanggalSemai.year}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Icon(
                  Icons.edit,
                  size: 18,
                  // ignore: deprecated_member_use
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
        if (estimasi != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.agriculture, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.estimasiPanen,
                      style: TextStyle(
                        fontSize: 12,
                        // ignore: deprecated_member_use
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                    Text(
                      '${estimasi.day}/${estimasi.month}/${estimasi.year}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${_selectedCrop!.durasiPanenHari} ${AppLocalizations.of(context)!.days ?? 'hari'} ${AppLocalizations.of(context)!.fromSeed ?? 'dari semai'}',
                      style: TextStyle(
                        fontSize: 11,
                        // ignore: deprecated_member_use
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep3() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.selectField,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (_lahanOptions.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FtCard(
              margin: EdgeInsets.zero,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    // ignore: deprecated_member_use
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.noFieldsMessage,
                      style: TextStyle(
                        // ignore: deprecated_member_use
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/settings/fields'),
                    child: Text(
                      AppLocalizations.of(context)!.createField,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else
          ..._lahanOptions.map((lahan) {
            final selected =
                _selectedLahanId == lahan.id || _selectedLahan == lahan.nama;
            final bgColor = selected
                ? theme.colorScheme.primaryContainer
                : theme.cardColor;
            final borderColor = selected
                ? theme.colorScheme.primary
                : theme.dividerColor;
            final iconBgColor = theme.colorScheme.primaryContainer;
            final iconColor = selected
                ? theme.colorScheme.onPrimaryContainer
                : theme.iconTheme.color;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor,
                  width: selected ? 2 : 0.5,
                ),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.landscape, color: iconColor),
                ),
                title: Text(
                  lahan.nama,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
                trailing: selected
                    ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                    : null,
                onTap: () => setState(() {
                  _selectedLahanId = lahan.id;
                  _selectedLahan = lahan.nama;
                }),
              ),
            );
          }),
        const SizedBox(height: 16),
        if (_selectedCrop != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📋 ${AppLocalizations.of(context)!.summary}',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _previewRow(
                  AppLocalizations.of(context)!.plantLabel ?? 'Tanaman',
                  '${_selectedCrop!.emoji} ${_selectedCrop!.nama}',
                ),
                _previewRow(
                  AppLocalizations.of(context)!.nameLabel ?? 'Nama',
                  _namaController.text.isEmpty ? '-' : _namaController.text,
                ),
                _previewRow(
                  AppLocalizations.of(context)!.varietasLabel,
                  _varietasController.text.isEmpty
                      ? '-'
                      : _varietasController.text,
                ),
                _previewRow(
                  AppLocalizations.of(context)!.fieldLabel ?? 'Lahan',
                  _selectedLahan ?? '-',
                ),
                _previewRow(
                  AppLocalizations.of(context)!.durationLabel ?? 'Durasi Panen',
                  '${_selectedCrop!.durasiPanenHari} ${AppLocalizations.of(context)!.days ?? 'hari'}',
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              // ignore: deprecated_member_use
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCrop() async {
    final theme = Theme.of(context);
    if (_selectedCrop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.choosePlantFirst ??
                'Pilih jenis tanaman terlebih dahulu',
          ),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final id = const Uuid().v4();
      final estimasiPanen = _tanggalSemai.add(
        Duration(days: _selectedCrop!.durasiPanenHari),
      );
      final crop = Crop(
        id: id,
        nama: _namaController.text.isEmpty
            ? _selectedCrop!.nama
            : _namaController.text.trim(),
        jenisTanaman: _selectedCrop!.nama,
        varietas: _varietasController.text.isEmpty
            ? '-'
            : _varietasController.text.trim(),
        namaLahan: _selectedLahan,
        tanggalSemai: _tanggalSemai,
        estimasiPanen: estimasiPanen,
        durasiHariPanen: _selectedCrop!.durasiPanenHari,
        healthStatus: CropHealthStatus.sehat,
        lifecycleStatus: CropLifecycleStatus.semai,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.addCrop(crop);
      await _firestore.addReminder(
        FarmReminder(
          id: const Uuid().v4(),
          cropId: id,
          judul: 'Siram ${crop.nama}',
          deskripsi: 'Penyiraman rutin harian',
          waktu: DateTime.now().add(const Duration(days: 1)),
          isOtomatis: true,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.cropAdded ??
                  '🎉 Tanaman berhasil ditambahkan!',
            ),
            backgroundColor: theme.colorScheme.secondary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.failedToSave}: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
