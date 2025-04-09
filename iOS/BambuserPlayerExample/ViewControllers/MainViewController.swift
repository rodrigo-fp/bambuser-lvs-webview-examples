//
//  MainViewController.swift
//  WebviewPlayerExample
//
// Bambuser Webview Player Integration Example
//

import UIKit

class MainViewController: UIViewController {
    var liveVideoController: UIViewController?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Main view"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(frame: CGRect(x:0, y:0, width: 200, height:50))
        button.center = view.center
        button.setTitle("Open Live", for: .normal)
        button.addTarget(self, action: #selector(playerButton), for: .touchUpInside)
        view.addSubview(button)
    }

    @objc
    func playerButton() {
        let bambuserController =  BambuserViewController()
        bambuserController.eventHandler = handleEvent
        
        self.liveVideoController = bambuserController
        self.present(liveVideoController!, animated: true)
    }
}

// Bambuser Helpers
extension MainViewController {
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
        case "player.EVENT.EXIT_PIP":
            print("We should recover the poped view")
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
        let pvc = ProductViewController()
        pvc.productTitle = product.title
        pvc.productSKU = product.sku

        // liveVideoController?.dismiss(animated: true)
        show(pvc, sender: nil)
    }
}

/// Player Interface Handler Methods
extension UIViewController {
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
