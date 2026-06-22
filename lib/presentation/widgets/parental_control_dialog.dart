import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/helpers/helpers.dart';

enum ParentalMode { verify, set }

class ParentalControlWidget extends StatefulWidget {
  final String userId;
  final ParentalMode mode;
  final Function(String?)? onSetSuccess; // Returns new PIN if set
  final VoidCallback? onVerifySuccess;

  const ParentalControlWidget({
    super.key,
    required this.userId,
    this.mode = ParentalMode.verify,
    this.onSetSuccess,
    this.onVerifySuccess,
  });

  @override
  State<ParentalControlWidget> createState() => _ParentalControlWidgetState();
}

class _ParentalControlWidgetState extends State<ParentalControlWidget> {
  String _pin = "";
  String _firstPin = ""; // For "set" mode, first entry
  String _title = "Enter PIN";
  final _storage = GetStorage("settings");

  @override
  void initState() {
    super.initState();
    if (widget.mode == ParentalMode.set) {
      _title = "Enter New PIN";
    }
  }

  void _onDigit(String d) {
    if (_pin.length < 4) {
      setState(() => _pin += d);
      if (_pin.length == 4) _submit();
    }
  }

  void _delete() {
    if (_pin.isNotEmpty)
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _submit() {
    if (widget.mode == ParentalMode.verify) {
      final stored = _storage.read("parental_pin_${widget.userId}") ?? "0000";
      if (_pin == stored) {
        if (widget.onVerifySuccess != null) widget.onVerifySuccess!();
        Get.back(); // Close dialog
      } else {
        _error("Incorrect PIN");
      }
    } else {
      // SET Mode
      if (_firstPin.isEmpty) {
        // First entry done, ask for confirm
        _firstPin = _pin;
        setState(() {
          _pin = "";
          _title = "Confirm New PIN";
        });
      } else {
        // Confirmation
        if (_pin == _firstPin) {
          _storage.write("parental_pin_${widget.userId}", _pin);
          if (widget.onSetSuccess != null) widget.onSetSuccess!(_pin);
          Get.back();
          Get.snackbar("Success", "PIN Updated",
              colorText: Colors.white, backgroundColor: Colors.green);
        } else {
          _error("PINs do not match");
          setState(() {
            _firstPin = "";
            _title = "Enter New PIN";
          });
        }
      }
    }
  }

  void _error(String msg) {
    Get.snackbar("Error", msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500));
    setState(() => _pin = "");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPhone = size.shortestSide < 600;
    // Landscape phone: width > height and it's a phone
    final isLandscape = size.width > size.height;
    final isCompact = isPhone && isLandscape;

    final dialogWidth = isPhone ? size.width * 0.50 : 300.0;
    final pad = isCompact ? 10.0 : (isPhone ? 12.0 : 24.0);
    final titleSize = isCompact ? 13.0 : (isPhone ? 16.0 : 20.0);
    final dotSize = isCompact ? 10.0 : (isPhone ? 12.0 : 16.0);
    final dotMargin = isCompact ? 5.0 : (isPhone ? 6.0 : 8.0);
    final vGap1 = isCompact ? 6.0 : (isPhone ? 14.0 : 20.0);
    final vGap2 = isCompact ? 8.0 : (isPhone ? 20.0 : 30.0);
    final vGap3 = isCompact ? 6.0 : (isPhone ? 16.0 : 24.0);

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: size.height * 0.92,
        ),
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_title,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: vGap1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: dotMargin),
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: index < _pin.length ? Colors.red : Colors.white24,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              SizedBox(height: vGap2),
              _buildKeypad(isCompact: isCompact, isPhone: isPhone),
              SizedBox(height: vGap3),
              TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 12 : (isPhone ? 16 : 24),
                      vertical: isCompact ? 4 : (isPhone ? 8 : 12)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.outfit(
                      fontSize: isCompact ? 12 : (isPhone ? 14 : 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad({bool isPhone = false, bool isCompact = false}) {
    final btnSize = isCompact ? 38.0 : (isPhone ? 48.0 : 60.0);
    final rowGap = isCompact ? 6.0 : (isPhone ? 10.0 : 16.0);

    Widget btn(String label) =>
        _KeypadButton(label: label, onTap: () => _onDigit(label), size: btnSize);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [btn("1"), btn("2"), btn("3")],
        ),
        SizedBox(height: rowGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [btn("4"), btn("5"), btn("6")],
        ),
        SizedBox(height: rowGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [btn("7"), btn("8"), btn("9")],
        ),
        SizedBox(height: rowGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: btnSize,
              height: btnSize,
              child: _KeypadButton(
                icon: Icons.backspace_outlined,
                onTap: _delete,
                size: btnSize,
              ),
            ),
            btn("0"),
            SizedBox(width: btnSize, height: btnSize), // spacer
          ],
        ),
      ],
    );
  }
}

class _KeypadButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final double size;

  const _KeypadButton({
    this.label,
    this.icon,
    required this.onTap,
    this.size = 60,
  });

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.size < 55 ? 20.0 : 24.0;
    final iconSize = widget.size < 55 ? 20.0 : 24.0;

    return InkWell(
      onTap: widget.onTap,
      onFocusChange: (val) => setState(() => _isFocused = val),
      borderRadius: BorderRadius.circular(widget.size / 2),
      child: Container(
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isFocused ? kColorPrimary : Colors.white10,
          shape: BoxShape.circle,
          border:
              _isFocused ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: kColorPrimary.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: widget.icon != null
            ? Icon(widget.icon, color: Colors.white, size: iconSize)
            : Text(
                widget.label!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
