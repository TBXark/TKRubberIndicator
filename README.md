# TKRubberIndicator
> A rubber animation pagecontrol

[![Swift Version][swift-image]][swift-url]
[![License MIT][license-image]][license-url]
[![CocoaPods][cocoapods-image]][cocoapods-url]
[![Carthage compatible][carthage-image]][carthage-url]
[![Support](https://img.shields.io/badge/support-iOS%208%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)


![](example.gif)

## Requirements

- Swift 3.0
- iOS 8.0+
- Xcode 8.0

## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `TKRubberPageControl` by adding it to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!
pod 'TKRubberPageControl'
```

To get the full benefits import `TKRubberPageControl` wherever you import UIKit

``` swift
import UIKit
import TKRubberPageControl
```
#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios) to add `$(SRCROOT)/Carthage/Build/iOS/TKRubberPageControl.framework` to an iOS project.

```
github "tbxark/TKRubberPageControl"
```
#### Manually
1. Download and drop ```TKRubberPageControl.swift``` in your project.  
2. Congratulations!  

## Usage example

You can use closure or Target-Action to listen control event

```swift
class ViewController: UIViewController {

    let page = TKRubberIndicator(frame: CGRectMake(100, 100, 200, 100), count: 6)

    override func viewDidLoad() {
        super.viewDidLoad()


        self.view.backgroundColor = UIColor(red:0.553,  green:0.376,  blue:0.549, alpha:1)
        page.center = self.view.center
        page.valueChange = {(num) -> Void in
            print("Closure : Page is \(num)")
        }
        page.addTarget(self, action: "targetActionValueChange:", forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(page)

        page.numberOfpage = 2
    }

    @IBAction func pageCountChange(sender: UISegmentedControl) {
        page.numberOfpage = (sender.selectedSegmentIndex + 1) * 2
    }
    func targetActionValueChange(page:TKRubberIndicator){
        print("Target-Action : Page is \(page.currentIndex)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

```

### Base

|Key | Usage| |
|---|---|---|
|smallBubbleSize|未选中小球尺寸|unselect  small ball size|
|mainBubbleSize|选中大球尺寸|select big ball size|
|bubbleXOffsetSpace|小球间距|The distance between the ball|
|bubbleYOffsetSpace|纵向间距|bubble Y Offset Space|
|animationDuration|动画时长|animation duration|
|backgroundColor|背景颜色|control background color|
|smallBubbleColor|小球颜色|unselect small ball color|
|mainBubbleColor|大球颜色|select big ball color|


## Release History

* 1.3.1
  Bug Fixed

* 1.3.0
  Support Swift 3.0

* 1.0.5
  Fix bug, add Cocoapod and Carthage support

* 1.0.4
  Complete basic functions

## Contribute

We would love for you to contribute to **TKRubberPageControl**, check the ``LICENSE`` file for more info.

## Meta

TBXark – [@tbxark](https://twitter.com/tbxark) – tbxark@outlook.com

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/TBXark](https://github.com/TBXark)

[swift-image]:https://img.shields.io/badge/swift-3.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[cocoapods-image]: http://img.shields.io/cocoapods/v/TKRubberPageControl.svg?style=flat
[cocoapods-url]: http://cocoapods.org/?q=TKRubberPageControl
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[carthage-url]:https://github.com/Carthage/Carthage
[carthage-image]: https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat
