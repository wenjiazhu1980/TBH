import Foundation

enum AppVersion {
    static var displayString: String {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
              !version.isEmpty else {
            return "dev"
        }
        return version.hasPrefix("v") ? version : "v\(version)"
    }
}
