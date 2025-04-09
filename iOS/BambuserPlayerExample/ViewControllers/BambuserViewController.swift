//
//  ViewController.swift
//  WebviewPlayerExample
//
// Bambuser Webview Player Integration Example
//

import UIKit
import WebKit

final class BambuserViewController: UIViewController {
    
    var eventHandler: EventHandlerClosure?
    
    var player = BambuserPlayer()

    override func loadView() {
        view = player
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Player"
        
        // MARK: Embed page to be rendered inside the webview
        // Note that player configurations, registering event listeners for the player, 
        //   and also initiating the player are done within the embed page.
        // You need to create a similar page and render that in the WebView. 
        // For inspiration, look at the example embed-html on the GitHub repo.
        
        // Here are a list of URLs to a sample embed page on different player states
        // Uncomment one at a time to test different scenarios

        // 1. Recorded show:
        let url = URL(string: "https://rodrigo-fp.github.io/bambuser-lvs-webview-examples/")

        // 2. Live Show (fake live for testing the chat)
        // let url = URL(string: "https://bambuser.github.io/bambuser-lvs-webview-examples/index.html?mockLiveBambuser=true")

        // 3. Countdown - Scheduled show:
        // let url = URL(string: "https://bambuser.github.io/bambuser-lvs-webview-examples/index.html?showId=2iduPdz2hn6UKd0eQmJq")

        guard let url else {
            return showAlert("Error", "Event has invalid URL")
        }

        do {
            if let eventHandler {
                try player.loadEmbeddedPlayer(url, eventHandler: eventHandler)
            }
        } catch {
            showAlert("Error", "Event has no playback URL")
        }
    }
}
