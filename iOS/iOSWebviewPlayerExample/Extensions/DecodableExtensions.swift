//
//  DecodableExtensions.swift
//  iOSWebviewPlayerExample
//

import Foundation

extension Dictionary {
    func decode<T: Decodable>(_ type: T.Type) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: self) else { return nil }
        return try? JSONDecoder().decode(type.self, from: data)
    }
}
