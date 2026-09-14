# TKRubberPageControl

> A rubber animation page control for UIKit and SwiftUI.

![Demo](Demo/Resources/demo.gif)

English | [中文说明](./README.zh-CN.md)

## Features

- The original rubber animation: the big bubble travels between pages, the
  small bubbles hop along a half circle under the bar and squash in flight.
- A `UIControl` based UIKit implementation, source compatible with 1.x.
- A native, `Binding` driven SwiftUI implementation with no `UIViewRepresentable`.
- Both implementations share the same layout model, so they look identical.
- Style configuration, dark mode support and basic accessibility.

## Requirements

- iOS 13.0+
- Swift 5.9+
- Xcode 15+

## Installation

### Swift Package Manager

Add the package in Xcode via **File → Add Package Dependencies**:

```
https://github.com/TBXark/TKRubberIndicator
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/TBXark/TKRubberIndicator.git", from: "2.0.0")
]
```

### CocoaPods

```ruby
pod 'TKRubberPageControl', '~> 2.0'
```

## Usage

### UIKit

```swift
import TKRubberPageControl
import UIKit

final class ViewController: UIViewController {

    private let pageControl = TKRubberPageControl(frame: .zero, count: 5)

    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.addTarget(
            self,
            action: #selector(pageChanged(_:)),
            for: .valueChanged
        )
        pageControl.valueChange = { index in
            print("page is \(index)")
        }

        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.widthAnchor.constraint(equalToConstant: 220),
            pageControl.heightAnchor.constraint(equalToConstant: 100),
        ])
    }

    @objc private func pageChanged(_ sender: TKRubberPageControl) {
        print("page is \(sender.currentIndex)")
    }
}
```

Assigning `currentIndex` animates and fires the events too. Assigning
`numberOfPage` or `styleConfig` rebuilds the indicator and resets the selection
to `0`:

```swift
pageControl.currentIndex = 2   // animates to page 2
pageControl.numberOfPage = 4   // rebuilds, back to page 0
```

### SwiftUI

```swift
import SwiftUI
import TKRubberPageControl

struct ContentView: View {
    @State private var page = 0

    var body: some View {
        RubberPageControl(selection: $page, pageCount: 5)
            .frame(width: 220, height: 100)
    }
}
```

The selection lives in the binding, so the control updates itself whenever the
state changes and writes back when the user taps it. On iOS 15 and later those
changes animate automatically; on iOS 13 and 14 wrap the assignment in
`withAnimation`:

```swift
withAnimation {
    page = 3
}
```

## Customization

`TKRubberPageControlConfig` and `RubberPageControlStyle` expose the same
options; both default to the colours and sizes of the 1.x releases.

| Option | Description | Default |
|---|---|---|
| `smallBubbleSize` | Diameter of the small bubbles | `16` |
| `mainBubbleSize` | Diameter of the bump behind the selected bubble | `40` |
| `bubbleXOffsetSpace` / `bubbleSpacing` | Spacing between bubbles | `12` |
| `bubbleYOffsetSpace` / `verticalPadding` | Vertical padding of the bar | `8` |
| `animationDuration` | Page change animation duration | `0.2` |
| `backgroundColor` / `barColor` | Bar and bump color | plum |
| `smallBubbleColor` | Small bubble color | coral |
| `bigBubbleColor` | Big bubble color | crimson |

UIKit:

```swift
var config = TKRubberPageControlConfig()
config.backgroundColor = .systemIndigo
config.bigBubbleColor = .systemYellow
let pageControl = TKRubberPageControl(frame: frame, count: 5, config: config)
```

SwiftUI:

```swift
RubberPageControl(
    selection: $page,
    pageCount: 5,
    style: RubberPageControlStyle(barColor: .indigo, bigBubbleColor: .yellow)
)
```

## Demo

The demo app shows the UIKit and the SwiftUI control side by side. It is
generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen) and consumes
the library as a local Swift package:

```bash
./Scripts/demo.sh
```

Or run `make demo`.

## License

TKRubberPageControl is available under the MIT license. See [LICENSE](./LICENSE).
