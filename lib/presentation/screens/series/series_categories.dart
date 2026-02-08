part of '../screens.dart';

class SeriesCategoriesScreen extends StatefulWidget {
  const SeriesCategoriesScreen({super.key});

  @override
  State<SeriesCategoriesScreen> createState() => _SeriesCategoriesScreenState();
}

class _SeriesCategoriesScreenState extends State<SeriesCategoriesScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Column(
          children: [
            // App Bar
            AppBarLive(
              onSearch: (val) => setState(() => _searchQuery = val),
            ),
            
            // Grid
            Expanded(
              child: BlocBuilder<SeriesCatyBloc, SeriesCatyState>(
                builder: (context, state) {
                  if (state is SeriesCatyLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SeriesCatySuccess) {
                    final filtered = state.categories.where((e) => 
                      e.categoryName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false
                    ).toList();
                    
                    return IPTVGrid(
                      itemCount: filtered.length,
                      childAspectRatio: 3.5, 
                      itemBuilder: (context, index) {
                        final cat = filtered[index];
                        return FocusableCard(
                          onTap: () {
                             Get.toNamed(screenSeriesChannels, arguments: cat);
                          },
                          scale: 1.03,
                          child: Container(
                            decoration: kDecorCard.copyWith(
                              gradient: LinearGradient(
                                colors: [kColorCardLight, kColorCard],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: kDecorIconCircle.copyWith(
                                    gradient: LinearGradient(colors: [kColorPrimary.withOpacity(0.7), kColorPrimaryDark]),
                                  ),
                                  child: const Icon(Icons.library_music, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    cat.categoryName ?? "Unknown",
                                    style: Get.textTheme.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is SeriesCatyFailed) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
