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
  Color primaryColor = const Color(0xFF000000),
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
                // 해더
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
                  if (f.id == 'maxParticipants') {
                    // 버튼으로만 조절하는 필드
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MaxParticipantsField(
                        min: 2,
                        max: 4,
                        initialValue: int.tryParse(f.initialValue ?? '2') ?? 2,
                        onChanged: (value) {
                          controllers[f.id]?.text = value.toString();
                        },
                      ),
                    );
                  } else {
                    // 기본 TextFormField
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
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'AppleSDGothicNeo',
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: f.hintText,
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'AppleSDGothicNeo',
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: f.validator,
                      ),
                    );
                  }
                }),
                const SizedBox(height: 4),
                // 생성하기 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
                        color: Colors.white,
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

class MaxParticipantsField extends StatefulWidget {
  final int min;
  final int max;
  final int initialValue;
  final ValueChanged<int> onChanged;

  const MaxParticipantsField({
    super.key,
    this.min = 2,
    this.max = 20,
    this.initialValue = 2,
    required this.onChanged,
  });

  @override
  _MaxParticipantsFieldState createState() => _MaxParticipantsFieldState();
}

class _MaxParticipantsFieldState extends State<MaxParticipantsField> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _increment() {
    if (_value < widget.max) {
      setState(() => _value++);
      widget.onChanged(_value);
    }
  }

  void _decrement() {
    if (_value > widget.min) {
      setState(() => _value--);
      widget.onChanged(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _decrement,
          icon: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(1, 0), // x=4픽셀 오른쪽 이동
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(
                Icons.remove_circle,
                color: Color(0xFFF3A753),
                size: 28,
              ),
            ],
          ),
        ),
        SizedBox(width: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(color: Colors.white),
          child: Text(
            '$_value',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              fontFamily: 'AppleSDGothicNeo',
            ),
          ),
        ),
        SizedBox(width: 20),
        IconButton(
          onPressed: _increment,
          icon: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(1, 0), // x=4픽셀 오른쪽 이동
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.add_circle, color: Color(0xFFF3A753), size: 28),
            ],
          ),
        ),
      ],
    );
  }
}
