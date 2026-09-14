//
//  SceneDelegate.swift
//  TKRubberPageControlDemo
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = DemoTabBarController()
    window.makeKeyAndVisible()
    self.window = window
  }
}
