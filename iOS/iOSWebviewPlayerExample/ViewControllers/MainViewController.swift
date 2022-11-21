//
//  MainViewController.swift
//  WebviewPlayerExample
//
// Bambuser Webview Player Integration Example
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func playerButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "playerVC", sender: nil)
    }
}
