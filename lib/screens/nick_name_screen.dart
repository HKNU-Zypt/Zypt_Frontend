import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/components/main_button.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:focused_study_time_tracker/services/user_service.dart';
import 'package:go_router/go_router.dart';

class NickNameScreen extends StatefulWidget {
  const NickNameScreen({super.key});

  @override
  State<NickNameScreen> createState() => _NickNameScreenState();
}

class _NickNameScreenState extends State<NickNameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _helperText = '닉네임은 언제든 설정에서 변경할 수 있어요.';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _isNicknameSet(BuildContext context) async {
    final userService = UserService();
    final savedNickname = await userService.getNickname();
    // 닉네임이 uuid 패턴인 경우 void

    if (savedNickname != null) {
      final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      );
      if (uuidPattern.hasMatch(savedNickname)) {
        return;
      }
      if (mounted) {
        context.go('/home');
      }
    }
  }

  Future<void> _saveNickname() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userService = UserService();
      final nickname = _nicknameController.text.trim();

      final result = await userService.setNickname(nickname);
      if (result) {
        print('zypt [NickNameScreen] 닉네임 설정 성공');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('닉네임 "$nickname"이(가) 저장되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        }
      } else {
        print('zypt [NickNameScreen] 닉네임 설정 실패');
        if (mounted) {
          setState(() {
            _helperText = '중복된 닉네임입니다.';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('중복된 닉네임입니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _helperText = '중복된 닉네임입니다.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('닉네임 저장에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _isNicknameSet(context);

    return DefaultLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 타이틀
                        const Text(
                          '닉네임을 알려주세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'AppleSDGothicNeo',
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 닉네임 입력 필드
                        TextFormField(
                          controller: _nicknameController,
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'AppleSDGothicNeo',
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontFamily: 'AppleSDGothicNeo',
                              fontWeight: FontWeight.w700,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '닉네임을 입력해주세요';
                            }
                            if (value.trim().length < 2) {
                              return '닉네임은 2자 이상 입력해주세요';
                            }
                            if (value.trim().length > 20) {
                              return '닉네임은 20자 이하로 입력해주세요';
                            }

                            // 특수문자 제한 (한글, 영문, 숫자만 허용)
                            final RegExp validChars = RegExp(
                              r'^[가-힣a-zA-Z0-9]+$',
                            );
                            if (!validChars.hasMatch(value.trim())) {
                              return '한글, 영문, 숫자만 사용 가능합니다';
                            }

                            // 부적절한 단어 필터링
                            final inappropriateWords = [
                              'admin',
                              '관리자',
                              'test',
                              '테스트',
                            ];
                            if (inappropriateWords.contains(
                              value.trim().toLowerCase(),
                            )) {
                              return '사용할 수 없는 닉네임입니다';
                            }

                            return null;
                          },
                          maxLength: 20,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _saveNickname(),
                          onChanged: (value) {
                            setState(() {
                              _helperText = '닉네임은 언제든 설정에서 변경할 수 있어요.';
                            });
                          },
                        ),

                        const SizedBox(height: 30),

                        // 안내 문구 (입력 아래)
                        Text(
                          _helperText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'AppleSDGothicNeo',
                            color:
                                _helperText == '중복된 닉네임입니다.'
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              MainButton(
                title: _isLoading ? '저장 중...' : '집중 시작',
                onPressed: _isLoading ? () {} : _saveNickname,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
