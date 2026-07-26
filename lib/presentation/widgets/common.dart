part of 'widgets.dart';

class FocusableCard extends StatefulWidget {
  final Widget? child;
  final Widget Function(BuildContext context, bool isFocused)? builder;
  final VoidCallback onTap;
  final VoidCallback? onFocus;
  final double scale;
  final bool autoFocus;
  final FocusNode? focusNode;
  final bool showFocusBorder;

  const FocusableCard({
    super.key,
    this.child,
    this.builder,
    required this.onTap,
    this.onFocus,
    this.scale = 1.05,
    this.autoFocus = false,
    this.focusNode,
    this.showFocusBorder = true,
  }) : assert(child != null || builder != null);

  @override
  State<FocusableCard> createState() => _FocusableCardState();
}

class _FocusableCardState extends State<FocusableCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusNode: widget.focusNode,
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
          clipBehavior: (_isFocused && widget.showFocusBorder) ? Clip.antiAlias : Clip.none,
          decoration: (_isFocused && widget.showFocusBorder)
              ? BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                )
              : null,
          child: ClipRRect(
            borderRadius: _isFocused
                ? BorderRadius.circular(8.5)
                : BorderRadius.zero,
            child: widget.builder != null 
                ? widget.builder!(context, _isFocused)
                : widget.child!,
          ),
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
        color: kColorCardLight.withValues(alpha: 0.3),
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
