//
//  DemoTabBarController.swift
//  TKRubberPageControlDemo
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import SwiftUI
import UIKit

/// Root shell of the demo. It hosts the UIKit and the SwiftUI showcase side by
/// side so both implementations can be compared from the same app.
final class DemoTabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let uikitDemo = UIKitDemoViewController()
    uikitDemo.tabBarItem = UITabBarItem(
      title: "UIKit",
      image: UIImage(systemName: "square.on.circle"),
      selectedImage: UIImage(systemName: "square.on.circle.fill")
    )

    let swiftUIDemo = UIHostingController(rootView: SwiftUIDemoView())
    swiftUIDemo.navigationItem.title = "TKRubberPageControl"
    swiftUIDemo.tabBarItem = UITabBarItem(
      title: "SwiftUI",
      image: UIImage(systemName: "swift"),
      selectedImage: UIImage(systemName: "swift")
    )

    viewControllers = [
      UINavigationController(rootViewController: uikitDemo),
      UINavigationController(rootViewController: swiftUIDemo),
    ]
  }
}
