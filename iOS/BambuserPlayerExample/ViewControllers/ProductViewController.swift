//
//  ProductViewController.swift
//  WebviewPlayerExample
//
// Bambuser Webview Player Integration Example
//

import UIKit

final class ProductViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 0 // Allow multiple lines if needed
        label.textColor = .black
        return label
    }()

    private let skuLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()

    var productTitle: String? = "" {
        didSet {
            titleLabel.text = productTitle
        }
    }
    var productSKU: String? = "" {
        didSet {
            skuLabel.text = productSKU
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(skuLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title Label Constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // SKU Label Constraints
            skuLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            skuLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            skuLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
}
