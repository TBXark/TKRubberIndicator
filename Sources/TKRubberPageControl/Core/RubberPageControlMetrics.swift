//
//  RubberPageControlMetrics.swift
//  TKRubberPageControl
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import CoreGraphics

/// Layout and selection model shared by the UIKit and SwiftUI implementations.
///
/// The geometry follows the 1.x implementation: a rounded bar with one slot per
/// page, a big bubble for the selected page and a small bubble in every other
/// slot. Both implementations derive their positions from this type, which is
/// what keeps them pixel-for-pixel identical.
struct RubberPageControlMetrics: Equatable {

  /// Number of pages, always at least one.
  let pageCount: Int
  /// Diameter of the small bubbles.
  let smallBubbleSize: CGFloat
  /// Diameter of the circular bump behind the big bubble.
  let mainBubbleSize: CGFloat
  /// Horizontal spacing between two bubbles.
  let bubbleSpacing: CGFloat
  /// Vertical padding of the bar around the small bubbles.
  let verticalPadding: CGFloat

  init(
    pageCount: Int,
    smallBubbleSize: CGFloat,
    mainBubbleSize: CGFloat,
    bubbleSpacing: CGFloat,
    verticalPadding: CGFloat
  ) {
    self.pageCount = max(1, pageCount)
    self.smallBubbleSize = smallBubbleSize
    self.mainBubbleSize = mainBubbleSize
    self.bubbleSpacing = bubbleSpacing
    self.verticalPadding = verticalPadding
  }

  /// Distance between the centers of two adjacent pages.
  var pageSpacing: CGFloat {
    smallBubbleSize + bubbleSpacing
  }

  /// Height of the rounded bar.
  var barHeight: CGFloat {
    smallBubbleSize + verticalPadding * 2
  }

  /// Width of the rounded bar.
  var barWidth: CGFloat {
    guard pageCount > 1 else { return mainBubbleSize }
    return CGFloat(pageCount - 2) * smallBubbleSize
      + mainBubbleSize
      + CGFloat(pageCount) * bubbleSpacing
  }

  /// Diameter of the big bubble. It is inset from `mainBubbleSize`, the
  /// diameter of the bump drawn behind it.
  var bigBubbleDiameter: CGFloat {
    mainBubbleSize - verticalPadding * 2
  }

  /// Size that fits the bar plus the overhang of the big bubble's bump.
  var intrinsicSize: CGSize {
    CGSize(
      width: barWidth + mainBubbleSize / 2,
      height: max(barHeight, mainBubbleSize)
    )
  }

  /// The bar rectangle inside a control of the given size.
  func barRect(in size: CGSize) -> CGRect {
    CGRect(
      x: (size.width - barWidth) / 2,
      y: (size.height - barHeight) / 2,
      width: barWidth,
      height: barHeight
    )
  }

  /// Center of the bubble that occupies `page` inside a control of `size`.
  func center(ofPage page: Int, in size: CGSize) -> CGPoint {
    let bar = barRect(in: size)
    return CGPoint(
      x: bar.minX + pageSpacing * CGFloat(clamp(page)) + mainBubbleSize / 2,
      y: bar.midY
    )
  }

  /// Page slot occupied by each small bubble for the given selection.
  ///
  /// The selected page always holds the big bubble, so small bubble `index`
  /// rests on page `index` when it sits left of the selection and on page
  /// `index + 1` otherwise. Every other page holds exactly one bubble, which
  /// is the invariant that keeps the layout stable across interrupted
  /// animations.
  func bubbleSlots(forSelection selection: Int) -> [Int] {
    let selection = clamp(selection)
    return (0..<(pageCount - 1)).map { $0 < selection ? $0 : $0 + 1 }
  }

  /// Nearest page for a horizontal coordinate, or `nil` when the coordinate
  /// falls outside the control.
  func page(atX x: CGFloat, in size: CGSize) -> Int? {
    guard pageSpacing > 0 else { return 0 }
    let bar = barRect(in: size)
    let firstCenter = bar.minX + mainBubbleSize / 2
    let lastCenter = firstCenter + pageSpacing * CGFloat(pageCount - 1)
    guard x >= firstCenter - pageSpacing / 2, x <= lastCenter + pageSpacing / 2 else {
      return nil
    }
    return clamp(Int(((x - firstCenter) / pageSpacing).rounded()))
  }

  /// Constrains `index` to a valid page.
  func clamp(_ index: Int) -> Int {
    min(max(0, index), pageCount - 1)
  }
}
