import Foundation

enum AppLanguage {
    static let chinese = "zh-Hans"
    static let english = "en"

    static var code: String {
        let preferredLanguage =
            Bundle.main.preferredLocalizations.first ??
            Locale.preferredLanguages.first ??
            english

        if preferredLanguage.lowercased().hasPrefix("zh") {
            return chinese
        }

        return english
    }
}

enum L10n {
    private static func bundle(for languageCode: String) -> Bundle {
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        if languageCode != AppLanguage.english,
           let path = Bundle.main.path(forResource: AppLanguage.english, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
    }

    private static var localizedBundle: Bundle {
        bundle(for: AppLanguage.code)
    }

    static func text(_ key: String) -> String {
        localizedBundle.localizedString(forKey: key, value: key, table: nil)
    }

    static func text(_ key: String, _ args: CVarArg...) -> String {
        let format = text(key)
        return String(format: format, locale: Locale(identifier: AppLanguage.code), arguments: args)
    }
}
