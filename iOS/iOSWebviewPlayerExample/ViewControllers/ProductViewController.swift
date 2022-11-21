//
//  ProductViewController.swift
//  WebviewPlayerExample
//
// Bambuser Webview Player Integration Example
//

import UIKit

class ProductViewController: UIViewController {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var skuLabel: UILabel!

    var productTitle: String? = ""
    var productSKU: String? = ""

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        titleLabel.text = productTitle
        skuLabel.text = productSKU
    }
}
