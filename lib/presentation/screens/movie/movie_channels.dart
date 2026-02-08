part of '../screens.dart';

class MovieChannelsScreen extends StatefulWidget {
  const MovieChannelsScreen({super.key});

  @override
  State<MovieChannelsScreen> createState() => _MovieChannelsScreenState();
}

class _MovieChannelsScreenState extends State<MovieChannelsScreen> {
  late CategoryModel _initialCategory;
  
  @override
  void initState() {
    super.initState();
    if (Get.arguments is CategoryModel) {
      _initialCategory = Get.arguments as CategoryModel;
      context.read<ChannelsBloc>().add(GetChannels(
        _initialCategory.categoryId!, 
        TypeCategory.movies
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Row(
          children: [
            // Left - Vertical Categories (Quick Switch)
            BlocBuilder<MovieCatyBloc, MovieCatyState>(
              builder: (context, state) {
                if (state is MovieCatySuccess) {
                  return SideCategoryMenu(
                    categories: state.categories,
                    selectedId: int.parse(_initialCategory.categoryId!),
                    onSelect: (cat) {
                      setState(() {
                        _initialCategory = cat;
                      });
                      context.read<ChannelsBloc>().add(GetChannels(
                        cat.categoryId!, 
                        TypeCategory.movies
                      ));
                    },
                  );
                }
                return const SizedBox(width: 200);
              },
            ),
            
            // Right - Movie Poster Grid
            Expanded(
              child: Column(
                children: [
                   AppBarLive(onSearch: (val) {}), 
                   Expanded(
                     child: BlocBuilder<ChannelsBloc, ChannelsState>(
                       builder: (context, state) {
                         if (state is ChannelsLoading) {
                           return const Center(child: CircularProgressIndicator());
                         } else if (state is ChannelsSuccess) {
                           final movies = state.channels.cast<ChannelMovie>();
                           
                           if (movies.isEmpty) {
                             return const Center(child: Text("No movies found."));
                           }
                           
                           return GridView.builder(
                             padding: const EdgeInsets.all(16),
                             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                               crossAxisCount: getGridColumns(context).toInt(), // 5-7 colums
                               childAspectRatio: 0.7, // Poster ratio
                               crossAxisSpacing: 16,
                               mainAxisSpacing: 16,
                             ),
                             itemCount: movies.length,
                             itemBuilder: (context, index) {
                               final movie = movies[index];
                               return FocusableCard(
                                 onTap: () {
                                    // Navigate to details
                                    Get.toNamed(screenMovieDetails, arguments: movie);
                                 },
                                 scale: 1.05,
                                 child: Container(
                                   decoration: kDecorCard.copyWith(
                                     image: DecorationImage(
                                       image: CachedNetworkImageProvider(movie.streamIcon ?? ""),
                                       fit: BoxFit.cover
                                     )
                                   ),
                                   child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                          stops: const [0.6, 1.0]
                                        )
                                      ),
                                      alignment: Alignment.bottomCenter,
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        movie.name ?? "",
                                        style: Get.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                   ),
                                 ),
                               );
                             },
                           );
                         } else if (state is ChannelsFailed) {
                           return Center(child: Text(state.message));
                         }
                         return const SizedBox();
                       },
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
