part of '../screens.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = "";
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Column(
          children: [
            // Search Bar Area
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              child: Column(
                children: [
                   Text("Search Content", style: Get.textTheme.headlineMedium),
                   const SizedBox(height: 30),
                   FocusableCard(
                     onTap: () {},
                     scale: 1.02,
                     child: TextField(
                       controller: _controller,
                       autofocus: true,
                       onChanged: (val) {
                         setState(() {
                           _query = val;
                         });
                         // Implement search logic here
                       },
                       style: Get.textTheme.titleLarge,
                       decoration: InputDecoration(
                         hintText: "Type to search...",
                         prefixIcon: const Icon(Icons.search, size: 30),
                         filled: true,
                         fillColor: kColorCard,
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(16),
                           borderSide: BorderSide.none,
                         ),
                         contentPadding: const EdgeInsets.all(20),
                       ),
                     ),
                   ),
                ],
              ),
            ),
            
            // Results Area
            Expanded(
              child: _query.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search, size: 80, color: Colors.white10),
                          const SizedBox(height: 20),
                          Text("Start typing to search movies, series, or channels", 
                            style: Get.textTheme.bodyLarge?.copyWith(color: kColorTextSecondary)),
                        ],
                      ),
                    )
                  : Center(
                      child: Text("Search functionality needs backend integration for global results.", style: Get.textTheme.bodyLarge),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
