import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/helpers/helpers.dart';

enum ParentalMode { verify, set }

class ParentalControlWidget extends StatefulWidget {
  final ParentalMode mode;
  final Function(String?)? onSetSuccess; // Returns new PIN if set
  final VoidCallback? onVerifySuccess;

  const ParentalControlWidget({
    super.key,
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
      final stored = _storage.read("parental_pin") ?? "0000";
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
          _storage.write("parental_pin", _pin);
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
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_title,
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: index < _pin.length ? Colors.red : Colors.white24,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            _buildKeypad(),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "Cancel",
                style: GoogleFonts.outfit(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _KeypadButton(label: "1", onTap: () => _onDigit("1")),
            _KeypadButton(label: "2", onTap: () => _onDigit("2")),
            _KeypadButton(label: "3", onTap: () => _onDigit("3")),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _KeypadButton(label: "4", onTap: () => _onDigit("4")),
            _KeypadButton(label: "5", onTap: () => _onDigit("5")),
            _KeypadButton(label: "6", onTap: () => _onDigit("6")),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _KeypadButton(label: "7", onTap: () => _onDigit("7")),
            _KeypadButton(label: "8", onTap: () => _onDigit("8")),
            _KeypadButton(label: "9", onTap: () => _onDigit("9")),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: _KeypadButton(
                icon: Icons.backspace_outlined,
                onTap: _delete,
              ),
            ),
            _KeypadButton(label: "0", onTap: () => _onDigit("0")),
            const SizedBox(width: 60, height: 60), // Alignment spacer
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

  const _KeypadButton({this.label, this.icon, required this.onTap});

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onFocusChange: (val) => setState(() => _isFocused = val),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isFocused ? kColorPrimary : Colors.white10,
          shape: BoxShape.circle,
          border: _isFocused ? Border.all(color: Colors.white, width: 2) : null,
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
            ? Icon(widget.icon, color: Colors.white, size: 24)
            : Text(
                widget.label!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
