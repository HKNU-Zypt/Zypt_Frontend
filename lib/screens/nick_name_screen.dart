import 'package:flutter/material.dart';
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
      } else {
        print('zypt [NickNameScreen] 닉네임 설정 실패');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('닉네임 "$nickname"이(가) 저장되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );

        // 홈 화면으로 이동
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
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
      appBar: AppBar(
        title: const Text('닉네임 설정'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // 제목
              const Text(
                '닉네임을 입력해주세요',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 닉네임 입력 필드
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: '닉네임',
                  hintText: '닉네임을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.person),
                  suffixText: '${_nicknameController.text.length}/10',
                  suffixStyle: TextStyle(
                    color:
                        _nicknameController.text.length > 8
                            ? Colors.orange
                            : Colors.grey,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '닉네임을 입력해주세요';
                  }
                  if (value.trim().length < 2) {
                    return '닉네임은 2자 이상 입력해주세요';
                  }
                  if (value.trim().length > 10) {
                    return '닉네임은 10자 이하로 입력해주세요';
                  }

                  // 특수문자 제한 (한글, 영문, 숫자만 허용)
                  final RegExp validChars = RegExp(r'^[가-힣a-zA-Z0-9]+$');
                  if (!validChars.hasMatch(value.trim())) {
                    return '한글, 영문, 숫자만 사용 가능합니다';
                  }

                  // 부적절한 단어 필터링 (예시)
                  final inappropriateWords = ['admin', '관리자', 'test', '테스트'];
                  if (inappropriateWords.contains(value.trim().toLowerCase())) {
                    return '사용할 수 없는 닉네임입니다';
                  }

                  return null;
                },
                maxLength: 10,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _saveNickname(),
                onChanged: (value) {
                  setState(() {
                    // 실시간으로 글자 수 업데이트를 위해 setState 호출
                  });
                },
              ),

              const SizedBox(height: 24),

              // 저장 버튼
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveNickname,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            '저장하기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
