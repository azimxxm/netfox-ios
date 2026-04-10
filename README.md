<p align="center">
  <img src="netfox-logo.svg" />
</p>

<p align="center">
<img alt="Version" src="https://img.shields.io/badge/version-2.0.0-green.svg?style=flat-square" />
<img alt="Platform" src="https://img.shields.io/badge/platform-iOS%2014%2B-blue.svg?style=flat-square" />
<img alt="Swift" src="https://img.shields.io/badge/swift-5.9-orange.svg?style=flat-square" />
<a href="https://opensource.org/licenses/MIT"><img alt="License" src="https://img.shields.io/badge/license-MIT-orange.svg?style=flat-square" /></a>
</p>

# netfox-ios

A lightweight in-app network debugging library for iOS. Intercepts all HTTP/HTTPS requests — yours, third-party libraries (Alamofire, URLSession, etc.), and presents them in a shake-activated inspector UI.

**Maintained by [Azimjon Abdurasulov](https://azimjondev.uz)** — forked from [kasketis/netfox](https://github.com/kasketis/netfox) and modernized for iOS 14+ with dark mode, SF Symbols, and modern Swift patterns.

### Overview

| ![](https://raw.githubusercontent.com/kasketis/netfox/master/assets/overview1_5_3.gif) | ![](https://cloud.githubusercontent.com/assets/1402212/12893260/78f90916-ce90-11e5-830a-d1a1b91b2ac4.png) |
|---|---|

## What's New in v2.0

- **iOS 14+ minimum** — dropped legacy iOS 12/13 support
- **Dark mode** — full dynamic color support, adapts automatically
- **SF Symbols** — replaced base64 PNG assets with native system icons
- **System fonts** — better Dynamic Type and accessibility support
- **Modern UI** — redesigned list cells with status dots, method badges, duration in ms/s
- **Segmented control** for Info/Request/Response tabs with swipe gestures
- **Privacy manifest** (`PrivacyInfo.xcprivacy`) for App Store compliance
- **Force unwrap cleanup** — eliminated all force unwraps from production code
- **Copy as cURL** — quickly copy any request as a cURL command
- **Thread safety improvements** in model management

## Installation

### Swift Package Manager (Recommended)

Add `netfox` as a package dependency in Xcode:

`File > Add Packages` → enter repository URL:

```
https://github.com/azimxxm/netfox-ios
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/azimxxm/netfox-ios", from: "2.0.0")
]
```

### Manually

Copy the `netfox/` folder into your project. Keep `Core/` and `iOS/` folders, remove `OSX/`.

## Quick Start

### UIKit (AppDelegate)

```swift
// AppDelegate.swift
import netfox

func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    #if DEBUG
    NFX.sharedInstance().start()
    #endif
    return true
}
```

### SwiftUI (App lifecycle)

```swift
// YourApp.swift
import SwiftUI
import netfox

@main
struct YourApp: App {
    init() {
        #if DEBUG
        NFX.sharedInstance().start()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

If you need to show/hide netfox manually in SwiftUI (with `.custom` gesture):

```swift
// Example: toggle with a button
Button("Network Logs") {
    NFX.sharedInstance().show()
}
```

Or present on a specific view controller from SwiftUI:

```swift
struct NetfoxButton: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    static func show(from vc: UIViewController) {
        NFX.sharedInstance().show(on: vc)
    }
}
```

**That's it.** Shake your device to open the network inspector. Shake again to dismiss.

> Always wrap with `#if DEBUG` to prevent execution in production builds. Add `-DDEBUG` in Build Settings → Swift Compiler → Other Swift Flags (Debug configuration).

## Usage

### Custom Gesture

If you prefer not to use shake:

```swift
NFX.sharedInstance().setGesture(.custom)

// Show manually
NFX.sharedInstance().show()

// Hide manually
NFX.sharedInstance().hide()

// Toggle
NFX.sharedInstance().toggle()
```

### Show on Specific View Controller

```swift
NFX.sharedInstance().show(on: myViewController)
```

### Ignore URLs

```swift
// Ignore by prefix
NFX.sharedInstance().ignoreURL("https://analytics.example.com")

// Ignore multiple
NFX.sharedInstance().ignoreURLs(["https://logs.example.com", "https://metrics.example.com"])

// Ignore by regex
NFX.sharedInstance().ignoreURLsWithRegex(".*\\.analytics\\..*")
```

### Stop & Clear

```swift
NFX.sharedInstance().stop()  // Stops logging and clears all data
```

### Session Logs

```swift
if let logData = NFX.sharedInstance().getSessionLog() {
    // Export or process log data
}
```

### Cache Policy

```swift
NFX.sharedInstance().setCachePolicy(.returnCacheDataElseLoad)
```

## Features

- **Request List** — all captured requests with status indicators, method badges, and duration
- **Search** — filter by URL, HTTP method, or response type
- **Response Filters** — show only JSON, XML, HTML, Image, or Other responses
- **Request Details** — headers, body, URL query parameters, timing info
- **Response Details** — status, headers, body with JSON pretty-printing
- **Copy as cURL** — one-tap copy of any request
- **Share Logs** — share via system share sheet or email
- **Statistics** — average response time, total data transferred
- **Device Info** — IP address, OS version, screen resolution
- **Dark Mode** — full support with dynamic colors
- **Disk Storage** — request/response bodies stored on disk for low memory overhead

## Requirements

- iOS 14.0+
- Swift 5.9+
- Xcode 15+

## Architecture

netfox works by registering a custom `URLProtocol` subclass (`NFXProtocol`) and swizzling `URLSessionConfiguration.default` and `.ephemeral` to inject it into every URLSession. This means it captures traffic from all networking libraries automatically — no integration code needed.

## Author

**Azimjon Abdurasulov** — iOS Developer
- Website: [azimjondev.uz](https://azimjondev.uz)
- GitHub: [@azimxxm](https://github.com/azimxxm)

## Credits

Original library by [kasketis/netfox](https://github.com/kasketis/netfox). Special thanks to [tbaranes](https://github.com/tbaranes) and [vincedev](https://github.com/vincedev) for their OSX contributions.

## License

MIT License. See [LICENSE](LICENSE) for details.
