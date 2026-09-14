//
//  RubberPageControlStyleTests.swift
//  TKRubberPageControl
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import SwiftUI
import XCTest

@testable import TKRubberPageControl

final class RubberPageControlStyleTests: XCTestCase {

  func testDefaultStyleMatchesUIKitDefaults() {
    let style = RubberPageControlStyle()
    let config = TKRubberPageControlConfig()
    XCTAssertEqual(style.smallBubbleSize, config.smallBubbleSize)
    XCTAssertEqual(style.mainBubbleSize, config.mainBubbleSize)
    XCTAssertEqual(style.bubbleSpacing, config.bubbleXOffsetSpace)
    XCTAssertEqual(style.verticalPadding, config.bubbleYOffsetSpace)
    XCTAssertEqual(style.animationDuration, config.animationDuration)
  }

  func testStyleBuildsTheSharedMetrics() {
    let style = RubberPageControlStyle(
      smallBubbleSize: 10,
      mainBubbleSize: 30,
      bubbleSpacing: 6,
      verticalPadding: 4,
      animationDuration: 0.3
    )
    let metrics = RubberPageControlMetrics(style: style, pageCount: 4)
    XCTAssertEqual(metrics.pageCount, 4)
    XCTAssertEqual(metrics.smallBubbleSize, 10)
    XCTAssertEqual(metrics.mainBubbleSize, 30)
    XCTAssertEqual(metrics.bubbleSpacing, 6)
    XCTAssertEqual(metrics.verticalPadding, 4)
    XCTAssertEqual(metrics.pageSpacing, 16)
    XCTAssertEqual(metrics.bigBubbleDiameter, 22)
  }

  func testStyleMetricsMatchTheUIKitGeometry() {
    let style = RubberPageControlStyle()
    let config = TKRubberPageControlConfig()
    let styleMetrics = RubberPageControlMetrics(style: style, pageCount: 5)
    let configMetrics = config.metrics(pageCount: 5)
    XCTAssertEqual(styleMetrics.barWidth, configMetrics.barWidth)
    XCTAssertEqual(styleMetrics.barHeight, configMetrics.barHeight)
    XCTAssertEqual(
      styleMetrics.intrinsicSize,
      configMetrics.intrinsicSize
    )
  }
}
