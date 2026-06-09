import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:samar_farming/l10n/app_localizations.dart';
import '../../../../core/domain/entities.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/widgets/ft_crop_card.dart';
import '../../../../core/widgets/ft_empty_state.dart';
import '../../../../injection/service_locator.dart';

class CropListScreen extends StatefulWidget {
  const CropListScreen({super.key});

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen>
    with SingleTickerProviderStateMixin {
  final _firestore = getIt<FirestoreService>();
  late TabController _tabController;
  String _searchQuery = '';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myPlants),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchPlants,
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.activePlantsLabel),
                  Tab(
                    text:
                        AppLocalizations.of(context)!.activePlantsLabel ==
                            'Active Plants'
                        ? 'Harvest History'
                        : AppLocalizations.of(context)!.historySubtitle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StreamBuilder<List<Crop>>(
            stream: _firestore.watchActiveCrops(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final crops = (snapshot.data ?? [])
                  .where(
                    (c) =>
                        _searchQuery.isEmpty ||
                        c.nama.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        c.jenisTanaman.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                  )
                  .toList();
              if (crops.isEmpty) {
                return FtEmptyState(
                  title: AppLocalizations.of(context)!.noPlants,
                  subtitle: AppLocalizations.of(context)!.addManageFields,
                  icon: Icons.eco_outlined,
                  actionLabel: AppLocalizations.of(context)!.addPlant,
                  onAction: () => context.push('/crop/add'),
                );
              }
              return _isGridView
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: crops.length,
                      itemBuilder: (ctx, i) => FtCropCard(
                        crop: crops[i],
                        isCompact: true,
                        onTap: () => context.push('/crop/${crops[i].id}'),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: crops.length,
                      itemBuilder: (ctx, i) => FtCropCard(
                        crop: crops[i],
                        onTap: () => context.push('/crop/${crops[i].id}'),
                      ),
                    );
            },
          ),
          StreamBuilder<List<HarvestResult>>(
            stream: _firestore.watchAllHarvests(),
            builder: (context, snapshot) {
              final theme = Theme.of(context);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final history = snapshot.data ?? [];
              if (history.isEmpty) {
                return FtEmptyState(
                  title: AppLocalizations.of(context)!.noHistory,
                  subtitle: AppLocalizations.of(context)!.historySubtitle,
                  icon: Icons.emoji_events_outlined,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: history.length,
                itemBuilder: (ctx, i) {
                  final h = history[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor, width: 0.5),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer
                              // ignore: deprecated_member_use
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      title: Text(
                        'Panen ${h.beratKg} Kg',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        'Kualitas: ${h.kualitas} • ⭐ ${h.rating}/5',
                        style: TextStyle(
                          // ignore: deprecated_member_use
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.85,
                          ),
                          fontSize: 12,
                        ),
                      ),
                      trailing: h.totalPendapatan != null
                          ? Text(
                              'Rp ${(h.totalPendapatan! / 1000).toStringAsFixed(0)}K',
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
