//
//  ViewController.swift
//  WebviewPlayerExample
//
// Bambuser Webview Player Integration Example
//

import UIKit
import WebKit

class BambuserViewController: UIViewController {
    
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
        let url = URL(string: "https://demo.bambuser.shop/content/webview-landing-v2.html")

        // 2. Live Show (fake live for testing the chat)
        // let url = URL(string: "https://demo.bambuser.shop/content/webview-landing-v2.html?mockLiveBambuser=true")

        // 3. Countdown - Scheduled show:
        // let url = URL(string: "https://demo.bambuser.shop/content/webview-landing-v2.html?eventId=2iduPdz2hn6UKd0eQmJq")

        guard let url else {
            return showAlert("Error", "Event has invalid URL")
        }

        do {
            try player.loadEmbeddedPlayer(url, eventHandler: handleEvent)
        } catch {
            showAlert("Error", "Event has no playback URL")
        }
    }

    func handleEvent(_ name: String, data: Any?) {
        // Check all available events on our Player API Reference
        // https://bambuser.com/docs/one-to-many/player-api-reference/
        // Here we only handled the following  'player.EVENT.READY' and 'player.EVENT.CLOSE' events as for example.
        let dataDictionary = data as? [String: AnyObject]

        switch name {
        case "player.EVENT.CLOSE":
            // Add your handler methods if needed
            // As an example we invoke the close() method
            close()
        case "player.EVENT.READY":
            // Add your handler methods if needed
            // As an example we print a message when the 'player.EVENT.READY' is emitted
            print("Ready")
        case "player.EVENT.SHOW_ADD_TO_CALENDAR":
            let calendarEvent = dataDictionary?.decode(CalendarEvent.self)
            addToCalendar(calendarEvent)
        case "player.EVENT.SHOW_SHARE":
            guard
                let urlString = dataDictionary?["url"] as? String,
                let url = URL(string: urlString)
            else { return }

            shareShow(url)
        case "player.EVENT.SHOW_PRODUCT_VIEW":
            let product = dataDictionary?.decode(ProductModel.self)
            showProductView(product)
        default:
            showAlert("eventName", "This event does not have a handler for event \(name)!")
        }
    }

    private func addToCalendar(_ calendarEvent: CalendarEvent?) {
        guard let showEvent = calendarEvent else { return }

        // Save to default calendar
        // NOTE: Don't forget to set the 'NSCalendarsUsageDescription' key in 'Info.plist'. Otherwise, the app
        // will crash in runtime.
        showEvent.saveToCalendar { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.showAlert("Saved to calendar", "The show event was saved in the calendar.")
            case .failure(let error):
                self.showAlert("Error", error.localizedDescription)
            }
        }
    }

    private func shareShow(_ url: URL?) {
        guard let url = url else { return }

        // Create an activity view controller containing the URL to share
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        // Present the activity view controller
        present(activityViewController, animated: true, completion: nil)
    }

    private func showProductView(_ product: ProductModel?) {
        // Get the data needed for presenting the product
        guard let product = product else { return }

        // Instantiate the product view controller and set the values
        guard let pvc = storyboard?.instantiateViewController(identifier: "product") as? ProductViewController else { return }
        pvc.productTitle = product.title
        pvc.productSKU = product.sku

        // Present the product view controller
        present(pvc, animated: true)
    }
}

/// Player Interface Handler Methods
extension BambuserViewController {
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            //Action
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Get Locale (ex. en-US)
    func getLocale() -> String {
        return (Locale.current.languageCode ?? "en") + (Locale.current.regionCode ?? "US")
    }
    
    //Close the current view and navigate to the previous view
    func close() {
        dismiss(animated: true)
    }
}
