import Flutter
import UIKit

public class MagicAppIconPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "magic_app_icon", binaryMessenger: registrar.messenger())
        let instance = MagicAppIconPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getCurrentIcon":
            getCurrentIcon(result: result)
        case "changeIcon":
            if let args = call.arguments as? [String: Any],
               let iconName = args["iconName"] as? String {
                changeIcon(iconName: iconName, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Icon name is required",
                                  details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getCurrentIcon(result: @escaping FlutterResult) {
        if #available(iOS 10.3, *) {
            let currentIcon = UIApplication.shared.alternateIconName ?? "default"
            result(currentIcon)
        } else {
            result(FlutterError(code: "UNSUPPORTED_PLATFORM",
                              message: "Dynamic app icons are only supported on iOS 10.3 and above",
                              details: nil))
        }
    }
    
    private func changeIcon(iconName: String, result: @escaping FlutterResult) {
        if #available(iOS 10.3, *) {
            let iconToSet = iconName == "default" ? nil : iconName
            
            // Önce ikon değiştirme desteği var mı kontrol et
            guard UIApplication.shared.supportsAlternateIcons else {
                result(FlutterError(code: "UNSUPPORTED_DEVICE",
                                  message: "This device does not support alternate icons",
                                  details: nil))
                return
            }
            
            // İkonu değiştir
            UIApplication.shared.setAlternateIconName(iconToSet) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(code: "ICON_CHANGE_FAILED",
                                          message: error.localizedDescription,
                                          details: nil))
                    } else {
                        result(true)
                    }
                }
            }
        } else {
            result(FlutterError(code: "UNSUPPORTED_PLATFORM",
                              message: "Dynamic app icons are only supported on iOS 10.3 and above",
                              details: nil))
        }
    }
} 