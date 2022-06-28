# Presenting UIKit view controllers from SwiftUI

This article provides a basic overview for wrapping your own UIKit controller - for more examples see some of the examples provided as part of the Swift package.

## Overview

`UIViewControllerPresenting` acts as a building block for creating APIs - usually in the form of SwiftUI view modifiers - for presenting either built-in or your own custom UIKit view controllers.

## Wrapping the view controller

In this example, we have a custom `WidgetViewController` that is intended to be used as a reusable component throughout our app. Most of our app is written in SwiftUI and so we need an easy way of presenting the widget view from anywhere within our SwiftUI view hierarchy. 

Additionally, the view is intended to be presented as a half sheet which we cannot accomplish in SwiftUI prior to iOS 16 without using a third-party library.

Using `UIViewControllerPresenting` we can create a binding-based SwiftUI view modifier that will display our widget view automatically. This is the final API we intend to build:

```swift
struct ContentView: View {
  @State var showingWidgetView: Bool = false

  var body: some View {
    Text("Hello World")
      .widgetView(isPresented: $showingWidgetView)
  }
}
```

First, we need to be able to create an instance of `UIViewControllerPresenting` that will display our custom `WidgetViewController` - a good place to define this is in a static function in a constrained extension:

```swift
extension UIViewControllerPresenting where Controller == WidgetViewController {
  static func widgetViewController(isPresented: Binding<Bool>) -> Self {
    ...
  }
}
```

Because this is not the public API that we intend to expose to users, it is fine to leave this defined as `internal` or even `private`.

Next, we need to initialize and return a `UIViewControllerPresenting` instance - the `makeUIViewController` parameter takes a closure that should return an instance of the UIViewController that we want to present: 

```swift
extension UIViewControllerPresenting where Controller == WidgetViewController {
  static func widgetViewController(isPresented: Binding<Bool>) {
    .init(
      isPresented: isPresented,
      makeUIViewController: { context, dismissHandler in
        let viewController = WidgetViewController()
        // Ensure the view is presented as a half sheet
        if let sheet = viewController.sheetPresentationController {
          sheet.detents = [.medium()]
        }
        return viewController
      }
    )
  }
}
```

Our custom controller is very simple, but it does have a completion handler API that will get called when a particular action happens and it is important for us to call the `dismissHandler` provided to the `makeUIViewController` closure whenever a view controller can be dismissed programatically. For delegate-based APIs, you will need to use a coordinator however as our controller uses a callback API we can handle it right here:

```swift
extension UIViewControllerPresenting where Controller == WidgetViewController {
  static func widgetViewController(isPresented: Binding<Bool>) {
    .init(
      isPresented: isPresented,
      makeUIViewController: { context, dismissHandler in
        let viewController = WidgetViewController()
        ...
        viewController.onCompletion = { dismissHandler() }
        return viewController
      }
    )
  }
}
```

Finally, in order to actually use this in a SwiftUI view, we need to embed it in the background. We will wrap this boilerplate up in an extension method on `View` and this will provide our public API. Alternatively, you could create a view modifier.

```swift
public extension View {
  func widgetView(isPresented: Binding<Bool>) -> some View {
    background(
      UIViewControllerPresenting.widgetViewController(isPresented: isPresented)
    )
  }
}
```

Now, whenever we call this on a SwiftUI view and pass it a binding to some boolean state, the view will be automatically presented whenever the state becomes true:


```swift
struct ContentView: View {
  @State var showingWidgetView: Bool = false

  var body: some View {
    Button { 
      showingWidgetView = true
    } label: {
        Text("Open Widget View")
    }
    .widgetView(isPresented: $showingWidgetView)
  }
}
```
