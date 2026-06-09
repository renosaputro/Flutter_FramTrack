import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:samar_farming/l10n/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/domain/entities.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/widgets/ft_card.dart';
import '../../../../injection/service_locator.dart';

class ManageFieldsScreen extends StatelessWidget {
  const ManageFieldsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = getIt<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.manageFields)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, firestore),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<FarmField>>(
        stream: firestore.watchFields(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final fields = snapshot.data ?? [];
          if (fields.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.landscape_outlined,
                    size: 64,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noPlants,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.addManageFields,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context, firestore),
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.addPlant),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fields.length,
            itemBuilder: (context, i) {
              final f = fields[i];
              return FtCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.landscape,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (f.deskripsi != null)
                            Text(
                              f.deskripsi!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          if (f.lokasi != null)
                            Text(
                              '📍 ${f.lokasi}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') {
                          _showEditDialog(context, firestore, f);
                        } else if (v == 'delete') {
                          firestore.deleteField(f.id);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                size: 18,
                                color: AppColors.danger,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: TextStyle(color: AppColors.danger),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, FirestoreService firestore) {
    final namaC = TextEditingController();
    final descC = TextEditingController();
    final locC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addManageFields),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaC,
              decoration: const InputDecoration(
                labelText: 'Nama Lahan',
                hintText: 'Contoh: Sawah Blok A',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descC,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (opsional)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locC,
              decoration: const InputDecoration(labelText: 'Lokasi (opsional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (namaC.text.isNotEmpty) {
                firestore.addField(
                  FarmField(
                    id: const Uuid().v4(),
                    nama: namaC.text.trim(),
                    deskripsi: descC.text.isNotEmpty ? descC.text.trim() : null,
                    lokasi: locC.text.isNotEmpty ? locC.text.trim() : null,
                  ),
                );
                Navigator.pop(ctx);
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    FirestoreService firestore,
    FarmField field,
  ) {
    final namaC = TextEditingController(text: field.nama);
    final descC = TextEditingController(text: field.deskripsi ?? '');
    final locC = TextEditingController(text: field.lokasi ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.manageFields),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaC,
              decoration: const InputDecoration(labelText: 'Nama Lahan'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descC,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locC,
              decoration: const InputDecoration(labelText: 'Lokasi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              firestore.updateField(
                FarmField(
                  id: field.id,
                  nama: namaC.text.trim(),
                  deskripsi: descC.text.isNotEmpty ? descC.text.trim() : null,
                  lokasi: locC.text.isNotEmpty ? locC.text.trim() : null,
                ),
              );
              Navigator.pop(ctx);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }
}
