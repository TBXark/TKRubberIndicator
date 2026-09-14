//
//  PageMotionTests.swift
//  TKRubberPageControl
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import CoreGraphics
import SwiftUI
import XCTest

@testable import TKRubberPageControl

final class PageMotionTests: XCTestCase {

  private let cellSize = CGSize(width: 40, height: 40)
  private let baseX: CGFloat = -80
  private let baseY: CGFloat = -20
  private let spacing: CGFloat = 28

  private func makeMotion(
    page: CGFloat,
    from: CGFloat,
    to: CGFloat,
    squash: CGFloat = 1,
    dip: CGFloat = 0
  ) -> PageMotion {
    PageMotion(
      page: page,
      from: from,
      to: to,
      spacing: spacing,
      baseX: baseX,
      baseY: baseY,
      squashX: squash,
      squashY: squash,
      dip: dip
    )
  }

  /// Center of the cell after the transform is applied in the cell's own
  /// coordinate space.
  private func transformedCenter(_ motion: PageMotion) -> CGPoint {
    let rect = CGRect(origin: .zero, size: cellSize).applying(motion.transform(in: cellSize))
    return CGPoint(x: rect.midX, y: rect.midY)
  }

  /// Center relative to the resting position on page 0, so the assertions do
  /// not depend on the local-frame origin.
  private func offsetFromPageZero(_ motion: PageMotion) -> CGPoint {
    let origin = transformedCenter(makeMotion(page: 0, from: 0, to: 0))
    let point = transformedCenter(motion)
    return CGPoint(x: point.x - origin.x, y: point.y - origin.y)
  }

  func testRestPositionsAreEvenlySpaced() {
    for page in 0..<5 {
      let motion = makeMotion(page: CGFloat(page), from: CGFloat(page), to: CGFloat(page))
      let offset = offsetFromPageZero(motion)
      XCTAssertEqual(offset.x, spacing * CGFloat(page), accuracy: 0.001)
      XCTAssertEqual(offset.y, 0, accuracy: 0.001)
    }
  }

  func testProgressRunsFromZeroToOne() {
    XCTAssertEqual(makeMotion(page: 2, from: 2, to: 5).progress, 0, accuracy: 0.001)
    XCTAssertEqual(makeMotion(page: 3.5, from: 2, to: 5).progress, 0.5, accuracy: 0.001)
    XCTAssertEqual(makeMotion(page: 5, from: 2, to: 5).progress, 1, accuracy: 0.001)
  }

  func testProgressAlsoWorksWhenMovingBackwards() {
    XCTAssertEqual(makeMotion(page: 5, from: 5, to: 1).progress, 0, accuracy: 0.001)
    XCTAssertEqual(makeMotion(page: 3, from: 5, to: 1).progress, 0.5, accuracy: 0.001)
    XCTAssertEqual(makeMotion(page: 1, from: 5, to: 1).progress, 1, accuracy: 0.001)
  }

  func testProgressIsClampedOutsideTheTransition() {
    XCTAssertEqual(makeMotion(page: 0, from: 2, to: 5).progress, 0, accuracy: 0.001)
    XCTAssertEqual(makeMotion(page: 9, from: 2, to: 5).progress, 1, accuracy: 0.001)
  }

  func testProgressFallsBackToPageFractionWhenOriginIsUnknown() {
    // Used at rest and on iOS 13, where the origin cannot be tracked: the
    // squash then happens once per page crossed.
    XCTAssertEqual(makeMotion(page: 0, from: 0, to: 0).progress, 0, accuracy: 0.001)
    XCTAssertEqual(makeMotion(page: 3, from: 3, to: 3).progress, 0, accuracy: 0.001)
    XCTAssertEqual(makeMotion(page: 0.5, from: 0.5, to: 0.5).progress, 0.5, accuracy: 0.001)
    XCTAssertEqual(makeMotion(page: 2.5, from: 2.5, to: 2.5).progress, 0.5, accuracy: 0.001)
  }

  func testTravelIsMonotonicAcrossAStep() {
    // Regression test: with the squash and the travel driven by separate
    // transforms the cell used to shoot past the destination and snap back.
    var previous = -CGFloat.greatestFiniteMagnitude
    for step in 0...20 {
      let page = CGFloat(step) / 20
      let offset = offsetFromPageZero(
        makeMotion(page: page, from: 0, to: 1, squash: 1 / 3)
      ).x
      XCTAssertGreaterThanOrEqual(offset, previous - 0.001, "overshoot at page \(page)")
      previous = offset
    }
    let landed = offsetFromPageZero(makeMotion(page: 1, from: 0, to: 1, squash: 1 / 3)).x
    XCTAssertEqual(landed, spacing, accuracy: 0.001)
  }

  func testTravelIsMonotonicAcrossAMultiPageJump() {
    var previous = -CGFloat.greatestFiniteMagnitude
    for step in 0...40 {
      let page = CGFloat(step) / 10
      let offset = offsetFromPageZero(
        makeMotion(page: page, from: 0, to: 4, squash: 1 / 3)
      ).x
      XCTAssertGreaterThanOrEqual(offset, previous - 0.001, "overshoot at page \(page)")
      previous = offset
    }
    let landed = offsetFromPageZero(makeMotion(page: 4, from: 0, to: 4, squash: 1 / 3)).x
    XCTAssertEqual(landed, spacing * 4, accuracy: 0.001)
  }

  func testSquashIsASingleLobeAcrossAMultiPageJump() {
    // A four page jump must squash once, half way through, not once per page
    // crossed on the way: the scale decreases smoothly to the minimum and grows
    // back, with no second dip in between.
    func scale(atProgress progress: CGFloat) -> CGFloat {
      let motion = makeMotion(page: 4 * progress, from: 0, to: 4, squash: 1 / 3)
      let rect = CGRect(origin: .zero, size: cellSize).applying(motion.transform(in: cellSize))
      return rect.width / cellSize.width
    }

    var previous = scale(atProgress: 0)
    XCTAssertEqual(previous, 1, accuracy: 0.001)
    for step in 1...50 {
      let progress = CGFloat(step) / 100
      let current = scale(atProgress: progress)
      if progress <= 0.5 {
        XCTAssertLessThanOrEqual(current, previous + 0.001, "not shrinking at \(progress)")
      } else {
        XCTAssertGreaterThanOrEqual(current, previous - 0.001, "second dip at \(progress)")
      }
      previous = current
    }
    XCTAssertEqual(scale(atProgress: 0.5), 1 / 3, accuracy: 0.001)
    XCTAssertEqual(scale(atProgress: 1), 1, accuracy: 0.001)
  }

  func testSquashDoesNotShiftTheCenter() {
    // The cell must stay centered on its travel line while it squashes,
    // however far it is from the coordinate origin.
    for page in [CGFloat(0), 0.25, 0.5, 0.75, 1] {
      let wide = offsetFromPageZero(makeMotion(page: page, from: 0, to: 1))
      let squashed = offsetFromPageZero(
        makeMotion(page: page, from: 0, to: 1, squash: 1 / 3)
      )
      XCTAssertEqual(squashed.x, wide.x, accuracy: 0.001)
      XCTAssertEqual(squashed.y, wide.y, accuracy: 0.001)
    }
  }

  func testSquashScalesTheCell() {
    let motion = makeMotion(page: 0.5, from: 0, to: 1, squash: 0.5)
    let projected = CGRect(origin: .zero, size: cellSize).applying(motion.transform(in: cellSize))
    XCTAssertEqual(projected.width, cellSize.width * 0.5, accuracy: 0.001)
    XCTAssertEqual(projected.height, cellSize.height * 0.5, accuracy: 0.001)
  }

  func testTravelIsLinearInPage() {
    let atStart = offsetFromPageZero(makeMotion(page: 0, from: 0, to: 1, squash: 0.5)).x
    let midway = offsetFromPageZero(makeMotion(page: 0.5, from: 0, to: 1, squash: 0.5)).x
    let atEnd = offsetFromPageZero(makeMotion(page: 1, from: 0, to: 1, squash: 0.5)).x
    XCTAssertEqual(midway - atStart, spacing / 2, accuracy: 0.001)
    XCTAssertEqual(atEnd - midway, spacing / 2, accuracy: 0.001)
  }

  func testDipOnlyLowersThePartMidTransition() {
    let dip: CGFloat = 14
    let resting = offsetFromPageZero(makeMotion(page: 0, from: 0, to: 1, dip: dip)).y
    let landed = offsetFromPageZero(makeMotion(page: 1, from: 0, to: 1, dip: dip)).y
    let midway = offsetFromPageZero(makeMotion(page: 0.5, from: 0, to: 1, dip: dip)).y
    XCTAssertEqual(resting, 0, accuracy: 0.001)
    XCTAssertEqual(landed, 0, accuracy: 0.001)
    XCTAssertEqual(midway, dip, accuracy: 0.001)
  }
}
