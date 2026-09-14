//
//  RubberPageControlMetricsTests.swift
//  TKRubberPageControl
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import CoreGraphics
import XCTest

@testable import TKRubberPageControl

final class RubberPageControlMetricsTests: XCTestCase {

  private let size = CGSize(width: 220, height: 100)

  private func makeMetrics(pageCount: Int = 5) -> RubberPageControlMetrics {
    RubberPageControlMetrics(
      pageCount: pageCount,
      smallBubbleSize: 16,
      mainBubbleSize: 40,
      bubbleSpacing: 12,
      verticalPadding: 8
    )
  }

  func testPageCountIsAtLeastOne() {
    XCTAssertEqual(makeMetrics(pageCount: 0).pageCount, 1)
    XCTAssertEqual(makeMetrics(pageCount: -3).pageCount, 1)
  }

  func testDerivedSizes() {
    let metrics = makeMetrics()
    XCTAssertEqual(metrics.pageSpacing, 28)
    XCTAssertEqual(metrics.barHeight, 32)
    XCTAssertEqual(metrics.bigBubbleDiameter, 24)
    XCTAssertEqual(metrics.barWidth, 3 * 16 + 40 + 5 * 12)
    XCTAssertEqual(metrics.intrinsicSize.width, metrics.barWidth + 20)
    XCTAssertEqual(metrics.intrinsicSize.height, 40)
  }

  func testBarWidthForSinglePage() {
    let metrics = makeMetrics(pageCount: 1)
    XCTAssertEqual(metrics.barWidth, 40)
    XCTAssertEqual(metrics.pageSpacing, 28)
  }

  func testBubbleSlotsQueueBehindTheSelection() {
    let metrics = makeMetrics()
    XCTAssertEqual(metrics.bubbleSlots(forSelection: 0), [1, 2, 3, 4])
    XCTAssertEqual(metrics.bubbleSlots(forSelection: 2), [0, 1, 3, 4])
    XCTAssertEqual(metrics.bubbleSlots(forSelection: 4), [0, 1, 2, 3])
  }

  func testBubbleSlotsForSinglePageIsEmpty() {
    XCTAssertEqual(makeMetrics(pageCount: 1).bubbleSlots(forSelection: 0), [])
  }

  func testBubbleSlotsCoverEveryUnselectedPage() {
    let metrics = makeMetrics(pageCount: 6)
    for selection in 0..<metrics.pageCount {
      let slots = metrics.bubbleSlots(forSelection: selection)
      XCTAssertEqual(slots.count, metrics.pageCount - 1)
      XCTAssertFalse(slots.contains(selection))
      XCTAssertEqual(Set(slots), Set(0..<metrics.pageCount).subtracting([selection]))
    }
  }

  func testClamp() {
    let metrics = makeMetrics()
    XCTAssertEqual(metrics.clamp(-1), 0)
    XCTAssertEqual(metrics.clamp(2), 2)
    XCTAssertEqual(metrics.clamp(99), 4)
  }

  func testCenterIsEvenlySpaced() {
    let metrics = makeMetrics()
    let first = metrics.center(ofPage: 0, in: size)
    for page in 1..<metrics.pageCount {
      let center = metrics.center(ofPage: page, in: size)
      XCTAssertEqual(center.y, first.y, accuracy: 0.001)
      XCTAssertEqual(center.x - first.x, metrics.pageSpacing * CGFloat(page), accuracy: 0.001)
    }
  }

  func testBarAndBubblesAreVerticallyCentered() {
    let metrics = makeMetrics()
    let bar = metrics.barRect(in: size)
    XCTAssertEqual(bar.midX, size.width / 2, accuracy: 0.001)
    XCTAssertEqual(bar.midY, size.height / 2, accuracy: 0.001)

    // Every bubble shares the vertical center of the bar.
    for page in 0..<metrics.pageCount {
      XCTAssertEqual(metrics.center(ofPage: page, in: size).y, bar.midY, accuracy: 0.001)
    }
  }

  func testFirstBubbleCenterMatchesBarOrigin() {
    // The first page center sits half the big bubble inside the bar's leading
    // edge, and every following page is one `pageSpacing` further right.
    let metrics = makeMetrics()
    let bar = metrics.barRect(in: size)
    let first = metrics.center(ofPage: 0, in: size)
    XCTAssertEqual(first.x, bar.minX + metrics.mainBubbleSize / 2, accuracy: 0.001)
  }

  func testPageAtXResolvesNearestPage() {
    let metrics = makeMetrics()
    for page in 0..<metrics.pageCount {
      let center = metrics.center(ofPage: page, in: size)
      XCTAssertEqual(metrics.page(atX: center.x, in: size), page)
    }

    // Half way between two centers rounds to the nearest page.
    let second = metrics.center(ofPage: 1, in: size)
    let third = metrics.center(ofPage: 2, in: size)
    XCTAssertEqual(metrics.page(atX: (second.x + third.x) / 2, in: size), 2)
  }

  func testPageAtXRejectsPointsOutsideTheBar() {
    let metrics = makeMetrics()
    let first = metrics.center(ofPage: 0, in: size)
    XCTAssertNil(metrics.page(atX: first.x - metrics.pageSpacing, in: size))
    XCTAssertNil(metrics.page(atX: size.width + 50, in: size))
  }
}
