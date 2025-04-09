//
//  SceneDelegate+makeApp.swift
//  BambuserPlayerExample
//
//  Created by RODRIGO FRANCISCO PABLO on 09/04/25.
//

import UIKit

extension SceneDelegate {
    func makeApp() -> UIViewController {
        let main = MainViewController()
        let navigationController = UINavigationController(rootViewController: main)
        
        return navigationController
    }
}
