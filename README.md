# FSTT_Frontend

## 📁 프로젝트 구조

``` md 
lib
├── main.dart
├── components # 재사용 가능한 UI 컴포넌트
├── models # 데이터 모델 정의
├── route # 앱의 페이지 라우팅을 관리
│   └── router.dart
├── screens # 각 화면/페이지
└── services # 비즈니스 로직과 외부 서비스 api 연동
```

## 🚀 시작하기

아래 단계를 따라 프로젝트 개발 환경을 설정하세요.

### 1️⃣ 프로젝트 클론

```bash
git clone https://github.com/HKNU-FSTT/FSTT_Frontend.git
cd FSTT_Frontend/
```

### 2️⃣ .env 파일 생성

프로젝트 루트 디렉토리에 `.env` 파일을 생성합니다.

```bash
cp env-template .env
```

### 3️⃣ 환경 변수 설정

`.env` 파일에 다음 키 값들을 입력하세요:

#### 카카오 로그인 설정
- `KAKAO_NATIVE_APP_KEY`: 카카오 개발자 콘솔에서 발급받은 네이티브 앱 키
- `KAKAO_JAVASCRIPT_APP_KEY`: 웹 환경에서 사용되는 JavaScript 앱 키

#### 네이버 로그인 설정
- `NAVER_CLIENT_ID`: 네이버 개발자 센터에서 발급받은 클라이언트 ID
- `NAVER_CLIENT_SECRET`: 네이버 개발자 센터에서 발급받은 클라이언트 시크릿
- `NAVER_APP_NAME`: 네이버 앱 등록 시 설정한 앱 이름

#### 구글 로그인 설정
- `GOOGLE_CLIENT_ID`: 구글 클라우드 콘솔에서 발급받은 클라이언트 ID

#### LiveKit 설정
- `LIVEKIT_URL`: 실시간 통신을 위한 LiveKit 서버 URL

### 4️⃣ 앱 실행

환경 변수 설정이 완료되면 Flutter 앱을 실행할 수 있습니다.

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

