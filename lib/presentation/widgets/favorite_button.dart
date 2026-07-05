part of 'widgets.dart';

enum FavoriteItemType { movie, series }

class FavoriteButton extends StatelessWidget {
  final FavoriteItemType type;
  final dynamic item;
  final bool isPhone;

  const FavoriteButton({
    super.key,
    required this.type,
    required this.item,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        bool isFav = false;
        String id = "";

        if (type == FavoriteItemType.movie) {
          final movie = item as ChannelMovie;
          id = movie.streamId ?? "";
          if (favState is FavoritesSuccess) {
            isFav = favState.movies.any((m) => m.streamId == id);
          }
        } else if (type == FavoriteItemType.series) {
          final serie = item as ChannelSerie;
          id = serie.seriesId ?? "";
          if (favState is FavoritesSuccess) {
            isFav = favState.series.any((s) => s.seriesId == id);
          }
        }

        return FocusableCard(
          onTap: () {
            if (isFav) {
              if (type == FavoriteItemType.movie) {
                context.read<FavoritesCubit>().removeMovie(id);
              } else {
                context.read<FavoritesCubit>().removeSeries(id);
              }
              Get.snackbar("Removed", "Removed from My List",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.grey.shade900,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 1));
            } else {
              if (type == FavoriteItemType.movie) {
                context.read<FavoritesCubit>().addMovie(item as ChannelMovie);
              } else {
                context.read<FavoritesCubit>().addSeries(item as ChannelSerie);
              }
              Get.snackbar("Added", "Added to My List",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.grey.shade900,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 1));
            }
          },
          scale: 1.05,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: isPhone ? 12 : 16, vertical: isPhone ? 6 : 8),
            decoration: BoxDecoration(
              color: isFav ? Colors.white : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFav ? Icons.check : Icons.add,
                  color: isFav ? Colors.black : Colors.white,
                  size: isPhone ? 16 : 20,
                ),
                SizedBox(width: isPhone ? 4 : 6),
                Text(
                  isFav ? "My List" : "Add To List",
                  style: TextStyle(
                    color: isFav ? Colors.black : Colors.white,
                    fontSize: isPhone ? 10 : 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FavoriteHeartIcon extends StatelessWidget {
  final FavoriteItemType type;
  final dynamic item;
  final bool isFav;
  final bool isPhone;

  const FavoriteHeartIcon({
    super.key,
    required this.type,
    required this.item,
    required this.isFav,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        String id = "";
        if (type == FavoriteItemType.movie) {
          id = (item as ChannelMovie).streamId ?? "";
        } else {
          id = (item as ChannelSerie).seriesId ?? "";
        }

        if (isFav) {
          if (type == FavoriteItemType.movie) {
            context.read<FavoritesCubit>().removeMovie(id);
          } else {
            context.read<FavoritesCubit>().removeSeries(id);
          }
          Get.snackbar(
            "Favorites",
            "Removed from favorites",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.grey,
            colorText: Colors.white,
            duration: const Duration(seconds: 1),
          );
        } else {
          if (type == FavoriteItemType.movie) {
            context.read<FavoritesCubit>().addMovie(item as ChannelMovie);
          } else {
            context.read<FavoritesCubit>().addSeries(item as ChannelSerie);
          }
          Get.snackbar(
            "Favorites",
            "Added to favorites",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: kColorSuccess,
            colorText: Colors.white,
            duration: const Duration(seconds: 1),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(isPhone ? 4 : 6),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? Colors.blue : Colors.white70,
          size: isPhone ? 14 : 18,
        ),
      ),
    );
  }
}
