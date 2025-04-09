//
//  ProductModel.swift
//  iOSWebviewPlayerExample
//

import Foundation

struct ProductModel: Decodable {
    var id: String
    var title: String
    var vendor: String?
    var url: String
    var actionOrigin: String?
    var actionTarget: String?
    var sku: String
}
