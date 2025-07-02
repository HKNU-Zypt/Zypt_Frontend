import Flutter
import UIKit
import NidThirdPartyLogin

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // 네이버 로그인 URL 처리
    if (NidOAuth.shared.handleURL(url) == true) {
      return true
    }
    
    // 다른 앱에서 오는 URL 처리 (예: 카카오 로그인 등)
    // 부모 클래스의 URL 핸들러 호출
    return super.application(app, open: url, options: options)
  }
}