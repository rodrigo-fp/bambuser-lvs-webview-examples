//
//  BambuserPlayer.swift
//  WebviewPlayerExample
//
// Bambuser Webview Player Integration Example
//

import WebKit

class BambuserPlayer: WKWebView {
    typealias EventHandlerClosure = (Event) -> ()

    var eventHandler: EventHandlerClosure?

    init() {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()

        webConfiguration.userContentController = contentController

        // Allow overlaying custom player components
        // Necessary to render Bambuser LiveShopping player
        webConfiguration.allowsInlineMediaPlayback = true

        // Make it fullscreen
        super.init(frame: .zero, configuration: webConfiguration)
        navigationDelegate = self
        uiDelegate = self

        // Add ScriptMessageHandler
        // Used to catch postMessage events from the webview
        contentController.add(
            self,
            name: "bambuserEventHandler"
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Load show url into the player
    public func loadShow(_ show: Show, eventHandler: @escaping EventHandlerClosure) throws {
        self.eventHandler = eventHandler
        guard let showURL = show.showUrl() else {
            throw BambuserPlayerError.invalidShowURL
        }

        load(URLRequest(url: showURL))
    }
}

extension BambuserPlayer: WKScriptMessageHandler, WKUIDelegate {

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

        eventHandler?(Event(eventName: eventName, data: body["data"]))
    }

    /// This function is used to communicate message to the JS
    private func evaluateJavascript(_ javascript: String, sourceURL: String? = nil, completion: ((_ result: Any? , _ error: String?) -> Void)? = nil) {
        evaluateJavaScript(javascript) { (result, error) in
            guard result != nil else {
                print("error \(String(describing: error))")
                completion?(nil, error?.localizedDescription)
                return
            }
            completion?(result, nil)
            print("Success: \(String(describing: result))")
        }
    }

    //MARK: Overriding URL requests coming from the app
    /*  No links from the player will be clickable unless handled here.
     Common ocassion where player contains links
     - Chat terms contains link to Privacy policy/Terms & conditions
     - Moderator may drop a link in the chat for viewers' usage
    */
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures) -> WKWebView?
    {
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

extension BambuserPlayer: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        debugPrint("didCommit")

        let iOSConfig = IOSConfig(locale: Locale.current, currency: getCurrency())
        guard let jsonData = try? JSONEncoder().encode(iOSConfig),
              let json = String(data: jsonData, encoding: .utf8) else {
            print("Something wrong with Json conversion")
            return
        }
        print("Json body: \(json)")

        // To send the iOS confog info
        // check in console: "window.iosAppConfig"
        let iOSConfigScript = "window.iosAppConfig = JSON.parse('\(json)');"
        evaluateJavascript("\(iOSConfigScript)")

    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        debugPrint("didFinish")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint("didFail")
    }

    //Get Currency (ISO 4217 ex. USD)
    private func getCurrency() -> String {
        return "USD"
    }
}

// MARK: BambuserPlayer models

extension BambuserPlayer {
    enum Show {
        case show(_ eventId: String)
        case customUrl(_ customUrl: String)

        func showUrl() -> URL? {
            switch self {
            case .customUrl(let customUrl):
                return URL(string: customUrl)
            case .show(let eventId):
                // Change this base-URL to the correct one for your environment.
                return URL(string: "https://demo.bambuser.shop/content/webview-landing-v2.html?eventId=\(eventId)")
            }
        }
    }

    enum Event {
        case close
        case ready
        case addToCalendar(CalendarEvent?)
        case share(URL?)
        case showProduct(ProductModel?)
        case unknown(eventName: String)

        init(eventName: String, data: Any? = nil) {
            let eventNameSuffix = eventName.replacingOccurrences(of: "player.EVENT.", with: "")
            let dataDict = data as? [String: AnyObject]

            switch eventNameSuffix {
            case "CLOSE": self = .close
            case "READY": self = .ready
            case "SHOW_ADD_TO_CALENDAR": self = .addToCalendar(dataDict?.decode(CalendarEvent.self))
            case "SHOW_SHARE": self = .share(URL(string: (dataDict?["url"] as? String) ?? ""))
            case "SHOW_PRODUCT_VIEW": self = .showProduct(dataDict?.decode(ProductModel.self))
            default: self = .unknown(eventName: eventName)
            }
        }
    }

    enum BambuserPlayerError: Error {
        case invalidShowURL
    }
}
