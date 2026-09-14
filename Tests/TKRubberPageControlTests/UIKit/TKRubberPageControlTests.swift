//
//  TKRubberPageControlTests.swift
//  TKRubberPageControl
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import QuartzCore
import UIKit
import XCTest

@testable import TKRubberPageControl

final class TKRubberPageControlTests: XCTestCase {

  private let config = TKRubberPageControlConfig()
  private let frame = CGRect(x: 0, y: 0, width: 240, height: 100)

  private func makeControl(count: Int = 5) -> TKRubberPageControl {
    TKRubberPageControl(frame: frame, count: count, config: config)
  }

  /// `UIControl.sendActions(for:)` only delivers target actions when the
  /// control is attached to a window.
  private func attachToWindow(_ control: TKRubberPageControl) {
    let window: UIWindow
    if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first {
      window = UIWindow(windowScene: scene)
    } else {
      window = UIWindow(frame: UIScreen.main.bounds)
    }
    window.frame = UIScreen.main.bounds
    window.addSubview(control)
    window.makeKeyAndVisible()
  }

  // MARK: - Helpers

  private var metrics: RubberPageControlMetrics {
    config.metrics(pageCount: 5)
  }

  private func expectedCenter(page: Int, in control: TKRubberPageControl) -> CGPoint {
    config.metrics(pageCount: control.numberOfPage).center(ofPage: page, in: control.bounds.size)
  }

  /// Small bubble layers sorted by x position.
  private func smallBubbles(of control: TKRubberPageControl) -> [CALayer] {
    (control.layer.sublayers ?? [])
      .filter { $0.zPosition == 1 }
      .sorted { $0.position.x < $1.position.x }
  }

  private func assertCanonicalPositions(_ control: TKRubberPageControl, line: UInt = #line) {
    let bubbles = smallBubbles(of: control)
    let slots = config.metrics(pageCount: control.numberOfPage)
      .bubbleSlots(forSelection: control.currentIndex)
    XCTAssertEqual(bubbles.count, slots.count, line: line)
    for (bubble, slot) in zip(bubbles, slots) {
      let expected = config.metrics(pageCount: control.numberOfPage)
        .center(ofPage: slot, in: control.bounds.size)
      XCTAssertEqual(bubble.position.x, expected.x, accuracy: 0.5, line: line)
      XCTAssertEqual(bubble.position.y, expected.y, accuracy: 0.5, line: line)
    }
  }

  // MARK: - Index handling

  func testIndexIsClamped() {
    let control = makeControl(count: 5)
    control.currentIndex = 99
    XCTAssertEqual(control.currentIndex, 4)
    control.currentIndex = -5
    XCTAssertEqual(control.currentIndex, 0)
  }

  func testProgrammaticIndexChangeFiresEvents() {
    let control = makeControl(count: 5)
    attachToWindow(control)
    var closureValues = [Int]()
    control.valueChange = { closureValues.append($0) }

    let target = EventTarget()
    control.addTarget(target, action: #selector(EventTarget.valueChanged(_:)), for: .valueChanged)
    // Delivery of target actions requires a foreground application scene,
    // which the test runner does not provide, so only the registration is
    // checked here. The actual delivery is covered by the demo app.
    XCTAssertEqual(
      control.actions(forTarget: target, forControlEvent: .valueChanged), ["valueChanged:"])

    control.currentIndex = 3

    XCTAssertEqual(closureValues, [3])
    XCTAssertEqual(control.currentIndex, 3)
  }

  func testSameIndexDoesNotFireEvents() {
    let control = makeControl(count: 5)
    var closureValues = [Int]()
    control.valueChange = { closureValues.append($0) }

    control.currentIndex = 0
    XCTAssertEqual(closureValues, [])
  }

  func testChangingNumberOfPagesResetsIndex() {
    let control = makeControl(count: 5)
    control.currentIndex = 4
    var closureValues = [Int]()
    control.valueChange = { closureValues.append($0) }

    control.numberOfPage = 3
    XCTAssertEqual(control.numberOfPage, 3)
    XCTAssertEqual(control.currentIndex, 0)
    XCTAssertEqual(closureValues, [0])
  }

  func testNumberOfPagesIsAtLeastOne() {
    let control = makeControl(count: 5)
    control.numberOfPage = 0
    XCTAssertEqual(control.numberOfPage, 1)
    control.numberOfPage = -3
    XCTAssertEqual(control.numberOfPage, 1)
  }

  // MARK: - Layout consistency (regression tests for the drifting bubbles bug)

  func testInitialBubbleLayoutMatchesSlots() {
    assertCanonicalPositions(makeControl(count: 5))
  }

  func testSingleStepKeepsBubblesCanonical() {
    let control = makeControl(count: 5)
    for index in [1, 2, 1, 0] {
      control.currentIndex = index
      assertCanonicalPositions(control)
    }
  }

  func testMultiStepJumpKeepsBubblesCanonical() {
    let control = makeControl(count: 5)
    for index in [4, 1, 3] {
      control.currentIndex = index
      assertCanonicalPositions(control)
    }
  }

  func testRapidChangesKeepBubblesCanonical() {
    // Regression test: in the old implementation overlapping animations
    // accumulated relative offsets and the bubbles drifted away.
    let control = makeControl(count: 6)
    for index in [3, 5, 0, 4, 2, 2, 5, 1, 0] {
      control.currentIndex = index
      XCTAssertEqual(control.currentIndex, index)
      assertCanonicalPositions(control)
    }
  }

  func testTapSelectsNearestPage() {
    let control = makeControl(count: 5)
    for page in 0..<5 {
      control.selectPage(at: expectedCenter(page: page, in: control))
      XCTAssertEqual(control.currentIndex, page, "tap on page \(page)")
    }
    let between = CGPoint(
      x: (expectedCenter(page: 1, in: control).x + expectedCenter(page: 2, in: control).x) / 2,
      y: expectedCenter(page: 1, in: control).y
    )
    control.selectPage(at: between)
    XCTAssertTrue([1, 2].contains(control.currentIndex))
  }

  func testTapOutsideBoundsIsIgnored() {
    let control = makeControl(count: 5)
    control.selectPage(at: CGPoint(x: -50, y: 50))
    XCTAssertEqual(control.currentIndex, 0)
    control.selectPage(at: CGPoint(x: control.bounds.width + 50, y: 50))
    XCTAssertEqual(control.currentIndex, 0)
  }

  // MARK: - Config / layout

  func testStyleConfigChangeRebuildsAndResetsIndex() {
    let control = makeControl(count: 5)
    control.currentIndex = 3

    var newConfig = config
    newConfig.smallBubbleColor = .green
    control.styleConfig = newConfig

    XCTAssertEqual(control.currentIndex, 0)
    let bubbles = smallBubbles(of: control)
    XCTAssertEqual(bubbles.count, 4)
    let fill = (bubbles.first?.sublayers?.first as? CAShapeLayer)?.fillColor
    XCTAssertEqual(fill, UIColor.green.cgColor)
    assertCanonicalPositions(control)
  }

  func testFrameChangeReappliesLayout() {
    let control = makeControl(count: 5)
    control.currentIndex = 2
    control.frame = CGRect(x: 0, y: 0, width: 400, height: 120)
    control.layoutIfNeeded()
    assertCanonicalPositions(control)
    let big = control.layer.sublayers?.first { $0.zPosition == 100 }
    let expected = expectedCenter(page: 2, in: control)
    XCTAssertEqual(big?.position.x ?? -1, expected.x, accuracy: 0.5)
  }

  func testSinglePageControl() {
    let control = makeControl(count: 1)
    XCTAssertEqual(smallBubbles(of: control).count, 0)
    control.currentIndex = 5
    XCTAssertEqual(control.currentIndex, 0)
  }

  func testIntrinsicContentSize() {
    let control = makeControl(count: 5)
    XCTAssertEqual(control.intrinsicContentSize, metrics.intrinsicSize)
  }

  // MARK: - Accessibility

  func testAccessibility() {
    let control = makeControl(count: 5)
    XCTAssertEqual(control.accessibilityTraits, .adjustable)
    XCTAssertEqual(control.accessibilityValue, "Page 1 of 5")
    control.accessibilityIncrement()
    XCTAssertEqual(control.currentIndex, 1)
    XCTAssertEqual(control.accessibilityValue, "Page 2 of 5")
    control.accessibilityDecrement()
    XCTAssertEqual(control.currentIndex, 0)
  }
}

/// Simple target-action spy.
private final class EventTarget: NSObject {
  var hitCount = 0

  @objc func valueChanged(_ sender: TKRubberPageControl) {
    hitCount += 1
  }
}
