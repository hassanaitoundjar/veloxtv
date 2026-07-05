part of 'widgets.dart';

class PlayButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final bool isPhone;
  final bool isExpanded;
  final bool autoFocus;

  const PlayButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.isPhone,
    this.isExpanded = false,
    this.autoFocus = true,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableCard(
      onTap: onTap,
      autoFocus: autoFocus,
      scale: 1.02,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 0 : (isPhone ? 12 : 30),
          vertical: isPhone ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow,
                color: const Color.fromARGB(255, 5, 5, 5),
                size: isPhone ? 16 : 20),
            SizedBox(width: isPhone ? 4 : 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: isPhone ? 10 : 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
