import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var blurEffectView: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Add observers to prevent screenshots in app switcher
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationWillResignActive),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @objc func applicationWillResignActive(_ notification: Notification) {
    // Add blur/white overlay when app goes to background
    if let window = self.window {
      let blurView = UIView(frame: window.bounds)
      blurView.backgroundColor = .white
      blurView.tag = 999
      window.addSubview(blurView)
      self.blurEffectView = blurView
    }
  }

  @objc func applicationDidBecomeActive(_ notification: Notification) {
    // Remove blur/overlay when app becomes active
    if let window = self.window {
      window.viewWithTag(999)?.removeFromSuperview()
    }
    self.blurEffectView = nil
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
