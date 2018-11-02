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
            return (UserDefaults.get(forKey: Constants.Keys.fullScreenBack) as? Bool) ?? false
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
            return (UserDefaults.get(forKey: Constants.Keys.webViewFontScale) as? Float) ?? 1.1
        }
    }

    /// 夜间模式
    var theme: Theme {
        set {
            ThemeStyle.update(style: newValue)
        }
        get {
            return ThemeStyle.style.value
        }
    }
    
    // 自动切换主题
    var autoSwitchTheme: Bool {
        set {
            UserDefaults.save(at: newValue, forKey: Constants.Keys.autoSwitchTheme)
        }
        get {
            return (UserDefaults.get(forKey: Constants.Keys.autoSwitchTheme) as? Bool) ?? false
        }
    }
    
    // 自动切换夜间模式下的 “夜间主题”
    var nightTheme: Theme {
        set {
            UserDefaults.save(at: newValue.rawValue, forKey: Constants.Keys.nightTheme)
        }
        get {
            guard let themeRawValue = UserDefaults.get(forKey: Constants.Keys.nightTheme) as? Int else {
                return .night
            }
            return Theme(rawValue: themeRawValue) ?? .night
        }
    }
    
    /// 摇一摇反馈
    var shakeFeedback: Bool {
        set {
            UserDefaults.save(at: newValue, forKey: Constants.Keys.shareFeedback)
        }
        get {
            return (UserDefaults.get(forKey: Constants.Keys.shareFeedback) as? Bool) ?? false
        }
    }

    /// 识别剪切板链接
    var recognizeClipboardLink: Bool {
        set {
            UserDefaults.save(at: newValue, forKey: Constants.Keys.recognizeClipboardLink)
        }
        get {
            return (UserDefaults.get(forKey: Constants.Keys.recognizeClipboardLink) as? Bool) ?? true
        }
    }
    
    /// 是否启用消息推送
    var isBackgroundEnable: Bool {
        set {
            UserDefaults.save(at: newValue, forKey: Constants.Keys.isBackgroundEnable)
        }
        get {
            return (UserDefaults.get(forKey: Constants.Keys.isBackgroundEnable) as? Bool) ?? false
        }
    }
}

