import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormDialogFieldConfig {
  final String id;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final String? Function(String?)? validator;
  final bool obscureText;

  const FormDialogFieldConfig({
    required this.id,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.initialValue,
    this.validator,
    this.obscureText = false,
  });
}

Future<Map<String, String>?> showFormDialog(
  BuildContext context, {
  required String title,
  required List<FormDialogFieldConfig> fields,
  String primaryButtonText = '저장',
  bool barrierDismissible = false,
  Color primaryColor = const Color(0xFFEF5A43),
}) async {
  final Map<String, TextEditingController> controllers = {
    for (final f in fields)
      f.id: TextEditingController(text: f.initialValue ?? ''),
  };
  final formKey = GlobalKey<FormState>();

  Map<String, String>? result = await showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        fontFamily: 'AppleSDGothicNeo',
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: const Icon(Icons.cancel, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...fields.map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: controllers[f.id],
                      obscureText: f.obscureText,
                      keyboardType: f.keyboardType,
                      inputFormatters: f.inputFormatters,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: f.hintText,
                        hintStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'AppleSDGothicNeo',
                        ),
                        filled: true,
                        fillColor: Colors.grey,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: f.validator,
                    ),
                  );
                }),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                        side: const BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? true) {
                        Navigator.of(context).pop({
                          for (final f in fields)
                            f.id: controllers[f.id]!.text.trim(),
                        });
                      }
                    },
                    child: Text(
                      primaryButtonText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'AppleSDGothicNeo',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  // 다이얼로그 위젯 트리가 완전히 제거된 다음 프레임에 안전하게 dispose
  WidgetsBinding.instance.addPostFrameCallback((_) {
    for (final c in controllers.values) {
      c.dispose();
    }
  });
  return result;
}
