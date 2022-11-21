//
//  ViewController.swift
//  WebviewPlayerExample
//
// Bambuser Webview Player Integration Example
//

import UIKit
import WebKit

class BambuserViewController: UIViewController, WKScriptMessageHandler, WKUIDelegate {
    
    var webView: WKWebView?
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        // Add ScriptMessageHandler
        // Used to catch postMessage events from the webview
        contentController.add(
            self,
            name: "bambuserEventHandler"
        )
        webConfiguration.userContentController = contentController
        
        // Allow overlaying custom player components
        // Necessary to render Bambuser LiveShopping player
        webConfiguration.allowsInlineMediaPlayback = true
        
        
        // Make it fullscreen
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Initialize the delagate methods
        // We use this to inject configuration data to the webview JS context
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
        
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Player"
        
        //MARK: Embed page to be rendered inside the webview
        // Note that player configurations, picking up player events, and triggering the player are done within the embed page.
        // You need to have a similar webpage
        
        // Here are a list of URLs to a sample embed page on different player states
        // Uncomment the one at a time for testing in different stats
        
        // 1. Recorded show:
//        let urlString = "https://demo.bambuser.shop/content/webview-landing-v2.html"
        
        // 2. Live Show (fake live for testing chat)
        let urlString = "https://demo.bambuser.shop/content/webview-landing-v2.html?mockLiveBambuser=true"
        
        // 3. Countdown - Scheduled show:
//        let urlString = "https://demo.bambuser.shop/content/webview-landing-v2.html?eventId=2iduPdz2hn6UKd0eQmJq"
        
        guard let eventURL = URL(string: urlString)
        else {
            showAlert("Error", "Event has no playback URL ")
            return
        }
        let myRequest = URLRequest(url: eventURL)
        webView?.load(myRequest)
    }
    
    /// This function is used to communicate message to the JS
    private func evaluateJavascript(_ javascript: String, sourceURL: String? = nil, completion: ((_ result: Any? , _ error: String?) -> Void)? = nil) {
        webView?.evaluateJavaScript(javascript) { (result, error) in
            guard result != nil else {
                print("error \(String(describing: error))")
                completion?(nil, error?.localizedDescription)
                return
            }
            completion?(result, nil)
            print("Success: \(String(describing: result))")
        }
    }
    
    //MARK: WKScriptMessageHandler
    /// This function is called when there is a postMessage from the WebView
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "bambuserEventHandler" else {
            print("No handler for this message: \(message)")
            return
        }
        
        guard let body = message.body as? [String: Any] else {
            print("could not convert message body to dictionary: \(message.body)")
            return
        }
        
        // Check all available events on our Player API Reference
        // https://bambuser.com/docs/one-to-many/player-api-reference/
        // Here we only handled the following  'player.EVENT.READY' and 'player.EVENT.CLOSE' events as for example.
        
        guard let eventName = body["eventName"] as? String else { return }
        switch eventName {
            // MARK: - Handle "Close"
        case "player.EVENT.CLOSE":
            // Add your handler methods if needed
            // As an example we invoke the close() method
            close()
            // MARK: - Handle "Ready"
        case "player.EVENT.READY":
            // Add your handler methods if needed
            // As an example we print a message when the 'player.EVENT.READY' is emitted
            print(body["eventName"] ?? "Default Event Name")
            
            // MARK: - Handle "Add to calendar"
        case "player.EVENT.SHOW_ADD_TO_CALENDAR":
            if let data = body["data"] as? [String: AnyObject] {
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions.insert(.withFractionalSeconds)
                
                guard
                    let title = data["title"] as? String,
                    let description = data["description"] as? String,
                    let startString = data["start"] as? String,
                    let startDate = dateFormatter.date(from: startString),
                    let duration = data["duration"] as? TimeInterval,
                    let urlString = data["url"] as? String,
                    let url = URL(string: urlString)
                else { return }
                
                // Create the end date by adding the durations, dividing by 1000 to convert from milliseconds to seconds
                let endDate = startDate.addingTimeInterval(duration / 1000)
                
                // Create the calendar event
                let showEvent = CalendarEvent(
                    title: title,
                    description: description,
                    startDate: startDate,
                    endDate: endDate,
                    url: url
                )
                
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
            
            // MARK: - Handle share events
        case "player.EVENT.SHOW_SHARE":
            guard
                let data = body["data"] as? [String: AnyObject],
                let urlString = data["url"] as? String,
                let url = URL(string: urlString)
            else { return }
            
            // Create an activity view controller containing the URL to share
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // Present the activity view controller
            present(activityViewController, animated: true, completion: nil)
            
            // MARK: - Handle product clicks
        case "player.EVENT.SHOW_PRODUCT_VIEW":
            // Get the data needed for presenting the product
            guard
                let data = body["data"] as? [String: AnyObject],
                //                let url = data["url"] as? String,
                //                let id = data["id"] as? String,
                    //                let vendor = data["vendor"] as? String,
                    let title = data["title"] as? String,
                //                let actionOrigin = data["actionOrigin"] as? String,
                //                let actionTarget = data["actionTarget"] as? String,
                    let sku = data["sku"] as? String
            else { return }
            
            // Instantiate the product view controller and set the values
            guard let pvc = storyboard?.instantiateViewController(identifier: "product") as? ProductViewController else { return }
            pvc.productTitle = title
            pvc.productSKU = sku
            
            // Present the product view controller
            present(pvc, animated: true)
            
        default:
            showAlert("eventName", "This event does not have a handler for event \(eventName)!")
        }
    }
    
    //MARK: Overriding URL requests coming from the app
    /*  No links from the player will be clickable unless handled here.
     Common ocassion where player contains links
     - Chat terms contains link to Privacy policy/Terms & conditions
     - Moderator may drop a link in the chat for viewers' usage
    */
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil}
        
        // Check if it's a valid URL
        if let validUrl = URL(string: "\(url)") {
            print("It is a valid URL: \(validUrl)")
            print("\(validUrl.absoluteString)")
            
            // Use regex to validate link type
            // E.g.
            let regex: String = "/privacy"
            let regexResult = validUrl.absoluteString.range(
                of: regex,
                options: .regularExpression
            )
            let isPrivacyPolicyLink = (regexResult != nil)
            
            // If it's a Privacy Policy link, open it in a browser
            if isPrivacyPolicyLink {
                print("Opening PP/TC link in a browser...")
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Detect and handle other types of link you expect in the player
                print("An unhandled URL request from the player: \(validUrl)")
            }
        } else {
            print("Not a valid URL: \(url)")
            return nil
        }
        return nil
    }
    
}

extension BambuserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        debugPrint("didCommit")
        let myJsonDict : [String: Any] = [
            "locale": "\(Locale.current.languageCode ?? "en")-\(Locale.current.regionCode ?? "")",
            "currency": "\(getCurrency())"
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: myJsonDict, options: []),
              let json = String(data: jsonData, encoding: .utf8) else {
            print("Something wrong with Json conversion")
            return
        }
        print("Json body: \(json)")
        
        // To send the iOS confog info
        // check in console: "window.iosAppConfig"
        let iOSConfig = "window.iosAppConfig = JSON.parse('\(json)');"
        evaluateJavascript("\(iOSConfig)")
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        debugPrint("didFinish")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint("didFail")
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
    
    //Get Currency (ISO 4217 ex. USD)
    func getCurrency() -> String {
        return "USD"
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
