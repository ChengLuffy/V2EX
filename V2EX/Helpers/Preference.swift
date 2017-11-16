import Foundation

class Preference {

    public static let shared: Preference = Preference()


    /// At 用户时是否添加楼层， 默认 false
    var atMemberAddFloor: Bool {
        set {
            UserDefaults.save(at: newValue, forKey: Constants.Keys.atMemberAddFloor)
        }
        get {
            return (UserDefaults.get(forKey: Constants.Keys.atMemberAddFloor) as? Bool) ?? false
        }
    }

    /// 是否启用全屏返回手势， 默认 true
    var enableFullScreenGesture: Bool {
        set {
            UserDefaults.save(at: newValue, forKey: Constants.Keys.fullScreenBack)
        }
        get {
            return (UserDefaults.get(forKey: Constants.Keys.fullScreenBack) as? Bool) ?? true
        }
    }

    /// 是否使用 Safari 浏览网页， 默认 true
    var useSafariBrowser: Bool {
        set {
            UserDefaults.save(at: newValue, forKey: Constants.Keys.openWithSafariBrowser)
        }
        get {
            return (UserDefaults.get(forKey: Constants.Keys.openWithSafariBrowser) as? Bool) ?? true
        }
    }

    /// 是否同意 协议
    var agreementOfConsent: Bool {
        set {
            UserDefaults.save(at: newValue, forKey: Constants.Keys.agreementOfConsent)
        }
        get {
            return (UserDefaults.get(forKey: Constants.Keys.agreementOfConsent) as? Bool) ?? false
        }
    }

    /// WebView 字体比例 默认 1.0
    var webViewFontScale: Float {
        set {
            UserDefaults.save(at: newValue, forKey: Constants.Keys.webViewFontScale)
        }
        get {
            return (UserDefaults.get(forKey: Constants.Keys.webViewFontScale) as? Float) ?? 1.0
        }
    }
}

