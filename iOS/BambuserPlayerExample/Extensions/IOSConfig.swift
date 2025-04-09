//
//  IOSConfig.swift
//  iOSWebviewPlayerExample
//

import Foundation

struct IOSConfig: Encodable {
    var locale: String
    var currency: String

    init(locale: Locale, currency: String) {
        self.locale = "\(locale.languageCode ?? "en")-\(locale.regionCode ?? "")"
        self.currency = currency
    }
}
