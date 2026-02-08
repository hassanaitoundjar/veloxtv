part of 'widgets.dart';

class FocusableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onFocus;
  final double scale;
  final bool autoFocus;

  const FocusableCard({
    super.key,
    required this.child,
    required this.onTap,
    this.onFocus,
    this.scale = 1.05,
    this.autoFocus = false,
  });

  @override
  State<FocusableCard> createState() => _FocusableCardState();
}

class _FocusableCardState extends State<FocusableCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onFocusChange: (value) {
        setState(() {
          _isFocused = value;
        });
        if (value && widget.onFocus != null) {
          widget.onFocus!();
        }
      },
      autofocus: widget.autoFocus,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: AnimatedScale(
        scale: _isFocused ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          decoration: _isFocused
              ? BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(
                      12), // Should match kRadiusCard if possible, or hardcode
                )
              : null,
          child: widget.child,
        ),
      ),
    );
  }
}

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: kColorCardLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class IPTVGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double childAspectRatio;

  const IPTVGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.childAspectRatio = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: getTvSafeMargins(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getGridColumns(context).toInt(),
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
