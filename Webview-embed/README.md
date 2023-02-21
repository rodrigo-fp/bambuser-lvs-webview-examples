# Example HTML embed

## Background
Bambuser Live Video Shopping player is a web-based apllication that requires to render in a web instance. Therefore, when integrating it on a native mobile app, you would need to render it through a WebView. Therefore, an HTML webpage is required to be rendered inside the WebView that has Bambuser player embedded in it.

## Summary
- This is a sample HTML page with Bambuser Live Video Shopping player embedded in it. 
- The player is configured to function in a WebView for both iOS and Android apps.
- Some of the events are handled to work in a WebView for both iOS and Android apps.

**Note**: This is an example implementation for the most common integration. You may change the configurations based on your needs. To learn more about the available configurations and event handlers, check out the [Bambuser Player JavaScript API documentation](https://bambuser.com/docs/one-to-many/player-api-reference/).

## Tips
- This webpage is to embed inside the webview
- Bambuser player should be embedded on this page ([How to embed Bambuser player](https://bambuser.com/docs/one-to-many/initial-setup))
- It is a good practice to keep the page blank and autoplay the show on page load
- This page should be host and managed on your side
- It is recommended that you host this page remotely, not locally on your app; so that you can change the content without a need for app release.
- Disable the 'click outside to close' behaviour, so the users will not accidentally close the player before it loads
  ```js
  window.initBambuserLiveShopping({
    showId: "SHOW_ID_HERE",
    type: "overlay",
    disableClickOutsideBehavior: true, // Tapping on the loading spinner will not terminate the player
  });
  ``` 

**Note:** This code only work on a Webview on Android or iOS.
