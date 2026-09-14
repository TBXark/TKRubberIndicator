//
//  DemoData.swift
//  TKRubberPageControlDemo
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import CoreGraphics

/// Data shared by the UIKit and the SwiftUI demo so both showcase the same
/// capabilities.
enum DemoData {
  /// Page counts offered by the picker in both demos.
  static let pageCounts = [3, 4, 5, 6]
  /// Page count selected when the demo starts.
  static let defaultPageCount = 5
  /// Size of the default control.
  static let controlSize = CGSize(width: 220, height: 100)
}
