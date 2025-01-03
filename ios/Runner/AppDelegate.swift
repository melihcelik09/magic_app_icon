import Flutter
import UIKit

/// Main application delegate class that handles app lifecycle and Flutter integration
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    // Channel to update app icon - Communication bridge between Flutter and iOS
    let appIconChannel = FlutterMethodChannel(
      name: "dynamic_icon_changer", binaryMessenger: controller.binaryMessenger)

    appIconChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      // Handle different method calls from Flutter
      switch call.method {
      case "updateIcon":
        // Change the app icon
        self?.changeAppIcon(call: call, result: result)
      case "getCurrentIcon":
        // Get the current app icon name
        self?.getCurrentIcon(result: result)
      default:
        result(FlutterMethodNotImplemented)
        return
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Changes the app icon based on the provided icon name
  /// - Parameters:
  ///   - call: Flutter method call containing the icon name
  ///   - result: Callback to return the result to Flutter
  private func changeAppIcon(call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Only work on iOS > 10.3
    if #available(iOS 10.3, *) {
      guard UIApplication.shared.supportsAlternateIcons else {
        result(
          FlutterError(
            code: "ICON_NOT_SUPPORTED",
            message: "Alternate icons are not supported on this device.", details: nil))
        return
      }

      // Get the icon name passed as argument
      guard let args = call.arguments as? [String: Any], let iconName = args["iconName"] as? String
      else {
        result(
          FlutterError(code: "INVALID_ARGUMENT", message: "Icon name not provided", details: nil))
        return
      }

      // Check if the icon name exists in the assets
      if !UIApplication.shared.supportsAlternateIcons || !isValidIconName(iconName) {
        result(
          FlutterError(
            code: "INVALID_ICON", message: "The requested icon is invalid.", details: nil))
        return
      }

      // Check if the current icon is already the requested icon
      if let currentIconName = UIApplication.shared.alternateIconName, currentIconName == iconName {
        result(false)  // No change needed
        return
      }

      // Apply the new icon
      UIApplication.shared.setAlternateIconName(iconName) { error in
        if let error = error {
          print("İkon değiştirilemedi: \(error.localizedDescription)")
          result(
            FlutterError(
              code: "ICON_CHANGE_FAILED", message: error.localizedDescription, details: nil))
        } else {
          result(true)  // Successfully changed the icon
        }
      }
    } else {
      result(false)  // iOS version too old
    }
  }

  /// Gets the current app icon name
  /// - Parameter result: Callback to return the result to Flutter
  private func getCurrentIcon(result: @escaping FlutterResult) {
    if #available(iOS 10.3, *) {
      // Get the current icon name, if nil it means the default icon is being used
      let currentIcon = UIApplication.shared.alternateIconName ?? "Default"
      result(currentIcon)
    } else {
      // For older iOS versions, always return Default
      result("Default")
    }
  }

  /// Helper function to validate if the icon name exists
  /// - Parameter iconName: Name of the icon to validate
  /// - Returns: Boolean indicating if the icon name is valid
  private func isValidIconName(_ iconName: String) -> Bool {
    let validIcons = ["Red", "Purple", "Default"]  // Add your icon names here
    return validIcons.contains(iconName)
  }
}
