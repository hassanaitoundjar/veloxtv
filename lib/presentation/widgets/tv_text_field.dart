part of 'widgets.dart';

class TvTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? prefixIconWidget;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool autofocus;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Color fillColor;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final EdgeInsetsGeometry? contentPadding;
  final InputDecoration? decoration;
  final int? maxLines;

  const TvTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.prefixIconWidget,
    this.suffixIcon,
    this.obscureText = false,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.onFieldSubmitted,
    this.validator,
    this.textInputAction,
    this.fillColor = Colors.transparent,
    this.border,
    this.focusedBorder,
    this.hintStyle,
    this.style,
    this.contentPadding,
    this.decoration,
    this.maxLines,
  });

  @override
  State<TvTextField> createState() => _TvTextFieldState();
}

class _TvTextFieldState extends State<TvTextField> {
  bool _isEditing = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      if (_isEditing) {
        setState(() {
          _isEditing = false;
        });
      }
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          if (!_isEditing) {
            _startEditing();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Listener(
        onPointerDown: (_) {
          if (!_isEditing) {
            setState(() {
              _isEditing = true;
            });
          }
        },
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          obscureText: widget.obscureText,
          readOnly: !_isEditing,
          maxLines: widget.maxLines ?? 1,
          onChanged: widget.onChanged,
          onFieldSubmitted: (v) {
            setState(() {
              _isEditing = false;
            });
            if (widget.onSubmitted != null) {
              widget.onSubmitted!(v);
            }
            if (widget.onFieldSubmitted != null) {
              widget.onFieldSubmitted!(v);
            }
          },
          validator: widget.validator,
          textInputAction: widget.textInputAction ?? TextInputAction.done,
          style: widget.style,
          decoration: widget.decoration ?? InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            hintStyle: widget.hintStyle,
            prefixIcon: widget.prefixIconWidget ??
                (widget.prefixIcon != null ? Icon(widget.prefixIcon) : null),
            suffixIcon: widget.suffixIcon,
            filled: widget.fillColor != Colors.transparent,
            fillColor: widget.fillColor,
            border: widget.border,
            focusedBorder: widget.focusedBorder,
            contentPadding: widget.contentPadding,
          ),
        ),
      ),
    );
  }
}
