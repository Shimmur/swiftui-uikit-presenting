# UIViewControllerPresenting

This package provides a custom SwiftUI view modifier and component that can be used to present UIKit views from a SwiftUI view using UIKit presentation APIs. It can also be used to present other SwiftUI views by wrapping them in a `UIHostingController` giving you access to presentation APIs that are not available in SwiftUI prior to iOS 16, such as sheet detents.

## SafariWebView

This package also contains a standalone library built on top of `UIViewControllerPresenting` which allows you to present a Safari web view controller from a SwiftUI view using a binding-based interface.

## Examples

For further examples of how this library can be used, please see the Examples directory.

## Documentation

* [API Documentation (main branch)](https://shimmur.github.io/swiftui-uikit-presenting/main/documentation/uiviewcontrollerpresenting/)

## Copyright and License

This library was developed out of the work on our app here at [Community.com](http://community.com) and is made available under the [Apache 2.0 license](LICENSE).

```
Copyright 2022 Community.com, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
